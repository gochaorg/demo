unit DBView;

interface

uses
  DBGrids;

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

    // Скрывает колонки которые относятся в версии данных
    procedure hideVersionColumns( const grid:TDBGrid );

    // Устанавливает ширину колонки
    procedure setColumnWidth( const grid:TDBGrid; const name:string; const width:Integer );
  end;

  // Расширение функций по работе с grid
  IDBGridExtension = interface
    // Возвращает кол-во строк в TDBGrid
    function getRowsCount(): Integer;
  end;

  // Дополнительные функции по работе с grid
  TDBGridExt = class(TInterfacedObject, IDBGridExtension)
    private
      grid: TDBGrid;
    public
    constructor Create( const grid:TDBGrid );
    function Ext(): IDBGridExtension;
    destructor Destroy; override;
    function getRowsCount(): Integer; virtual;
  end;

  // Расширение функций по работе с grid
  function extend( const grid: TDBGrid ): IDBGridExtension;

var
  dbViewPreparer : TDBViewConfig;

implementation

uses
  Dialogs, SysUtils;

const
  CARS_MODEL = 'TCarsModelsController';

{ DBViewConfig }
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

{ TDBGridExt }

constructor TDBGridExt.Create(const grid: TDBGrid);
begin
  inherited Create();
  self.grid := grid;
end;


destructor TDBGridExt.Destroy;
begin
  self.grid := nil;
  inherited Destroy;
end;

function TDBGridExt.Ext: IDBGridExtension;
begin
  result := self;
end;

function TDBGridExt.getRowsCount: Integer;
begin
  result := 0;
  if assigned(self.grid) then begin
    if assigned(self.grid.DataSource) then begin
      if assigned(self.grid.DataSource.DataSet) then begin
        result := self.grid.DataSource.DataSet.RecordCount;
      end;
    end;
  end;
end;

function extend( const grid: TDBGrid ): IDBGridExtension;
begin
  result := TDBGridExt.Create(grid).Ext;
end;

initialization
  dbViewPreparer := TDBViewConfig.Create();

end.
