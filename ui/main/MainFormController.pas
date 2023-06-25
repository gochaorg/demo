unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus, ComObj, Grids, DBGrids,
  ComCtrls,

  DBView, DBRows,
  CarsModelsFrame, CarsFrame, DispatchersFrame, DriversFrame,
  WaybillsFrame,

  Config, DBConfForm, ExtCtrls,
  Map,
  Logging, Loggers;

type
  // Главное окно программы
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    dbConnectMenu: TMenuItem;
    connectToDBMenuItem: TMenuItem;
    PageControl1: TPageControl;
    waybillsTabSheet: TTabSheet;
    driversTabSheet: TTabSheet;
    dispatchersTabSheet: TTabSheet;
    carsTabSheet: TTabSheet;
    carsModelTabSheet: TTabSheet;
    ADOMainConnection: TADOConnection;
    carsModelsController: TCarsModelsController;
    carsController: TCarsController;
    dispatchersController: TDispatchersController;
    driversController: TDriversController;
    waybillsController: TwaybillsController;
    waybillsMenu: TMenuItem;
    dbConnectConfig: TMenuItem;
    waybillsExcelExport: TMenuItem;
    procedure connectToDBMenuItemClick(Sender: TObject);
    procedure dbConnectConfigClick(Sender: TObject);
    procedure waybillsExcelExportClick(Sender: TObject);
  public
  end;

var
  MainForm: TMainForm;

implementation

var
  log : ILog;

{$R *.dfm}


procedure TMainForm.connectToDBMenuItemClick(Sender: TObject);
begin
  log.println('Connect to db');
  try
    ADOMainConnection.Open(applicationConfigItf.dbUsername, applicationConfigItf.dbPassword);
    carsModelsController.ActivateDataView;
    carsController.ActivateDataView;
    dispatchersController.ActivateDataView;
    driversController.ActivateDataView;
    waybillsController.ActivateDataView;
    log.println('Connected');
  except
    on e: EOleException do begin
      ShowMessage('Ошибка соединения:'+e.Message);
    end;
  end;
end;

procedure TMainForm.dbConnectConfigClick(Sender: TObject);
var
  conf: TDBConfController;
begin
  conf := TDBConfController.Create(self);
  try
    conf.edit(applicationConfigItf, applicationConfigSaveItf);
  finally
    FreeAndNil(conf);
  end;
end;

procedure TMainForm.waybillsExcelExportClick(Sender: TObject);
var
  rows: IDBRows;
  col: TDBRowColumn;
  row: TStringMap;
  i: Integer;
begin
  log.println('waybillsExcelExportClick');
  rows := extend(waybillsController.waybillsDBGrid).GetDBRows;

  log.println('columns count='+IntToStr(rows.GetColumnsCount));
  for i:=0 to rows.GetColumnsCount-1 do begin
    if rows.GetColumn(i,col) then begin
      log.println('col#'+IntToStr(i)+' name='+col.Name+' title='+col.Title);
    end;
  end;

  log.println('rows count='+IntToStr(rows.GetCount));
  for i:=0 to rows.GetCount-1 do begin
    if rows.GetItem(i,row) then begin
      log.println( 'row#'+IntToStr(i)+' '+row.toString );
    end;
  end;
end;

initialization
log := logger('MainForm');

end.
