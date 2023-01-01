unit Util.Conditional;

interface

type
  TConditional = class abstract
  public
    class function IfThen<T>(const ACondition: Boolean; const ATrue: T): T; overload; static;
    class function IfThen<T>(const ACondition: Boolean; const ATrue, AFalse: T): T; overload; static;

    class function NVL<T>(const AValue: T): T; overload; static;
    class function NVL<T>(const AValue, ADefault: T): T; overload; static;
    class function NVL(const AValue, ADefault: Variant): Variant; overload; static;
  end;

implementation

uses
  System.Rtti,
  System.Variants;

// Realiza um IF ternário (Shorthand Syntax)
class function TConditional.IfThen<T>(const ACondition: Boolean; const ATrue: T): T;
begin
  Result := IfThen<T>(ACondition, ATrue, Default (T));
end;

// Realiza um IF ternário (Longhand Syntax)
class function TConditional.IfThen<T>(const ACondition: Boolean; const ATrue, AFalse: T): T;
begin
  if ACondition then
  begin
    Result := ATrue;
  end
  else
  begin
    Result := AFalse;
  end;
end;

// Verifica se um valor é nulo e retorna um valor padrão, caso seja nulo
class function TConditional.NVL<T>(const AValue: T): T;
begin
  Result := NVL<T>(AValue, Default (T));
end;

// Verifica se um valor é nulo e retorna o valor padrão informado, caso seja nulo
class function TConditional.NVL<T>(const AValue, ADefault: T): T;
var
  LValue: Variant;
begin
  LValue := TValue.From<T>(AValue).AsVariant;

  if VarIsEmpty(LValue) or VarIsNull(LValue) then
  begin
    Result := ADefault;
  end
  else
  begin
    Result := AValue;
  end;
end;

// Função Null Value equivalente ao NVL do Oracle SQL
class function TConditional.NVL(const AValue, ADefault: Variant): Variant;
begin
  if VarIsEmpty(AValue) or VarIsNull(AValue) or (AValue = Unassigned) then
  begin
    Result := ADefault;
  end
  else
  begin
    Result := AValue;
  end;
end;

end.
