program AutoAccounting;

uses
  Forms,
  MainFormController in 'MainFormController.pas' {MainForm},
  Config in 'Config.pas',
  Dialogs,
  DbConfForm in 'DbConfForm.pas' {DbConfController},
  Log in 'Log.pas',
  AutoFrame in 'AutoFrame.pas' {AutoController: TFrame},
  CarsModelsFrame in 'CarsModelsFrame.pas' {CarsModelsController: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  try
    applicationConfigObj.Load();
  except
    on e: EConfigLoad do begin
      ShowMessage('can''t read config: ' + e.Message);
    end;
  end;

  Application.Run;
end.
