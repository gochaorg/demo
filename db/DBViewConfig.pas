unit DBViewConfig;

interface

uses
  DBGrids, SysUtils;

type
  // Подгатовка визуальных таблиц
  TDBViewConfig = class(TObject)
    constructor Create();

    // Подгатовка таблицы TDBGrid в зависимости от того где она используется
    // Аргументы
    //   className - имя класса контроллера
    //   grid - сетка
    procedure prepareGrid( const className:string; const grid:TDBGrid );
  private
    // Скрыть конкретные колонки
    procedure hideColumn( const grid:TDBGrid; const name:string );

    // Скрывает колонки которые относятся в версии данных
    procedure hideVersionColumns( const grid:TDBGrid );

    // Устанавливает ширину колонки
    procedure setColumnWidth( const grid:TDBGrid; const name:string; const width:Integer );

    procedure setColumnTitle(
      const grid:TDBGrid;
      const name:string;
      const displayName:WideString
    );
  end;

var
  dbViewPreparer : TDBViewConfig;

implementation

const
  CARS_MODEL = 'TCarsModelsController';
  CARS = 'TCarsController';
  WAYBILLS = 'TWaybillsController';

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
    setColumnWidth(grid, 'name', 150);
  end;
  if className = CARS then begin
    hideColumn(grid, 'model_id');
    setColumnWidth(grid, 'legal_number', 130);
    setColumnWidth(grid, 'model_name', 150);
  end;
  if className = WAYBILLS then begin
    hideColumn(grid, 'car_id');
    hideColumn(grid, 'car_model_id');
    hideColumn(grid, 'driver_id');
    hideColumn(grid, 'dispatcher_id');
    hideColumn(grid, 'outcome_date');
    hideColumn(grid, 'income_date');
    hideColumn(grid, 'car_total_wear');

    setColumnWidth(grid, 'car_legal_number', 130);
    setColumnTitle(grid, 'car_legal_number', 'Гос номер');

    setColumnWidth(grid, 'driver_name', 130);
    setColumnTitle(grid, 'driver_name', 'Водитель');

    setColumnWidth(grid, 'dispatcher_name', 130);
    setColumnTitle(grid, 'dispatcher_name', 'Диспетчер');

    setColumnWidth(grid, 'outcome_date_s', 130);
    setColumnTitle(grid, 'outcome_date_s', 'Выезд');

    setColumnWidth(grid, 'income_date_s', 130);
    setColumnTitle(grid, 'income_date_s', 'Возврат');

    setColumnWidth(grid, 'car_model_name', 130);
    setColumnTitle(grid, 'car_model_name', 'Диспетчер');
  end;
end;

procedure TDBViewConfig.setColumnTitle(
  const grid:TDBGrid;
  const name:string;
  const displayName:WideString
);
var
  tcol : TColumn;
  ci : Integer;
begin
  for ci := 0 to (grid.Columns.Count-1) do begin
    tcol := grid.Columns[ci];
    if SameText(tcol.FieldName,name) then begin
      tcol.Title.Caption := displayName;
    end;
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

procedure TDBViewConfig.hideColumn
( const grid: TDBGrid;
  const name: string
);
var
  tcol : TColumn;
  ci : Integer;
begin
  for ci := 0 to (grid.Columns.Count-1) do begin
    tcol := grid.Columns[ci];
    if SameText(tcol.FieldName,name) then begin tcol.Visible := false; end;
  end;
end;

initialization
  dbViewPreparer := TDBViewConfig.Create();

end.
