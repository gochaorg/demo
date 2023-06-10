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
  private
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
  //ADOQuery1.Active := false;
  //ADOQuery1.Active := true;
  ADOQuery1.Refresh;
end;

procedure TCarsModelsController._carModelDBGridTitleClick(Column: TColumn);
begin
  //_ADOTable.Sort := 'name desc';
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
    insertDialog.insertDialog( ADOQuery1.Connection );
  finally
    freeAndNil(insertDialog);
  end;
end;

end.
