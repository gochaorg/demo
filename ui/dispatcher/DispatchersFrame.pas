unit DispatchersFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, Grids, DBGrids, StdCtrls, DB, ADODB,

  DBRows, DBRowPredicate, DBView, Map, DBRowsSqlExec,
  DBViewConfig
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
begin
  // 
end;

procedure TDispatchersController.editButtonClick(Sender: TObject);
begin
  //
end;

procedure TDispatchersController.deleteButtonClick(Sender: TObject);
begin
  //
end;

end.
