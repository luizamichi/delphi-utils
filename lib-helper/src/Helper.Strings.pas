unit Helper.Strings;

interface

type
  TStringHelper = record helper for String
  private
    function NotInArray(const AAllowed: array of Char): Boolean;

  public
    function GetLetters: String;
    function GetNumbers: String;

    function UpperCaseFirst: String;
    function UpperCaseWords: String;
    function Normalize: String;
    function Randomize(const ALength: Integer): String;

    function InArray(const AValues: array of String; const AIgnoreCase: Boolean = False): Boolean;
    function ContainsInvalidChars: Boolean; overload;
    function ContainsInvalidChars(const AAllowed: array of Char): Boolean; overload;

    function ToCharArray: TArray<Char>;
  end;

implementation

uses
  Helper.Char,
  System.RegularExpressions,
  System.StrUtils,
  System.SysUtils;

// Verifica se o texto não contém caracteres que estejam contidos na lista
function TStringHelper.NotInArray(const AAllowed: array of Char): Boolean;
var
  LChars: TArray<Char>;
begin
  LChars := Self.ToCharArray;
  Result := True;

  for var LI: Integer := 0 to Length(Self) - 1 do
  begin
    if not LChars[LI].InArray(AAllowed) then
    begin
      Exit(False);
    end;
  end;
end;

// Remove todos os números do texto
function TStringHelper.GetLetters: String;
begin
  Result := TRegEx.Replace(Self, '[-+]?[0-9]*\.?[0-9]+', '');
end;

// Remove todos os caracteres não numéricos do texto
function TStringHelper.GetNumbers: String;
begin
  Result := TRegEx.Replace(Self, '\D', '');
end;

// Altera o primeiro caractere não nulo para maiúsculo
function TStringHelper.UpperCaseFirst: String;
begin
  Result := Self;

  for var LI: Integer := 1 to Length(Self) do
  begin
    if Self[LI] <> ' ' then
    begin
      Result[LI] := UpCase(Self[LI]);
      Break;
    end;
  end;
end;

// Altera o primeiro caractere de cada palavra para maiúsculo
function TStringHelper.UpperCaseWords: String;
var
  LArray: TArray<String>;
begin
  Result := '';
  LArray := SplitString(Self, ' ');

  for var LItem: String in LArray do
  begin
    Result := Result + LItem.UpperCaseFirst + ' ';
  end;

  Result := Copy(Result, 1, Length(Self));
end;

// Substitui os caracteres com acentuação, cedilha, etc.
function TStringHelper.Normalize: String;
var
  LOriginal: array of Char;
  LNormalized: array of Char;
begin
  LOriginal := ['á', 'à', 'ã', 'â', 'ª', 'ç', 'é', 'è', 'ê', 'í', 'ì', 'ñ', 'ó', 'ò', 'õ', 'ö', 'º', 'ú', 'ù', 'ü',
    'Á', 'À', 'Ã', 'Â', 'Ç', 'É', 'È', 'Ê', 'Í', 'Ì', 'Ñ', 'Ó', 'Ò', 'Õ', 'Ö', 'Ú', 'Ù', 'Ü'];
  LNormalized := ['a', 'a', 'a', 'a', 'a', 'c', 'e', 'e', 'e', 'i', 'i', 'n', 'o', 'o', 'o', 'o', 'o', 'u', 'u', 'u',
    'A', 'A', 'A', 'A', 'C', 'E', 'E', 'E', 'I', 'I', 'N', 'O', 'O', 'O', 'O', 'U', 'U', 'U'];

  Result := Self;

  for var LI: Integer := 0 to Length(LOriginal) - 1 do
  begin
    Result := StringReplace(Result, LOriginal[LI], LNormalized[LI], [rfReplaceAll]);
  end;
end;

// Embaralha um texto e corta em um tamanho definido
function TStringHelper.Randomize(const ALength: Integer): String;
var
  LStr: String;
  LStrLength: Integer;
begin
  LStr := IfThen(Length(Self) = 0, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', Self);
  LStrLength := Length(LStr);

  Result := '';

  for var LI: Integer := 1 to ALength do
  begin
    Result := Result + LStr[Random(LStrLength) + 1];
  end;
end;

// Verifica se o texto contém ao menos uma das palavras informadas na lista
function TStringHelper.InArray(const AValues: array of String; const AIgnoreCase: Boolean): Boolean;
begin
  for var LValue: String in AValues do
  begin
    if (AIgnoreCase and (Pos(UpperCase(LValue), UpperCase(Self)) > 0)) or (Pos(LValue, Self) > 0) then
    begin
      Exit(True);
    end;
  end;

  Result := False;
end;

// Verifica se o texto contém caracteres inválidos
function TStringHelper.ContainsInvalidChars: Boolean;
begin
  Result := not Self.NotInArray(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' ']);
end;

// Verifica se o texto contém caracteres que não estão na lista de caracteres permitidos
function TStringHelper.ContainsInvalidChars(const AAllowed: array of Char): Boolean;
begin
  Result := not Self.NotInArray(AAllowed);
end;

// Converte o texto em um vetor de caracteres
function TStringHelper.ToCharArray: TArray<Char>;
var
  LLength: Integer;
begin
  LLength := Length(Self);
  SetLength(Result, LLength);

  for var LI: Integer := 1 to LLength do
  begin
    Result[LI - 1] := Self[LI];
  end;
end;

end.
