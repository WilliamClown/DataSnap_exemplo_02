unit uModel;

interface
uses
  DBXJSON, DBXJSONReflect, System.JSON, System.Generics.Collections, REST.Json,
  System.Classes, uAtributos, System.Rtti;

type
  TModel = class
  public
    class function ObjetoListaParaJson<T: class>(ALista: TObjectList<T>): TJSONArray;
    class function JSONArrayStreamToJSONArray(pStream: TStringStream): TJSONArray;

    class function ObjectToJSON<O: class>(objeto: O): TJSONValue;
    class function JSONToObject<O: class>(pObjetoJson: TJSONValue): O;
    function ToJSONString: string;
    function ToJSON: TJSONValue; virtual;
  end;

  TGenericVO<T: class> = class
  private
    class function CreateObject: T;
    class function GetColumn(pName: string): TColumn;
  public
    class function FieldCaption(pFieldName: string): string;
    class function FieldLength(pFieldName: string): Integer;
  end;

implementation

{ TModel }

class function TModel.ObjetoListaParaJson<T>(ALista: TObjectList<T>): TJSONArray;
var
  item: T;
begin
  Result := TJSONArray.Create;

  for item in Alista do
    Result.AddElement(TJson.ObjectToJsonObject(item));
end;

class function TModel.JSONArrayStreamToJSONArray( pStream: TStringStream): TJSONArray;
var
  jObj: TJSONObject;
  jPair: TJSONPair;
begin
  jObj := TJSONObject.Create;
  try
    jObj.Parse(pStream.Bytes, 0);
    jPair := jObj.Pairs[0];

    Result := (TJSONArray(jPair.JsonValue).Items[0] as TJSONArray).Clone as TJSONArray;
  finally
    jObj.Free;
  end;
end;

class function TModel.JSONToObject<O>(pObjetoJson: TJSONValue): O;
var
  Deserializa: TJSONUnMarshal;
begin
  if pObjetoJson is TJSONNull then
    Exit(nil);

  Deserializa := TJSONUnMarshal.Create;
  try
    Exit(O(Deserializa.Unmarshal(pObjetoJson)))
  finally
    Deserializa.Free;
  end;
end;

class function TModel.ObjectToJSON<O>(objeto: O): TJSONValue;
var
  Serializa: TJSONMarshal;
begin
  if Assigned(objeto) then
  begin
    Serializa := TJSONMarshal.Create(TJSONConverter.Create);
    try
      Exit(Serializa.Marshal(objeto));
    finally
      Serializa.Free;
    end;
  end
  else
    Exit(TJSONNull.Create);
end;

function TModel.ToJSON: TJSONValue;
var
  Serializa: TJSONMarshal;
begin
  Serializa := TJSONMarshal.Create(TJSONConverter.Create);
  try
    Exit(Serializa.Marshal(Self));
  finally
    Serializa.Free;
  end;
end;

function TModel.ToJSONString: string;
var
  jValue: TJSONValue;
begin
  if Assigned(Self) then
  begin
    jValue := ToJSON;
    try
      Result := jValue.ToString;
    finally
      jValue.Free;
    end;
  end
  else
    Result := '';
end;

{ TGenericVO<T> }

class function TGenericVO<T>.CreateObject: T;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Value: TValue;
  Obj: TObject;
begin
  // Criando Objeto via RTTI para chamar o envento OnCreate no Objeto
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(TClass(T));
    Value := Tipo.GetMethod('Create').Invoke(Tipo.AsInstance.MetaclassType, []);
    Result := T(Value.AsObject);
  finally
    Contexto.Free;
  end;
end;

class function TGenericVO<T>.FieldCaption(pFieldName: string): string;
var
  Atributo: TColumn;
begin
  Atributo := GetColumn(pFieldName);

  if Assigned(Atributo) then
  begin
    Result := Atributo.Caption;
    Atributo.Free;
  end
  else
  begin
    Result := '';
  end;
end;

class function TGenericVO<T>.FieldLength(pFieldName: string): Integer;
var
  Atributo: TColumn;
begin
  Atributo := GetColumn(pFieldName);
  if Assigned(Atributo) then
  begin
    Result := Atributo.Length;
    Atributo.Free;
  end
  else
  begin
    Result := 0;
  end;
end;

class function TGenericVO<T>.GetColumn(pName: string): TColumn;
var
  Obj: T;
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  Encontrou: Boolean;
begin
  Result := nil;

  Obj := CreateObject;
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(TObject(Obj).ClassType);

    Encontrou := False;
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo is TColumn then
        begin
          if (Atributo as TColumn).Name = pName then
          begin
            Result := (Atributo as TColumn).Clone;
            Encontrou := True;
            Break;
          end;
        end;
      end;

      if Encontrou then
        Break;
    end;
  finally
    TObject(Obj).Free;
    Contexto.Free;
  end;
end;

end.

