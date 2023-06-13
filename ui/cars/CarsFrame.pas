unit CarsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ExtCtrls, Grids, DBGrids, ADODB,

  DBRows, DBRowPredicate, DBView, Map,
  CarForm,
  DBViewConfig;

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
    procedure refreshAll();
    procedure refreshCurrent();
  public
    procedure activateDataView();
  end;

implementation

{$R *.dfm}

procedure TCarsController.activateDataView();
begin
  carsADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, carsDBGrid);
end;

procedure TCarsController.refreshCurrent();
begin
  carsADOQuery.Refresh;
end;

procedure TCarsController.refreshAll();
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
begin
 //
end;

end.
