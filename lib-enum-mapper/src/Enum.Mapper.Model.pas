unit Enum.Mapper.Model;

interface

uses
  Enum.Mapper.Interfaces;

type
  TEnumMapper<T: record> = class(TInterfacedObject, IEnumMapper<T>)
  public
    constructor Create;
    class function New: IEnumMapper<T>;

    function ToInteger(const AEnum: T): Integer;
    function ToString(const AEnum: T): String; reintroduce;

    function GetDescription(const AEnum: T): String;
    function GetEnumerator(const AValue: String): Integer;
  end;

implementation

uses
  Enum.Mapper.Attribute,
  System.Rtti;

// Construtor
constructor TEnumMapper<T>.Create;
begin
  inherited;
end;

// Construtor estático (autodestrutivo)
class function TEnumMapper<T>.New: IEnumMapper<T>;
begin
  Result := Self.Create;
end;

// Converte o enumerado em um numérico inteiro
function TEnumMapper<T>.ToInteger(const AEnum: T): Integer;
begin
  Result := TValue.From<T>(AEnum).AsOrdinal;
end;

// Converte o enumerado em um texto
function TEnumMapper<T>.ToString(const AEnum: T): String;
var
  LContext: TRttiContext;
  LType: TRttiType;
begin
  Result := '';
  LContext := TRttiContext.Create;

  try
    LType := LContext.GetType(TypeInfo(T));
    for var LAttribute: TCustomAttribute in LType.GetAttributes do
    begin
      if LAttribute is TEnumItem then
      begin
        if Self.ToInteger(AEnum) = TEnumItem(LAttribute).Key then
        begin
          Result := TEnumItem(LAttribute).Value;
          Break;
        end;
      end;
    end;
  finally
    LContext.Free;
  end;
end;

// Retorna a descrição do enumerado
function TEnumMapper<T>.GetDescription(const AEnum: T): String;
var
  LContext: TRttiContext;
  LType: TRttiType;
begin
  Result := '';
  LContext := TRttiContext.Create;

  try
    LType := LContext.GetType(TypeInfo(T));
    for var LAttribute: TCustomAttribute in LType.GetAttributes do
    begin
      if LAttribute is TEnumItem then
      begin
        if Self.ToInteger(AEnum) = TEnumItem(LAttribute).Key then
        begin
          Result := TEnumItem(LAttribute).Description;
          Break;
        end;
      end;
    end;
  finally
    LContext.Free;
  end;
end;

// Converte o texto no número inteiro equivalente ao enumerado
function TEnumMapper<T>.GetEnumerator(const AValue: String): Integer;
var
  LContext: TRttiContext;
  LType: TRttiType;
begin
  Result := 0;
  LContext := TRttiContext.Create;

  try
    LType := LContext.GetType(TypeInfo(T));
    for var LAttribute: TCustomAttribute in LType.GetAttributes do
    begin
      if LAttribute is TEnumItem then
      begin
        if AValue = TEnumItem(LAttribute).Value then
        begin
          Result := TEnumItem(LAttribute).Key;
          Break;
        end;
      end;
    end;
  finally
    LContext.Free;
  end;
end;

end.
