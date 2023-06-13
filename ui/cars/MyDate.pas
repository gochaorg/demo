unit MyDate;

interface
  uses
    SysUtils;

  type

  // Представление даты
  // Год - Месяц - Дата
  TMyDate = class
    year: Integer;
    month: Integer;
    date: Integer;
    constructor Create(const year: Integer; const month:Integer; const date:Integer);
    constructor Copy(const myDate: TMyDate);
    destructor Destroy; override;
    function toString(): WideString;
  end;

  // Результат парсинга
  TMyDateParsed = class
    // дата
    date: TMyDate;
    // номер символа следующего за датой
    endIndex: Integer;
    constructor Create(const date: TMyDate; const endIndex:Integer);
    destructor Destroy; override;
  end;

  // Ошибка парсинга / формата
  EParseException = class(Exception);

  // Парсинг даты
  // Ожидаемый формат yyyy-mm-dd
  //  str - строка
  //  from - номер символа начиная с которого производить парсинг
  function parseDate( const str: WideString; const from:Integer ):TMyDateParsed;

implementation

uses Math;

{ TDate }

constructor TMyDate.Copy(const myDate: TMyDate);
begin
  inherited Create;
  self.year  := myDate.year;
  self.month := myDate.month;
  self.date  := myDate.date;
end;

constructor TMyDate.Create(const year, month, date: Integer);
begin
  inherited Create;
  self.year  := year;
  self.month := month;
  self.date  := date;
end;

destructor TMyDate.Destroy;
begin
  inherited;
end;

function TMyDate.toString: WideString;
  function pad(str:WideString; len:Integer):WideString;
  var
    i:Integer;
  begin
    if length(str) < len then
    begin
      result := str;
      for i:=1 to (len - length(str)) do begin
        result := '0' + result;
      end;
    end else begin
      result := str;
    end;
  end;
begin
  result :=
    pad(IntToStr(self.year),4) +
    '-'+
    pad(IntToStr(self.month),2) +
    '-'+
    pad(IntToStr(self.date),2);
end;

{ TDateParsed }

constructor TMyDateParsed.Create(const date: TMyDate; const endIndex:Integer);
begin
  inherited Create;
  self.date := date;
  self.endIndex := endIndex;
end;

destructor TMyDateParsed.Destroy;
begin
  FreeAndNil(self.date);
  inherited Destroy;
end;

function parseDate( const str: WideString; const from:Integer ):TMyDateParsed;
var
  dres : TMyDate;
  p : Integer;
  state : Integer;

  y0,y1,y2,y3 : Integer;
  m0,m1 : Integer;
  d0,d1 : Integer;

  function getDigit():Integer;
  begin
    result := -1;
    if str[p] = WideChar('0') then result := 0 else
    if str[p] = WideChar('1') then result := 1 else
    if str[p] = WideChar('2') then result := 2 else
    if str[p] = WideChar('3') then result := 3 else
    if str[p] = WideChar('4') then result := 4 else
    if str[p] = WideChar('5') then result := 5 else
    if str[p] = WideChar('6') then result := 6 else
    if str[p] = WideChar('7') then result := 7 else
    if str[p] = WideChar('8') then result := 8 else
    if str[p] = WideChar('9') then result := 9;
  end;
begin
  if from > length(str) then raise EParseException.Create('from out side of string');

  p := from;

  state := 0;
  // 0 - y
  // 1 - yy
  // 2 - yyy
  // 3 - yyyy
  // 4 - yyyy-
  // 5 - yyyy-m
  // 6 - yyyy-mm
  // 7 - yyyy-mm-
  // 8 - yyyy-mm-d
  // 9 - yyyy-mm-dd

  while p <= length(str) do
  begin
    if state = 0 then begin
      y0 := getDigit;
      if y0 < 0 then raise EParseException.Create('expect digit, but found '+str[p]);
      state := 1;
    end else
    if state = 1 then begin
      y1 := getDigit;
      if y1 < 0 then raise EParseException.Create('expect digit, but found '+str[p]);
      state := 2;
    end else
    if state = 2 then begin
      y2 := getDigit;
      if y2 < 0 then raise EParseException.Create('expect digit, but found '+str[p]);
      state := 3;
    end else
    if state = 3 then begin
      y3 := getDigit;
      if y3 < 0 then raise EParseException.Create('expect digit, but found '+str[p]);
      state := 4;
    end else
    if state = 4 then begin
      if not (str[p] = WideChar('-')) then EParseException.Create('expect -, but found '+str[p]);
      state := 5;
    end else
    if state = 5 then begin
      m0 := getDigit;
      if m0 < 0 then raise EParseException.Create('expect digit, but found '+str[p]);
      state := 6;
    end else
    if state = 6 then begin
      m1 := getDigit;
      if m1 < 0 then raise EParseException.Create('expect digit, but found '+str[p]);
      state := 7;
    end else
    if state = 7 then begin
      if not (str[p] = WideChar('-')) then EParseException.Create('expect -, but found '+str[p]);
      state := 8;
    end else
    if state = 8 then begin
      d0 := getDigit;
      if d0 < 0 then raise EParseException.Create('expect digit, but found '+str[p]);
      state := 1;
    end else
    if state = 9 then begin
      d1 := getDigit;
      if d1 < 0 then raise EParseException.Create('expect digit, but found '+str[p]);
      p := p + 1;
      break;
    end;

    ////
    p := p + 1;
  end;

  if not state = 9 then raise
    EParseException.Create('not fully parsed');

  dres := TMyDate.Create(
    y0 * 1000 + y1 * 100 + y2 * 10 + y3,
    m0 * 10 + m1,
    d0 * 10 + d1
  );
  result := TMyDateParsed.Create(dres, p);

end;

end.
