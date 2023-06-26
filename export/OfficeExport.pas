unit OfficeExport;

interface

uses
  DBRows, Config;

type
  // Экспорт DBRows в офисные приложения
  IOfficeExport = interface
    // Выполнить экспорт
    procedure doExport( dbRows:IDBRows );
  end;

var
  excelExporter : IOfficeExport;
  wordExporter : IOfficeExport;

implementation

uses
  ExcelExport, WordExport, IniFiles;

type
TOfficeConfig = class(TConfigReader)
  procedure read(ini:TIniFile); override;
end;

{ TOfficeConfig }

procedure TOfficeConfig.read(ini: TIniFile);
var
  template: string;
  bookmark: string;
begin
  template := ini.ReadString('excel', 'template', '-');
  if not (template = '-') then begin
    excelExporter := TExcelExport.Create.withTemplate(template);
  end;

  template := ini.ReadString('word', 'template', '-');
  if not (template = '-') then begin
    bookmark := ini.ReadString('word', 'insertInto', '');
    
    wordExporter := TWordExport.Create
      .withTemplate(template)
      .withInsertIntoBookmark(bookmark);
  end;
end;

var
configReader : TOfficeConfig;

initialization

excelExporter := TExcelExport.Create;
wordExporter := TWordExport.Create;

configReader := TOfficeConfig.Create;
applicationConfigObj.addReader(configReader);

end.
