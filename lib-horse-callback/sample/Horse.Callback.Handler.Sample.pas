unit Horse.Callback.Handler.Sample;

interface

uses
  Horse,
  Horse.Callback.Handler;

type
  TCallbackHandlerSample = class(TCallbackHandler)
  public
    class function Authenticate(var ARequest: THorseRequest): Boolean; override;
    class procedure Generic(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
  end;

implementation

// Rotina de autenticação da requisição
class function TCallbackHandlerSample.Authenticate(var ARequest: THorseRequest): Boolean;
begin
  Result := True;
  Writeln('Authentication procedure');
end;

// Exemplo de tratamento de uma requisição de callback
class procedure TCallbackHandlerSample.Generic(ARequest: THorseRequest; AResponse: THorseResponse; ANext: TProc);
begin
  Self.ContainsQuery := True;

  Self.HandleCallback(
    ARequest,
    AResponse,
    procedure
    begin
      Writeln('Request handling procedure');
    end
  );
end;

initialization

THorse.Group.Prefix('/callback').Get('/sample', TCallbackHandlerSample.Generic);

end.
