unit Command.Invoker;

interface

uses
  Command.Interfaces,
  System.Classes;

type
  TInvoker = class
  private
    FCommands: TInterfaceList; // Lista para armazenamento dos comandos

  public
    constructor Create;
    destructor Destroy; override;

    function Add(const ACommand: ICommand): TInvoker;
    function Execute: TInvoker;
  end;

implementation

// Construtor
constructor TInvoker.Create;
begin
  Self.FCommands := TInterfaceList.Create; // Cria a lista que armazenará os comandos
end;

// Destrutor
destructor TInvoker.Destroy;
begin
  Self.FCommands.DisposeOf; // Limpa a lista da memória
  inherited;
end;

// Adiciona um comando à lista
function TInvoker.Add(const ACommand: ICommand): TInvoker;
begin
  Result := Self;

  Self.FCommands.Add(ACommand); // Adiciona o comando na lista
end;

// Executa todos os comandos da lista na ordem que foram adicionados
function TInvoker.Execute: TInvoker;
begin
  Result := Self;

  // Percorre a lista dos comandos armazenados, executando a operação de cada um
  for var LIndex: Integer := 0 to Pred(Self.FCommands.Count) do
  begin
    ICommand(Self.FCommands[LIndex]).Execute;
  end;
end;

end.
