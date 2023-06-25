unit DBRows;

interface

uses
  Classes, SysUtils,

  Map, Logging, DBRowPredicate;

type

  // Функция прнимающая строку
  TDataRowConsumer  = procedure (row:TStringMap) of object;
  TDataRowConsumerI = procedure (row:IStringMap) of object;

  // Опиcание колонки
  IDBRowColumn = interface
    procedure SetName( str:WideString );
    function  GetName: WideString;
    property Name: WideString read GetName write SetName;
  end;

  TDBRowColumn = class(TStringMap)
  published
    constructor Create;
    destructor Destroy; override;

    procedure SetName( str:WideString );
    function GetName: WideString;
    property Name: WideString read GetName write SetName;
  private
    FName: WideString;
  end;

  /////////////////////////////////////////////////////////////
  // Выборка строк
  IDBRows = interface
    // Получение колонки (или создание) по имени
    // Аргументы
    //   name - имя колонки
    //   ссылка на колонку
    // Результат
    //   true - ссылка на колонку содержит актуальное значение
    //   false - колонка не создана, ссылка на колонку не актуальна
    function AddOrGetColumn( name:WideString; var column:IDBRowColumn ):boolean;

    // Получение колонки по имени
    // Аргументы
    //   name - имя колонки
    //   ссылка на колонку
    // Результат
    //   true - ссылка на колонку содержит актуальное значение
    //   false - колонка не создана, ссылка на колонку не актуальна
    function GetColumn( name:WideString; var column:IDBRowColumn ):boolean; overload;

    // Получение колонки по индексу
    // Аргументы
    //   index - индекс колонки (0 - первая колонка)
    //   ссылка на колонку
    // Результат
    //   true - ссылка на колонку содержит актуальное значение
    //   false - колонка не создана, ссылка на колонку не актуальна
    function GetColumn( index:Integer; var column:IDBRowColumn ):boolean; overload;

    // Возвращает кол-во колонок
    function GetColumnsCount: Integer;

    // Возвращает кол-во строк в выборке
    function GetCount: Integer;

    // Возвращает строку по индексу
    function GetItem(index:Integer): IStringMap;

    // Обход всех строк в выборке и передача каждой в приемник
    // Аргументы
    //   consumer - применик
    procedure Each( consumer:TDataRowConsumer );

    // Добавляет строку в выборку
    procedure Add(row:TStringMap);

    // Удаляет строки кроме указанныъ
    // Аргументы
    //   predicate - указывает условие (предикат) какие строки надо оставить
    procedure Retain( predicate: IDataRowPredicate );
  end;

  TDBRows = class(TInterfacedObject,IDBRows)
  private
    list: TList; // коллекция строк TStringMap
    header: TList; // коллекция колонок TStringMap
  public
    constructor Create;
    destructor Destroy; override;

    function AddOrGetColumn( name:WideString; var column:IDBRowColumn ):boolean;
    function GetColumn( name:WideString; var column:IDBRowColumn ):boolean; overload;
    function GetColumn( index:Integer; var column:IDBRowColumn ):boolean; overload;
    function GetColumnsCount: Integer;

    procedure Each( consumer:TDataRowConsumer ); virtual;
    function GetCount: Integer; virtual;
    function GetItem(index:Integer): IStringMap; virtual;
    procedure Add(row:TStringMap); virtual;
    procedure Retain( predicate: IDataRowPredicate ); virtual;
  end;

  EIndexOutOfBound = class(Exception);


implementation

{ TDBRows }

constructor TDBRows.Create;
begin
  inherited Create;
  self.list := TList.Create;
  self.header := TList.Create;
end;

destructor TDBRows.Destroy;
var
  i: Integer;
  row: TStringMap;
  hdr: TStringMap;
begin
  for i:=0 to self.list.Count-1 do begin
    row := self.list.Items[i];
    FreeAndNil(row);
  end;
  list.Clear;
  FreeAndNil(list);

  for i:=0 to self.header.Count-1 do begin
    hdr := self.header.Items[i];
    FreeAndNil(hdr);
  end;
  self.header.Clear;
  FreeAndNil(self.header);

  inherited Destroy;
end;

procedure TDBRows.Add(row: TStringMap);
var
  rowCopy: TStringMap;
begin
  rowCopy := TStringMap.Copy(row);
  list.Add( rowCopy );
end;

function TDBRows.GetCount: Integer;
begin
  result := list.Count;
end;

function TDBRows.GetItem(index: Integer): IStringMap;
var
  row : TStringMap;
begin
  if index<0 then
    raise EIndexOutOfBound.Create('index (='+IntToStr(index)+') param < 0');

  if index>=list.Count then
    raise EIndexOutOfBound.Create(
      'index (='+IntToStr(index)+
      ') param > list.count(='+IntToStr(list.Count)+')');

  row := list[index];
  result := row;
end;

procedure TDBRows.Each(consumer: TDataRowConsumer);
var
  i:Integer;
  row: TStringMap;
begin
  for i:=0 to list.Count-1 do begin
    row := list[i];
    consumer(row);
  end;
end;

procedure TDBRows.Retain( predicate: IDataRowPredicate );
var
  i:Integer;
  row: TStringMap;
begin
  for i:=list.Count-1 downto 0 do begin
    row := list[i];
    if not predicate.test(row) then begin
      list.Delete(i);
      FreeAndNil(row);
    end;
  end;
end;


function TDBRows.AddOrGetColumn(
  name: WideString;
  var column: IDBRowColumn
  ): boolean;
var
  i: Integer;
  hdr: TDBRowColumn;
  found: boolean;
begin
  found := false;
  for i:=0 to self.header.Count-1 do begin
    hdr := self.header[i];
    if assigned(hdr) and hdr.Name = name then begin
      result := true;
      column := hdr;
      found := true;
    end;
  end;

  if not found then begin
    hdr := TDBRowColumn.Create;
    self.header.Add(hdr);
    column := hdr;
    result := true;
  end;
end;

function TDBRows.GetColumn(
  name: WideString;
  var column: IDBRowColumn): boolean;
var
  i: Integer;
  hdr: TDBRowColumn;
begin
  for i:=0 to self.header.Count-1 do begin
    hdr := self.header[i];
    if assigned(hdr) and hdr.Name = name then begin
      result := true;
      column := hdr;
    end;
  end;
end;

function TDBRows.GetColumn(index: Integer;
  var column: IDBRowColumn): boolean;
var
  hdr: TDBRowColumn;
begin
  if (index>=0) and (index<self.header.Count) then begin
    hdr := self.header[index];
    column := hdr;
    result := true;
  end;
end;

function TDBRows.GetColumnsCount: Integer;
begin
  result := self.header.Count;
end;

{ TDBRowColumn }

constructor TDBRowColumn.Create;
begin
  inherited Create;
end;

destructor TDBRowColumn.Destroy;
begin
  inherited Destroy;
end;

function TDBRowColumn.getName: WideString;
begin
  if self.exists('name')
  then result := self.get('name')
  else result := '';
end;

procedure TDBRowColumn.setName(str: WideString);
begin
  self.put('name', str);
end;

end.
