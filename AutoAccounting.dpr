program AutoAccounting;

uses
  Forms,
  Config in 'Config.pas',
  Dialogs,
  DbConfForm in 'DbConfForm.pas' {DbConfController},
  Logging in 'Logging.pas',
  DBView in 'DBView.pas',
  Map in 'Map.pas',
  DBRows in 'DBRows.pas',
  DBRowPredicate in 'DBRowPredicate.pas',
  DBRowsLogger in 'DBRowsLogger.pas',
  DBRowsSqlExec in 'DBRowsSqlExec.pas',
  DBViewConfig in 'DBViewConfig.pas',
  AutoFrame in 'ui\cars\AutoFrame.pas' {AutoController: TFrame},
  CarsModelsFrame in 'ui\carsModel\CarsModelsFrame.pas' {CarsModelsController: TFrame},
  CarModelFrame in 'ui\carsModel\CarModelFrame.pas' {CarModelController},
  MainFormController in 'ui\main\MainFormController.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  //Application.CreateForm(TCarModelController, CarModelController);
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
