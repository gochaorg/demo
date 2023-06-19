unit DriversFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, ExtCtrls, StdCtrls, DB, ADODB,

  DBRows, DBRowPredicate, DBView, Map, DBRowsSqlExec,
  DBViewConfig,

  DriverForm,
  Loggers, Logging
  ;

type
  TDriversController = class(TFrame)
    Panel1: TPanel;
    driversDBGrid: TDBGrid;
    refreshButton: TButton;
    newButton: TButton;
    editButton: TButton;
    deleteButton: TButton;
    driversDataSource: TDataSource;
    driversADOQuery: TADOQuery;
    procedure newButtonClick(Sender: TObject);
    procedure editButtonClick(Sender: TObject);
    procedure deleteButtonClick(Sender: TObject);
    procedure refreshButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ActivateDataView();
    procedure RefreshCurrent();
    procedure RefreshAll();
  end;

implementation

var
log:ILog;

{$R *.dfm}

procedure TDriversController.ActivateDataView();
begin
  driversADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, driversDBGrid);

  refreshButton.Enabled := true;
  newButton.Enabled := true;
  editButton.Enabled := true;
  deleteButton.Enabled := true;
end;

procedure TDriversController.RefreshCurrent();
begin
  driversADOQuery.Refresh;
end;

procedure TDriversController.RefreshAll();
begin
  driversADOQuery.Active := false;
  driversADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, driversDBGrid);
end;


procedure TDriversController.newButtonClick(Sender: TObject);
var
  insertDialog : TDriverController;
begin
  insertDialog := TDriverController.Create(self);
  try
    if insertDialog.InsertDialog(driversADOQuery.Connection) then begin
      refreshAll;

      extend(driversDBGrid).SelectAndFocus(
        TDataRowValueEqualsPredicate.Create('id', insertDialog.getInsertedId)
      );

      driversDBGrid.SetFocus;
    end;
  finally
    FreeAndNil(insertDialog);
  end;
end;

procedure TDriversController.editButtonClick(Sender: TObject);
var
  curRow: TStringMap;
  updateDialog : TDriverController;
begin
  curRow := TStringMap.Create;
  try
    if extend(driversDBGrid).GetFocusedRow(curRow) then begin
      updateDialog := TDriverController.Create(self);
      try
        if updateDialog.UpdateDialog(
          driversADOQuery.Connection,
          curRow.get('id'),
          curRow.get('name'),
          curRow.get('birth_day')
        ) then begin
          RefreshCurrent;
        end;
      finally
        updateDialog.Close;
      end;
    end;
  finally
    FreeAndNil(curRow);
  end;
end;

procedure TDriversController.deleteButtonClick(Sender: TObject);
var
  rows: TDBRows;
  rowDelete:  TDBRowsSqlExec;
  query: TADOQuery;
begin
  rows := TDBRows.Create;

  query := TADOQuery.Create(nil);
  query.Connection := driversADOQuery.Connection;
  query.SQL.Text := 'delete from drivers where [id] = :ID';

  rowDelete := TDBRowsSqlExec.Create(query);
  rowDelete.Map('id', 'id');
  try
    extend(driversDBGrid).fetchRows(true,false, rows.Add);
    rows.Each(rowDelete.Execute);
    if rowDelete.getErrorsCount > 0 then
      begin
        ShowMessage('В процессе удаления обнаружены ошибки');
      end
    else
      begin
        refreshAll;
      end;
  finally
    FreeAndNil(query);
    FreeAndNil(rows);
    FreeAndNil(rowDelete);
  end;
end;

procedure TDriversController.refreshButtonClick(Sender: TObject);
begin
  RefreshAll;
end;

initialization
log := logger('DriversFrame');

end.
