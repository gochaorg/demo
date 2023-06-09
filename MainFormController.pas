unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus,

  Config, DBConfForm;

type
  // Главное окно программы
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    configMenu: TMenuItem;
    configDBMenuItem: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure configDBMenuItemClick(Sender: TObject);
  private
    applicationConfig: TConfig;
  public
    // Указывает конфигурацию приложения
    procedure SetConfig( config: TConfig );
  end;

var
  MainForm: TMainForm;

implementation


{$R *.dfm}

procedure TMainForm.SetConfig(config: TConfig);
begin
  FreeAndNil(applicationConfig);
  applicationConfig := config;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  applicationConfig := TConfig.Create();
end;

procedure TMainForm.configDBMenuItemClick(Sender: TObject);
var
  conf: TDBConfController;
begin
  conf := TDBConfController.Create(self);
  try
    conf.edit(applicationConfig);
  finally
    FreeAndNil(conf);
  end;
end;

end.
