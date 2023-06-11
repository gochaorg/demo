unit DBView;

interface

uses
  DBGrids,
  DB,

  Map;

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

  // Функция прнимающая строку
  TDataRowConsumer = procedure (row:IStringMap) of object;

  // Расширение функций по работе с grid
  IDBGridExtension = interface
    // Возвращает кол-во строк в TDBGrid
    function getRowsCount(): Integer;

    // Выборка строк
    // Аргументы
    //   selected - выделенные строки
    //   unselected - не выделенные строки
    //   consumer - применик
    procedure fetchRows(
      selected: Boolean;
      unselected:Boolean;
      consumer:TDataRowConsumer
    );
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
    procedure fetchRows(
      selected: Boolean;
      unselected:Boolean;
      consumer:TDataRowConsumer
    ); virtual;
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

procedure TDBGridExt.fetchRows(
  selected, unselected: Boolean;
  consumer: TDataRowConsumer
);
var
  bm: TBookmark;
  i,c: Integer;
  row: TStringMap;
begin
  if assigned(self.grid) then begin
    if assigned(self.grid.DataSource) then begin
      if assigned(self.grid.DataSource.DataSet) then begin
        bm := self.grid.DataSource.DataSet.GetBookmark;
        self.grid.DataSource.DataSet.DisableControls;
        self.grid.DataSource.DataSet.First;
        try
          for i:=0 to self.grid.DataSource.DataSet.RecordCount-1 do begin
            row := TStringMap.Create;
            try
              for c:=0 to self.grid.DataSource.DataSet.Fields.Count-1 do begin
                row.put(
                  self.grid.Columns.Items[c].FieldName,
                  self.grid.Fields[c].Value
                );
              end;
              if self.grid.SelectedRows.CurrentRowSelected then
                begin
                  if selected then begin
                    consumer(row);
                  end;
                end
              else
                begin
                  if unselected then begin
                    consumer(row);
                  end;
                end;
            finally
              self.grid.DataSource.DataSet.Next;
              //FreeAndNil(row);
            end;
          end;
        finally
          self.grid.DataSource.DataSet.EnableControls;
          self.grid.DataSource.DataSet.GotoBookmark(bm);
          self.grid.DataSource.DataSet.FreeBookmark(bm);
        end;
      end;
    end;
  end;
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
