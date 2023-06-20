unit WaybillSQLView;

// Функции SQL по работе с путевыми листами
// Составление запросов к СУБД

interface

uses
  SysUtils, ADODB,

  Loggers, Logging,
  Map;

type

IWaybillsQuery = interface
  procedure apply( query:TADOQuery );
end;

TWaybillsQuery = class(TInterfacedObject, IWaybillsQuery)
  private
    sql: WideString;
    params: TStringMap;
  public
    constructor Create(sql:WideString; params:TStringMap);
    destructor Destroy; override;
    procedure apply( query:TADOQuery );
end;

IWaybillsQueryBuilder = interface
end;

TWaybillsQueryBuilder = class(TInterfacedObject, IWaybillsQueryBuilder)
  private
    withHistoryValue: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    property history:boolean read withHistoryValue write withHistoryValue;

    function build:IWaybillsQuery;
end;

TWaybillColumn = class
  private
    aliasValue: WideString;
    expressionValue: WideString;
    visibleValue: boolean;
  public
    constructor Create(alias:WideString; expr:WideString; visible:boolean);
    property alias:WideString read aliasValue;
    property expression:WideString read expressionValue;
    property visible:boolean read visibleValue;
end;

implementation

var
  log:ILog;
  columns:array[0 .. 16] of TWaybillColumn;
  histColumns:array[0 .. 16] of TWaybillColumn;

{ TWaybillsQuery }

procedure TWaybillsQuery.apply(query: TADOQuery);
begin
  //
end;

constructor TWaybillsQuery.Create(sql: WideString; params: TStringMap);
begin
  inherited Create;
  self.sql := sql;
  self.params := params;
end;

destructor TWaybillsQuery.Destroy;
begin
  FreeAndNil(self.params);
  inherited Destroy;
end;

{ TWaybillsQueryBuilder }

constructor TWaybillsQueryBuilder.Create;
begin
  self.withHistoryValue := false;
end;

destructor TWaybillsQueryBuilder.Destroy;
begin
  inherited;
end;

function TWaybillsQueryBuilder.build: IWaybillsQuery;
  function columnsExp( cols: array of TWaybillColumn ):WideString;
    var
      exp:WideString;
      i: Integer;
  begin
    exp := '';
    for i:=low(cols) to high(cols) do begin
      if i>0 then exp := exp + ' , ';
      exp := exp + ' ' + cols[i].expression + ' as ' + cols[i].alias;
    end;
    result := exp;
  end;
var
  sql: WideString;
begin
  // отображаемые столбцы
  sql := 'select ' +
    columnsExp(columns) +
    ' from '+
    ' waybills w '+
    ' left join drivers dr on (dr.id = w.driver) '+
    ' left join dispatchers ds on (ds.id = w.dispatcher) '+
    ' left join cars c on (c.id = w.car) '+
    ' left join cars_model cm on (c.model = cm.id) '
    ;

  // исторические данные  
  if self.withHistoryValue then begin
    sql := sql + ' union all ';
    sql := sql + 'select ' +
      columnsExp(histColumns) +
      ' from '+
      ' waybills_hist w '+
      ' left join drivers dr on (dr.id = w.driver) '+
      ' left join dispatchers ds on (ds.id = w.dispatcher) '+
      ' left join cars c on (c.id = w.car) '+
      ' left join cars_model cm on (c.model = cm.id) '
      ;
  end;

  result := TWaybillsQuery.Create(sql, TStringMap.Create);
end;


{ TWaybillColumn }

constructor TWaybillColumn.Create(alias, expr: WideString;
  visible: boolean);
begin
  self.aliasValue := alias;
  self.expressionValue := expr;
  self.visibleValue := visible;
end;

initialization
log := logger('WaybillSQLView');

// колонки актуальных данных
columns[ 0] := TWaybillColumn.Create('id', 'w.id', true);
columns[ 1] := TWaybillColumn.Create('state', '''actual''', true);
columns[ 2] := TWaybillColumn.Create('car_id', 'w.car', true);
columns[ 3] := TWaybillColumn.Create('car_model_id', 'c.model', true);
columns[ 4] := TWaybillColumn.Create('car_model_name', 'cm.name', true);
columns[ 5] := TWaybillColumn.Create('car_total_wear', 'isnull((select sum(wear) from waybills where car = w.car), 0) + c.wear', true);
columns[ 6] := TWaybillColumn.Create('car_legal_number', 'c.legal_number', true);
columns[ 7] := TWaybillColumn.Create('driver_id', 'w.driver', true);
columns[ 8] := TWaybillColumn.Create('driver_name', 'dr.name', true);
columns[ 9] := TWaybillColumn.Create('dispatcher_id', 'w.dispatcher', true);
columns[10] := TWaybillColumn.Create('dispatcher_name', 'ds.name', true);
columns[11] := TWaybillColumn.Create('outcome_date', 'w.outcome_date', true);
columns[12] := TWaybillColumn.Create('outcome_date_s', 'convert( nvarchar(100), w.outcome_date, 23 ) + '' '' + convert( nvarchar(50), w.outcome_date, 108 )', true);
columns[13] := TWaybillColumn.Create('income_date', 'w.income_date', true);
columns[14] := TWaybillColumn.Create('income_date_s', 'convert( nvarchar(100), w.income_date, 23 ) + '' '' + convert( nvarchar(50), w.income_date, 108 )', true);
columns[15] := TWaybillColumn.Create('fuel_cons', 'w.fuel_cons', true);
columns[16] := TWaybillColumn.Create('wear', 'w.wear', true);

// колонки исторических данных
histColumns[ 0] := columns[0];
histColumns[ 1] := TWaybillColumn.Create('state', '''hist''', true);
histColumns[ 2] := columns[2];
histColumns[ 3] := columns[3];
histColumns[ 4] := columns[4];
histColumns[ 5] := columns[5];
histColumns[ 6] := columns[6];
histColumns[ 7] := columns[7];
histColumns[ 8] := columns[8];
histColumns[ 9] := columns[9];
histColumns[10] := columns[10];
histColumns[11] := columns[11];
histColumns[12] := columns[12];
histColumns[13] := columns[13];
histColumns[14] := columns[14];
histColumns[15] := columns[15];
histColumns[16] := columns[16];

end.
