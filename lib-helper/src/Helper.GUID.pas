unit Helper.GUID;

interface

type
  TGUIDHelper = record helper for TGUID
  public
    class function UUID(const AAsHex: Boolean = False): String; static;
  end;

implementation

uses
  System.SysUtils;

// Gera um identificador único universal
class function TGUIDHelper.UUID(const AAsHex: Boolean): String;
var
  LGUID: TGUID;
begin
  Result := '';

  if CreateGUID(LGUID) = S_OK then
  begin
    Result := GUIDToString(LGUID);
    Result := Result.Substring(1, Result.Length - 2);
  end;

  if AAsHex then
  begin
    Result := Result.Replace('-', '', [rfReplaceAll]);
  end;
end;

end.
