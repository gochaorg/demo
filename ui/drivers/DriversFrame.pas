unit DriversFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, ExtCtrls, StdCtrls, DB, ADODB,

  DBRows, DBRowPredicate, DBView, Map, DBRowsSqlExec,
  DBViewConfig,

  DriverForm
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
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ActivateDataView();
    procedure RefreshCurrent();
    procedure RefreshAll();
  end;

implementation

{$R *.dfm}

procedure TDriversController.ActivateDataView();
begin
  driversADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, driversDBGrid);
end;

procedure TDriversController.RefreshCurrent();
begin
  driversDBGrid.Refresh;
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

end.
