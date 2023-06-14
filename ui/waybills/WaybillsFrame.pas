unit WaybillsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Grids, DBGrids, ExtCtrls, StdCtrls, DB, ADODB,

  DBRows, DBRowPredicate, DBView, Map, DBRowsSqlExec,
  DBViewConfig
  ;

type
  TWaybillsController = class(TFrame)
    Panel1: TPanel;
    waybillsDBGrid: TDBGrid;
    refreshButton: TButton;
    newButton: TButton;
    editButton: TButton;
    deleteButton: TButton;
    waybillsDataSource: TDataSource;
    waybillsADOQuery: TADOQuery;
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
  waybillsDBGrid.Refresh;
end;

procedure TWaybillsController.RefreshAll();
begin
  waybillsADOQuery.Active := false;
  waybillsADOQuery.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, waybillsDBGrid);
end;

end.
