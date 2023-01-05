unit Helper.Memo;

interface

uses
  Vcl.StdCtrls;

type
  THtmlStyles = (hsNone, hsBold, hsItalic, hsUnderlined, hsDeleted, hsMarked, hsBreakline, hsParagraph, hsSubscript, hsSuperscript, hsTitle1, hsTitle2, hsTitle3, hsTitle4, hsTitle5, hsTitle6, hsSmall);

  TMemoHelper = class helper for TCustomMemo
  private
    function GetHtmlStyle(const AHtmlStyle: THtmlStyles; const AText: String = ''): String;

  public
    function AddText(const AText: String): TCustomMemo;
    function AddHtmlStyle(const AHtmlStyle: THtmlStyles): TCustomMemo;

    procedure Preview;
  end;

implementation

uses
  Util.Constant,
  Vcl.Forms,
  Winapi.ShellAPI,
  Winapi.Windows;

// Adiciona/concatena uma tag HTML ao texto
function TMemoHelper.GetHtmlStyle(const AHtmlStyle: THtmlStyles; const AText: String = ''): String;
begin
  case AHtmlStyle of
    hsBold:
      Result := '<strong>' + AText + '</strong>';
    hsItalic:
      Result := '<em>' + AText + '</em>';
    hsUnderlined:
      Result := '<u>' + AText + '</u>';
    hsDeleted:
      Result := '<del>' + AText + '</del>';
    hsMarked:
      Result := '<marked>' + AText + '</marked>';
    hsBreakline:
      Result := '<br/>' + AText;
    hsParagraph:
      Result := '<p>' + AText + '</p>';
    hsSubscript:
      Result := '<sub>' + AText + '</sub>';
    hsSuperscript:
      Result := '<sup>' + AText + '</sup>';
    hsTitle1:
      Result := '<h1>' + AText + '</h1>';
    hsTitle2:
      Result := '<h2>' + AText + '</h2>';
    hsTitle3:
      Result := '<h3>' + AText + '</h3>';
    hsTitle4:
      Result := '<h4>' + AText + '</h4>';
    hsTitle5:
      Result := '<h5>' + AText + '</h5>';
    hsTitle6:
      Result := '<h6>' + AText + '</h6>';
    hsSmall:
      Result := '<small>' + AText + '</small>';
  else
    Result := '';
  end;
end;

// Adiciona um texto no componente de texto
function TMemoHelper.AddText(const AText: String): TCustomMemo;
var
  LText: String;
  LPosition: Integer;
begin
  Result := Self;
  LText := '';
  LPosition := Length(Self.Text);

  if Self.Focused then
  begin
    LText := Copy(Self.Text, 0, Self.SelStart) + AText + Copy(Self.Text, Self.SelStart + Self.SelLength + 1, Length(Self.Text));

    LPosition := Self.SelStart + Length(AText);
  end;

  Self.Lines.Text := LText;
  Self.SelStart := LPosition;
end;

// Adiciona uma tag HTML no componente de texto
function TMemoHelper.AddHtmlStyle(const AHtmlStyle: THtmlStyles): TCustomMemo;
begin
  Result := Self.AddText(Self.GetHtmlStyle(AHtmlStyle, Copy(Self.Text, Self.SelStart + 1, Self.SelLength)));
end;

// Renderiza o HTML no navegador web padrão
procedure TMemoHelper.Preview;
var
  LFile: TextFile;
  LName: String;
begin
  LName := 'html-preview.html';

  AssignFile(LFile, LName);
  Rewrite(LFile);

  Writeln(LFile, '<!doctype html>' + TConstant.NEW_LINE + '<html>' + TConstant.NEW_LINE);
  Writeln(LFile, '  <head>' + TConstant.NEW_LINE + '    <title>Pré-visualização de conteúdo</title>' + TConstant.NEW_LINE + '  </head>' + TConstant.NEW_LINE);
  Writeln(LFile, '  <body>' + TConstant.NEW_LINE + Self.Text + TConstant.NEW_LINE + '  </body>' + TConstant.NEW_LINE + '</html>');
  CloseFile(LFile);

  ShellExecute(Application.Handle, nil, PChar(LName), nil, nil, SW_SHOWNORMAL);
end;

end.
