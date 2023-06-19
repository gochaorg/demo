unit DispatchersFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, Grids, DBGrids, StdCtrls, DB, ADODB,

  DBRows, DBRowPredicate, DBView, Map, DBRowsSqlExec,
  DBViewConfig,

  DispatcherForm,
  Loggers, Logging
  ;

type
  TDispatchersController = class(TFrame)
    Panel1: TPanel;
    dispatchersDBGrid: TDBGrid;
    refreshButton: TButton;
    newButton: TButton;
    editButton: TButton;
    deleteButton: TButton;
    dispatchersDataSource: TDataSource;
    dispatchersADOQuery: TADOQuery;
    procedure refreshButtonClick(Sender: TObject);
    procedure newButtonClick(Sender: TObject);
    procedure editButtonClick(Sender: TObject);
    procedure deleteButtonClick(Sender: TObject);
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
log: ILog;

{$R *.dfm}

procedure TDispatchersController.ActivateDataView();
begin
  dispatchersADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, dispatchersDBGrid);
end;

procedure TDispatchersController.RefreshCurrent();
begin
  dispatchersDBGrid.Refresh;
end;

procedure TDispatchersController.RefreshAll();
begin
  dispatchersADOQuery.Active := false;
  dispatchersADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, dispatchersDBGrid);
end;


procedure TDispatchersController.refreshButtonClick(Sender: TObject);
begin
  RefreshAll;
end;

procedure TDispatchersController.newButtonClick(Sender: TObject);
var
  insertDialog : TDispatcherController;
begin
  insertDialog := TDispatcherController.Create(self);
  try
    if insertDialog.InsertDialog(dispatchersADOQuery.Connection) then begin
      refreshAll;

      extend(dispatchersDBGrid).SelectAndFocus(
        TDataRowValueEqualsPredicate.Create('id', insertDialog.getInsertedId)
      );

      dispatchersDBGrid.SetFocus;
    end;
  finally
    FreeAndNil(insertDialog);
  end;
end;

procedure TDispatchersController.editButtonClick(Sender: TObject);
var
  curRow: TStringMap;
  updateDialog : TDispatcherController;
begin
  curRow := TStringMap.Create;
  try
    if extend(dispatchersDBGrid).GetFocusedRow(curRow) then begin
      updateDialog := TDispatcherController.Create(self);
      try
        if updateDialog.UpdateDialog(
          dispatchersADOQuery.Connection,
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

procedure TDispatchersController.deleteButtonClick(Sender: TObject);
var
  rows: TDBRows;
  rowDelete:  TDBRowsSqlExec;
  query: TADOQuery;
begin
  rows := TDBRows.Create;

  query := TADOQuery.Create(nil);
  query.Connection := dispatchersADOQuery.Connection;
  query.SQL.Text := 'delete from dispatchers where [id] = :ID';

  rowDelete := TDBRowsSqlExec.Create(query);
  rowDelete.Map('id', 'id');
  try
    extend(dispatchersDBGrid).fetchRows(true,false, rows.Add);
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

initialization
log := logger('DispatchersFrame');

end.
