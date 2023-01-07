unit Enum.Mapper.Interfaces;

interface

type
  IEnumMapper<T: record> = interface
    ['{42173CBF-F495-46A9-9B29-BBE6EF4530DD}']
    function ToInteger(const AEnum: T): Integer;
    function ToString(const AEnum: T): String;

    function GetDescription(const AEnum: T): String;
    function GetEnumerator(const AValue: String): Integer;
  end;

implementation

end.
