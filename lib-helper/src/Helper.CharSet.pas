unit Helper.CharSet;

interface

uses
  System.SysUtils;

type
  TCharSetHelper = record helper for TSysCharSet
  public
    function Length: Integer;
    function ToArray: TArray<Char>;
  end;

implementation

// Retorna o tamanho do conjunto de caracteres
function TCharSetHelper.Length: Integer;
begin
  Result := 0;

  for var LChar: Char := Low(Char) to High(Char) do
  begin
    if CharInSet(LChar, Self) then
    begin
      Inc(Result);
    end;
  end;
end;

// Converte o conjunto de caracteres em um vetor
function TCharSetHelper.ToArray: TArray<Char>;
var
  LIndex: Integer;
begin
  SetLength(Result, Self.Length);
  LIndex := 0;

  for var LChar: Char := Low(Char) to High(Char) do
  begin
    if CharInSet(LChar, Self) then
    begin
      Result[LIndex] := LChar;
      Inc(LIndex);
    end;
  end;

  SetLength(Result, LIndex);
end;

end.
