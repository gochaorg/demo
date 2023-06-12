unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus, ComObj,

  Config, DBConfForm, ComCtrls, ExtCtrls, Grids, DBGrids,
  CarsModelsFrame, Map, CarsFrame;

type
  // Главное окно программы
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    configMenu: TMenuItem;
    configDBMenuItem: TMenuItem;
    dbConnectMenu: TMenuItem;
    connectToDBMenuItem: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    ADOMainConnection: TADOConnection;
    carsModelsController: TCarsModelsController;
    carsController: TCarsController;
    procedure configDBMenuItemClick(Sender: TObject);
    procedure connectToDBMenuItemClick(Sender: TObject);
  public
  end;

var
  MainForm: TMainForm;

implementation


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
  try
    ADOMainConnection.Open(applicationConfigItf.dbUsername, applicationConfigItf.dbPassword);
    carsModelsController.activateDataView();
    carsController.activateDataView();
  except
    on e: EOleException do begin
      ShowMessage('Ошибка соединения:'+e.Message);
    end;
  end;
end;


end.
