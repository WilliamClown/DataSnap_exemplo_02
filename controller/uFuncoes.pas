unit uFuncoes;

interface

uses
  Windows, Messages, SysUtils, Variants, System.Classes, Graphics, Controls,
  Forms, System.UITypes,
  Dialogs, Registry, System.Rtti,
  Vcl.ExtCtrls, Vcl.Imaging.jpeg, System.NetEncoding,
  System.Generics.Collections,  Data.DBXCommon,
  FireDAC.Comp.Client, Data.DBXDBReaders, Data.DBXCDSReaders,
  Datasnap.DBClient, IdIPWatch, Data.DB, REST.Response.Adapter, System.JSON,
  Vcl.StdCtrls;

const
  Aplic = 'SISTWIN';
  Raiz = 'TCC';

type
  TFuncoes = class
  private
    class function DateToDateSql(Date: TDateTime;
      lData: Boolean = True): string;
  public
    class function PegaIp:string;
    class function VersaoExe: String;
    class function FloatToSql(Value: double): string;
    class function StrOf(Value: Extended): string;
    class function IntOf(Value: string): Integer;
    class function DateToSql(Value: TDateTime; lDate: Boolean = True): string;
    class function StringToSql(Value: string): string; static;
    class function ZeroAsNull(Value: double): string; static;
    class function DlgOK(sMsg: string; FInformation: Boolean = True): Integer;
    class function DlgSN(sMsg: string): Boolean; overload;
    class function DlgSN(sMsg: string; bFoco: Integer): Boolean; overload;
    class function MsgDlgButtonPersonal(const Msg: string; DlgType: TMsgDlgType;
                   Buttons: TMsgDlgButtons; Captions: array of string): Integer;
    class function DlgEX(sMsg: string): Integer;
    class function SimNao(Value: string): Boolean; overload;
    class function SimNao(Value: Boolean): string; overload;
    class procedure FocarComponente(Value: TWinControl);
    class function GetDescOperacao(Value: string): string;
    class procedure SetRegister(cNome, Value: string);
    class function GetRegister(cNome: string): string;
    class function FormatFloat(Value: double): string;
    class function RemoveSimbolos(sParametro: String): String;
    class function RemoveChar(STR: string; CHR: char): string;
    class Function RetiraAspaSimples(Texto: String): String;
    class function Crypt(Action, Src: String): String;
    class procedure JsonToDataset(aDataset : TDataSet; json : string; jsonarray: TJSONArray);
    class procedure CriarDiretorio(Diretorio: String);
  end;

implementation

{ TFuncoes }

class function TFuncoes.FloatToSql(Value: double): string;
begin
  Result := '';
  Result := StringReplace(StrOf(Value), ',', '.', [rfReplaceAll]);
end;

class procedure TFuncoes.FocarComponente(Value: TWinControl);
begin
  try
    Value.SetFocus;
  except
    on E: Exception do
      // somente não estoura erro se nao conseguir focar
  end;
end;

class function TFuncoes.FormatFloat(Value: double): string;
begin
  Result := Format('%.2f', [Value]);
end;

class function TFuncoes.GetDescOperacao(Value: string): string;
begin
  if Value = 'C' then
    Result := 'Crédito'
  else
    Result := 'Débito';
end;

class function TFuncoes.GetRegister(cNome: string): string;
var
  oReg: TRegistry;
begin
  // LER REGISTRO GRAVADOS NO WINDOWS
    oReg := TRegistry.Create;
  try
    oReg.RootKey:=HKEY_CURRENT_USER; // adicionado essa linha para inicializar
    oReg.OpenKey(Raiz, False);
    if oReg.ReadString(cNome) <> '' then
      Result := oReg.ReadString(cNome);
    oReg.CloseKey;

  finally
    oReg.Free;
  end;
end;

class function TFuncoes.IntOf(Value: string): Integer;
begin
  try
    Result := StrToIntDef(Value, 0);
  except
    Result := 0
  end;
end;

class procedure TFuncoes.JsonToDataset(aDataset: TDataSet; json: string; jsonarray: TJSONArray);
var
  jarray: TJSONArray;
  vConv : TCustomJSONDataSetAdapter;
begin
  if json <> EmptyStr then
    jarray := TJSONObject.ParseJSONValue(json) as TJSONArray
  else
    jarray := jsonarray;

  vConv := TCustomJSONDataSetAdapter.Create(Nil);

  try
    vConv.Dataset := aDataset;
    vConv.UpdateDataSet(jarray);
  finally
    vConv.Free;
    jarray.Free;
  end;
end;

class function TFuncoes.MsgDlgButtonPersonal(const Msg: string;
  DlgType: TMsgDlgType; Buttons: TMsgDlgButtons;
  Captions: array of string): Integer;
var
  aMsgDlg: TForm;
  i: Integer;
  dlgButton: TButton;
  CaptionIndex: Integer;
begin
  { Criar o dialogo }
  aMsgDlg := CreateMessageDialog(Msg, DlgType, Buttons);
  CaptionIndex := 0;
  { Faz um loop varrendo os objetos do dialogo }
  for i := 0 to pred(aMsgDlg.ComponentCount) do
  begin
    if (aMsgDlg.Components[i] is TButton) then
    begin
      { Apenas entra na condição se o objeto for um button }
      dlgButton := TButton(aMsgDlg.Components[i]);
      if CaptionIndex > High(Captions) then //Captura o Index dos captions dos buttons criado no array
         Break;
      dlgButton.Caption := Captions[CaptionIndex];
      Inc(CaptionIndex);
    end;
  end;
  Result := aMsgDlg.ShowModal;
end;

class function TFuncoes.PegaIp: string;
var
  ip : TIdIPWatch;
begin
  ip := TIdIPWatch.Create(nil);
  Result := ip.LocalIP;
  ip.free;
end;

class function TFuncoes.RemoveChar(STR: string; CHR: char): string;
var
  cont: Integer;
begin
  Result := '';
  for cont := 1 to Length(STR) do
  begin
    if (STR[cont] <> CHR) then
      Result := Result + STR[cont];
  end;
end;

class function TFuncoes.RemoveSimbolos(sParametro: String): String;
var
  sResult: String;
begin
  sResult := sParametro;
  sResult := StringReplace(Trim(sResult), '-', '',
    [rfReplaceAll, rfIgnoreCase]);
  sResult := StringReplace(Trim(sResult), '.', '',
    [rfReplaceAll, rfIgnoreCase]);
  sResult := StringReplace(Trim(sResult), '(', '',
    [rfReplaceAll, rfIgnoreCase]);
  sResult := StringReplace(Trim(sResult), ')', '',
    [rfReplaceAll, rfIgnoreCase]);
  sResult := StringReplace(Trim(sResult), '/', '',
    [rfReplaceAll, rfIgnoreCase]);
  sResult := StringReplace(Trim(sResult), ' ', '',
    [rfReplaceAll, rfIgnoreCase]);
  sResult := StringReplace(Trim(sResult), '+', '',
    [rfReplaceAll, rfIgnoreCase]);
  sResult := StringReplace(Trim(sResult), '*', '',
    [rfReplaceAll, rfIgnoreCase]);
  sResult := StringReplace(Trim(sResult), '''''', '',
    [rfReplaceAll, rfIgnoreCase]);

  Result := sResult;
end;

class function TFuncoes.RetiraAspaSimples(Texto: String): String;
var
  n: Integer;
  NovoTexto: String;
begin
  NovoTexto := '';
  for n := 1 to Length(Texto) do
  begin
    if copy(Texto, n, 1) <> CHR(39) then
      NovoTexto := NovoTexto + copy(Texto, n, 1)
    else
      NovoTexto := NovoTexto + ' ';
  end;
  Result := NovoTexto;
end;

class function TFuncoes.StringToSql(Value: string): string;
begin
  Result := QuotedStr(Value);
end;

class procedure TFuncoes.CriarDiretorio(Diretorio: String);
begin
  if not DirectoryExists(Diretorio) then
    ForceDirectories(Diretorio);
end;

class function TFuncoes.Crypt(Action, Src: String): String;
Label Fim;
var
  KeyLen: Integer;
  KeyPos: Integer;
  OffSet: Integer;
  Dest, Key: String;
  SrcPos: Integer;
  SrcAsc: Integer;
  TmpSrcAsc: Integer;
  Range: Integer;
begin
  if (Src = '') Then
  begin
    Result := '';
    Goto Fim;
  end;

  Key := 'YUQL23KL23DF90WI5E1JAS467NMCXXL6JAOAUWWMCL0AOMM4A4VZYW9KHJUI2347EJHJKDF3424SKL K3LAKDJSL9RTIKJ';
  Dest := '';
  KeyLen := Length(Key);
  KeyPos := 0;
  Range := 256;
  if (Action = UpperCase('C')) then
  begin
    Randomize;
    OffSet := Random(Range);
    Dest := Format('%1.2x', [OffSet]);
    for SrcPos := 1 to Length(Src) do
    begin
      Application.ProcessMessages;
      SrcAsc := (Ord(Src[SrcPos]) + OffSet) Mod 255;
      if KeyPos < KeyLen then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;

      SrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
      Dest := Dest + Format('%1.2x', [SrcAsc]);
      OffSet := SrcAsc;
    end;
  end
  Else if (Action = UpperCase('D')) then
  begin
    OffSet := StrToInt('$' + copy(Src, 1, 2));
    // <--------------- adiciona o $ entra as aspas simples
    SrcPos := 3;
    repeat
      SrcAsc := StrToInt('$' + copy(Src, SrcPos, 2));
      // <--------------- adiciona o $ entra as aspas simples
      if (KeyPos < KeyLen) Then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;
      TmpSrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
      if TmpSrcAsc <= OffSet then
        TmpSrcAsc := 255 + TmpSrcAsc - OffSet
      else
        TmpSrcAsc := TmpSrcAsc - OffSet;
      Dest := Dest + CHR(TmpSrcAsc);
      OffSet := SrcAsc;
      SrcPos := SrcPos + 2;
    until (SrcPos >= Length(Src));
  end;
  Result := Dest;
Fim:
end;

class function TFuncoes.DateToDateSql(Date: TDateTime; lData: Boolean): string;
var
  cString: string;
begin
  if lData then
    cString := FormatDateTime('dd/mm/yyyy', Date)
  else
    cString := FormatDateTime('dd/mm/yyyy hh:mm:ss', Date);
  Result := QuotedStr(cString);
end;

class function TFuncoes.StrOf(Value: Extended): string;
begin
  Result := '';
  try
    Result := FloatToStr(Value);
  except
    Result := '';
  end;
end;

class function TFuncoes.VersaoExe: String;
type
  PFFI = ^vs_FixedFileInfo;
var
    F : PFFI;
    Handle : Dword;
    Len : Longint;
    Data : Pchar;
    Buffer : Pointer;
    Tamanho : Dword;
    Parquivo: Pchar;
    Arquivo : String;
begin
    Arquivo := Application.ExeName;
    Parquivo := StrAlloc(Length(Arquivo) + 1);
    StrPcopy(Parquivo, Arquivo);
    Len := GetFileVersionInfoSize(Parquivo, Handle);
    Result := '';
    if Len > 0 then
      begin
      Data:=StrAlloc(Len+1);
      if GetFileVersionInfo(Parquivo,Handle,Len,Data) then
      begin
          VerQueryValue(Data, '\',Buffer,Tamanho);
          F := PFFI(Buffer);
          Result := Format('%d.%d.%d.%d',
          [HiWord(F^.dwFileVersionMs),
          LoWord(F^.dwFileVersionMs),
          HiWord(F^.dwFileVersionLs),
          Loword(F^.dwFileVersionLs)]
          );
      end;
      StrDispose(Data);
    end;
    StrDispose(Parquivo);
end;

class function TFuncoes.DateToSql(Value: TDateTime;
  lDate: Boolean = True): string;
begin
  Result := DateToDateSql(Value, lDate)
end;

class function TFuncoes.DlgEX(sMsg: string): Integer;
begin
  Result := Application.MessageBox(PWideChar(sMsg), PWideChar(Aplic),
    MB_ICONERROR or MB_OK);
end;

class function TFuncoes.DlgOK(sMsg: string; FInformation: Boolean): Integer;
begin
  if FInformation then
    Result := Application.MessageBox(PWideChar(sMsg), PWideChar(Aplic),
      MB_ICONINFORMATION or MB_OK)
  else
    Result := Application.MessageBox(PWideChar(sMsg), PWideChar(Aplic),
      MB_ICONEXCLAMATION or MB_OK)
end;

class function TFuncoes.DlgSN(sMsg: string): Boolean;
begin
  Result := (Application.MessageBox(PWideChar(sMsg), PWideChar(Aplic),
    MB_ICONQUESTION or MB_YESNO) = IDYES);
end;

class function TFuncoes.DlgSN(sMsg: string; bFoco: Integer): Boolean;
begin
  case bFoco of
    1:
      Result := (Application.MessageBox(PWideChar(sMsg), PWideChar(Aplic),
        MB_ICONQUESTION or MB_YESNO + MB_DEFBUTTON1) = IDYES);
  else
    Result := (Application.MessageBox(PWideChar(sMsg), PWideChar(Aplic),
      MB_ICONQUESTION or MB_YESNO + MB_DEFBUTTON2) = IDYES);
  end;
end;

class function TFuncoes.ZeroAsNull(Value: double): string;
begin
  if Value = 0 then
    Result := 'NULL'
  else
    Result := FloatToSql(Value);
end;

class function TFuncoes.SimNao(Value: string): Boolean;
begin
  Result := (UpperCase(Value) = 'S')
end;


class procedure TFuncoes.SetRegister(cNome, Value: string);
var
  oReg: TRegistry;
begin
  // Grava dados no Registro do Windows
    oReg := TRegistry.Create;
  try
    oReg.OpenKey(Raiz, True);
    oReg.WriteString(cNome, Value);
    oReg.CloseKey;
  finally
    oReg.Free;
  end;
end;

class function TFuncoes.SimNao(Value: Boolean): string;
begin
  Result := 'N';
  if Value then
    Result := 'S';
end;

end.
