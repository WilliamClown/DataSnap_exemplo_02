unit uDMConexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Phys.IBBase, FireDAC.Comp.UI,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TdmConexao = class(TDataModule)
    conexao: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    Transacao: TFDTransaction;
  private
    FComando: TFDQuery;
    procedure SetComando(const Value: TFDQuery);
    { Private declarations }
  public
    { Public declarations }
    function RetornaID(Tabela : String) : Integer;
    property Comando : TFDQuery read FComando write SetComando;
  end;

var
  dmConexao: TdmConexao;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmConexao }

function TdmConexao.RetornaID(Tabela: String): Integer;
var
   sSQLString, sGenerator : String;
   sqlQuery : TFDQuery;
begin
   try
      //Cria Objeto TSQlQuery.
      sqlQuery := TFDQuery.Create( sqlQuery );

      { Configurando TSQLQuery }
      sqlQuery.Connection := Self.Conexao;

      sGenerator := Tabela;
      sSQLString := 'SELECT GEN_ID(' + sGenerator + ',1) AS ID FROM RDB$DATABASE';

      sqlQuery.SQL.Add( sSQLString );
      try
        sqlQuery.Open;
        Result := sqlQuery.FieldByName('ID').value;
      finally
         sqlQuery.Close;
         FreeAndNil( sqlQuery );
      end;
   except
      on E : Exception do
         raise Exception.Create( 'TFirebirdDB.RetornaID: ' + E.Message );
   end;
end;

procedure TdmConexao.SetComando(const Value: TFDQuery);
begin
  FComando := Value;
end;

end.
