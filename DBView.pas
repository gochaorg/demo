unit DBView;

interface

uses
  DBGrids, DB,
  Classes, SysUtils,

  Logging, Map;

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
  TDataRowConsumer = procedure (row:TStringMap) of object;

  /////////////////////////////////////////////////////////////
  // Расширение функций по работе с grid
  IDBGridExtension = interface
    // Возвращает кол-во строк в TDBGrid
    function GetRowsCount(): Integer;

    // Выборка строк
    // Аргументы
    //   selected - выделенные строки
    //   unselected - не выделенные строки
    //   consumer - применик, см TDBRows.add
    procedure FetchRows(
      selected: Boolean;
      unselected:Boolean;
      consumer:TDataRowConsumer
    );
  end;

  /////////////////////////////////////////////////////////////
  // Дополнительные функции по работе с grid
  TDBGridExt = class(TInterfacedObject, IDBGridExtension)
    private
      grid: TDBGrid;
    public
    constructor Create( const grid:TDBGrid );
    function Ext(): IDBGridExtension;
    destructor Destroy; override;

    function GetRowsCount(): Integer; virtual;
    procedure FetchRows(
      selected: Boolean;
      unselected:Boolean;
      consumer:TDataRowConsumer
    ); virtual;
  end;

  /////////////////////////////////////////////////////////////
  // Выборка строк
  IDBRows = interface
    // Возвращает кол-во строк в выборке
    function GetCount: Integer;

    // Возвращает строку по индексу
    function GetItem(index:Integer): IStringMap;

    // Добавляет строку в выборку
    procedure Add(row:TStringMap);

    // Обход всех строк в выборке и передача каждой в приемник
    // Аргументы
    //   consumer - применик
    procedure Each( consumer:TDataRowConsumer );
  end;

  TDBRows = class(TInterfacedObject,IDBRows)
  private
    list: TList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCount: Integer; virtual;
    function GetItem(index:Integer): IStringMap; virtual;
    procedure Add(row:TStringMap); virtual;
    procedure Each( consumer:TDataRowConsumer ); virtual;
  end;

  EIndexOutOfBound = class(Exception);

  ///////////////////////////////////////
  IDBRowsLogger = interface
  end;
  TDBRowsLogger = class(TInterfacedObject,IDBRowsLogger)
    private
      logger: ILog;
    public
      constructor Create( logger:ILog );
      destructor Destroy; override;
      procedure Add(row:TStringMap); virtual;
  end;

  //////////////////////////////////////////////////////////////
  // Расширение функций по работе с grid
  function extend( const grid: TDBGrid ): IDBGridExtension;

var
  dbViewPreparer : TDBViewConfig;

implementation

uses
  Dialogs, Variants;

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

procedure TDBGridExt.FetchRows(
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
              //FreeAndNil(row);
              row.Destroy;
              row := nil;
              self.grid.DataSource.DataSet.Next;
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

function TDBGridExt.GetRowsCount: Integer;
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

{ TDBRows }

constructor TDBRows.Create;
begin
  inherited Create;
  list := TList.Create;
end;

destructor TDBRows.Destroy;
var
  i: Integer;
  row: TStringMap;
begin
  for i:=0 to list.Count-1 do begin
    row := list.Items[i];
    FreeAndNil(row);
  end;
  list.Clear;

  FreeAndNil(list);
  inherited Destroy;
end;

procedure TDBRows.Add(row: TStringMap);
var
  rowCopy: TStringMap;
begin
  rowCopy := TStringMap.Copy(row);
  list.Add( rowCopy );
end;


function TDBRows.GetCount: Integer;
begin
  result := list.Count;
end;

function TDBRows.GetItem(index: Integer): IStringMap;
var
  row : TStringMap;
begin
  if index<0 then
    raise EIndexOutOfBound.Create('index (='+IntToStr(index)+') param < 0');

  if index>=list.Count then
    raise EIndexOutOfBound.Create(
      'index (='+IntToStr(index)+
      ') param > list.count(='+IntToStr(list.Count)+')');

  row := list[index];
  result := row;
end;

procedure TDBRows.Each(consumer: TDataRowConsumer);
var
  i:Integer;
  row: TStringMap;
begin
  for i:=0 to list.Count-1 do begin
    row := list[i];
    consumer(row);
  end;
end;

{ TDBRowsLogger }

constructor TDBRowsLogger.Create(logger: ILog);
begin
  inherited Create;
  self.logger := logger;
end;

destructor TDBRowsLogger.Destroy;
begin
  self.logger := nil;
  inherited Destroy;
end;

procedure TDBRowsLogger.Add(row: TStringMap);
var
  i: Integer;
  key: string;
  value: variant;
  value_str: string;
begin
  self.logger.print('row: ');
  self.logger.println( row.toString );
end;

initialization
  dbViewPreparer := TDBViewConfig.Create();

end.
