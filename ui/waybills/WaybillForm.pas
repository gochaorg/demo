unit WaybillForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TMode = (InsertMode, UpdateMode);

  TWaybillController = class(TForm)
    outcomeDatetimeEdit: TLabeledEdit;
    incomeDatetimeEdit: TLabeledEdit;
    Panel1: TPanel;
    dispatcherGroupBox: TGroupBox;
    Splitter1: TSplitter;
    driverGroupBox: TGroupBox;
    dispatchersListBox: TListBox;
    driversListBox: TListBox;
    carGroupBox: TGroupBox;
    carEdit: TEdit;
    carsListBox: TListBox;
    carFindButton: TButton;
    wearEdit: TLabeledEdit;
    fuelConsEdit: TLabeledEdit;
    okButton: TButton;
    dispatcherPanel: TPanel;
    dispatcherFindButton: TButton;
    dispatcherEdit: TEdit;
    driverFindPanel: TPanel;
    driverFindButton: TButton;
    driverEdit: TEdit;
    procedure okButtonClick(Sender: TObject);
  private
    mode: TMode;
  public
    { Public declarations }
  end;

var
  WaybillController: TWaybillController;

implementation

{$R *.dfm}

procedure TWaybillController.okButtonClick(Sender: TObject);
begin
  //
end;

end.
