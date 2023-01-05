unit DataModule.Connection;

interface

uses
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.ConsoleUI.Wait,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.Oracle,
  FireDAC.Phys.OracleDef,
  FireDAC.UI.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Pool,
  System.Classes;

type
  TConnectionDataModule = class(TDataModule)
    Connection: TFDConnection;

    procedure DataModuleCreate(const ASender: TObject);
    procedure DataModuleDestroy(const ASender: TObject);

    procedure AfterConnect(const ASender: TObject);
    procedure BeforePost(const ADataSet: TDataSet);
    procedure ChangeError(const ADataSet: TDataSet; const AError: EDatabaseError; var AAction: TDataAction);
    procedure ReconcileError(const ADataSet: TFDDataSet; const AException: EFDException; const AUpdateKind: TFDDatSRowState; var AAction: TFDDAptReconcileAction);
    procedure ReconcileRow(const ASender: TObject; const ARow: TFDDatSRow; var Action: TFDDAptReconcileAction);

  private
    FError: String;
    FRaiseException: Boolean;
    FManager: TFDManager;

  class var
    FDatabase: String;
    FUsername: String;
    FPassword: String;

    procedure PrepareConnection(const AConnection: TFDCustomConnection);
    procedure ThrowException;

  public
    property Error: String read FError;
    property RaiseException: Boolean read FRaiseException write FRaiseException;

    class property Database: String read FDatabase write FDatabase;
    class property Username: String read FUsername write FUsername;
    class property Password: String read FPassword write FPassword;

    class function New: TConnectionDataModule; overload;
    class function New(const AConnection: TFDCustomConnection): TConnectionDataModule; overload;
    class function New(var ADataModule: TConnectionDataModule; const AConnection: TFDCustomConnection): TConnectionDataModule; overload;

    class function New<T: TConnectionDataModule>: T; overload;
    class function New<T: TConnectionDataModule>(const AConnection: TFDCustomConnection): T; overload;
    class function New<T: TConnectionDataModule>(var ADataModule: T; const AConnection: TFDCustomConnection): T; overload;

    function Connect: Boolean;
  end;

var
  ConnectionDataModule: TConnectionDataModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses
  FireDAC.Phys.OracleWrapper,
  System.Generics.Collections,
  System.SysUtils;

// Construtor
procedure TConnectionDataModule.DataModuleCreate(const ASender: TObject);
var
  LParams: TStringList;
begin
  Self.Connection.Params.Clear;
  Self.Connection.LoginPrompt := False;

  Self.Connection.FetchOptions.AssignedValues := [evItems, evLiveWindowFastFirst];
  Self.Connection.FetchOptions.Items := [fiBlobs, fiDetails];
  Self.Connection.FormatOptions.AssignedValues := [fvMapRules, fvMaxStringSize, fvMaxBcdPrecision, fvMaxBcdScale];

  with Self.Connection.FormatOptions do
  begin
    OwnMapRules := True;
    with MapRules.Add do
    begin
      SourceDataType := dtBcd;
      TarGetDataType := dtDouble;
    end;

    MaxBcdPrecision := 2147483647;
    MaxBcdScale := 2147483647;
    MaxStringSize := 256;
  end;

  if not Assigned(ConnectionDataModule) then
  begin
    LParams := nil;
    try
      LParams := TStringList.Create;
      LParams.Add('DriverID=Ora');
      LParams.Add('Database=' + Self.FDatabase);
      LParams.Add('User_Name=' + Self.FUsername);
      LParams.Add('Password=' + Self.FPassword);
      Self.FManager.AddConnectionDef('ManagerConnectionDef', 'Ora', LParams);
    finally
      LParams.DisposeOf;
    end;
  end;

  Self.Connection.FormatOptions.MaxStringSize := 256;
  Self.Connection.FormatOptions.MaxBcdPrecision := 2147483647;
  Self.Connection.FormatOptions.MaxBcdScale := 2147483647;
  Self.Connection.ResourceOptions.AssignedValues := [rvAutoReconnect];
  Self.Connection.ResourceOptions.AutoReconnect := True;
  Self.Connection.ConnectedStoredUsage := [];
  Self.Connection.DriverName := 'Ora';

  Self.Connection.ConnectionDefName := 'ManagerConnectionDef';
  Self.Connection.Connected := Assigned(ConnectionDataModule);
end;

// Destrutor
procedure TConnectionDataModule.DataModuleDestroy(const ASender: TObject);
begin
  if Assigned(Self.FManager) then
  begin
    Self.FManager.DisposeOf;
  end;
end;

// Adiciona informações na sessão do Oracle após conectar na base
procedure TConnectionDataModule.AfterConnect(const ASender: TObject);
var
  LQuery: TFDCustomQuery;
begin
  LQuery := nil;

  try
    LQuery := TFDCustomQuery.Create(nil);
    LQuery.Connection := Self.Connection;

    LQuery.SQL.Add('ALTER SESSION SET NLS_TERRITORY = ''BRAZIL''');
    LQuery.ExecSQL;

    LQuery.SQL.Clear;
    LQuery.SQL.Add('ALTER SESSION SET NLS_LANGUAGE = ''BRAZILIAN PORTUGUESE''');
    LQuery.ExecSQL;

    LQuery.SQL.Clear;
    LQuery.SQL.Add('ALTER SESSION SET NLS_SORT = ''BINARY''');
    LQuery.ExecSQL;

    LQuery.SQL.Clear;
    LQuery.SQL.Add('ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''');
    LQuery.ExecSQL;
  finally
    LQuery.Close;
    LQuery.DisposeOf;
  end;
end;

// Rotina padrão (realizada antes do POST) para consultas SQL
procedure TConnectionDataModule.BeforePost(const ADataSet: TDataSet);
var
  LErrors: TList<String>;
begin
  LErrors := nil;

  try
    LErrors := TList<String>.Create;

    for var LField: TField in ADataSet.Fields do
    begin
      if LField.Required and LField.IsNull and (Length(LField.Value) = 0) then
      begin
        LErrors.Add(LField.DisplayLabel);
      end;
    end;

    if LErrors.Count > 0 then
    begin
      raise Exception.Create('Required fields: ' + String.Join(', ', LErrors.ToArray));
    end;
  finally
    LErrors.DisposeOf;
  end;
end;

// Rotina padrão para tratamento de erros em modificações nas consultas SQL
procedure TConnectionDataModule.ChangeError(const ADataSet: TDataSet; const AError: EDatabaseError; var AAction: TDataAction);
begin
  Self.FError := Self.UnitName + ' - ' + AError.Message + ' (' + AError.GetHashCode.ToString + ')';
  Self.ThrowException;
end;

// Rotina padrão para tratamento de erros nas consultas SQL
procedure TConnectionDataModule.ReconcileError(const ADataSet: TFDDataSet; const AException: EFDException; const AUpdateKind: TFDDatSRowState; var AAction: TFDDAptReconcileAction);
begin
  Self.FError := Self.UnitName + ' - ' + AException.Message + ' (' + AException.FDCode.ToString + ')';
  Self.ThrowException;
end;

// Rotina padrão para tratamento de erros nas stored procedures
procedure TConnectionDataModule.ReconcileRow(const ASender: TObject; const ARow: TFDDatSRow; var Action: TFDDAptReconcileAction);
begin
  Self.FError := Self.UnitName + ' - ' + ARow.RowError.Message + ' (' + ARow.RowError.FDCode.ToString + ')';
  Self.ThrowException;
end;

// Retorna a conexão global
class function TConnectionDataModule.New: TConnectionDataModule;
begin
  if not Assigned(ConnectionDataModule) then
  begin
    ConnectionDataModule := TConnectionDataModule.New(nil);
  end;

  Result := Self.New(ConnectionDataModule.Connection);
end;

// Retorna uma nova conexão
class function TConnectionDataModule.New(const AConnection: TFDCustomConnection): TConnectionDataModule;
begin
  Result := TConnectionDataModule.Create(nil);
  Result.PrepareConnection(AConnection);
end;

// Retorna uma nova conexão para a instância que foi informada
class function TConnectionDataModule.New(var ADataModule: TConnectionDataModule; const AConnection: TFDCustomConnection): TConnectionDataModule;
begin
  ADataModule := Self.New(AConnection);
  Result := ADataModule;
end;

// Retorna a conexão global com o tipo da classe herdada
class function TConnectionDataModule.New<T>: T;
begin
  if not Assigned(ConnectionDataModule) then
  begin
    ConnectionDataModule := TConnectionDataModule.New(nil);
  end;

  Result := Self.New<T>(ConnectionDataModule.Connection);
end;

// Retorna uma nova conexão com o tipo da classe herdada
class function TConnectionDataModule.New<T>(const AConnection: TFDCustomConnection): T;
begin
  Result := T.Create(nil);
  Result.PrepareConnection(AConnection);
end;

// Retorna uma nova conexão para a instância que foi informada com o tipo da classe herdada
class function TConnectionDataModule.New<T>(var ADataModule: T; const AConnection: TFDCustomConnection): T;
begin
  Result := ADataModule;
  Result.New(AConnection);
end;

// Realiza a conexão com o banco de dados
function TConnectionDataModule.Connect: Boolean;
begin
  try
    Self.Connection.Connected := True;
  except
    on E: EOCINativeException do
    begin
      Self.FError := Self.UnitName + ' - ' + E.Message + ' (' + E.FDCode.ToString + ')';
      Self.ThrowException;

      Exit(False);
    end;
  end;

  Result := True;
end;

// Rotina padrão realizada após a instanciação da classe para definir a conexão dos componentes FireDAC
procedure TConnectionDataModule.PrepareConnection(const AConnection: TFDCustomConnection);
var
  LComponent: TFDCustomQuery;
begin
  if Assigned(AConnection) then
  begin
    for var LI: Integer := 0 to Pred(Self.ComponentCount) do
    begin
      if (Self.Components[LI].InheritsFrom(TFDCustomQuery)) then
      begin
        LComponent := (Self.Components[LI] as TFDCustomQuery);
        LComponent.Connection := AConnection;

        if not Assigned(LComponent.SchemaAdapter) then
        begin
          LComponent.CachedUpdates := False;
        end;
      end
      else if (Self.Components[LI].InheritsFrom(TFDCustomStoredProc)) then
      begin
        (Self.Components[LI] as TFDCustomStoredProc).Connection := AConnection;
      end;
    end;
  end;
end;

// Define se irá lançar exceções em casos de erros ocorridos em tempo de execução
procedure TConnectionDataModule.ThrowException;
begin
  if Self.FRaiseException and not Self.FError.IsEmpty then
  begin
    raise Exception.Create(Self.FError);
  end;
end;

initialization

ConnectionDataModule := TConnectionDataModule.New(nil);

finalization

if Assigned(ConnectionDataModule) then
begin
  ConnectionDataModule.DisposeOf;
end;

end.
