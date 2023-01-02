unit Helper.JSON;

interface

uses
  System.JSON;

type
  TJSONHelper = class helper for TJSONValue
  public
    class function ParseJSONArray(const AText: String): TJSONArray;
    class function ParseJSONObject(const AText: String): TJSONObject;
  end;

implementation

uses
  System.SysUtils;

// Converte um texto em um vetor JSON
class function TJSONHelper.ParseJSONArray(const AText: String): TJSONArray;
var
  LContent: TJSONValue;
begin
  LContent := TJSONObject.ParseJSONValue(AText);

  if not Assigned(LContent) or not (LContent is TJSONArray) then
  begin
    LContent.DisposeOf;
    raise Exception.Create('Invalid JSON array');
  end
  else
  begin
    Result := LContent as TJSONArray;
  end;
end;

// Converte um texto em um objeto JSON
class function TJSONHelper.ParseJSONObject(const AText: String): TJSONObject;
var
  LContent: TJSONValue;
begin
  LContent := TJSONObject.ParseJSONValue(AText);

  if not Assigned(LContent) or not (LContent is TJSONObject) then
  begin
    LContent.DisposeOf;
    raise Exception.Create('Invalid JSON object');
  end
  else
  begin
    Result := LContent as TJSONObject;
  end;
end;

end.
