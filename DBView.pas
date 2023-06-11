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

  // Используется для обновдления
  TDataRowSelectionUpdate = class(TObject)
    private
      index: Integer;
      row: TStringMap;
      hasSelectedValue: boolean;
      setSelectedValue: boolean;
      hasFocusValue: boolean;
      setFocusValue: boolean;
    public
      // Создание
      //   row - данные строки, удалять надо самостоятельно
      //   index - индекс строки
      constructor Create(
        row:TStringMap;
        index:Integer;
        hasSelection:boolean;
        hasFocus:boolean
      );
      destructor Destory;

      // Возвращает текущую строку (данные)
      function getRow:TStringMap; virtual;

      // Текущая строка выбрана ?
      function isSelected:boolean; virtual;

      // Установить строку как выбранную
      procedure setSelect(selected:boolean); virtual;

      // Для текущей строки выборанность изменена ?
      function isSelectChanged:boolean; virtual;

      // Текущая строка содержит фокус
      function hasFocus:boolean; virtual;

      // Установить фокус на строку
      procedure setFocus(focus:boolean); virtual;

      // Для текущей строки следует сменить фокус
      function isFocusChanged:boolean; virtual;
  end;

  // Функция прнимающая строку
  TDataRowConsumer  = procedure (row:TStringMap) of object;
  TDataRowConsumerI = procedure (row:IStringMap) of object;

  // Функция обновляющая выделение строки
  TDataRowSelectUpdater = procedure (row:TDataRowSelectionUpdate) of object;

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

      procedure UpdateSelection(updater: TDataRowSelectUpdater); virtual;
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

procedure TDBGridExt.UpdateSelection(updater: TDataRowSelectUpdater);
var
  bm: TBookmark;
  i,c: Integer;
  row: TStringMap;
  rowUpdate: TDataRowSelectionUpdate;
  savedActiveRecNo: Integer;
  restoreActiveRecNo: Integer;
begin
  if assigned(self.grid) then begin
    if assigned(self.grid.DataSource) then begin
      if assigned(self.grid.DataSource.DataSet) then begin
        savedActiveRecNo := self.grid.DataSource.DataSet.RecNo;
        restoreActiveRecNo := savedActiveRecNo;
        bm := self.grid.DataSource.DataSet.GetBookmark;
        self.grid.DataSource.DataSet.DisableControls;
        self.grid.DataSource.DataSet.First;
        try
          for i:=0 to self.grid.DataSource.DataSet.RecordCount-1 do begin
            row := TStringMap.Create;
            rowUpdate := TDataRowSelectionUpdate.Create(
              row,
              i,
              self.grid.SelectedRows.CurrentRowSelected,
              savedActiveRecNo = (i+1)
            );
            try
              // build data
              for c:=0 to self.grid.DataSource.DataSet.Fields.Count-1 do begin
                row.put(
                  self.grid.Columns.Items[c].FieldName,
                  self.grid.Fields[c].Value
                );
              end;
              updater( rowUpdate );
              if rowUpdate.isFocusChanged then begin
                restoreActiveRecNo := (i+1);
              end;
              if rowUpdate.isSelectChanged then begin
                self.grid.SelectedRows.CurrentRowSelected := rowUpdate.isSelected;
              end;
            finally
              FreeAndNil(rowUpdate);
              FreeAndNil(row);
              self.grid.DataSource.DataSet.Next;
            end;
          end;
        finally
          self.grid.DataSource.DataSet.EnableControls;
          if restoreActiveRecNo = savedActiveRecNo then
            begin
              self.grid.DataSource.DataSet.GotoBookmark(bm);
            end
          else
            begin
              if restoreActiveRecNo > 0 then
              begin
                self.grid.DataSource.DataSet.RecNo := restoreActiveRecNo;
              end;
            end;
          self.grid.DataSource.DataSet.FreeBookmark(bm);
        end;
      end;
    end;
  end;
end;

{ TDataRowSelectionUpdate }

constructor TDataRowSelectionUpdate.Create(
  row: TStringMap;
  index: Integer;
  hasSelection:boolean;
  hasFocus:boolean
);
begin
  inherited Create();
  self.row := row;
  self.index := index;
  self.hasSelectedValue := hasSelection;
  self.setSelectedValue := hasSelection;
  self.hasFocusValue := hasFocus;
  self.setFocusValue := hasFocus;
end;

destructor TDataRowSelectionUpdate.Destory;
begin
  self.row := nil;
  inherited Destroy();
end;

function TDataRowSelectionUpdate.getRow: TStringMap;
begin
  result := self.row;
end;

function TDataRowSelectionUpdate.hasFocus: boolean;
begin
  result := self.hasFocusValue;
end;

function TDataRowSelectionUpdate.isFocusChanged: boolean;
begin
  result := self.hasFocusValue <> self.setFocusValue;
end;

function TDataRowSelectionUpdate.isSelectChanged: boolean;
begin
  result := self.hasSelectedValue <> self.setSelectedValue;
end;

function TDataRowSelectionUpdate.isSelected: boolean;
begin
  result := self.hasSelectedValue;
end;

procedure TDataRowSelectionUpdate.setFocus(focus: boolean);
begin
  self.setFocusValue := true;
end;

procedure TDataRowSelectionUpdate.setSelect(selected: boolean);
begin
  self.setSelectedValue := true;
end;

initialization
  dbViewPreparer := TDBViewConfig.Create();

end.
