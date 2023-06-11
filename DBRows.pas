unit DBRows;

interface

uses
  Classes, SysUtils,
  DB, ADODB, ComObj,
  Variants,

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

    // Добавляет строку в выборку
    procedure Add(row:TStringMap);

    // Обход всех строк в выборке и передача каждой в приемник
    // Аргументы
    //   consumer - применик
    procedure Each( consumer:TDataRowConsumer );
    procedure eachi( consumer: TDataRowConsumerI );
  end;

  TDBRows = class(TInterfacedObject,IDBRows)
  private
    list: TList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCount: Integer; virtual;
    function GetItem(index:Integer): IStringMap; virtual;

    procedure Add(row:TStringMap); virtual;
    procedure Addi(row:IStringMap); virtual;
    procedure Each( consumer:TDataRowConsumer ); virtual;
    procedure eachi( consumer: TDataRowConsumerI ); virtual;

    procedure Retain( predicate: IDataRowPredicate ); virtual;
  end;

  EIndexOutOfBound = class(Exception);

  ///////////////////////////////////////
  // Запись в лог выборки
  IDBRowsLogger = interface
    procedure Add(row:TStringMap);
    procedure Addi(row:IStringMap);
  end;

  TDBRowsLogger = class(TInterfacedObject,IDBRowsLogger)
    private
      logger: ILog;
    public
      constructor Create( logger:ILog );
      destructor Destroy; override;
      procedure Add(row:TStringMap); virtual;
      procedure Addi(row:IStringMap); virtual;
  end;

  /////////////////////////////////////////////
  // Выполнение операции над группой строк
  TDBRowsSqlExec = class(TObject)
  private
    query: TADOQuery;
    mapParams: TStringMap;
    errorsCount: Integer;
  public
    constructor Create( query:TADOQuery );
    destructor Destroy; override;
    procedure Map( columnName:string; paramName:string );  virtual;
    procedure Delete(row:TStringMap); virtual;
    function getErrorsCount: Integer; virtual;
  end;

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

procedure TDBRows.Addi(row: IStringMap);
var
  rowCopy: TStringMap;
begin
  rowCopy := TStringMap.Copyi(row);
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

procedure TDBRows.eachi(consumer: TDataRowConsumerI);
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

{ TDBRowsLogger }

constructor TDBRowsLogger.Create(logger: ILog);
begin
  inherited Create;
  self.logger := logger;
end;

destructor TDBRowsLogger.Destroy;
begin
  self.logger := nil;
  inherited Destroy;
end;

procedure TDBRowsLogger.Add(row: TStringMap);
begin
  self.logger.print('row: ');
  self.logger.println( row.toString );
end;

procedure TDBRowsLogger.Addi(row: IStringMap);
begin
  self.logger.print('row: ');
  self.logger.println( row.toString );
end;

{ TDBRowsSqlExec }

constructor TDBRowsSqlExec.Create(query: TADOQuery);
begin
  inherited Create();
  self.query := query;
  self.mapParams := TStringMap.Create;
  self.errorsCount := 0;
end;

destructor TDBRowsSqlExec.Destroy;
begin
  self.query := nil;
  self.mapParams.Destroy;
  self.mapParams := nil;
  inherited;
end;

procedure TDBRowsSqlExec.Map( columnName:string; paramName:string );
begin
  self.mapParams.put(columnName, paramName);
end;

procedure TDBRowsSqlExec.Delete(row: TStringMap);
var
  columnName: string;
  paramName: string;
  paramValue: Variant;
  i: Integer;
begin
  log.println('execute sql '+self.query.SQL.Text);
  for i:=0 to self.mapParams.count-1 do begin
    columnName := self.mapParams.key(i);
    paramName := VarToStr(self.mapParams.get(columnName));
    paramValue := row.get(columnName);
    log.println('  param '+paramName+' = '+VarToStr(paramValue));
    self.query.Parameters.ParamByName(paramName).Value := paramValue;
  end;
  try
    self.query.ExecSQL;
    log.println('  successfully executed');
  except
    on e:EOleException do begin
      self.errorsCount := self.errorsCount + 1;
      log.println('  got error: '+e.Message);
    end
  end;
end;


function TDBRowsSqlExec.getErrorsCount: Integer;
begin
  result := self.errorsCount;
end;

end.
