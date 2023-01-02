unit Helper.Char;

interface

type
  TCharHelper = record helper for Char
  public
    function InArray(const AArray: array of Char; const AIgnoreCase: Boolean = False): Boolean;
  end;

implementation

// Verifica se um caractere está contido no vetor
function TCharHelper.InArray(const AArray: array of Char; const AIgnoreCase: Boolean): Boolean;
begin
  for var LI: Integer := Low(AArray) to High(AArray) do
  begin
    if (Self = AArray[LI]) or (AIgnoreCase and (UpCase(Self) = UpCase(AArray[LI]))) then
    begin
      Exit(True);
    end;
  end;

  Result := False;
end;

end.
