unit uGenericDAO;

interface

uses
  DBXJSON, DBXJSONReflect, DBXCommon, RTTI, System.SysUtils,
  System.Classes, Datasnap.DSServer, Datasnap.DSAuth, System.TypInfo,
  uAtributos, uModel, Datasnap.DBclient, Data.SqlExpr,
  Datasnap.Provider, Forms, uConstantes, uFuncoes, System.JSON,
  Data.DBXCDSReaders, Data.FireDACJSONReflect, FireDAC.Comp.Client;

type
  TGenericDAO = class
  private
    class function GetTableName<T: class>(Obj: T): String;
  public
    class function Inserir(Obj: TObject): Boolean;
    class function Excluir(Obj: TObject): Boolean;
    class function Atualizar(Obj: TObject): Boolean;
    class function ObterCDS(const campos: String; filtro: String; Obj: TObject): TFDJSONDataSets;
  end;

implementation

{ TGenericDAO }

uses uDMConexao;

class function TGenericDAO.Inserir(Obj: TObject): Boolean;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  ConsultaSQL, CamposSQL,
  ValoresSQL, Tabela,
  NomeTipo, rows: String;
  UltimoID: Integer;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(Obj.ClassType);
    DMConexao.Comando.Transaction.StartTransaction;
    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTable then
      begin
        ConsultaSQL := 'INSERT INTO ' + (Atributo as TTable).Name;
        Tabela := (Atributo as TTable).Name;
      end;
    end;

    // preenche os nomes dos campos e valores
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo is TColumn then
        begin
          if not(Atributo as TColumn).Transiente then
          begin
            if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
            begin
              if (Propriedade.GetValue(Obj).AsInteger <> 0) then
              begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';
                ValoresSQL := ValoresSQL + Propriedade.GetValue(Obj)
                  .ToString + ',';
              end;
            end
            else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString])
            then
            begin
              if (Propriedade.GetValue(Obj).AsString <> '') then
              begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';
                ValoresSQL := ValoresSQL +
                  QuotedStr(Propriedade.GetValue(Obj).ToString) + ',';
              end;
            end
            else if (Propriedade.PropertyType.TypeKind = tkFloat) then
            begin
              NomeTipo := LowerCase(Propriedade.PropertyType.Name);
              if NomeTipo = 'tdatetime' then
              begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';

                if Propriedade.GetValue(Obj).AsExtended > 0 then
                  ValoresSQL := ValoresSQL +
                    QuotedStr(FormatDateTime('yyyy-mm-dd HH:mm',
                    Propriedade.GetValue(Obj).AsExtended)) + ','
                else
                  ValoresSQL := ValoresSQL + 'null,';
              end
              else if NomeTipo = 'tdate' then
              begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';

                if Propriedade.GetValue(Obj).AsExtended > 0 then
                  ValoresSQL := ValoresSQL +
                    QuotedStr(FormatDateTime('yyyy-mm-dd',
                    Propriedade.GetValue(Obj).AsExtended)) + ','
                else
                  ValoresSQL := ValoresSQL + 'null,';
              end
              else
              begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';
                ValoresSQL := ValoresSQL +
                  QuotedStr(FormatFloat('0.000000', Propriedade.GetValue(Obj)
                  .AsExtended)) + ',';
              end;
            end
            else
            begin
              CamposSQL := CamposSQL + (Atributo as TColumn).Name + ',';
              ValoresSQL := ValoresSQL +
                QuotedStr(Propriedade.GetValue(Obj).ToString) + ',';
            end;
          end;
        end
        else if Atributo is TId then
        begin
          if (Propriedade.GetValue(Obj).AsInteger <> 0) then
          begin
            CamposSQL := CamposSQL + (Atributo as TId).NameField + ',';
            ValoresSQL := ValoresSQL + Propriedade.GetValue(Obj).ToString + ',';
          end;
        end;
      end;
    end;

    // retirando as vírgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);
    Delete(ValoresSQL, Length(ValoresSQL), 1);

    ConsultaSQL := ConsultaSQL + '(' + CamposSQL + ') VALUES (' +
      ValoresSQL + ')';

    DMConexao.Comando.SQL.Text := ConsultaSQL;
    DMConexao.Comando.ExecSQL;
    DMConexao.Comando.Transaction.Commit;
    rows := IntToStr( DMConexao.Comando.RowsAffected );
  except
    on E: Exception do
    begin
      Result := False;
      DMConexao.Comando.Transaction.Rollback;
    end;
  end;
end;

class function TGenericDAO.ObterCDS(const campos: String; filtro: String; Obj: TObject): TFDJSONDataSets;
var
  consulta: String;
  qryConsulta: TFDQuery;
begin
  Result := TFDJSONDataSets.Create;

  consulta := Format('SELECT ' + campos + '  FROM %s ', [GetTableName(Obj)]);
  if filtro <> '' then
     consulta := consulta + filtro;
  consulta := consulta + ' ORDER BY 1';

  //Criando query para execução da consulta SQL.
  qryConsulta := TFDQuery.Create(nil);
  qryConsulta.Connection := DMConexao.Conexao;
  qryConsulta.sql.Text := consulta;
  qryConsulta.Open;

  TFDJSONDataSetsWriter.ListAdd(Result, qryConsulta);

end;

class function TGenericDAO.Excluir(Obj: TObject): Boolean;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  ConsultaSQL, FiltroSQL, rows: String;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(Obj.ClassType);
    DMConexao.Comando.Transaction.StartTransaction;
    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTable then
        ConsultaSQL := 'DELETE FROM ' + (Atributo as TTable).Name;
    end;

    // preenche o filtro
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo is TId then
        begin
          FiltroSQL := ' WHERE ' + (Atributo as TId).NameField + ' = ' +
            QuotedStr(Propriedade.GetValue(Obj).ToString);
        end;
      end;
    end;

    ConsultaSQL := ConsultaSQL + FiltroSQL;

    DMConexao.Comando.SQL.Text := ConsultaSQL;
    DMConexao.Comando.ExecSQL;
    DMConexao.Comando.Transaction.Commit;
    Result := True;
    rows := IntToStr( DMConexao.Comando.RowsAffected );
  except
    on E: Exception do
    begin
      Result := False;
      DMConexao.Comando.Transaction.Rollback;
    end;
  end;
end;

class function TGenericDAO.GetTableName<T>(Obj: T): String;
var
  Contexto: TRttiContext;
  TypObj: TRttiType;
  Atributo: TCustomAttribute;
  strTable: String;
begin
  Contexto := TRttiContext.Create;
  TypObj := Contexto.GetType(TObject(Obj).ClassInfo);
  for Atributo in TypObj.GetAttributes do
  begin
    if Atributo is TTable then
      Exit((Atributo as TTable).Name);
  end;
end;

class function TGenericDAO.Atualizar(Obj: TObject): Boolean;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  ConsultaSQL, CamposSQL,
  FiltroSQL, NomeTipo, rows: String;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(Obj.ClassType);
    DMConexao.Comando.Transaction.StartTransaction;
    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTable then
        ConsultaSQL := 'UPDATE ' + (Atributo as TTable).Name + ' SET ';
    end;

    // preenche os nomes dos campos e filtro
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo is TColumn then
        begin
          if not(Atributo as TColumn).Transiente then
          begin
            if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
            begin
              if Copy((Atributo as TColumn).Name,1,3) = 'ID_' then
              begin
                if Propriedade.GetValue(Obj).AsInteger <> 0 then
                  CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' +
                    Propriedade.GetValue(Obj).ToString + ','
                else
                  CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = null,';
              end
              else
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' +
                  Propriedade.GetValue(Obj).ToString + ',';
            end

            else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString])
            then
            begin
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' +
                  QuotedStr(Propriedade.GetValue(Obj).ToString) + ',';
            end

            else if (Propriedade.PropertyType.TypeKind = tkFloat) then
            begin
              if Propriedade.GetValue(Obj).AsExtended <> 0 then
              begin
                NomeTipo := LowerCase(Propriedade.PropertyType.Name);
                if NomeTipo = 'tdatetime' then
                  CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' +
                    QuotedStr(FormatDateTime('yyyy-mm-dd HH:mm',
                    Propriedade.GetValue(Obj).AsExtended)) + ','

                else if NomeTipo = 'tdate' then
                  CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' +
                    QuotedStr(FormatDateTime('yyyy-mm-dd',
                    Propriedade.GetValue(Obj).AsExtended)) + ','

                else
                  CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' +
                    QuotedStr(FormatFloat('0.000000', Propriedade.GetValue(Obj)
                    .AsExtended)) + ',';
              end
              else
                CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' +
                  'null' + ',';
            end

            else if Propriedade.GetValue(Obj).ToString <> '' then
            begin
              CamposSQL := CamposSQL + (Atributo as TColumn).Name + ' = ' +
                QuotedStr(Propriedade.GetValue(Obj).ToString) + ','
            end;
          end;
        end
        else if Atributo is TId then
          FiltroSQL := ' WHERE ' + (Atributo as TId).NameField + ' = ' +
            QuotedStr(Propriedade.GetValue(Obj).ToString);
      end;
    end;

    // retirando as vírgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);

    ConsultaSQL := ConsultaSQL + CamposSQL + FiltroSQL;
    DMConexao.Comando.SQL.Text := ConsultaSQL;
    DMConexao.Comando.ExecSQL;
    DMConexao.Comando.Transaction.Commit;
    rows := IntToStr( DMConexao.Comando.RowsAffected );
  except
    on E: Exception do
    begin
      Result := False;
      DMConexao.Comando.Transaction.Rollback;
    end;
  end;
end;

end.
