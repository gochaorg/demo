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
    _DataSource: TDataSource;
    ADOQuery1: TADOQuery;
    procedure _refreshButtonClick(Sender: TObject);
    procedure _carModelDBGridTitleClick(Column: TColumn);
  private
    sort: Integer;
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
  //_ADOTable.Active := true;
  ADOQuery1.Active := true;
  dbViewPreparer.prepareGrid(Self.ClassName, _carModelDBGrid);
  sort := 0;
end;

procedure TCarsModelsController._refreshButtonClick(Sender: TObject);
begin
  //_ADOTable.Refresh();
  ADOQuery1.Refresh();
end;

procedure TCarsModelsController._carModelDBGridTitleClick(Column: TColumn);
begin
//  if sort = 0 then
//    begin sort := 1; end
//  else
//    begin
//      if sort = 1 then
//        begin sort := -1
//    end;

  //_ADOTable.Sort := 'name desc';
  ADOQuery1.Active := false;
  ADOQuery1.SQL.Clear();
  ADOQuery1.SQL.Add('select * from cars_model order by name desc');
  ADOQuery1.Active := true;
end;

end.
