unit CarsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ExtCtrls, Grids, DBGrids, ADODB,

  DBRows, DBRowPredicate, DBView, Map, DBRowsSqlExec,
  DBViewConfig,

  CarForm
  ;

type
  TCarsController = class(TFrame)
    topPanel: TPanel;
    refreshButton: TButton;
    newButton: TButton;
    editButton: TButton;
    deleteButton: TButton;
    carsDataSource: TDataSource;
    carsDBGrid: TDBGrid;
    carsADOQuery: TADOQuery;
    procedure refreshButtonClick(Sender: TObject);
    procedure newButtonClick(Sender: TObject);
    procedure editButtonClick(Sender: TObject);
    procedure deleteButtonClick(Sender: TObject);
  private
    procedure RefreshAll();
    procedure RefreshCurrent();
  public
    procedure ActivateDataView();
  end;

implementation

{$R *.dfm}

procedure TCarsController.ActivateDataView();
begin
  carsADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, carsDBGrid);
end;

procedure TCarsController.RefreshCurrent();
begin
  carsADOQuery.Refresh;
end;

procedure TCarsController.RefreshAll();
begin
  carsADOQuery.Active := false;
  carsADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, carsDBGrid);
end;



procedure TCarsController.refreshButtonClick(Sender: TObject);
begin
  refreshAll;
end;

procedure TCarsController.newButtonClick(Sender: TObject);
var
  insertDialog : TCarController;
begin
  insertDialog := TCarController.Create(self);
  try
    if insertDialog.insertDialog(self.carsADOQuery.Connection) then
    begin
      refreshAll;

      extend(carsDBGrid).SelectAndFocus(
        TDataRowValueEqualsPredicate.Create('id', insertDialog.getInsertedId)
      );

      carsDBGrid.SetFocus;
    end;
  finally
    FreeAndNil(insertDialog);
  end;
end;

procedure TCarsController.editButtonClick(Sender: TObject);
var
  updateDialog : TCarController;
  curRow: TStringMap;
begin
  curRow := TStringMap.Create;
  try
    if extend(carsDBGrid).GetFocusedRow(curRow) then begin
      updateDialog := TCarController.Create(self);
      try
        if updateDialog.updateDialog(
          self.carsADOQuery.Connection,
          curRow.get('id'),
          curRow.get('legal_number'),
          curRow.get('model_id'),
          curRow.get('wear'),
          curRow.get('birth_year'),
          curRow.get('maintenance'),
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

procedure TCarsController.deleteButtonClick(Sender: TObject);
var
  rows: TDBRows;
  rowDelete:  TDBRowsSqlExec;
  query: TADOQuery;
begin
  rows := TDBRows.Create;

  query := TADOQuery.Create(nil);
  query.Connection := carsADOQuery.Connection;
  query.SQL.Text := 'delete from cars where [id] = :ID';

  rowDelete := TDBRowsSqlExec.Create(query);
  rowDelete.Map('id', 'id');
  try
    extend(carsDBGrid).fetchRows(true,false, rows.Add);
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
