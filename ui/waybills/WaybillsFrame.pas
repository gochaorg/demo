unit WaybillsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, ExtCtrls, StdCtrls, DB, ADODB,

  DBRows, DBRowPredicate, DBView, Map, DBRowsSqlExec,
  DBViewConfig, 

  WaybillForm, WaybillSQLView,
  Loggers, Logging
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
    showHistoryCheckBox: TCheckBox;
    procedure newButtonClick(Sender: TObject);
    procedure refreshButtonClick(Sender: TObject);
    procedure editButtonClick(Sender: TObject);
    procedure deleteButtonClick(Sender: TObject);
    procedure showHistoryCheckBoxClick(Sender: TObject);
    procedure waybillsDBGridDrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
  private
    queryBuilderValue: IWaybillsQueryBuilder;
    function queryBuilder: IWaybillsQueryBuilder;

    function isActivated: boolean;
    procedure RebuildQuery();
  public
    procedure ActivateDataView();
    procedure RefreshCurrent();
    procedure RefreshAll();
  end;

implementation

var
log : ILog;

{$R *.dfm}

procedure TWaybillsController.ActivateDataView();
begin
  waybillsADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, waybillsDBGrid);

  refreshButton.Enabled := true;
  newButton.Enabled := true;
  editButton.Enabled := true;
  deleteButton.Enabled := true;
  showHistoryCheckBox.Enabled := true;
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
      if curRow.get('state') = 'actual' then begin
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
            curRow.get('car_total_wear'),
            curRow.get('wear'),
            curRow.get('fuel_cons')
          ) then begin
            refreshCurrent;
          end;
        finally;
          FreeAndNil(updateDialog);
        end;
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
    rows.Retain(TDataRowValueEqualsPredicate.Create('state', 'actual'));
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

procedure TWaybillsController.showHistoryCheckBoxClick(Sender: TObject);
begin
  self.rebuildQuery;
end;

procedure TWaybillsController.RebuildQuery;
begin
  queryBuilder.history := showHistoryCheckBox.Checked;
  if self.isActivated then begin
    queryBuilder.build.apply(waybillsADOQuery);
    dbViewPreparer.prepareGrid(Self.ClassName, waybillsDBGrid);
  end;
end;

function TWaybillsController.isActivated: boolean;
begin
  result := waybillsADOQuery.Active;
end;

function TWaybillsController.queryBuilder: IWaybillsQueryBuilder;
begin
  if assigned(self.queryBuilderValue) then begin
    result := self.queryBuilderValue;
  end else begin
    self.queryBuilderValue := TWaybillsQueryBuilder.Create;
    result := self.queryBuilderValue;
  end;
end;

procedure TWaybillsController.waybillsDBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  isActual : boolean;
  row: TStringMap;

  bgHistColor: TColor;
  bgHistSelectedColor: TColor;
  bgHistFocusedColor: TColor;

  fgHistColor: TColor;
  fgHistSelectedColor: TColor;
  fgHistFocusedColor: TColor;

  bgColor: TColor;
  fgColor: TColor;
begin
  fgColor := TColor($00000000);
  bgColor := TColor($00ffFFff);

  bgHistColor := TColor($00bbFFbb);
  fgHistColor := TColor($00000000);

  bgHistSelectedColor := TColor($0088FF88);
  fgHistSelectedColor := TColor($00000000);

  bgHistFocusedColor := TColor($0000bb00);
  fgHistFocusedColor := TColor($00ffFFff);

  row := TStringMap.Create;
  try
    if extend(waybillsDBGrid).GetCurrentRow(row) then begin
      if row.get('state') = 'hist'
      then begin
        fgColor := fgHistColor;
        bgColor := bgHistColor;

        if gdSelected in state then begin
          bgColor := bgHistSelectedColor;
          fgColor := fgHistSelectedColor;
        end;

        if gdFocused in state then begin
          bgColor := bgHistFocusedColor;
          fgColor := fgHistFocusedColor;
        end;

        waybillsDBGrid.Canvas.Brush.Color := bgColor;
        waybillsDBGrid.Canvas.Font.Color := fgColor;
        waybillsDBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
      end;
    end;
  finally
    FreeAndNil(row);
  end;
end;

initialization
log := logger('WaybillsFrame');

end.
