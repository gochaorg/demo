unit OfficeExport;

interface

uses
  DBRows;

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
  ExcelExport, WordExport;

initialization

excelExporter := TExcelExport.Create;
wordExporter := TWordExport.Create;

end.
