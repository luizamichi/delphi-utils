unit Horse.Callback.Handler;

interface

uses
  Horse,
  System.SysUtils;

type
  TCallbackHandler = class abstract
  private
    class var FStatusCode: Integer;
    class var FContainsQuery: Boolean;
    class var FContainsBody: Boolean;

  protected
    class function Authenticate(var ARequest: THorseRequest): Boolean; virtual; abstract;
    class procedure HandleCallback(var ARequest: THorseRequest; var AResponse: THorseResponse; const AProcedure: TProc);

  public
    class property StatusCode: Integer read FStatusCode write FStatusCode default 200;
    class property ContainsQuery: Boolean read FContainsQuery write FContainsQuery default False;
    class property ContainsBody: Boolean read FContainsBody write FContainsBody default False;
  end;

implementation

uses
  System.JSON;

// Rotina para tratamento de requisições de callback
class procedure TCallbackHandler.HandleCallback(var ARequest: THorseRequest; var AResponse: THorseResponse; const AProcedure: TProc);
var
  LResponse: TJSONObject;
  LCallbackData: TJSONValue;
  LMessage: String;
begin
  try
    // Verifica a autenticação JWT ou BasicAuthentication, se necessário
    if not Self.Authenticate(ARequest) then
    begin
      // Responde com erro se as credenciais do usuário/fornecedor estão inválidas
      LResponse := TJSONObject.Create;
      LResponse.AddPair('error', 'User is not authenticated');
      AResponse.Status(401);
      AResponse.Send(LResponse);
      Exit;
    end;

    LCallbackData := nil;
    LMessage := '';

    // Lê os parâmetros de consulta da URL
    if Self.ContainsQuery and (ARequest.Query.Count = 0) then
    begin
      LMessage := 'Invalid request query param';
    end;

    // Lê o corpo da requisição
    if Self.ContainsBody then
    begin
      LCallbackData := TJSONValue.ParseJSONValue(ARequest.Body);

      if not Assigned(LCallbackData) then
      begin
        LMessage := 'Invalid request body';
      end;
    end;

    if not LMessage.IsEmpty then
    begin
      // Responde com erro se não possuir parâmetros de consulta ou se o corpo da requisição estiver vazio/inválido
      LResponse := TJSONObject.Create;
      LResponse.AddPair('error', LMessage);
      AResponse.Status(400);
      AResponse.Send(LResponse);
      Exit;
    end;

    try
      // Processa os dados recebidos da plataforma externa (a lógica específica para tratar os callbacks deve ser implementada na origem)
      AProcedure();

      // Responde com sucesso
      LResponse := TJSONObject.Create;
      LResponse.AddPair('status', 'OK');
      AResponse.Status(Self.StatusCode);
      AResponse.Send(LResponse);
    finally
      LCallbackData.DisposeOf;
    end;
  except
    // Responde com erro genérico em caso de exceção não tratada
    LResponse := TJSONObject.Create;
    LResponse.AddPair('error', 'Internal server error');
    AResponse.Status(500);
    AResponse.Send(LResponse);
  end;
end;

end.
