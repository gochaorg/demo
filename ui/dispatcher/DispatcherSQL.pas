unit DispatcherSQL;

interface

uses
  SysUtils,

  MyDate,
  Map,
  DMLOperation,
  Validation;

type

// Ошибка создания/валидации при построение операций
EDispatcherDataBuilder = class(Exception);

// Шаблон строитель
// для создания либо запроса insert либо update
IDispatcherDataBuilder = interface
  // Сброс состояния, надо заново указать значения
  procedure Reset;

  // Указывает обновляемую запись
  procedure setDriverId(id:Integer);

  procedure setName(name:WideString);
  procedure setBirthDay(date:WideString); overload;
  procedure setBirthDay(date:TDateTime); overload;

  // Проверка данных перед INSERT
  function ValidateInsert: IDataValidation;

  // Создает операцию INSERT.
  // Если какие данные указаны не верно,
  //   то генерирует исключение EDriverDataBuilder
  function BuildInsert: IDMLOperation;

  // Проверка данных перед UPDATE
  function ValidateUpdate: IDataValidation;

  // Создает операцию UPDATE.
  // Если какие данные указаны не верно,
  //   то генерирует исключение EDriverDataBuilder
  function BuildUpdate: IDMLOperation;
end;

TDispatcherDataBuilder = class(TInterfacedObject, IDispatcherDataBuilder)
  private
    driverId: Integer;
    driverIdExists: boolean;

    name: WideString;
    nameExists: boolean;

    birthDay: TDateTime;
    birthDayExists: boolean;
    birthDayConvError: WideString;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reset;

    procedure setDriverId(id:Integer);

    procedure setName(name:WideString);
    procedure setBirthDay(date:WideString); overload;
    procedure setBirthDay(date:TDateTime); overload;

    function ValidateInsert: IDataValidation;
    function BuildInsert: IDMLOperation;

    function ValidateUpdate: IDataValidation;
    function BuildUpdate: IDMLOperation;
  private
    function Validate(insert:boolean): IDataValidation;
end;

implementation

constructor TDispatcherDataBuilder.Create;
begin

end;

destructor TDispatcherDataBuilder.Destroy;
begin

  inherited;
end;

procedure TDispatcherDataBuilder.Reset;
begin
  self.driverIdExists := false;
  self.nameExists := false;
  self.birthDayExists := false;
  self.birthDayConvError := '';
end;

procedure TDispatcherDataBuilder.setBirthDay(date: WideString);
var
  myDate: TMyDate;
  nextFrom: Integer;
  parseError: WideString;
begin
  myDate := TMyDate.Create(0,0,0);
  try
    if TryParseDate(date,1,myDate,nextFrom,parseError) then begin
      self.birthDay := myDate.ToDateTime;
      self.birthDayExists := true;
      self.birthDayConvError := '';
    end else begin
      self.birthDayExists := false;
      self.birthDayConvError := parseError;
    end;
  finally
    FreeAndNil(myDate);
  end;
end;

procedure TDispatcherDataBuilder.setBirthDay(date: TDateTime);
begin
  self.birthDay := date;
  self.birthDayExists := true;
  self.birthDayConvError := '';
end;

procedure TDispatcherDataBuilder.setName(name: WideString);
begin
  self.name := name;
  self.nameExists := true;
end;

procedure TDispatcherDataBuilder.setDriverId(id: Integer);
begin
  self.driverId := id;
  self.driverIdExists := true;
end;

function TDispatcherDataBuilder.ValidateInsert: IDataValidation;
begin
  result := validate(true);
end;

function TDispatcherDataBuilder.ValidateUpdate: IDataValidation;
begin
  result := validate(false);
end;

function TDispatcherDataBuilder.Validate(insert:boolean): IDataValidation;
var
  validation : TDataValidation;
begin
  validation := TDataValidation.Create;
  if not self.nameExists then validation.addError('Не указано имя');
  if not self.birthDayExists then
    if length(self.birthDayConvError)>0 then
      validation.addError('Формат даты задан не верно '+self.birthDayConvError)
    else
      validation.addError('Дата рождения не указана');

  if (not insert) and (not self.driverIdExists) then
    validation.addError('Не указан id обновляемой записи');

  result := validation;
end;

function TDispatcherDataBuilder.BuildInsert: IDMLOperation;
var
  params : TStringMap;
  dmlOp : TSqlInsertOperation;
  validation : IDataValidation;
  sql: string;
begin
  validation := ValidateInsert;
  if not validation.isOk then
    raise EDispatcherDataBuilder.Create(validation.getMessage);

  sql := 'insert into dispatchers (name, birth_day)' +
         ' values (:name, :birth_day) '+
         ';'+
         'select @@IDENTITY as _id';
  params := TStringMap.Create;
  params.put('name', self.name);
  params.put('birth_day',self.birthDay);

  dmlOp := TSqlInsertOperation.Create(sql, params, '_id');
  result := dmlOp;
end;

function TDispatcherDataBuilder.BuildUpdate: IDMLOperation;
var
  params : TStringMap;
  dmlOp : TSqlUpdateOperation;
  validation : IDataValidation;
  sql: string;
begin
  validation := ValidateUpdate;
  if not validation.isOk then
    raise EDispatcherDataBuilder.Create(validation.getMessage);

  sql := 'update dispatcher set'+
    ' name = :name,'+
    ' birth_day = :birth_day'+
    ' where id = :id';

  params := TStringMap.Create;
  params.put('name', self.name);
  params.put('birth_day',self.birthDay);
  params.put('id', self.driverId);

  dmlOp := TSqlUpdateOperation.Create(sql, params);
  result := dmlOp;
end;

end.
