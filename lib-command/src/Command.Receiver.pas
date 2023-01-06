unit Command.Receiver;

interface

type
  TReceiver = class;

  TObjectFunction = function: TReceiver of object;

  TObjectProcedure = procedure of object;

  TReceiver = class
  public
    function ExecuteFunction(const AFunction: TObjectFunction): TReceiver;
    function ExecuteProcedure(const AProcedure: TObjectProcedure): TReceiver;
  end;

implementation

// Executa a função informada
function TReceiver.ExecuteFunction(const AFunction: TObjectFunction): TReceiver;
begin
  Result := Self;

  AFunction();
end;

// Executa o procedimento informado
function TReceiver.ExecuteProcedure(const AProcedure: TObjectProcedure): TReceiver;
begin
  Result := Self;

  AProcedure();
end;

end.
