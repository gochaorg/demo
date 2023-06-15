unit DriverSQL;

interface

uses
  SysUtils,

  MyDate,
  Map,
  DMLOperation,
  Validation;

type

// ������ ��������/��������� ��� ���������� ��������
EDriverDataBuilder = class(Exception);

// ������ ���������
// ��� �������� ���� ������� insert ���� update
IDriverDataBuilder = interface
  // ����� ���������, ���� ������ ������� ��������
  procedure Reset;

  // ��������� ����������� ������
  procedure setDriverId(id:Integer);

  procedure setName(name:WideString);
  procedure setBirthDay(date:WideString); overload;
  procedure setBirthDay(date:TDateTime); overload;

  // �������� ������ ����� INSERT
  function ValidateInsert: IDataValidation;

  // ������� �������� INSERT.
  // ���� ����� ������ ������� �� �����,
  //   �� ���������� ���������� EDriverDataBuilder
  function BuildInsert: IDMLOperation;

  // �������� ������ ����� UPDATE
  function ValidateUpdate: IDataValidation;

  // ������� �������� UPDATE.
  // ���� ����� ������ ������� �� �����,
  //   �� ���������� ���������� EDriverDataBuilder
  function BuildUpdate: IDMLOperation;
end;

TDriverDataBuilder = class(TInterfacedObject, IDriverDataBuilder)
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

{ TDriverDataBuilder }

constructor TDriverDataBuilder.Create;
begin

end;

destructor TDriverDataBuilder.Destroy;
begin

  inherited;
end;

procedure TDriverDataBuilder.Reset;
begin
  self.driverIdExists := false;
  self.nameExists := false;
  self.birthDayExists := false;
  self.birthDayConvError := '';
end;

procedure TDriverDataBuilder.setBirthDay(date: WideString);
var
  parserDate : TMyDateParsed;
begin
  try
    parserDate := ParseDate(date, 1);
    try
      self.birthDay := parserDate.date.ToDateTime;
      self.birthDayExists := true;
      self.birthDayConvError := '';
    finally
      FreeAndNil(parserDate);
    end;
  except
    on e:EParseException do begin
      self.birthDayConvError := e.Message;
      self.birthDayExists := false;
    end;
  end;
end;

procedure TDriverDataBuilder.setBirthDay(date: TDateTime);
begin
  self.birthDay := date;
  self.birthDayExists := true;
  self.birthDayConvError := '';
end;

procedure TDriverDataBuilder.setName(name: WideString);
begin
  self.name := name;
  self.nameExists := true;
end;

procedure TDriverDataBuilder.setDriverId(id: Integer);
begin
  self.driverId := id;
  self.driverIdExists := true;
end;

function TDriverDataBuilder.ValidateInsert: IDataValidation;
begin
  result := validate(true);
end;

function TDriverDataBuilder.ValidateUpdate: IDataValidation;
begin
  result := validate(false);
end;

function TDriverDataBuilder.Validate(insert:boolean): IDataValidation;
var
  validation : TDataValidation;
begin
  validation := TDataValidation.Create;
  if not self.nameExists then validation.addError('�� ������� ���');
  if not self.birthDayExists then
    if length(self.birthDayConvError)>0 then
      validation.addError('������ ���� ����� �� ����� '+self.birthDayConvError)
    else
      validation.addError('���� �������� �� �������');

  if (not insert) and (not self.driverIdExists) then
    validation.addError('�� ������ id ����������� ������');

  result := validation;
end;

function TDriverDataBuilder.BuildInsert: IDMLOperation;
var
  params : TStringMap;
  dmlOp : TSqlInsertOperation;
  validation : IDataValidation;
  sql: string;
begin
  validation := ValidateInsert;
  if not validation.isOk then raise EDriverDataBuilder.Create(validation.getMessage);

  sql := 'insert into drivers (name, birth_day)' +
         ' values (:name, :birth_day) '+
         ';'+
         'select @@IDENTITY as _id';
  params := TStringMap.Create;
  params.put('name', self.name);
  params.put('birth_day',self.birthDay);

  dmlOp := TSqlInsertOperation.Create(sql, params, '_id');
  result := dmlOp;
end;

function TDriverDataBuilder.BuildUpdate: IDMLOperation;
var
  params : TStringMap;
  dmlOp : TSqlUpdateOperation;
  validation : IDataValidation;
  sql: string;
begin
  validation := ValidateUpdate;
  if not validation.isOk then raise EDriverDataBuilder.Create(validation.getMessage);

  sql := 'update drivers set'+
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
