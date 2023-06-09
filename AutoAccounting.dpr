program AutoAccounting;

uses
  Forms,
  MainFormController in 'MainFormController.pas' {MainForm},
  Config in 'Config.pas',
  Dialogs,
  DbConfForm in 'DbConfForm.pas' {DbConfController};

{$R *.res}

var
  applicationConfig: TConfig;
begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  //Application.CreateForm(TDbConfController, DbConfController);
  try
    applicationConfig := TConfig.Create();
    applicationConfig.Load();
    MainForm.SetConfig( applicationConfig );
  except
    on e: EConfigLoad do begin
      ShowMessage('can''t read config: ' + e.Message);
      MainForm.SetConfig( TConfig.Create() );
    end;
  end;

  Application.Run;
end.
