unit Util.Converter;

interface

type
  TConverter<T> = class abstract
  public
    class function ToString(const AValue: T): String; reintroduce;

    class function ToInteger(const AValue: T): Integer;
    class function ToInt64(const AValue: T): Int64;

    class function ToDate(const AValue: T): TDate;
    class function ToDateTime(const AValue: T): TDateTime;
  end;

implementation

uses
  System.Rtti,
  System.Variants;

// Converte o valor em texto
class function TConverter<T>.ToString(const AValue: T): String;
begin
  if TypeInfo(T) = TypeInfo(Variant) then
  begin
    Result := VarToStr(PVariant(@AValue)^);
  end
  else
  begin
    Result := TValue.From<T>(AValue).ToString;
  end;
end;

// Converte o valor em inteiro
class function TConverter<T>.ToInteger(const AValue: T): Integer;
begin
  Result := Self.ToInt64(AValue);
end;

// Converte o valor em inteiro estendido
class function TConverter<T>.ToInt64(const AValue: T): Int64;
begin
  Result := TValue.From<T>(AValue).AsInt64;
end;

// Converte o valor em data
class function TConverter<T>.ToDate(const AValue: T): TDate;
begin
  Result := Self.ToDateTime(AValue);
end;

// Converte o valor em data-hora
class function TConverter<T>.ToDateTime(const AValue: T): TDateTime;
begin
  if TypeInfo(T) = TypeInfo(Variant) then
  begin
    Result := VarToDateTime(PVariant(@AValue)^);
  end
  else
  begin
    Result := TValue.From<T>(AValue).AsType<TDateTime>;
  end;
end;

end.
