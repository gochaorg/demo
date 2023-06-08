program AutoAccounting;

uses
  Forms,
  MainFormController in 'MainFormController.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
