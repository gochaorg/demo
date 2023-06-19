unit DBRows;

interface

uses
  Classes, SysUtils,

  Map, Logging, DBRowPredicate;

type

  // Функция прнимающая строку
  TDataRowConsumer  = procedure (row:TStringMap) of object;
  TDataRowConsumerI = procedure (row:IStringMap) of object;

  /////////////////////////////////////////////////////////////
  // Выборка строк
  IDBRows = interface
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
    list: TList;
  public
    constructor Create;
    destructor Destroy; override;

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
  list := TList.Create;
end;

destructor TDBRows.Destroy;
var
  i: Integer;
  row: TStringMap;
begin
  for i:=0 to list.Count-1 do begin
    row := list.Items[i];
    FreeAndNil(row);
  end;
  list.Clear;

  FreeAndNil(list);
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


end.
