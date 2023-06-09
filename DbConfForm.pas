unit DbConfForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TDbConfController = class(TForm)
    passwordEdit: TEdit;
    passwordLabel: TLabel;
    userNameEdit: TLabeledEdit;
    connectionStringEdit: TLabeledEdit;
    testConnectionButton: TButton;
    applyButton: TButton;
    closeButton: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DbConfController: TDbConfController;

implementation

{$R *.dfm}

end.
