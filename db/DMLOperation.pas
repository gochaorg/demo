unit DMLOperation;

interface

uses
  DB, ADODB, SysUtils,

  Logging,
  Map;

type

// Функции для добавления / обновления информации о сущности в БД
// Представляет информацию о машине
IDMLOperation = interface
  // Выполнение операции
  // Аргументы
  //   connection - Соединение с БД
  // Возвращает
  //   id добавленной или обновленной записи
  function Execute( connection: TADOConnection ): Variant;

  function Run( query: TADOQuery ): Variant;
end;

// Выполнение операции Insert и получение сгенерированного идентификатора
TSqlInsertOperation = class(TInterfacedObject,IDMLOperation)
  private
    sql: WideString;
    params: TStringMap;
    generatedIdColumn: WideString;
  public
    // Конструктор
    // Аргументы
    //   sql - Запрос
    //   params - Параметры
    //   generatedIdColumn - название колонки в
    //                       выборке содержащаяя идентификатор
    constructor Create(
      sql:WideString;
      params:TStringMap;
      generatedIdColumn: WideString
    );
    destructor Destroy; override;
    function Execute( connection: TADOConnection ): Variant;
    function Run( query: TADOQuery ): Variant;
end;

implementation

{ TSqlExecOperation }

constructor TSqlInsertOperation.Create(
  sql: WideString;
  params: TStringMap;
  generatedIdColumn: WideString
);
begin
  inherited Create;
  self.sql := sql;
  self.params := params;
  self.generatedIdColumn := generatedIdColumn;
end;

destructor TSqlInsertOperation.Destroy;
begin
  FreeAndNil(self.params);
  inherited Destroy;
end;

function TSqlInsertOperation.Execute(connection: TADOConnection): Variant;
var
  query: TADOQuery;
  name: String;
  i: Integer;
  p: TParameter;
begin
  query := TADOQuery.Create(nil);
  try
    query.Connection := connection;
    log.println('self.sql '+self.sql);

    {query.EnableBCD := True;
    query.AutoCalcFields := true;
    query.Filtered := false;

    query.ParamCheck := false;

    query.SQL.BeginUpdate;
    query.SQL.Add( self.sql );
    query.SQL.EndUpdate;

    for i:=0 to self.params.count - 1 do begin
      name := self.params.key(i);
      //query.Parameters.CreateParameter(name,ftUnknown,pdInput,0,self.params.get(name));
      p := query.Parameters.AddParameter;
      p.Name := name;
      p.Value := self.params.get(name);
      //query.Parameters.ParamByName(name).Value := self.params.get(name);
    end;
    query.Parameters.Refresh;

    //query.ParamCheck := true;
    }

    query.Close;
    query.ParamCheck := false;
    query.SQL.BeginUpdate;
     query.SQL.Text := 'insert into cars '+
      '(legal_number, model, wear, bearth_year, maintenance) '+
      'values ( ? , ? , ? , ? , convert( datetime2, ?, 23 ));'+
      'select @@IDENTITY as _id';
    query.SQL.EndUpdate;
    query.ParamCheck := true;

    p := query.Parameters.AddParameter;
    p.DataType := ftString;
    p.Value := 'gos num 2';

    p := query.Parameters.AddParameter;
    p.DataType := ftInteger;
    p.Value := 11;

    p := query.Parameters.AddParameter;
    p.DataType := ftInteger;
    p.Value := 1010;

    p := query.Parameters.AddParameter;
    p.DataType := ftInteger;
    p.Value := 2020;

    p := query.Parameters.AddParameter;
    p.DataType := ftString;
    p.Value := '2022-01-01';

    query.Parameters.Refresh;

    query.Open;
    query.First;
    while not query.Eof do begin
      result := query.FieldByName(self.generatedIdColumn).Value;
      query.Next;
    end;
    query.Close;
  finally
    query.Connection := nil;
    FreeAndNil(query);
  end;
end;

function TSqlInsertOperation.Run(query: TADOQuery): Variant;
begin
  query.Close;

  try
    query.Open;
    query.First;
    while not query.Eof do begin
      result := query.FieldByName(self.generatedIdColumn).Value;
      query.Next;
    end;
    query.Close;
  finally
    query.Connection := nil;
    FreeAndNil(query);
  end;
end;

end.
