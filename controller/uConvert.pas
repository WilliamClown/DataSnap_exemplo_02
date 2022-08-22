unit uConvert;

interface

uses
  DBXJSON, DBXJSONReflect, RTTI, System.SysUtils, DBClient,
  System.Classes, Datasnap.DSServer, Datasnap.DSAuth, System.TypInfo, uAtributos,
  uModel, Data.DBXCommon, Data.DBXDBReaders, Data.DBXCDSReaders;

type
  TConvert = class
  public
    class procedure CopyReaderToCds(Reader : TDBXReader; cds : TClientDataSet);
  end;


implementation

{ TConvert }

uses uFuncoes;



class procedure TConvert.CopyReaderToCds(Reader: TDBXReader; cds: TClientDataSet);
var
  cdsAux : TClientDataSet;
begin
  try
    TDBXClientDataSetReader.CopyReaderToClientDataSet(Reader, cds);
    cds.First;
  finally
    cdsAux.Free;
  end;
end;

end.
