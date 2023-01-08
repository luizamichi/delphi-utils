unit Interceptor.Dictionary;

interface

uses
  System.Generics.Collections;

type
  TDictionary<K, V> = class(System.Generics.Collections.TDictionary<K, V>)
  private
    FAcceptNullValue: Boolean;

  public
    property AcceptNullValue: Boolean read FAcceptNullValue write FAcceptNullValue default True;

    constructor Create; overload;

    function Clone: TDictionary<K, V>;
    function IsEmpty: Boolean;

    function Get(const AKey: K): V;
    function GetKey(const AValue: V): K;

    function AddOrRemoveKey(const AKey: K; const AValue: V): Boolean;
    function AddOrRemoveValue(const AKey: K; const AValue: V): Boolean;

    function GetValueToString(const AKey: K; const ADefault: String = ''; const ARequired: Boolean = False): String;
    function GetValueToInteger(const AKey: K; const ADefault: Integer = 0; const ARequired: Boolean = False): Integer;
    function GetValueToInt64(const AKey: K; const ADefault: Int64 = 0; const ARequired: Boolean = False): Int64;
    function GetValueToDate(const AKey: K; const ADefault: TDate = 0.0; const ARequired: Boolean = False): TDate;
    function GetValueToDateTime(const AKey: K; const ADefault: TDateTime = 0.0; const ARequired: Boolean = False): TDateTime;
  end;

implementation

uses
  System.SysUtils,
  System.Variants,
  Util.Converter;

// Construtor
constructor TDictionary<K, V>.Create;
begin
  inherited;

  Self.FAcceptNullValue := True;
end;

// Clona a classe
function TDictionary<K, V>.Clone: TDictionary<K, V>;
begin
  Result := TDictionary<K, V>.Create(Self);
end;

// Verifica se o dicionário está vazio
function TDictionary<K, V>.IsEmpty: Boolean;
begin
  Result := Self.Count = 0;
end;

// Obtém o valor alocado na chave (retorna o valor padrão caso não exista)
function TDictionary<K, V>.Get(const AKey: K): V;
begin
  if not Self.TryGetValue(AKey, Result) then
  begin
    Result := Default (V);
  end;
end;

// Obtém o valor da chave a partir do valor
function TDictionary<K, V>.GetKey(const AValue: V): K;
begin
  Result := Default (K);

  for var LItem: TPair<K, V> in Self.ToArray do
  begin
    if LItem.Key = AValue then
    begin
      Exit(LItem.Key);
    end;
  end;
end;

// Verifica se a chave já existe, se sim, remove (FALSE), se não, adiciona (TRUE)
function TDictionary<K, V>.AddOrRemoveKey(const AKey: K; const AValue: V): Boolean;
begin
  Result := Self.ContainsKey(AKey);

  if Result then
  begin
    Self.Remove(AKey);
  end
  else
  begin
    Self.Add(AKey, AValue);
  end;
end;

// Verifica se o valor já existe, se sim, remove (FALSE), se não, adiciona (TRUE)
function TDictionary<K, V>.AddOrRemoveValue(const AKey: K; const AValue: V): Boolean;
begin
  Result := Self.ContainsValue(AValue);

  if Result then
  begin
    Self.Remove(Self.GetKey(AValue));
  end;
end;

// Verifica se possui a chave no dicionário e converte o valor para string
function TDictionary<K, V>.GetValueToString(const AKey: K; const ADefault: String; const ARequired: Boolean): String;
var
  LValue: V;
begin
  if ARequired and not Self.TryGetValue(AKey, LValue) then // Chave é obrigatória e não foi encontrada
  begin
    raise EVariantInvalidArgError.Create('Key "' + TConverter<K>.ToString(AKey) + '" not found');
  end;

  Result := TConverter<V>.ToString(Self.Get(AKey));

  if Result.IsEmpty then // Valor vazio
  begin
    Result := ADefault;
  end;

  if Result.IsEmpty and not Self.FAcceptNullValue then // Valor (original ou default) estão vazios e não está permitido (propriedade "AcceptNullValue")
  begin
    raise EVariantInvalidArgError.Create('Null value');
  end;
end;

// Verifica se possui a chave no dicionário e converte o valor para inteiro
function TDictionary<K, V>.GetValueToInteger(const AKey: K; const ADefault: Integer; const ARequired: Boolean): Integer;
begin
  Result := Self.GetValueToInt64(AKey, ADefault, ARequired);
end;

// Verifica se possui a chave no dicionário e converte o valor para inteiro estendido
function TDictionary<K, V>.GetValueToInt64(const AKey: K; const ADefault: Int64; const ARequired: Boolean): Int64;
var
  LValue: V;
begin
  if ARequired and not Self.TryGetValue(AKey, LValue) then // Chave é obrigatória e não foi encontrada
  begin
    raise EVariantInvalidArgError.Create('Key "' + TConverter<K>.ToString(AKey) + '" not found');
  end;

  Result := TConverter<V>.ToInteger(Self.Get(AKey));

  if Result = 0 then // Valor vazio
  begin
    Result := ADefault;
  end;

  if (Result = 0) and not Self.FAcceptNullValue then // Valor (original ou default) estão vazios e não está permitido (propriedade "AcceptNullValue")
  begin
    raise EVariantInvalidArgError.Create('Null value');
  end;
end;

// Verifica se possui a chave no dicionário e converte o valor para date
function TDictionary<K, V>.GetValueToDate(const AKey: K; const ADefault: TDate; const ARequired: Boolean): TDate;
begin
  Result := Self.GetValueToDateTime(AKey, ADefault, ARequired);
end;

// Verifica se possui a chave no dicionário e converte o valor para datetime
function TDictionary<K, V>.GetValueToDateTime(const AKey: K; const ADefault: TDateTime; const ARequired: Boolean): TDateTime;
var
  LValue: V;
begin
  if ARequired and not Self.TryGetValue(AKey, LValue) then // Chave é obrigatória e não foi encontrada
  begin
    raise EVariantInvalidArgError.Create('Key "' + TConverter<K>.ToString(AKey) + '" not found');
  end;

  Result := TConverter<V>.ToDateTime(Self.Get(AKey));

  if Result = 0.0 then // Valor vazio
  begin
    Result := ADefault;
  end;

  if (Result = 0.0) and not Self.FAcceptNullValue then // Valor (original ou default) estão vazios e não está permitido (propriedade "AcceptNullValue")
  begin
    raise EVariantInvalidArgError.Create('Null value');
  end;
end;

end.
