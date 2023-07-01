unit DateFormat;

// Заготовка для парсинга форматы даты

interface

uses
  MyDate,
  Validation,
  Logging, Loggers,
  IntegerList,

  SysUtils;

type

IMyDateFormat = interface
  function parse(
    str:WideString;
    from:Integer;
    var date:TMyDate;
    var validation:TDataValidation;
    var nextFrom:Integer
  ): boolean;

  procedure build( var str:WideString; var myDate: TMyDate );
end;

TMyDateFormatPlainText = class(TInterfacedObject,IMyDateFormat)
  private
    plainText: WideString;
  public
    constructor Create(plainText:WideString);
    destructor Destroy; override;

    function parse(
      str:WideString;
      from:Integer;
      var date:TMyDate;
      var validation:TDataValidation;
      var nextFrom:Integer
    ): boolean;

    procedure build( var str:WideString; var myDate: TMyDate );
end;

TMyDateFormatNumber = class(TInterfacedObject,IMyDateFormat)
  private
    digitCountMin:Integer;
    digitCountMax:Integer;
  public
    constructor Create(digitCountMin:Integer;digitCountMax:Integer);
    destructor Destroy; override;
    
    function parse(
      str:WideString;
      from:Integer;
      var date:TMyDate;
      var validation:TDataValidation;
      var nextFrom:Integer
    ): boolean;

    function numberParsed(
      num:Integer;
      var date:TMyDate;
      var validation:TDataValidation
    ):boolean; virtual;

    procedure build( var str:WideString; var myDate: TMyDate ); virtual;
end;

TMyDateFormatYear = class(TMyDateFormatNumber)
  public
    constructor Create;
    destructor Destroy; override;

    function numberParsed(
      num:Integer;
      var date:TMyDate;
      var validation:TDataValidation
    ):boolean; override;
    
    procedure build( var str:WideString; var myDate: TMyDate ); override;
end;

implementation

var
  log: ILog;

{ TMyDateFormatPlainText }

// Добавление нулей слева до необходимой длинны
function PadNumber(str:WideString; len:Integer):WideString;
var
  i:Integer;
begin
  result := str;
  if length(str) < len then
  begin
    for i:=1 to (len - length(str)) do begin
      result := '0' + result;
    end;
  end;
end;

constructor TMyDateFormatPlainText.Create(plainText: WideString);
begin
  inherited Create;
  self.plainText := plainText;
end;

destructor TMyDateFormatPlainText.Destroy;
begin
  inherited Destroy;
end;

procedure TMyDateFormatPlainText.build(var str: WideString; var myDate: TMyDate);
begin
  str := str + self.plainText;
end;


function TMyDateFormatPlainText.parse(
  str: WideString;
  from: Integer;
  var date: TMyDate;
  var validation: TDataValidation;
  var nextFrom: Integer): boolean;
var
  subStr: WideString;
begin
  result := false;

  if ((from-1) > (length(str) - length(self.plainText)) ) then begin
    validation.addError(
      'Нет входных данных, from='+IntToStr(from)+
      ' length='+IntToStr(length(str))
    );
  end else begin
    subStr := Copy(str, from, length(self.plainText));
    if subStr = self.plainText then begin
      result := true;
      nextFrom := from + length(self.plainText);
    end else begin
      validation.addError(
        'Ожидалось '''+self.plainText+
        ''' но встретилось: '''+subStr+'''' );
    end;
  end;
end;

{ TMyDateFormatNumber }

constructor TMyDateFormatNumber.Create(digitCountMin:Integer;digitCountMax:Integer);
begin
  inherited Create;
  self.digitCountMin := digitCountMin;
  self.digitCountMax := digitCountMax;
end;

destructor TMyDateFormatNumber.Destroy;
begin
  inherited Destroy;
end;

function TMyDateFormatNumber.numberParsed(
  num: Integer;
  var date:TMyDate;
  var validation: TDataValidation): boolean;
begin
  result := true;
end;

procedure TMyDateFormatNumber.build(
  var str: WideString;
  var myDate: TMyDate
);
begin

end;

function TMyDateFormatNumber.parse(
  str: WideString;
  from: Integer;
  var date: TMyDate;
  var validation: TDataValidation;
  var nextFrom: Integer): boolean;

var
  ptr : Integer;
  state : Integer;
  digits : TIntegerList;
  digit : Integer;
  num : Integer;
  numPow: Integer;
  i: Integer;

  function getDigit: Integer;
  begin
    result := -1;
    if str[ptr] = WideChar('0') then result := 0
    else if str[ptr] = WideChar('1') then result := 1
    else if str[ptr] = WideChar('2') then result := 2
    else if str[ptr] = WideChar('3') then result := 3
    else if str[ptr] = WideChar('4') then result := 4
    else if str[ptr] = WideChar('5') then result := 5
    else if str[ptr] = WideChar('6') then result := 6
    else if str[ptr] = WideChar('7') then result := 7
    else if str[ptr] = WideChar('8') then result := 8
    else if str[ptr] = WideChar('9') then result := 9;
  end;

  
begin
  result := false;
  digits := TIntegerList.Create;
  try
    if (from > length(str)) or (from < 1) then begin
      validation.addError('Нет входных данных начиная с позиции '+IntToStr(from));
    end else begin
      ptr := from;
      state := 0;
      while state >= 0 do begin
        if ptr > length(str) then state := -1
        else if (digits.Count >= self.digitCountMax) and (self.digitCountMax > 0) then state := -2
        else begin
          digit := getDigit;
          if digit < 0 then begin
            state := -3;          
          end else begin
            digits.add( digit );
            ptr := ptr + 1;
          end;
        end;
      end;

      if ((digits.Count >= self.digitCountMin) and (self.digitCountMin>0)) or (self.digitCountMin <= 0) then begin
        num := 0;
        numPow := 1;
        for i := (digits.Count-1) downto 0 do begin 
          digit := digits.Items[i];
          num := num + digit * numPow;
          numPow := numPow * 10;
        end;
        if self.numberParsed(num, date, validation) then begin
          nextFrom := ptr;
          result := true;
        end;
      end else begin
        validation.addError('Введено малое кол-во цифр');
      end;
    end;
  finally
    digits.Destroy;
  end;  
end;

{ TMyDateFormatYear }

constructor TMyDateFormatYear.Create;
begin
  inherited Create(4,4)
end;

destructor TMyDateFormatYear.Destroy;
begin
  inherited Destroy;
end;

procedure TMyDateFormatYear.build(var str: WideString;
  var myDate: TMyDate);
begin
  str := str + PadNumber(IntToStr(myDate.year),4);
end;

function TMyDateFormatYear.numberParsed(
  num: Integer;
  var date:TMyDate;
  var validation: TDataValidation): boolean;
begin
  date.year := num;
end;

procedure test;
var
  plain : TMyDateFormatPlainText;
  number : TMyDateFormatNumber;
  year : TMyDateFormatYear;

  myDate : TMyDate;
  nextFrom : Integer;
  validation : TDataValidation;

  generatedString: WideString;

begin
  log.println('test !');

  plain := TMyDateFormatPlainText.Create('hello');
  number := TMyDateFormatNumber.Create(0,4);
  year := TMyDateFormatYear.Create;

  validation := TDataValidation.Create;
  myDate := TMyDate.Create(0,0,0);
  
  try
    log.println('plain test');
    if plain.parse('hello',1,myDate,validation,nextFrom) then begin
      log.println('parsed');
      log.println('  nextFrom='+IntToStr(nextFrom));
    end else begin
      log.println('not parsed');
    end;

    log.println('number test');
    if number.parse('123456',1,myDate,validation,nextFrom) then begin
      log.println('parsed');
      log.println('  nextFrom='+IntToStr(nextFrom));
    end else begin
      log.println('not parsed');
    end;

    log.println('year test');
    if year.parse('123456',1,myDate,validation,nextFrom) then begin
      log.println('parsed');
      log.println('  year='+IntToStr(myDate.year));
      log.println('  nextFrom='+IntToStr(nextFrom));

      generatedString := '';
      year.build(generatedString, myDate);
      log.println('  generated string='+generatedString);
    end else begin
      log.println('not parsed');
    end;

  finally
    plain.Destroy;
    validation.Destroy;
    myDate.Destroy;
    number.Destroy;
    year.Destroy;
  end;
end;

initialization
  log := logger('DateFormat');
  rootLog.addListener(test);


end.
 