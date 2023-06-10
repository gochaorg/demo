unit CarsModelsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Grids, DBGrids, StdCtrls, ExtCtrls, DB, ADODB,

  CarModelFrame;

type
  // Визуальныей элемент - список/таблица моделей авто
  // Задачи
  //   - Просмотр
  //     - Сортировка по полям
  //     - Фильтрация по полям
  //   - Добавление модели
  //   - Редактирование модели
  //   - Удаление модели
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
    procedure _newButtonClick(Sender: TObject);
    procedure _editButtonClick(Sender: TObject);
  private
    procedure refreshAll();
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
end;

procedure TCarsModelsController._refreshButtonClick(Sender: TObject);
begin
  refreshAll;
end;

procedure TCarsModelsController._carModelDBGridTitleClick(Column: TColumn);
begin
  ADOQuery1.Active := false;
  ADOQuery1.SQL.Clear();
  ADOQuery1.SQL.Add('select * from cars_model order by name desc');
  ADOQuery1.Active := true;
end;

procedure TCarsModelsController._newButtonClick(Sender: TObject);
var
  insertDialog : TCarModelController;
begin
  insertDialog := TCarModelController.Create(self);
  try
    if insertDialog.insertDialog( ADOQuery1.Connection ) then begin
      refreshAll;
    end;
  finally
    freeAndNil(insertDialog);
  end;
end;

procedure TCarsModelsController._editButtonClick(Sender: TObject);
var
  id : variant;
  id_int : Integer;
  name : variant;
  updateDialog : TCarModelController;
begin
  id := _carModelDBGrid.Fields[0].Value;
  name := _carModelDBGrid.Fields[1].Value;
  id_int := StrToInt(VarToStr(id));

  updateDialog := TCarModelController.Create(self);
  try
    if updateDialog.updateDialog(
      ADOQuery1.Connection, id_int, varToWideStr(name) ) then begin
      refreshAll;
    end;
  finally
    FreeAndNil(updateDialog);
  end;
end;

procedure TCarsModelsController.refreshAll;
begin
  ADOQuery1.Refresh;
end;

end.
