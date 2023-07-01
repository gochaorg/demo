unit MyDate;

interface
  uses
    SysUtils,

    Loggers,
    Logging;

  type

  // ������������� ����
  // ��� - ����� - ����
  TMyDate = class
    year: Integer;
    month: Integer;
    date: Integer;
    constructor Create(const year: Integer; const month:Integer; const date:Integer);
    constructor Copy(const myDate: TMyDate);
    destructor Destroy; override;
    function ToString(): WideString;
    function ToMSSQLDateTime2(): WideString;
    function ToDateTime(): TDateTime;
  private
    function Pad(str:WideString; len:Integer):WideString;
  end;

  // ������� ����
  // ��������� ������ yyyy-mm-dd
  //  str - ������
  //  from - ����� ������� ������� � �������� ����������� �������
  //  date - ����� ����� ������� ��������� ����
  //  nextFrom - ����� ������� ���������� �� ������ ����
  //  error - ��������� � ������
  // ����������
  //  true - �������
  //  false - ������
  function TryParseDate(
    const str: WideString;
    const from: Integer;
    var date: TMyDate;
    var nextFrom: Integer;
    var error: WideString
  ): boolean; overload;

implementation

uses Math;

var
  // ����� ��� ������� parseDate ?
  parseDateDebug : boolean;

  // ������������
  log: ILog;


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

function TMyDate.Pad(str:WideString; len:Integer):WideString;
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

function TMyDate.ToString: WideString;
begin
  result :=
    pad(IntToStr(self.year),4) +
    '-'+
    pad(IntToStr(self.month),2) +
    '-'+
    pad(IntToStr(self.date),2);
end;

function TMyDate.ToMSSQLDateTime2: WideString;
begin
  result :=
    pad(IntToStr(self.year),4) +
    '-'+
    pad(IntToStr(self.month),2) +
    '-'+
    pad(IntToStr(self.date),2) +
    ' 00:00:00.000';
end;

{ TDateParsed }

function TMyDate.ToDateTime: TDateTime;
begin
  result := EncodeDate( self.year, self.month, self.date );
end;

///////////////////////////
function TryParseDate(
  const str: WideString;
  const from: Integer;
  var date: TMyDate;
  var nextFrom: Integer;
  var error: WideString
): boolean; overload;
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

  function isLeapYear(year:Integer):boolean;
  begin
    result := false;
    if (year mod 400) = 0 then result := true
    else if (year mod 100) = 0 then result := false
    else if (year mod 4) = 0 then result := true;
  end;

  function getMonthLen(year,mon:Integer):Integer;
  begin
    result := 0;
    if mon = 1 then result := 31
    else if (mon = 2) and (isLeapYear(year)) then result := 29
    else if (mon = 2) and (not isLeapYear(year)) then result := 28
    else if mon = 3  then result := 31
    else if mon = 4  then result := 30
    else if mon = 5  then result := 31
    else if mon = 6  then result := 30
    else if mon = 7  then result := 31
    else if mon = 8  then result := 31
    else if mon = 9  then result := 30
    else if mon = 10 then result := 31
    else if mon = 11 then result := 30
    else if mon = 12 then result := 31;
  end;

begin
  if parseDateDebug then begin
    log.println('TryParseDate');
    log.println('  str="'+str+'"');
    log.println('  from='+IntToStr(from));
  end;

  if from > length(str) then begin
    error := '������ ������ ��� ��� ������� ������';
    result := false;
  end else begin
    p := from;

    state := 0;
    y0 := 0; y1 := 0; y2 := 0; y3 := 0;
    m0 := 0; m1 := 0;
    d0 := 0; d1 := 0;
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
      if parseDateDebug then
        log.println('p='+IntToStr(p)+' c='+str[p]+' state='+IntToStr(state));

      if state = 0 then begin
        y0 := getDigit;
        if y0 < 0 then begin
          error := '��������� �����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          state := 1;
        end;
      end else
      if state = 1 then begin
        y1 := getDigit;
        if y1 < 0 then begin
          error := '��������� �����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          state := 2;
        end;
      end else
      if state = 2 then begin
        y2 := getDigit;
        if y2 < 0 then begin
          error := '��������� �����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          state := 3;
        end;
      end else
      if state = 3 then begin
        y3 := getDigit;
        if y3 < 0 then begin
          error := '��������� �����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          state := 4;
        end;
      end else
      if state = 4 then begin
        if not (str[p] = WideChar('-')) then begin
          error :=  '��������� ����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          state := 5;
        end;
      end else
      if state = 5 then begin
        m0 := getDigit;
        if m0 < 0 then begin
          error := '��������� �����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          state := 6;
        end;
      end else
      if state = 6 then begin
        m1 := getDigit;
        if m1 < 0 then begin
          error := '��������� �����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          state := 7;
        end;
      end else
      if state = 7 then begin
        if not (str[p] = WideChar('-')) then begin
          error := '��������� ����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          state := 8;
        end;
      end else
      if state = 8 then begin
        d0 := getDigit;
        if d0 < 0 then begin
          error := '��������� �����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          state := 9;
        end;
      end else
      if state = 9 then begin
        d1 := getDigit;
        if d1 < 0 then begin
          error := '��������� �����, ����������� ���: '+str[p];
          state := -1;
        end else begin
          p := p + 1;
          break;
        end;
      end else
      if state = -1 then begin
        break;
      end;

      ////
      p := p + 1;
    end;

    result := false;

    if state = -1 then begin
      result := false;
    end else
    if not (state = 9) then begin
      error := '������� �� ��� ����';
      result := false;
    end else begin
      nextFrom := p;

      log.println('state='+IntToStr(state));
      log.println('y0='+IntToStr(y0));
      log.println('y1='+IntToStr(y1));
      log.println('y2='+IntToStr(y2));
      log.println('y3='+IntToStr(y3));

      date.year := (y0 * 1000) + (y1 * 100) + (y2 * 10) + y3;
      date.month := m0 * 10 + m1;
      date.date := d0 * 10 + d1;

      if date.date < 1 then begin
        result := false;
        error := '���� (����) ������ 1';
      end else
      if date.date > 31 then begin
        result := false;
        error := '���� ������ 31';
      end else
      if date.month < 1 then begin
        result := false;
        error := '����� ������ 1';
      end else
      if date.month > 12 then begin
        result := false;
        error := '����� ������ 12';
      end else begin
        if date.date > getMonthLen(date.year,date.month) then begin
          result := false;
          error := '������� ������ ���-�� ���� ��� ���� � ������';
        end else begin
          result := true;
        end;
      end;
    end;
  end;
end;

initialization
  parseDateDebug := false;
  log := logger('MyDate');

end.
