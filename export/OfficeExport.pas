unit OfficeExport;

interface

uses
  DBRows;

type
  // ������� DBRows � ������� ����������
  IOfficeExport = interface
    // ��������� �������
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
