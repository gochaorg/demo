unit DriverForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TDriverController = class(TForm)
    nameEdit: TLabeledEdit;
    birthDayEdit: TLabeledEdit;
    okButton: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DriverController: TDriverController;

implementation

{$R *.dfm}

end.
