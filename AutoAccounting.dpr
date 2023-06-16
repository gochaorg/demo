program AutoAccounting;

uses
  Forms,
  Dialogs,
  Config in 'Config.pas',
  Logging in 'Logging.pas',
  DBView in 'DBView.pas',
  Map in 'Map.pas',
  DBRows in 'DBRows.pas',
  DBRowPredicate in 'DBRowPredicate.pas',
  DBRowsLogger in 'DBRowsLogger.pas',
  DBRowsSqlExec in 'DBRowsSqlExec.pas',
  DBViewConfig in 'DBViewConfig.pas',
  DbConfForm in 'ui\dbConf\DbConfForm.pas' {DbConfController},
  CarsFrame in 'ui\cars\CarsFrame.pas' {CarsController: TFrame},
  CarsModelsFrame in 'ui\carsModel\CarsModelsFrame.pas' {CarsModelsController: TFrame},
  CarModelFrame in 'ui\carsModel\CarModelFrame.pas' {CarModelController},
  MainFormController in 'ui\main\MainFormController.pas' {MainForm},
  CarForm in 'ui\cars\CarForm.pas' {CarController},
  MyDate in 'ui\cars\MyDate.pas',
  CarSQL in 'ui\cars\CarSQL.pas',
  DMLOperation in 'db\DMLOperation.pas',
  Validation in 'validate\Validation.pas',
  DispatchersFrame in 'ui\dispatcher\DispatchersFrame.pas' {DispatchersController: TFrame},
  DriversFrame in 'ui\drivers\DriversFrame.pas' {DriversController: TFrame},
  WaybillsFrame in 'ui\waybills\WaybillsFrame.pas' {waybillsController: TFrame},
  DriverForm in 'ui\drivers\DriverForm.pas' {DriverController},
  DriverSQL in 'ui\drivers\DriverSQL.pas',
  IntegerList in 'IntegerList.pas',
  DispatcherSQL in 'ui\dispatcher\DispatcherSQL.pas',
  DispatcherForm in 'ui\dispatcher\DispatcherForm.pas' {DispatcherController},
  WaybillForm in 'ui\waybills\WaybillForm.pas' {WaybillController};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TWaybillController, WaybillController);
  try
    applicationConfigObj.Load();
  except
    on e: EConfigLoad do begin
      ShowMessage('can''t read config: ' + e.Message);
    end;
  end;

  Application.Run;
end.
