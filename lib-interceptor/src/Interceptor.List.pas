unit Interceptor.List;

interface

uses
  System.Generics.Collections;

type
  TList<T> = class(System.Generics.Collections.TList<T>)
  private
    FQuotes: Char;
    FNotInClause: Boolean;

    function QuotedString(AValue: String): String;

    function InClause(const AField: String; const AIndex: Integer): String; overload;

  public
    property Quotes: Char read FQuotes write FQuotes default '''';
    property NotInClause: Boolean read FNotInClause write FNotInClause default False;

    constructor Create;

    function RemoveDuplicates: TList<T>;
    function RemoveAll(const AValue: T): TList<T>;
    function RemoveRange(const AFromIndex, AToIndex: Integer): TList<T>;
    function GetRange(const AFromIndex, AToIndex: Integer): TList<T>;

    function Clone: TList<T>;
    function Join(const ASeparator: String; const AQuotedString: Boolean = False): String;

    function IsEmpty: Boolean;
    function RealCount: Integer;
    function ContainsAll(const AList: TList<T>): Boolean;

    function &Set(const AIndex: Integer; AValue: T): T;
    function Get(const AIndex: Integer): T;

    function AddOrRemove(const AValue: T): Boolean;
    function AddIfNotExists(const AValue: T): Boolean;

    function ToStringList: TList<String>;

    function InClause(const AField: String): String; overload;
  end;

implementation

uses
  System.Generics.Defaults,
  System.SysUtils,
  Util.Converter;

// Construtor
constructor TList<T>.Create;
begin
  inherited;

  Self.FQuotes := '''';
  Self.NotInClause := False;
end;

// Remove todas as chaves duplicadas da lista
function TList<T>.RemoveDuplicates: TList<T>;
var
  LItem: T;
  LList: TList<T>;
begin
  Result := Self;
  LList := TList<T>.Create;

  for var LIndex: Integer := 0 to Pred(Self.Count) do
  begin
    LItem := Self.Items[LIndex];
    if not LList.Contains(LItem) then
    begin
      LList.Add(LItem);
    end;
  end;

  Self.Clear;
  Self.AddRange(LList);

  LList.DisposeOf;
end;

// Remove todas as ocorrências da chave na lista
function TList<T>.RemoveAll(const AValue: T): TList<T>;
var
  LItem: T;
  LList: TList<T>;
  LComparer: IEqualityComparer<T>;
begin
  Result := Self;
  LList := TList<T>.Create;
  LComparer := TEqualityComparer<T>.Default;

  for var LIndex: Integer := 0 to Pred(Self.Count) do
  begin
    LItem := Self.Items[LIndex];
    if not LComparer.Equals(LItem, AValue) then
    begin
      LList.Add(LItem);
    end;
  end;

  Self.Clear;
  Self.AddRange(LList);

  LList.DisposeOf;
end;

// Remove todos os elementos da lista cujo índice está entre "AFromIndex" e "AToIndex"
function TList<T>.RemoveRange(const AFromIndex, AToIndex: Integer): TList<T>;
var
  LFromIndex: Integer;
  LToIndex: Integer;
  LList: TList<T>;
begin
  Result := Self;
  LList := TList<T>.Create;

  LFromIndex := AFromIndex;
  if AFromIndex < 0 then
  begin
    LFromIndex := Self.Count + AFromIndex;
  end;

  LToIndex := AToIndex;
  if AToIndex < 0 then
  begin
    LToIndex := Self.Count + AToIndex;
  end;

  for var LIndex: Integer := LFromIndex to LToIndex do
  begin
    LList.Add(Self.Items[LIndex]);
  end;

  Self.Clear;
  Self.AddRange(LList);

  LList.DisposeOf;
end;

// Retorna todos os elementos da lista cujo índice está entre "AFromIndex" e "AToIndex"
function TList<T>.GetRange(const AFromIndex, AToIndex: Integer): TList<T>;
var
  LFromIndex: Integer;
  LToIndex: Integer;
begin
  Result := TList<T>.Create;

  LFromIndex := AFromIndex;
  if AFromIndex < 0 then
  begin
    LFromIndex := Self.Count + AFromIndex;
  end;

  LToIndex := AToIndex;
  if AToIndex < 0 then
  begin
    LToIndex := Self.Count + AToIndex;
  end;

  for var LIndex: Integer := 0 to Pred(Self.Count) do
  begin
    if (LIndex >= LFromIndex) and (LIndex <= LToIndex) then
    begin
      Result.Add(Self.Items[LIndex]);
    end;
  end;
end;

// Clona a classe
function TList<T>.Clone: TList<T>;
begin
  Result := TList<T>.Create;

  for var LIndex: Integer := 0 to Pred(Self.Count) do
  begin
    Result.Add(Self.Items[LIndex]);
  end;
end;

// Une os itens da lista em uma string (divididos por um separador), podendo colocar aspas nos valores
function TList<T>.Join(const ASeparator: String; const AQuotedString: Boolean): String;
begin
  Result := '';

  for var LIndex: Integer := 0 to Pred(Self.Count) do
  begin
    if AQuotedString then
    begin
      Result := Result + Self.QuotedString(TConverter<T>.ToString(Self.Items[LIndex])) + ASeparator;
    end
    else begin
      Result := Result + TConverter<T>.ToString(Self.Items[LIndex]) + ASeparator;
    end;
  end;

  Result := Result.Substring(0, Result.Length - ASeparator.Length);
end;

// Verifica se a lista está vazia
function TList<T>.IsEmpty: Boolean;
begin
  Result := Self.Count = 0;
end;

// Retorna o tamanho real da lista (ignorando chaves repetidas)
function TList<T>.RealCount: Integer;
var
  LItem: T;
  LList: TList<T>;
begin
  LList := TList<T>.Create;

  for var LIndex: Integer := 0 to Pred(Self.Count) do
  begin
    LItem := Self.Items[LIndex];
    if not LList.Contains(LItem) then
    begin
      LList.Add(LItem);
    end;
  end;

  Result := LList.Count;
  LList.DisposeOf;
end;

// Verifica se a lista contém todos os elementos da lista informada por parâmetro
function TList<T>.ContainsAll(const AList: TList<T>): Boolean;
begin
  Result := True;

  for var LIndex: Integer := 0 to Pred(AList.Count) do
  begin
    if not Self.Contains(AList.Items[LIndex]) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

// Substitui o elemento da lista na posição especificada
function TList<T>.&Set(const AIndex: Integer; AValue: T): T;
begin
  Result := AValue;
  Self.Items[AIndex] := AValue;
end;

// Retorna o elemento da lista alocado no índice fornecido
function TList<T>.Get(const AIndex: Integer): T;
var
  LIndex: Integer;
begin
  LIndex := AIndex;

  if AIndex < 0 then
  begin
    LIndex := Self.Count + AIndex;
  end;

  Result := Self.Items[LIndex];
end;

// Verifica se o valor já existe, se sim, remove (FALSE), se não, adiciona (TRUE)
function TList<T>.AddOrRemove(const AValue: T): Boolean;
begin
  if Self.Contains(AValue) then
  begin
    Result := False;
    Self.Remove(AValue);
  end
  else
  begin
    Result := True;
    Self.Add(AValue);
  end;
end;

// Verifica se o valor não existe para adicionar, se não, não adiciona
function TList<T>.AddIfNotExists(const AValue: T): Boolean;
begin
  Result := False;

  if not Self.Contains(AValue) then
  begin
    Result := True;
    Self.Add(AValue);
  end;
end;

// Converte todos os valores da lista para uma lista de string
function TList<T>.ToStringList: TList<String>;
begin
  Result := TList<String>.Create;

  for var LIndex: Integer := 0 to Pred(Self.Count) do
  begin
    Result.Add(TConverter<T>.ToString(Self.Items[LIndex]));
  end;
end;

// Retorna uma string SQL utilizando o operador IN/NOT IN
function TList<T>.InClause(const AField: String): String;
begin
  Result := Self.InClause(AField, 0);
end;

// Retorna a string entre aspas
function TList<T>.QuotedString(AValue: String): String;
begin
  Result := AnsiQuotedStr(AValue, Self.FQuotes);
end;

// Cria uma string com instrução SQL para operador IN/NOT IN
function TList<T>.InClause(const AField: String; const AIndex: Integer): String;
var
  LLogicOperator: String;
  LInOperator: String;
begin
  Result := '';

  if Self.FNotInClause then
  begin
    LLogicOperator := 'AND';
    LInOperator := 'NOT IN';
  end
  else
  begin
    LLogicOperator := 'OR';
    LInOperator := 'IN';
  end;

  if Self.Count > 0 then
  begin
    Result := 'AND (' + AField + ' ' + LInOperator + ' (';

    for var LIndex: Integer := AIndex to Pred(Self.Count) do
    begin
      Result := Result + Self.QuotedString(TConverter<T>.ToString(Self.Items[LIndex]));

      if LIndex mod 100000 = 99999 then // Limite de valores para o operador IN/NOT IN composto (99.999 registros)
      begin
        Result := Result + '))' + Self.InClause(AField, LIndex);
        Break;
      end;

      if LIndex mod 1000 = 999 then // Limite de valores para o operador IN/NOT IN (999 registros)
      begin
        if LIndex <> Pred(Self.Count) then
        begin
          Result := Result + ') ' + LLogicOperator + ' ' + AField + ' ' + LInOperator + ' (';
        end;

        Continue;
      end;

      if LIndex <> Pred(Self.Count) then
      begin
        Result := Result + ', ';
      end;
    end;

    Result := Result + '))';
  end;
end;

end.
