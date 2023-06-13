unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus, ComObj, Grids, DBGrids,

  Config, DBConfForm, ComCtrls, ExtCtrls,
  CarsModelsFrame, Map, CarsFrame, Logging;

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
    Button1: TButton;
    procedure configDBMenuItemClick(Sender: TObject);
    procedure connectToDBMenuItemClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
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


procedure TMainForm.Button1Click(Sender: TObject);
var
  query : TADOQuery;
  id: variant;
  p: TParam;
begin
  log.println('try query');
  query := TADOQuery.Create(nil);
  query.Connection := ADOMainConnection;
  try
    log.println('try set sql');

    query.Parameters.CreateParameter('M_DATE', ftVariant, pdOutput, 0, '');

    query.SQL.Text := 'insert into cars '+
      '( legal_number, model, wear, bearth_year, maintenance) '+
      //'values ( :LEG_NUM, :MODEL_ID, :WEAR, :B_YEAR,'+
      //'convert( datetime2, :MAINTENANCE_DATE, 23 ));'+
      'values ( :LEG_NUM, :MODEL_ID, :WEAR, :B_YEAR,'+
      'convert( datetime2, :M_DATE, 23 ));'+
      'select @@IDENTITY as _id';

    log.println('try set params');
    query.Parameters.ParamByName('LEG_NUM').Value := 'gosNum-b';
    query.Parameters.ParamByName('MODEL_ID').Value := 11;
    query.Parameters.ParamByName('WEAR').Value := 500;
    query.Parameters.ParamByName('B_YEAR').Value := 2020;

    query.Parameters.ParamByName('M_DATE').DataType := ftVariant;
    query.Parameters.ParamByName('M_DATE').Value := '2020-02-01';

    log.println('query open');
    query.Open;
    while not query.Eof do begin
      id := query.FieldValues['_id'];
      log.println('id: '+vartostr(id));
      query.Next;
    end;
    query.Close;
  finally
    FreeAndNil(query);
  end;
end;

end.
