object ConnectionDataModule: TConnectionDataModule
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 100
  Width = 100
  object Connection: TFDConnection
    Params.Strings = (
      'Database=DATABASE_NAME'
      'User_Name=USER_NAME'
      'Password=SECRET_KEY'
      'CharacterSet=UTF8'
      'BooleanFormat=String'
      'DriverID=Ora')
    FetchOptions.AssignedValues = [evItems, evLiveWindowFastFirst]
    FetchOptions.Items = [fiBlobs, fiDetails]
    FormatOptions.AssignedValues = [fvMapRules, fvMaxStringSize, fvMaxBcdPrecision, fvMaxBcdScale, fvFmtDisplayDateTime, fvFmtDisplayDate]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <
      item
        SourceDataType = dtBCD
        TargetDataType = dtDouble
      end>
    FormatOptions.MaxStringSize = 256
    FormatOptions.MaxBcdPrecision = 2147483647
    FormatOptions.MaxBcdScale = 2147483647
    FormatOptions.FmtDisplayDateTime = 'DD/MM/YYYY HH:MM'
    FormatOptions.FmtDisplayDate = 'DD/MM/YYYY'
    ResourceOptions.AssignedValues = [rvAutoConnect]
    ConnectedStoredUsage = []
    LoginPrompt = False
    AfterConnect = AfterConnect
    Left = 35
    Top = 25
  end
end
