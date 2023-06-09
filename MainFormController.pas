unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus,

  Config, DBConfForm, ComCtrls, ExtCtrls, Grids, DBGrids;

type
  // ������� ���� ���������
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
    ADOConnection1: TADOConnection;
    autoModelDBGrid: TDBGrid;
    Panel1: TPanel;
    autoModelDataSource: TDataSource;
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
 //
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  // autoModelDataSource.
end;

end.
