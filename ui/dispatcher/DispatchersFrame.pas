unit DispatchersFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, Grids, DBGrids, StdCtrls, DB, ADODB;

type
  TDispatchersController = class(TFrame)
    Panel1: TPanel;
    dispatchersDBGrid: TDBGrid;
    refreshButton: TButton;
    newButton: TButton;
    editButton: TButton;
    deleteButton: TButton;
    dispatchersDataSource: TDataSource;
    dispatchersADOQuery: TADOQuery;
    procedure refreshButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TDispatchersController.refreshButtonClick(Sender: TObject);
begin
  // обновить
end;

end.
