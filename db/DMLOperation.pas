unit DMLOperation;

interface

uses
  DB, ADODB, SysUtils,

  Logging,
  Map;

type

// ������� ��� ���������� / ���������� ���������� � �������� � ��
// ������������ ���������� � ������
IDMLOperation = interface
  // ���������� ��������
  // ���������
  //   connection - ���������� � ��
  // ����������
  //   id ����������� ��� ����������� ������
  function Execute( connection: TADOConnection ): Variant;

  function Run( query: TADOQuery ): Variant;
end;

// ���������� �������� Insert � ��������� ���������������� ��������������
TSqlInsertOperation = class(TInterfacedObject,IDMLOperation)
  private
    sql: WideString;
    params: TStringMap;
    generatedIdColumn: WideString;
  public
    // �����������
    // ���������
    //   sql - ������
    //   params - ���������
    //   generatedIdColumn - �������� ������� �
    //                       ������� ����������� �������������
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

    query.SQL.Text := self.sql;
    for i:=0 to self.params.count - 1 do begin
      name := self.params.key(i);
      query.Parameters.ParamByName(name).Value := self.params.get(name);
    end;

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
var
  i:Integer;
  name:string;
  p: TParameter;
begin
    query.Close;
    query.Parameters.Clear;
    query.SQL.Clear;
    query.SQL.Add(self.sql);

    for i:=0 to self.params.count - 1 do begin
      name := self.params.key(i);
      //query.Parameters.CreateParameter(name,ftUnknown,pdInput,0,self.params.get(name));

      //p := query.Parameters.AddParameter;
      //p.Name := name;
      //p.Value := self.params.get(name);

      query.Parameters.ParamByName(name).Value := self.params.get(name);
    end;

    query.Open;
    query.First;
    while not query.Eof do begin
      result := query.FieldByName(self.generatedIdColumn).Value;
      query.Next;
    end;
    query.Close;
end;

end.
