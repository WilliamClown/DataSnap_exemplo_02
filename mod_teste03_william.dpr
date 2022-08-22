library mod_teste03_william;



uses
  {$IFDEF MSWINDOWS}
  Winapi.ActiveX,
  System.Win.ComObj,
  {$ENDIF }
  Web.WebBroker,
  Web.ApacheApp,
  Web.HTTPD24Impl,
  Data.DBXCommon,
  Datasnap.DSSession,
  Pessoa in 'Pessoa.pas',
  ServerContainerUnit1 in 'ServerContainerUnit1.pas' {ServerContainer1: TDataModule},
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas' {ServerMethods1: TDSServerModule},
  uDMConexao in 'uDMConexao.pas' {dmConexao: TDataModule},
  uGenericDAO in 'uGenericDAO.pas',
  WebModuleUnit1 in 'WebModuleUnit1.pas' {WebModule1: TWebModule},
  Controller in 'controller\Controller.pas',
  TrataException in 'controller\TrataException.pas',
  uAtributos in 'controller\uAtributos.pas',
  uBiblioteca in 'controller\uBiblioteca.pas',
  uConstantes in 'controller\uConstantes.pas',
  uConvert in 'controller\uConvert.pas',
  uFuncoes in 'controller\uFuncoes.pas',
  uModel in 'controller\uModel.pas',
  DataSetConverter4D.Helper in 'DataSetHelper\DataSetConverter4D.Helper.pas',
  DataSetConverter4D.Impl in 'DataSetHelper\DataSetConverter4D.Impl.pas',
  DataSetConverter4D in 'DataSetHelper\DataSetConverter4D.pas',
  DataSetConverter4D.Util in 'DataSetHelper\DataSetConverter4D.Util.pas';

{$R *.res}

// httpd.conf entries:
//
(*
 LoadModule teste03_william_module modules/mod_teste03_william.dll

 <Location /xyz>
    SetHandler mod_teste03_william-handler
 </Location>
*)
//
// These entries assume that the output directory for this project is the apache/modules directory.
//
// httpd.conf entries should be different if the project is changed in these ways:
//   1. The TApacheModuleData variable name is changed.
//   2. The project is renamed.
//   3. The output directory is not the apache/modules directory.
//   4. The dynamic library extension depends on a platform. Use .dll on Windows and .so on Linux.
//

// Declare exported variable so that Apache can access this module.
var
  GModuleData: TApacheModuleData;
exports
  GModuleData name 'teste03_william_module';

procedure TerminateThreads;
begin
  TDSSessionManager.Instance.Free;
  Data.DBXCommon.TDBXScheduler.Instance.Free;
end;

begin
{$IFDEF MSWINDOWS}
  CoInitFlags := COINIT_MULTITHREADED;
{$ENDIF}
  Web.ApacheApp.InitApplication(@GModuleData);
  Application.Initialize;
  Application.WebModuleClass := WebModuleClass;
  TApacheApplication(Application).OnTerminate := TerminateThreads;
  Application.CreateForm(TdmConexao, dmConexao);
  Application.Run;
end.
