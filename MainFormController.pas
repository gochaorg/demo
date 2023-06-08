unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls,

  Config;

type
  // Главное окно программы
  TMainForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TMainForm.Button1Click(Sender: TObject);
var
  conf: TConfig;
begin
  conf := TConfig.Create();
  conf.Load();
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  conf: TConfig;
begin
  conf := TConfig.Create();
  conf.Save();
end;

procedure TMainForm.SetConfig(config: TConfig);
begin
  FreeAndNil(applicationConfig);
  applicationConfig := config;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  applicationConfig := TConfig.Create();
end;

end.
