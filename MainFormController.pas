unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus, ComObj,

  Config, DBConfForm, ComCtrls, ExtCtrls, Grids, DBGrids, AutoFrame,
  CarsModelsFrame;

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
    TFrame11: TAutoController;
    carsModelsController: TCarsModelsController;
    procedure configDBMenuItemClick(Sender: TObject);
    procedure connectToDBMenuItemClick(Sender: TObject);
    procedure refreshAutoModelButtonClick(Sender: TObject);
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
    carsModelsController.ADOTable1.Active := true;
    carsModelsController.carModelDBGrid.Columns[3].Visible := false;
    carsModelsController.carModelDBGrid.Columns[2].Visible := false;
    carsModelsController.carModelDBGrid.Columns[1].Width := 500;
  except
    on e: EOleException do begin
      ShowMessage('Ошибка соединения:'+e.Message);
    end;
  end;
end;

procedure TMainForm.refreshAutoModelButtonClick(Sender: TObject);
begin
  // autoModelDataSource.
end;

end.
