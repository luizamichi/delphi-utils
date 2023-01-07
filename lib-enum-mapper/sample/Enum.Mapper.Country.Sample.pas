unit Enum.Mapper.Country.Sample;

interface

uses
  Enum.Mapper.Attribute;

type
  [TEnumItem(1, 'BRA', 'Brasil')]
  [TEnumItem(2, 'ESP', 'Espanha')]
  [TEnumItem(3, 'EUA', 'Estados Unidos')]
  TCountry = (cNone = 0, cBrazil = 1, cSpain = 2, cUSA = 3);

  TCountryHelper = record helper for TCountry
  public
    class function New(const AEnum: String): TCountry; static;

    function ToString: String;
    function Description: String;
  end;

implementation

uses
  Enum.Mapper.Model;

// Construtor estático
class function TCountryHelper.New(const AEnum: String): TCountry;
begin
  Result := TCountry(TEnumMapper<TCountry>.New.GetEnumerator(AEnum));
end;

// Retorna a chave (texto) do enumerado
function TCountryHelper.ToString: String;
begin
  Result := TEnumMapper<TCountry>.New.ToString(Self);
end;

// Retorna a descrição do enumerado
function TCountryHelper.Description: String;
begin
  Result := TEnumMapper<TCountry>.New.GetDescription(Self);
end;

end.
