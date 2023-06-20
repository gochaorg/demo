unit WaybillSQLView;

// ������� SQL �� ������ � �������� �������
// ����������� �������� � ����

interface

uses
  SysUtils, ADODB, Variants,

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
  function build:IWaybillsQuery;

  function getHistory:boolean;
  procedure setHistory(show:boolean);
  property history:boolean read getHistory write setHistory;

end;

TWaybillsQueryBuilder = class(TInterfacedObject, IWaybillsQueryBuilder)
  private
    withHistoryValue: boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function getHistory:boolean;
    procedure setHistory(show:boolean);
    property history:boolean read getHistory write setHistory;

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
var
  i:Integer;
  name:String;
  value:variant;
begin
  log.println('query.Active := false');
  query.Active := false;

  log.println('query.Parameters.Clear');
  query.Parameters.Clear;

  log.println('query.SQL.Text := '+self.sql);
  query.SQL.Text := self.sql;

  for i:=0 to (self.params.count-1) do begin
    name := self.params.key(i);
    value := self.params.get(name);

    log.println('query param '+name+' = '+VarToStr(value));
    query.Parameters.ParamByName(name).Value := value;
  end;

  log.println('query.Active := true');
  query.Active := true;
end;

constructor TWaybillsQuery.Create(sql: WideString; params: TStringMap);
begin
  inherited Create;
  self.sql := sql;
  self.params := params;
  log.println('TWaybillsQuery.Create');
end;

destructor TWaybillsQuery.Destroy;
begin
  log.println('TWaybillsQuery.Destroy');
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
  // ������������ �������
  sql := 'select ' +
    columnsExp(columns) +
    ' from '+
    ' waybills w '+
    ' left join drivers dr on (dr.id = w.driver) '+
    ' left join dispatchers ds on (ds.id = w.dispatcher) '+
    ' left join cars c on (c.id = w.car) '+
    ' left join cars_model cm on (c.model = cm.id) '
    ;

  // ������������ ������  
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


function TWaybillsQueryBuilder.getHistory: boolean;
begin
  result := self.withHistoryValue;
end;

procedure TWaybillsQueryBuilder.setHistory(show: boolean);
begin
  self.withHistoryValue := show;
  log.println('setHistory '+BoolToStr(show));
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

// ������� ���������� ������
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

// ������� ������������ ������
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
