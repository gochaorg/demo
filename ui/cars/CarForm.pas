unit CarForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,

  ADODB, ComObj, DB, Logging, MyDate, CarSql, DMLOperation;

type
  TMode = (InsertMode, UpdateMode);

  // Диалог добавления/обновления машины
  TCarController = class(TForm)
    legalNumberEdit: TLabeledEdit;
    modelListBox: TListBox;
    leagalNumLabel: TLabel;
    wearEdit: TLabeledEdit;
    birthYearEdit: TLabeledEdit;
    maintainceEdit: TLabeledEdit;
    okButton: TButton;
    insertADOQuery: TADOQuery;
    updateADOQuery: TADOQuery;
    carsModelADOQuery: TADOQuery;
    errLabel: TLabel;
    procedure okButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    mode: TMode;

    connection: TADOConnection;
    insertedId: Integer;
    updatingId: Integer;
    insertSuccessfully: Boolean;
    updateSuccessfully: Boolean;
  private
    procedure clearCarsModelListbox();
    procedure insertData();
    procedure updateData();
    procedure setConnection( connection: TADOConnection );
    procedure refreshModelList();
    procedure validateInput(Sender: TObject);
    function validate():boolean;
  public
    // Открыть диалог для добавления
    // Аргументы
    //   connection - соединение с СУБД
    // Возвращает
    //   true - успешно добавлена запись
    //   false - не добавлена
    function insertDialog(connection: TADOConnection): Boolean;

    // Возвращает id добавленной записи
    function getInsertedId(): Integer;

    // Открыть диалог для обновления
    // Возвращает
    //   true - успено обновлена запись
    //   false - ошибка
    function updateDialog(connection: TADOConnection; id: Integer; name: WideString): Boolean;
  end;

var
  CarController: TCarController;

implementation

type
  TCarModelInfo = class(TObject)
    public
      name: variant;
      id: variant;
  end;

{$R *.dfm}

{ TCarController }

function TCarController.getInsertedId: Integer;
begin
  result := self.insertedId;
end;

procedure TCarController.insertData;
var
  builder: ICarDataBuilder;
  modelInfo: TCarModelInfo;
  dmlOp: IDMLOperation;
  id: Variant;
begin
  builder := TCarDataBuilder.Create;
  builder.setLegalNumber(legalNumberEdit.Text);

  modelInfo := modelListBox.Items.Objects[ modelListBox.ItemIndex ] as TCarModelInfo;
  builder.setModelId(modelInfo.id);

  builder.setWear(wearEdit.Text);
  builder.setBirthYear(birthYearEdit.Text);
  builder.setMaintainceDate(maintainceEdit.Text);

  //dmlOp := builder.buildInsert;
  //id := dmlOp.Run( self.insertADOQuery );

  //self.insertedId := id;
  //self.insertSuccessfully := true;
  //Close;
end;

function TCarController.insertDialog(connection: TADOConnection): Boolean;
begin
  self.setConnection(connection);
  self.mode := InsertMode;
  self.Caption := 'Добавление машины';
  self.okButton.Caption := 'Добавить';
  self.insertSuccessfully := false;
  try
    refreshModelList;
    validateInput(self);
    ShowModal;
  finally
    self.setConnection(nil);
  end;
end;

procedure TCarController.updateData;
begin

end;

function TCarController.updateDialog(connection: TADOConnection;
  id: Integer; name: WideString): Boolean;
begin
  self.setConnection(connection);
  self.mode := UpdateMode;
  self.Caption := 'Обновление машины';
  self.okButton.Caption := 'обновить';
  self.updateSuccessfully := false;
  try
    refreshModelList;
    ShowModal;
  finally
    self.setConnection(nil);
  end;
end;

procedure TCarController.okButtonClick(Sender: TObject);
begin
  if validate then
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
end;

procedure TCarController.refreshModelList;
var
  model: TCarModelInfo;
begin
  clearCarsModelListbox;
  try
    try
      log.println('try refreshModelList');

      self.carsModelADOQuery.Open;
      self.carsModelADOQuery.First;
      while not self.carsModelADOQuery.Eof do begin
        model := TCarModelInfo.Create;

        model.name :=
          self.carsModelADOQuery.FieldByName('name').Value;

        model.id :=
          self.carsModelADOQuery.FieldByName('id').Value;

        self.modelListBox.Items.AddObject(
          VarToStr(model.name),
          model
        );
        self.carsModelADOQuery.Next;
      end;
    except
      on e:EOleException do begin
        log.println('got error: '+e.Message);
        ShowMessage('Ощибка при обновлении списка моделей '+e.Message);
      end;
    end;
  finally
    self.carsModelADOQuery.Close;
  end;
end;

procedure TCarController.setConnection(connection: TADOConnection);
begin
  self.connection := connection;
  self.insertADOQuery.Connection := connection;
  self.updateADOQuery.Connection := connection;
  self.carsModelADOQuery.Connection := connection;
end;

procedure TCarController.FormDestroy(Sender: TObject);
begin
  clearCarsModelListbox;
end;

procedure TCarController.clearCarsModelListbox;
var
  i : Integer;
begin
  for i:=0 to self.modelListBox.Items.Count-1 do begin
    self.modelListBox.Items.Objects[i].Destroy;
  end;
  self.modelListBox.Items.Clear;
end;

procedure TCarController.validateInput(Sender: TObject);
begin
  validate;
end;

function TCarController.validate: boolean;
  procedure ok;
  begin
    errLabel.Caption := '';
    okButton.Enabled := true;
    validate := true;
  end;

  procedure err(messageText:WideString);
  begin
    errLabel.Caption := messageText;
    okButton.Enabled := false;
    validate := false;
  end;
var
  wearNum:Integer;
  birthYearNum:Integer;
  maintainceDate: TMyDateParsed;
begin
  ok;

  if length(legalNumberEdit.Text)<1 then err('Не введен Гос номер');
  if modelListBox.ItemIndex < 0 then err('Не выбрана модель');

  try
    wearNum := StrToInt(wearEdit.Text);
  except
    on e:EConvertError do err('Пробег - не число');
  end;
  if wearNum < 0 then err('Пробег - отрицательное число');

  try
    birthYearNum := StrToInt(birthYearEdit.Text);
  except
    on e:EConvertError do err('Год выпуска - не число');
  end;
  if birthYearNum < 0 then err('Год выпуска - отрицательное число');

  if length(maintainceEdit.Text) > 0 then begin
    try
      maintainceDate := parseDate(maintainceEdit.Text,1);
      FreeAndNil(maintainceDate);
    except
      on e:EParseException do begin
        err('Дата обслуживания ТО задана не верно');
      end;
    end;
  end;
end;

procedure TCarController.FormShow(Sender: TObject);
begin
  legalNumberEdit.OnChange := self.validateInput;
  modelListBox.OnClick := self.validateInput;
  modelListBox.OnEnter := self.validateInput;
  wearEdit.OnChange := self.validateInput;
  birthYearEdit.OnChange := self.validateInput;
  maintainceEdit.OnChange := self.validateInput;
end;

end.
