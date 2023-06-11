program AutoAccounting;

uses
  Forms,
  MainFormController in 'MainFormController.pas' {MainForm},
  Config in 'Config.pas',
  Dialogs,
  DbConfForm in 'DbConfForm.pas' {DbConfController},
  Logging in 'Logging.pas',
  AutoFrame in 'AutoFrame.pas' {AutoController: TFrame},
  CarsModelsFrame in 'CarsModelsFrame.pas' {CarsModelsController: TFrame},
  DBView in 'DBView.pas',
  CarModelFrame in 'CarModelFrame.pas' {CarModelController},
  Map in 'Map.pas',
  DBRows in 'DBRows.pas',
  DBRowPredicate in 'DBRowPredicate.pas',
  DBRowsLogger in 'DBRowsLogger.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TCarModelController, CarModelController);
  try
    applicationConfigObj.Load();
  except
    on e: EConfigLoad do begin
      ShowMessage('can''t read config: ' + e.Message);
    end;
  end;

  Application.Run;
end.
