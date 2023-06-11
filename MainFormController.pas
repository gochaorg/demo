unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus, ComObj,

  Config, DBConfForm, ComCtrls, ExtCtrls, Grids, DBGrids, AutoFrame,
  CarsModelsFrame, Map;

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
    test1: TMenuItem;
    test2: TMenuItem;
    procedure configDBMenuItemClick(Sender: TObject);
    procedure connectToDBMenuItemClick(Sender: TObject);
    procedure test2Click(Sender: TObject);
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
  except
    on e: EOleException do begin
      ShowMessage('Ошибка соединения:'+e.Message);
    end;
  end;
end;

// todo delete
procedure TMainForm.test2Click(Sender: TObject);
var
  imap: IStringMap;
begin
  imap := TStringMap.Create;
  imap.put('a', 1);
  imap.put('b', 'aaaa');
  imap.put('c', 'bbbb');
  imap.put('d', 'dddd');
  imap.put('e', 'eeeeeeeeeeeeeeeeeeeeeeeeeeeee');
  imap.put('f', 'ffffffffffffffffffffffffffffff');
  ShowMessage(imap.toString);
end;

end.
