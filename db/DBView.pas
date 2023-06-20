unit DBView;

interface

uses
  DBGrids, DB,
  Classes, SysUtils,

  DBRowPredicate,
  Logging, Map;

type
  // ������������ ��� �����������
  TDataRowSelectionUpdate = class(TObject)
    private
      index: Integer;
      row: TStringMap;
      hasSelectedValue: boolean;
      setSelectedValue: boolean;
      hasFocusValue: boolean;
      setFocusValue: boolean;
    public
      // ��������
      //   row - ������ ������, ������� ���� ��������������
      //   index - ������ ������
      constructor Create(
        row:TStringMap;
        index:Integer;
        hasSelection:boolean;
        hasFocus:boolean
      );
      destructor Destory;

      // ���������� ������� ������ (������)
      function getRow:TStringMap; virtual;

      // ������� ������ ������� ?
      function isSelected:boolean; virtual;

      // ���������� ������ ��� ���������
      procedure setSelect(selected:boolean); virtual;

      // ��� ������� ������ ������������ �������� ?
      function isSelectChanged:boolean; virtual;

      // ������� ������ �������� �����
      function hasFocus:boolean; virtual;

      // ���������� ����� �� ������
      procedure setFocus(focus:boolean); virtual;

      // ��� ������� ������ ������� ������� �����
      function isFocusChanged:boolean; virtual;
  end;

  // ������� ���������� ������
  TDataRowConsumer  = procedure (row:TStringMap) of object;
  TDataRowConsumerI = procedure (row:IStringMap) of object;

  // ������� ����������� ��������� ������
  TDataRowSelectUpdater = procedure (row:TDataRowSelectionUpdate) of object;

  /////////////////////////////////////////////////////////////
  // ���������� ������� �� ������ � grid
  IDBGridExtension = interface
    // ���������� ���-�� ����� � TDBGrid
    function GetRowsCount(): Integer;

    // ������� �����
    // ���������
    //   selected - ���������� ������
    //   unselected - �� ���������� ������
    //   consumer - ��������, �� TDBRows.add
    procedure FetchRows(
      selected: Boolean;
      unselected:Boolean;
      consumer:TDataRowConsumer
    );

    // �������� � ������������� ����� �� ��������� ������
    procedure SelectAndFocus( predicate: IDataRowPredicate );

    // �������� �������� ������ ���������� �����
    // ���������
    //   row - ������ �� ������
    // ���������
    //   true - ������ ������� ��������
    //   false - ������� ������ �� �������
    function GetFocusedRow( var row:TStringMap ): boolean;

    // �������� �������� ������� ������
    // ���������
    //   row - ������ �� ������
    // ���������
    //   true - ������ ������� ��������
    //   false - ������� ������ �� �������
    function GetCurrentRow( var row:TStringMap ): boolean;
  end;

  /////////////////////////////////////////////////////////////
  // �������������� ������� �� ������ � grid
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

      procedure UpdateSelection( updater: TDataRowSelectUpdater ); virtual;

      procedure SelectAndFocus( predicate: IDataRowPredicate ); virtual;

      function GetFocusedRow( var row:TStringMap ): boolean;

      function GetCurrentRow( var row:TStringMap ): boolean;
  end;

  //////////////////////////////////////////////////////////////
  // ���������� ������� �� ������ � grid
  function extend( const grid: TDBGrid ): IDBGridExtension;

implementation

uses
  Dialogs, Variants;

type
  TSetSelectAndFocusUpdater = class
    private
      predicate: IDataRowPredicate;
      setFocus: boolean;
      setSelect: boolean;
    public
      constructor Create( setFocus:boolean; setSelect:boolean; predicate:IDataRowPredicate );
      destructor Destroy;
      procedure Update(row:TDataRowSelectionUpdate);
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

// todo ���� ��� ����� ��������� � ������ UpdateSelection
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

function TDBGridExt.GetCurrentRow(var row: TStringMap): boolean;
var
  c : Integer;
begin
  result := false;
  if assigned(self.grid) then begin
    if assigned(self.grid.DataSource) then begin
      if assigned(self.grid.DataSource.DataSet) then begin
        for c:=0 to self.grid.DataSource.DataSet.Fields.Count-1 do begin
          row.put(
            self.grid.Columns.Items[c].FieldName,
            self.grid.Fields[c].Value
          );
        end;
        result := true;
      end;
    end;
  end;
end;

function TDBGridExt.GetFocusedRow(var row: TStringMap): boolean;
var
  c : Integer;
begin
  result := false;
  if assigned(self.grid) then begin
    if assigned(self.grid.DataSource) then begin
      if assigned(self.grid.DataSource.DataSet) then begin
        if self.grid.DataSource.DataSet.RecNo>0 then begin
          for c:=0 to self.grid.DataSource.DataSet.Fields.Count-1 do begin
            row.put(
              self.grid.Columns.Items[c].FieldName,
              self.grid.Fields[c].Value
            );
          end;
          result := true;
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

procedure TDBGridExt.SelectAndFocus(predicate: IDataRowPredicate);
var
  updater : TSetSelectAndFocusUpdater;
begin
  updater := TSetSelectAndFocusUpdater.Create(true,true,predicate);
  try
    UpdateSelection(updater.Update);
  finally
    FreeAndNil(updater);
  end;
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

{ TSetSelectAndFocusUpdater }

constructor TSetSelectAndFocusUpdater.Create(setFocus, setSelect: boolean;
  predicate: IDataRowPredicate);
begin
  self.predicate := predicate;
  self.setFocus := setFocus;
  self.setSelect := setSelect;
end;

destructor TSetSelectAndFocusUpdater.Destroy;
begin
  self.predicate := nil;
end;

procedure TSetSelectAndFocusUpdater.Update(row: TDataRowSelectionUpdate);
var
  matched: boolean;
begin
  matched := self.predicate.test(row.getRow);
  row.setFocus(matched);
  row.setSelect(matched);
end;

end.
