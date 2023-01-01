unit Util.Constant;

interface

uses
  System.SysUtils;

type
  TConstant = class abstract
  public
  const
    // Caractere de nova linha para ambiente Windows ou Linux/MacOS
    NEW_LINE: String = {$IFDEF MSWINDOWS} AnsiString(#13#10) {$ELSE} AnsiChar(#10) {$ENDIF};

    // Verifica se o ambiente de execução é Linux
    IS_LINUX: Boolean = {$IFDEF LINUX} True {$ELSE} False {$ENDIF};

    // Verifica se o ambiente de execução é Windows
    IS_WINDOWS: Boolean = {$IFDEF MSWINDOWS} True {$ELSE} False {$ENDIF};

    // Verifica se o ambiente de execução é MacOS
    IS_MACOS: Boolean = {$IF DEFINED(MACOS) OR DEFINED(OSX)} True {$ELSE} False {$ENDIF};

    // Verifica se a configuração de compilação está definida para depuração (DEBUG)
    IS_DEBUG: Boolean = {$IFDEF DEBUG} True {$ELSE} False {$ENDIF};

    // Verifica se a configuração de compilação está definido para lançamento (RELEASE)
    IS_RELEASE: Boolean = {$IFDEF RELEASE} True {$ELSE} False {$ENDIF};

    // Conjunto de caracteres limpos
    CHARS: TSysCharSet = ['a' .. 'z', 'A' .. 'Z', '0' .. '9'];
  end;

implementation

end.
