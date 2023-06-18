unit WaybillsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, ExtCtrls, StdCtrls, DB, ADODB,

  DBRows, DBRowPredicate, DBView, Map, DBRowsSqlExec,
  DBViewConfig,

  WaybillForm
  ;

type
  // Контроллер управления путевыми листами
  TWaybillsController = class(TFrame)
    Panel1: TPanel;
    waybillsDBGrid: TDBGrid;
    refreshButton: TButton;
    newButton: TButton;
    editButton: TButton;
    deleteButton: TButton;
    waybillsDataSource: TDataSource;
    waybillsADOQuery: TADOQuery;
    procedure newButtonClick(Sender: TObject);
    procedure refreshButtonClick(Sender: TObject);
    procedure editButtonClick(Sender: TObject);
    procedure deleteButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ActivateDataView();
    procedure RefreshCurrent();
    procedure RefreshAll();
  end;

implementation

{$R *.dfm}

procedure TWaybillsController.ActivateDataView();
begin
  waybillsADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, waybillsDBGrid);
end;

procedure TWaybillsController.RefreshCurrent();
begin
  waybillsADOQuery.Refresh;
end;

procedure TWaybillsController.RefreshAll();
begin
  waybillsADOQuery.Active := false;
  waybillsADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, waybillsDBGrid);
end;

procedure TWaybillsController.newButtonClick(Sender: TObject);
var
  insertDialog : TWaybillController;
begin
  insertDialog := TWaybillController.Create(self);
  try
    if insertDialog.InsertDialog(waybillsADOQuery.Connection) then begin
      RefreshAll;

      extend(waybillsDBGrid).SelectAndFocus(
        TDataRowValueEqualsPredicate.Create('id', insertDialog.getInsertedId)
      );

      waybillsDBGrid.SetFocus;
    end
  finally
    FreeAndNil(insertDialog);
  end;
end;

procedure TWaybillsController.refreshButtonClick(Sender: TObject);
begin
  RefreshAll;
end;

procedure TWaybillsController.editButtonClick(Sender: TObject);
var
  updateDialog : TWaybillController;
  curRow: TStringMap;
begin
  curRow := TStringMap.Create;
  try
    if extend(waybillsDBGrid).GetFocusedRow(curRow) then begin
      updateDialog := TWaybillController.Create(self);
      try
        if updateDialog.updateDialog(
          self.waybillsADOQuery.Connection,
          curRow.get('id'),
          curRow.get('income_date_s'),
          curRow.get('outcome_date_s'),
          curRow.get('driver_id'),
          curRow.get('driver_name'),
          curRow.get('dispatcher_id'),
          curRow.get('dispatcher_name'),
          curRow.get('car_id'),
          curRow.get('car_model_id'),
          curRow.get('car_model_name'),
          curRow.get('car_legal_number'),
          curRow.get('wear'),
          curRow.get('fuel_cons')
        ) then begin
          refreshCurrent;
        end;
      finally;
        FreeAndNil(updateDialog);
      end;
    end;
  finally
    FreeAndNil(curRow);
  end;
end;

procedure TWaybillsController.deleteButtonClick(Sender: TObject);
var
  rows: TDBRows;
  rowDelete:  TDBRowsSqlExec;
  query: TADOQuery;
begin
  rows := TDBRows.Create;

  query := TADOQuery.Create(nil);
  query.Connection := waybillsADOQuery.Connection;
  query.SQL.Text := 'delete from waybills where [id] = :ID';

  rowDelete := TDBRowsSqlExec.Create(query);
  rowDelete.Map('id', 'id');
  try
    extend(waybillsDBGrid).fetchRows(true,false, rows.Add);
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

end.
