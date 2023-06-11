unit Map;

interface

  uses
    SysUtils,
    Variants,
    Classes;

  type
    // ����-��������
    IStringMap = interface
      // ���������� ���-�� ���
      function count: Integer;

      // ���������� �������� �� ���������� �����
      function get( name:string ):variant;

      // �������� ������� �����
      function exists( name:string ):boolean;

      // ��������� ����� ����� �� ��� ������� (0 - ������)
      function key( index:Integer ):string;

      // ����������/������ ��������
      // ��������
      //   name - ����
      //   ��������
      // �����������
      //   ���������� ��������
      function put( name:string; value:variant ):variant;

      // �������� ��������
      // ��������
      //   name - ����
      // �����������
      //   ���������� ��������
      function delete( name:string ):variant;

      function toString(): WideString;
    end;
    TStringMap = class(TInterfacedObject, IStringMap)
      private
        list: TList;
      public
        constructor Create();
        destructor Destroy(); override;

        function count: Integer; virtual;
        function get( name:string ):variant; virtual;
        function exists( name:string ):boolean; virtual;
        function key( index:Integer ):string; virtual;

        function put( name:string; value:variant ):variant; virtual;
        function delete( name:string ):variant; virtual;

        function toString(): WideString; virtual;
    end;

    IStringPair = interface(IInterface)
      function getName(): string;
      property name:string read getName;

      function getValue(): variant;
      procedure setValue( value:variant );
      property value:variant read getValue write setValue;
    end;
    TStringPair = class(TInterfacedObject, IStringPair, IInterface)
      private
        name:string;
        value:variant;
      public
        constructor Create( name:string; value:variant );
        destructor Destroy(); override;

        function getName(): string;
        function getValue(): variant;
        procedure setValue( value:variant );
    end;

implementation

{ TStringPair }

constructor TStringPair.Create(name: string; value: variant);
begin
  inherited Create();

  self.name := name;
  self.value := value;
end;

destructor TStringPair.Destroy;
begin
  inherited Destroy;
end;

function TStringPair.getName: string;
begin
  result := self.name;
end;

function TStringPair.getValue: variant;
begin
  result := self.value;
end;

procedure TStringPair.setValue(value: variant);
begin
  self.value := value;
end;

{ TStringMap }

constructor TStringMap.Create;
begin
  inherited Create();
  list := TList.Create();
end;

destructor TStringMap.Destroy;
var
  i:Integer;
  pair: TStringPair;
begin
  for i:=0 to list.Count-1 do begin
    pair := list.Items[i];
    FreeAndNil(pair);
  end;
  list.Clear;

  FreeAndNil(list);
  inherited Destroy;
end;

function TStringMap.count: Integer;
begin
  result := list.Count;
end;

function TStringMap.exists(name: string): boolean;
var
  i: Integer;
  pair: TStringPair;
begin
  result := false;
  for i:=0 to list.Count-1 do begin
    pair := list.Items[i];
    if pair.name = name then begin
      result := true;
      break;
    end;
  end;
end;

function TStringMap.get(name: string): variant;
var
  i: Integer;
  pair: TStringPair;
begin
  result := Unassigned();
  for i:=0 to list.Count-1 do begin
    pair := list.Items[i];
    if pair.name = name then begin
      result := pair.value;
      break;
    end;
  end;
end;

function TStringMap.key( index:Integer ):string;
var
  i: Integer;
  pair: TStringPair;
begin
  if index<0 then
    begin
      result := '';
    end
  else
    begin
      if index>=list.Count then
        begin
          result := '';
        end
      else
        begin
          pair := list.Items[index];
          result := pair.name;
        end;
    end;
end;

function TStringMap.delete(name: string): variant;
var
  i: Integer;
  pair: TStringPair;
begin
  result := Unassigned();
  for i:=0 to list.Count-1 do begin
    pair := list.Items[i];
    if pair.name = name then begin
      result := pair.value;
      list.Delete(i);
      break;
    end;
  end;
end;

function TStringMap.put(name: string; value: variant): variant;
var
  i: Integer;
  pair: TStringPair;
  found: boolean;
begin
  result := Unassigned();
  found := false;
  for i:=0 to list.Count-1 do begin
    pair := list.Items[i];
    if pair.name = name then begin
      result := pair.value;
      pair.value := value;
      found := true;
      break;
    end;
  end;

  if not found then begin
    pair := TStringPair.Create(name, value);
    list.Add(pair);
  end;
end;

function TStringMap.toString(): WideString;
var
  i: Integer;
  pair: TStringPair;
  str: PChar;
  value: WideString;
  tstr: TStringList;
begin
  tstr := TStringList.Create;
  tstr.Append('{');

  str := WideString('{');
  for i:=0 to list.Count-1 do begin
    pair := list.Items[i];
    if i>0 then begin
      str := concat(str, WideString(', '));
      tstr.Append(', ');
    end;
    str := format('%s%s',[str,PChar(pair.name)]);
    tstr.Append(pair.name);

    str := concat(str,WideString(':'));
    tstr.Append(':');

    value := WideString(VarToStr(pair.value));
    tstr.Append(VarToStr(pair.value));

    str := concat(str,value);
  end;
  str := concat(str,WideString('}'));
  tstr.Append('}');
  // tstr.Text;

  result := tstr.Text;
end;

end.
