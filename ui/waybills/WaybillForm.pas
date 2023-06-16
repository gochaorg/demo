unit WaybillForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ADODB;

type
  // Режим InsertMode / UpdateMode
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
    // Режим InsertMode / UpdateMode
    mode: TMode;

    connection: TADOConnection;

    insertedId: Integer;
    updatingId: Integer;

    insertSuccessfully: Boolean;
    updateSuccessfully: Boolean;

    // Валидация и построение SQL
  public
    // Открыть диалог для добавления
    // Аргументы
    //   connection - соединение с СУБД
    // Возвращает
    //   true - успешно добавлена запись
    //   false - не добавлена
    function InsertDialog(connection: TADOConnection): Boolean;

    // Возвращает id добавленной записи
    function GetInsertedId(): Integer;

    // Открыть диалог для обновления
    // Аргументы
    //   connection - соединение с СУБД
    //   id - идентификатор записи
    //   name - Имя
    //   birthDate - Дата рождения
    // Возвращает
    //   true - успено обновлена запись
    //   false - ошибка
    function UpdateDialog(
      connection: TADOConnection;
      id: Integer;
      incomeDate:  TDateTime;
      outcomeDate: TDateTime;
      driverId: Integer;
      driverName: WideString;
      dispatcherId: Integer;
      dispatcherName: WideString;
      carId: Integer;
      carModelId: Integer;
      carModelName: WideString;
      carLegalNumber: WideString;
      wear: Integer;
      fuelCons: Integer;
    ): Boolean;
  end;

var
  WaybillController: TWaybillController;

implementation

{$R *.dfm}

function TWaybillController.GetInsertedId: Integer;
begin
  result := self.insertedId;
end;

function TWaybillController.InsertDialog(
  connection: TADOConnection): Boolean;
begin
  result := false;
end;

procedure TWaybillController.okButtonClick(Sender: TObject);
begin
  //
end;

function TWaybillController.UpdateDialog(
  connection: TADOConnection;
  id: Integer; name, birthDate: WideString
): Boolean;
begin
  result := false;
end;

end.
