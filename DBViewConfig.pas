unit DBViewConfig;

interface

uses
  DBGrids, SysUtils;

type
  // ���������� ���������� ������
  TDBViewConfig = class(TObject)
    constructor Create();

    // ���������� ������� TDBGrid � ����������� �� ���� ��� ��� ������������
    // ���������
    //   className - ��� ������ �����������
    //   grid - �����
    procedure prepareGrid( const className:string; const grid:TDBGrid );
  private

    // �������� ������� ������� ��������� � ������ ������
    procedure hideVersionColumns( const grid:TDBGrid );

    // ������������� ������ �������
    procedure setColumnWidth( const grid:TDBGrid; const name:string; const width:Integer );
  end;

var
  dbViewPreparer : TDBViewConfig;

implementation

const
  CARS_MODEL = 'TCarsModelsController';

constructor TDBViewConfig.Create;
begin
  inherited Create();
end;

procedure TDBViewConfig.prepareGrid(
  const className:string;
  const grid: TDBGrid
);
begin
  if className = CARS_MODEL then begin
    hideVersionColumns(grid);
    setColumnWidth(grid, 'name', 500);
  end;
end;

procedure TDBViewConfig.hideVersionColumns(const grid: TDBGrid);
var
  tcol : TColumn;
  ci : Integer;
begin
  for ci := 0 to (grid.Columns.Count-1) do begin
    tcol := grid.Columns[ci];
    if SameText(tcol.FieldName,'ValidFrom') then begin tcol.Visible := false; end;
    if SameText(tcol.FieldName,'ValidTo')   then begin tcol.Visible := false; end;
  end;
end;

procedure TDBViewConfig.setColumnWidth( const grid:TDBGrid; const name:string; const width:Integer );
var
  tcol : TColumn;
  ci : Integer;
begin
  for ci := 0 to (grid.Columns.Count-1) do begin
    tcol := grid.Columns[ci];
    if SameText(tcol.FieldName,name) then begin tcol.Width := width; end;
  end;
end;

initialization
  dbViewPreparer := TDBViewConfig.Create();

end.
