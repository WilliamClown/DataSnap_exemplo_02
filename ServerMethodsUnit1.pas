unit ServerMethodsUnit1;

interface

uses System.SysUtils, System.Classes, System.Json,
    DataSnap.DSProviderDataModuleAdapter,
    Datasnap.DSServer, Datasnap.DSAuth, FireDAC.UI.Intf, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageBin,
  FireDAC.Comp.UI, Pessoa, uGenericDAO, DataSetConverter4D.Helper,
  DataSetConverter4D.Impl, uDMConexao;

type
  TServerMethods1 = class(TDSServerModule)
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    FDStanStorageBinLink: TFDStanStorageBinLink;
    FDStanStorageJSONLink: TFDStanStorageJSONLink;
    qPessoas: TFDQuery;
    procedure DSServerModuleCreate(Sender: TObject);
    procedure DSServerModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    dmConexao: TdmConexao;
  public
    { Public declarations }
    class var JsonArrayResposta: TJSONArray;
    //inserir
    function acceptPessoa(aObj : TJSONValue) : Integer;
    //alterar
    function updatePessoa(aObj : TJSONValue) : TJSONArray;
    //excluir
    function cancelPessoa(vId: Integer): TJSONArray;
    //Busca
    function buscaPessoa(id: Integer): TJSONValue;

    function ListaPessoas: TJSONValue;
  end;
var
  vPessoa: TPessoa;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}


{ TServerMethods1 }

function TServerMethods1.acceptPessoa(aObj: TJSONValue): Integer;
begin
  try
    Result := 0;

    vPessoa := TPessoa.JSONToObject<TPessoa>(aObj);
    if vPessoa.ID <= 0 then
      vPessoa.ID := DMConexao.RetornaID('PESSOA');

    TGenericDAO.Inserir(vPessoa);
    Result := vPessoa.ID;
  except
    on E: Exception do
    begin
      Result := 0;
      //Exibir erro
    end;
  end;
end;

function TServerMethods1.buscaPessoa(id: Integer): TJSONValue;
begin
  vPessoa := TPessoa.Create;
  try
    qPessoas.Close;
    qPessoas.ParamByName('ID').AsInteger := id;
    qPessoas.Open();
    qPessoas.First;

    if qPessoas.SQL.Count > 0 then
    begin
      vPessoa.ID := qPessoas.FieldByName('ID').AsInteger;
      vPessoa.NOME := qPessoas.FieldByName('NOME').AsString;
      vPessoa.SOBRE_NOME := qPessoas.FieldByName('SOBRE_NOME').AsString;
    end;

    qPessoas.Close;
    Result := TPessoa.ObjectToJSON(vPessoa);
  finally
    FreeAndNil(vPessoa);
  end;
end;

function TServerMethods1.cancelPessoa(vId: Integer): TJSONArray;
begin
  try
    JsonArrayResposta := TJSONArray.Create;
    Result := JsonArrayResposta;
    vPessoa := TPessoa.Create;
    vPessoa.Id := vId;
    TGenericDAO.Excluir(vPessoa);
  except
    on E: Exception do
    begin
      Result.AddElement(TJSOnString.Create('ERRO'));
      Result.AddElement(TJSOnString.Create(E.Message));
    end;
  end;
end;

procedure TServerMethods1.DSServerModuleCreate(Sender: TObject);
begin
  dmConexao := TdmConexao.Create(nil);
end;

procedure TServerMethods1.DSServerModuleDestroy(Sender: TObject);
begin
  dmConexao.Free;
end;

function TServerMethods1.ListaPessoas: TJSONValue;
begin
  dmConexao.conexao.Connected := True;

  qPessoas.Connection := dmConexao.conexao;

  qPessoas.Close;
  qPessoas.Open();
  qPessoas.First;

  result := qPessoas.AsJSONArray;
end;

function TServerMethods1.updatePessoa(aObj: TJSONValue): TJSONArray;
begin
  try
    JsonArrayResposta := TJSONArray.Create;
    Result := JsonArrayResposta;
    vPessoa := TPessoa.JSONToObject<TPessoa>(aObj);
    TGenericDAO.Atualizar(vPessoa);
  except
    on E: Exception do
    begin
      Result.AddElement(TJSOnString.Create('ERRO'));
      Result.AddElement(TJSOnString.Create(E.Message));
    end;
  end;
end;

end.

