unit DbConfForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Config, ComObj;

type
  TDbConfController = class(TForm)
    passwordEdit: TEdit;
    passwordLabel: TLabel;
    userNameEdit: TLabeledEdit;
    connectionStringEdit: TLabeledEdit;
    testConnectionButton: TButton;
    applyButton: TButton;
    closeButton: TButton;
    ADOConnectionTest: TADOConnection;
    procedure testConnectionButtonClick(Sender: TObject);
  private
    conf: TConfig;
  public
    { Public declarations }
    procedure edit( conf:TConfig );
  end;

var
  DbConfController: TDbConfController;

implementation

{$R *.dfm}

{ TDbConfController }

procedure TDbConfController.edit(conf: TConfig);
begin
  self.conf := conf;
  userNameEdit.Text := conf.dbUserName;
  connectionStringEdit.Text := conf.dbConnectionString;
  passwordEdit.Text := conf.dbPassword;
  ShowModal();
  self.conf := nil;
end;

procedure TDbConfController.testConnectionButtonClick(Sender: TObject);
var
  conf: TConfig;
begin
  ADOConnectionTest.ConnectionString := connectionStringEdit.Text;
  try
    ADOConnectionTest.Open(userNameEdit.Text, passwordEdit.Text);
    if ADOConnectionTest.Connected then ShowMessage('Соединение установлено');
    ADOConnectionTest.Close();
  except
    on e: EOleException do begin
      ShowMessage('Ошибка соединения:'+e.Message);
    end;
  end;
end;

end.
