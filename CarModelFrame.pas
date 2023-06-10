unit CarModelFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB;

type
  TMode = (InsertMode, UpdateMode);

  // ������ ����������/���������� ������
  TCarModelController = class(TForm)
    nameEdit: TLabeledEdit;
    doButton: TButton;
    ADOQueryInsert: TADOQuery;
    ADOQueryUpdate: TADOQuery;
    procedure doButtonClick(Sender: TObject);
  private
    mode: TMode;

    connection: TADOConnection;
    insertedId: Integer;
    insertSuccessfully: Boolean;

    procedure insertData();
    procedure updateData();
  public
    // ������� ������ ��� ����������
    // ���������
    //   connection - ���������� � ����
    // ����������
    //   true - ������� ��������� ������
    //   false - �� ���������
    function insertDialog(connection: TADOConnection): Boolean;

    // ���������� id ����������� ������
    function getInsertedId(): Integer;

    // ������� ������ ��� ����������
    procedure updateDialog(connection: TADOConnection; id: Integer; name: WideString);
  end;

var
  CarModelController: TCarModelController;

implementation

{$R *.dfm}

procedure TCarModelController.doButtonClick(Sender: TObject);
begin
  if mode = InsertMode
  then
    begin
      insertData();
    end
  else
    begin
      updateData();
    end;
end;

// ���������� ������

procedure TCarModelController.insertData;
var
  insertedId : Integer;
begin
  try
    ADOQueryInsert.Close;
    ADOQueryInsert.Connection := connection;
    ADOQueryInsert.SQL.Clear;
    ADOQueryInsert.SQL.Add('insert into cars_model (name) values (:NAME);');
    ADOQueryInsert.SQL.Add('select @@IDENTITY as _id');

    ADOQueryInsert.Parameters.Clear;
    ADOQueryInsert.Parameters.CreateParameter('NAME', ftWideString, pdInput, 250, 'init');
    ADOQueryInsert.Parameters.ParamByName('NAME').Value := nameEdit.Text;

    ADOQueryInsert.Prepared := true;
    ADOQueryInsert.Open;
    while not ADOQueryInsert.Eof do begin
      insertedId := ADOQueryInsert.FieldByName('_id').AsInteger;
      ADOQueryInsert.Next;
    end;

    insertSuccessfully := true;
    Close;
  finally
    ADOQueryInsert.Close;
    ADOQueryInsert.Parameters.Clear;
    ADOQueryInsert.Connection := nil;
  end;
end;

function TCarModelController.insertDialog(connection: TADOConnection): Boolean;
begin
  result := false;

  self.mode := InsertMode;

  self.connection := connection;
  self.doButton.Caption := '��������';
  self.Caption := '�������� ������';
  self.insertSuccessfully := false;

  try
    ShowModal();
    result := self.insertSuccessfully;
  finally
    self.connection := nil;
  end;
end;

function TCarModelController.getInsertedId: Integer;
begin
  result := insertedId;
end;

// ���������� ������

procedure TCarModelController.updateData;
begin
  //
end;

procedure TCarModelController.updateDialog(connection: TADOConnection;  id: Integer; name: WideString);
begin
  self.mode := UpdateMode;

  self.connection := connection;
  self.doButton.Caption := '��������';
  self.Caption := '�������� ������';

  try
    ShowModal();
  finally
    self.connection := nil;
  end;
end;

end.
