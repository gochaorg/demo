unit CarSQL;

interface

uses
  Classes,
  SysUtils,
  ADODB,

  MyDate,
  DMLOperation,
  Validation,
  Map;

type

// Шаблон строитель
// для создания либо запроса insert либо update
ICarDataBuilder = interface
  // Сброс состояния, надо заново указать значения
  procedure reset;

  // Указывает id машины, необходимо для update
  procedure setCarID( id:Integer );

  // Указывает Гос номер
  procedure setLegalNumber( num: WideString );

  // Указывает ссылку на модель
  procedure setModelId( id:Integer );

  // Указывает пробег
  procedure setWear( wear:Integer ); overload;
  procedure setWear( wear:WideString ); overload;

  // Указывает год выпуска
  procedure setBirthYear( year:Integer ); overload;
  procedure setBirthYear( year:WideString ); overload;

  // Указывает дату прохождения ТО
  procedure setMaintainceDate( date:TMyDate; own:boolean ); overload;
  procedure setMaintainceDate( date:WideString ); overload;

  // Проверка данных перед INSERT
  function validateInsert: IDataValidation;

  // Создает операцию INSERT.
  // Если какие данные указаны не верно,
  //   то генерирует исключение ECarDataBuilder
  function buildInsert: IDMLOperation;

  // Проверка данных перед UPDATE
  function validateUpdate: IDataValidation;

  // Создает операцию UPDATE.
  // Если какие данные указаны не верно,
  //   то генерирует исключение ECarDataBuilder
  function buildUpdate: IDMLOperation;
end;

TCarDataBuilder = class(TInterfacedObject,ICarDataBuilder)
  private
    // Id - обязательное для update
    updateId: Integer;
    updateIdExists: boolean;

    // Гос номер - обязательное
    legalNumber: WideString;
    legalNumberExists: boolean;

    // Ссылка на модель - обязательное
    modelId: Integer;
    modelIdExists: boolean;

    // Пробег - обязательное
    wear: Integer;
    wearExists: boolean;
    wearConvError: WideString;

    // Год выпуска - обязательное
    birthYear: Integer;
    birthYearExists: boolean;
    birthYearConvError: WideString;

    // Дата прохождения ТО - опциональное поле
    maintainceDate: TMyDate;
    maintainceDateOwn: boolean;
    maintainceDateExists: boolean;
    maintainceDateConvError: WideString;
  public
    constructor Create;
    destructor Destroy; override;

    procedure reset;
    
    procedure setCarID( id:Integer );

    procedure setLegalNumber( str: WideString );

    procedure setModelId( id:Integer );

    procedure setWear( wear:Integer ); overload;
    procedure setWear( wear:WideString ); overload;

    procedure setBirthYear( year:Integer ); overload;
    procedure setBirthYear( year:WideString ); overload;

    procedure setMaintainceDate( date:TMyDate; own:boolean ); overload;
    procedure setMaintainceDate( date:WideString ); overload;

    function validateInsert: IDataValidation;
    function buildInsert: IDMLOperation;

    function validateUpdate: IDataValidation;
    function buildUpdate: IDMLOperation;
  private
    // Проверка данных
    //   insert = true  - проверка для операции buildInsert
    //   insert = false - проверка для операции buildUpdate
    function validate(insert:boolean):IDataValidation;
end;

// Ошибка создания/валидации при построение операций
ECarDataBuilder = class(Exception);

implementation



{ TCarDataBuilder }

constructor TCarDataBuilder.Create;
begin
  inherited Create;
  self.updateIdExists := false;
  self.legalNumberExists := false;
  self.modelIdExists := false;
  self.wearExists := false;
  self.wearConvError := '';
  self.birthYearExists := false;
  self.maintainceDateExists := false;
  self.maintainceDateOwn := false;
  self.birthYearConvError := '';
  self.maintainceDateConvError := '';
end;

destructor TCarDataBuilder.Destroy;
begin
  if self.maintainceDateOwn and assigned(self.maintainceDate) then begin
    FreeAndNil(self.maintainceDate);
  end;
  inherited Destroy;
end;

//------------------------------------------------------

procedure TCarDataBuilder.reset;
begin
  self.birthYearExists := false;
  self.birthYearConvError := '';

  self.legalNumberExists := false;

  self.maintainceDateExists := false;
  self.maintainceDateConvError := '';

  self.modelIdExists := false;

  self.updateIdExists := false;

  self.wearExists := false;
  self.wearConvError := '';
end;

//------------------------------------------------------

procedure TCarDataBuilder.setBirthYear(year: Integer);
begin
  self.birthYear := year;
  self.birthYearExists := true;
end;

procedure TCarDataBuilder.setBirthYear(year: WideString);
begin
  try
    self.setBirthYear(StrToInt(year));
  except
    on e:EConvertError do begin
      self.birthYearExists := false;
      self.birthYearConvError := e.Message;
    end;
  end;
end;

//------------------------------------------------------

procedure TCarDataBuilder.setCarID(id: Integer);
begin
  self.updateId := id;
  Self.updateIdExists := true;
end;

//------------------------------------------------------

procedure TCarDataBuilder.setLegalNumber(str: WideString);
begin
  self.legalNumber := str;
  self.legalNumberExists := true;
end;

//------------------------------------------------------

procedure TCarDataBuilder.setMaintainceDate(date: TMyDate; own: boolean);
begin
  if assigned(self.maintainceDate) and self.maintainceDateOwn then
  begin
    FreeAndNil(self.maintainceDate);
  end;

  self.maintainceDate := date;
  self.maintainceDateOwn := own;
  self.maintainceDateExists := true;
end;

procedure TCarDataBuilder.setMaintainceDate(date: WideString);
var
  maintainceDateParsed: TMyDateParsed;
  maintainceDate: TMyDate;
begin
  if length(date)>0 then
  begin
    try
      maintainceDateParsed := parseDate(date,1);
      maintainceDate := TMyDate.Copy(maintainceDateParsed.date);
      FreeAndNil(maintainceDateParsed);
      self.setMaintainceDate(maintainceDate,true);
    except
      on e:EParseException do begin
        maintainceDateConvError := e.Message;
        maintainceDateExists := false;
      end;
    end;
  end else begin
    self.maintainceDateExists := false;
  end;
end;

procedure TCarDataBuilder.setModelId(id: Integer);
begin
  self.modelId := id;
  self.modelIdExists := true;
end;

procedure TCarDataBuilder.setWear(wear: Integer);
begin
  self.wear := wear;
  self.wearExists := true;
  self.wearConvError := '';
end;

procedure TCarDataBuilder.setWear(wear: WideString);
begin
  if length(wear)>0 then begin
    try
      self.setWear(StrToInt(wear));
    except
      on e:EConvertError do begin
        self.wearExists := false;
        self.wearConvError := e.Message;
      end;
    end;
  end else begin
    self.wearExists := false;
    self.wearConvError := '';
  end;
end;

function TCarDataBuilder.validateInsert: IDataValidation;
begin
  result := validate(true);
end;

function TCarDataBuilder.validateUpdate: IDataValidation;
begin
  result := validate(false);
end;

function TCarDataBuilder.validate(insert:boolean): IDataValidation;
var
  validation: IDataValidationMut;
begin
  validation := TDataValidation.Create;
  result := validation;

  if not self.birthYearExists then
    if length(self.birthYearConvError)>0
    then validation.addError(self.birthYearConvError)
    else validation.addError('Не указан год выпуска');

  if not self.legalNumberExists then validation.addError('Не указан Гос номер');

  if not self.maintainceDateExists then
    if length(self.maintainceDateConvError)>0
    then validation.addError(
      'Дата прохождения указана не верно: '+self.maintainceDateConvError);

  if not self.modelIdExists then
    validation.addError('Не указана ссылка на модель машины');

  if not self.wearExists then
    if length(self.wearConvError)>0
    then validation.addError('Пробег машины не является числом')
    else validation.addError('Не указан пробег машины');

  if self.wearExists and (self.wear < 0) then
    validation.addError('Пробег машины - отрицательное число');

  if self.birthYearExists and (self.birthYear < 1800) then
    validation.addError('Год выпуска меньше 1800 года');

  if not insert then
  begin
    if not self.updateIdExists then
      validation.addError('Не указан id обновляемой записи');
  end;
end;

function TCarDataBuilder.buildInsert: IDMLOperation;
var
  validation: IDataValidation;
  params: TStringMap;
  sql: String;
begin
  validation := validateInsert;
  if not validation.isOk then
    raise ECarDataBuilder.Create(validation.getMessage);

  sql :=
    'insert into cars (legal_number, model, wear, birth_year) '+
    'values (:legal_number, :model, :wear, :birth_year '+
    '); ' +
    'select @@IDENTITY as _id';

  params := TStringMap.Create;
  params.put('legal_number', self.legalNumber);
  params.put('model',        self.modelId );
  params.put('wear',         self.wear);
  params.put('birth_year',   self.birthYear);

  if maintainceDateExists then
  begin
    // Нашел странный баг
    // если использовать SQL
    //
    // insert into cars (... maintenance )
    //   values (... convert( datetime2, :M_DATE, 23 )
    //
    // где M_DATE - параметр '2020-01-01'
    // то блин валиться с EOleAccessViolation
    // если просто передавать как строку
    //
    // insert into cars (... maintenance )
    //   values (... convert( datetime2, '2020-01-01', 23 )
    //
    // то проблем нет
    sql :=
      'insert into cars (legal_number, model, wear, birth_year, maintenance) '+
      'values (:legal_number, :model, :wear, :birth_year, :maintenance);' +
      'select @@IDENTITY as _id';

    params.put('maintenance',  self.maintainceDate.toMSSQLDateTime2);
  end;

  result := TSqlInsertOperation.Create( sql, params, '_id');
end;

function TCarDataBuilder.buildUpdate: IDMLOperation;
var
  validation: IDataValidation;
  params: TStringMap;
  sql: String;
begin
  validation := validateUpdate;
  if not validation.isOk then
    raise ECarDataBuilder.Create(validation.getMessage);

  sql :=
    'update cars set '+
    ' legal_number = :legal_number,'+
    ' model = :model,'+
    ' wear = :wear,'+
    ' birth_year = :birth_year,'+
    ' maintenance = null'+
    ' where id = :id';

  params := TStringMap.Create;
  params.put('legal_number', self.legalNumber);
  params.put('model',        self.modelId );
  params.put('wear',         self.wear);
  params.put('birth_year',   self.birthYear);
  params.put('id',           self.updateId);

  if maintainceDateExists then
  begin
  sql :=
    'update cars set '+
    ' legal_number = :legal_number,'+
    ' model = :model,'+
    ' wear = :wear,'+
    ' birth_year = :birth_year,'+
    ' maintenance = :maintenance'+
    ' where id = :id';

    params.put('maintenance',  self.maintainceDate.toMSSQLDateTime2);
  end;

  result := TSqlUpdateOperation.Create( sql, params, 'id');
end;

end.
