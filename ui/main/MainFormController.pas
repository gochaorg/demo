unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus, ComObj, Grids, DBGrids,

  Config, DBConfForm, ComCtrls, ExtCtrls,
  CarsModelsFrame, Map, CarsFrame,
  Logging, Loggers,
  DispatchersFrame, DriversFrame,
  WaybillsFrame;

type
  // Главное окно программы
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    configMenu: TMenuItem;
    configDBMenuItem: TMenuItem;
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
    procedure configDBMenuItemClick(Sender: TObject);
    procedure connectToDBMenuItemClick(Sender: TObject);
  public
  end;

var
  MainForm: TMainForm;

implementation

var
  log : ILog;

{$R *.dfm}


procedure TMainForm.configDBMenuItemClick(Sender: TObject);
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

initialization
log := logger('MainForm');

end.
