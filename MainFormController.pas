unit MainFormController;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Menus,

  Config, DBConfForm;

type
  // Главное окно программы
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    configMenu: TMenuItem;
    configDBMenuItem: TMenuItem;
    procedure configDBMenuItemClick(Sender: TObject);
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
    ShowMessage('ref count after ' +
      IntToStr(applicationConfigObj.getRefCount())
    );
    conf.edit(applicationConfigItf, applicationConfigSaveItf);
    ShowMessage('ref count after ' +
      IntToStr(applicationConfigObj.getRefCount())
    );
  finally
    FreeAndNil(conf);
  end;
end;

end.
