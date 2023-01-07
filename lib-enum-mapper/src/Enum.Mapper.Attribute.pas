unit Enum.Mapper.Attribute;

interface

type
  TEnumItem = class(TCustomAttribute)
  private
    FKey: Integer;
    FValue: String;
    FDescription: String;

  public
    constructor Create(const AKey: Integer; const AValue: String); overload;
    constructor Create(const AKey: Integer; const AValue, ADescription: String); overload;

    property Key: Integer read FKey write FKey;
    property Value: String read FValue write FValue;
    property Description: String read FDescription write FDescription;
  end;

implementation

// Construtor do atributo
constructor TEnumItem.Create(const AKey: Integer; const AValue: String);
begin
  Self.Create(AKey, AValue, '');
end;

// Construtor do atributo (sobrecarga)
constructor TEnumItem.Create(const AKey: Integer; const AValue, ADescription: String);
begin
  Self.FKey := AKey;
  Self.FValue := AValue;
  Self.FDescription := ADescription;
end;

end.
