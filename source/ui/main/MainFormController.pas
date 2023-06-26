unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus, ComObj, Grids, DBGrids,
  ComCtrls, ExtCtrls,

  CarsModelsFrame, CarsFrame, DispatchersFrame, DriversFrame,
  WaybillsFrame,

  OfficeExport,
  DBView, DBRows,
  Config, DBConfForm,
  Map, Logging, Loggers;

type
  // ������� ���� ���������
  // �������� 5 ��������� �������
  //   ������� �����
  //   ��������
  //   ����������
  //   ������
  //   ������ �����
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
    waybillsWordExport: TMenuItem;

    // ���������� ���������� � ����
    procedure connectToDBMenuItemClick(Sender: TObject);

    // ��������� �����������
    procedure dbConnectConfigClick(Sender: TObject);

    // ������� ������� ������ � Excel
    procedure waybillsExcelExportClick(Sender: TObject);

    // ������� ������� ������ � Word
    procedure waybillsWordExportClick(Sender: TObject);
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

    waybillsMenu.Enabled := true;

    log.println('Connected');
  except
    on e: EOleException do begin
      ShowMessage('������ ����������:'+e.Message);
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
begin
  try
    excelExporter.doExport(
      extend(waybillsController.waybillsDBGrid).GetDBRows
    );
  except
    on e:EOleException do begin
      log.println('! ������ �������� Excel: '+e.Message);
    end;
  end;
end;

procedure TMainForm.waybillsWordExportClick(Sender: TObject);
begin
  try
    wordExporter.doExport(
      extend(waybillsController.waybillsDBGrid).GetDBRows
    );
  except
    on e:EOleException do begin
      log.println('! ������ �������� Word: '+e.Message);
    end;
  end;
end;

initialization
log := logger('MainForm');

end.
