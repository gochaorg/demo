unit CarsModelsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Grids, DBGrids, StdCtrls, ExtCtrls, DB, ADODB;

type
  TCarsModelsController = class(TFrame)
    _topPanel: TPanel;
    _refreshButton: TButton;
    _newButton: TButton;
    _editButton: TButton;
    _deleteButton: TButton;
    _carModelDBGrid: TDBGrid;
    _ADOTable: TADOTable;
    _DataSource: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure activateDataView();
  end;

implementation

uses
  DBView;

{$R *.dfm}

{ TCarsModelsController }

procedure TCarsModelsController.activateDataView;
begin
  _ADOTable.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, _carModelDBGrid);
  //_carModelDBGrid.Columns[2].Visible := false;
  //_carModelDBGrid.Columns[3].Visible := false;
end;

end.
