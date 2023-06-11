unit Logging;

interface

type
  // ������ ����
  ILog = interface
    procedure print( const messageText: string );
    procedure println( const messageText: string );
  end;

  // ��������� ������ ����
  TDummyLog = class(TInterfacedObject,ILog)
    procedure print( const messageText: string ); virtual;
    procedure println( const messageText: string ); virtual;
  end;

  // ������ � ��� ����
  TFileLog = class(TInterfacedObject,ILog)
    public
      constructor Create( fileName: WideString; appendFile:Boolean );
      destructor Close(); virtual;
      procedure print( const messageText: string ); virtual;
      procedure println( const messageText: string ); virtual;
    private
      textFile: TextFile;
  end;

  // ���������� �������� � ��������� ��� �����
  TPrefixBuilder = function():string of object;
  TPrefixLog = class(TInterfacedObject,ILog)
    private
      prefixBuilder: TPrefixBuilder;
      targetLog: ILog;
    public
      constructor Create( logTo:ILog; prefix:TPrefixBuilder );
      destructor Destroy(); override;
      procedure print( const messageText: string ); virtual;
      procedure println( const messageText: string ); virtual;
  end;

  // ����������� �������� � �������� ��� ������
  IConstPrefixLog = interface
    function getMessage():string;
  end;
  TConstPrefixLog = class(TInterfacedObject, IConstPrefixLog)
    private
      prefix: string;
    public
      constructor Create(text:string);
      destructor Destroy(); override;
      function getMessage():string;
  end;

  // ������� ����.����� � �������� ��� ������
  IDateTimePrefixLog = interface
    function getMessage():string;
  end;
  TDateTimePrefixLog = class(TInterfacedObject, IDateTimePrefixLog)
    private
    public
      constructor Create();
      destructor Destroy(); override;
      function getMessage():string;
  end;

var
  log: ILog;

implementation

uses
  SysUtils;

{ TDummyLog }

procedure TDummyLog.print(const messageText: string);
begin
  // no operation
end;

procedure TDummyLog.println(const messageText: string);
begin
  // no operation
end;

{ TFileLog }

constructor TFileLog.Create(fileName: WideString; appendFile:Boolean);
begin
  inherited Create();
  if appendFile then begin
    if not FileExists( fileName ) then
      begin
        AssignFile( textFile, fileName );
        Rewrite( textFile );
      end
    else
      begin
        AssignFile( textFile, fileName );
        Append( textFile );
      end;
    end
  else
    begin
      AssignFile( textFile, fileName );
      Rewrite( textFile );
    end;
end;

destructor TFileLog.Close;
begin
  CloseFile( textFile );
  inherited Destroy;
end;

procedure TFileLog.print(const messageText: string);
begin
  Write( textFile, messageText );
  Flush( textFile );
end;

procedure TFileLog.println( const messageText: string );
begin
  Writeln( textFile, messageText );
  Flush( textFile );
end;

{ TPrefixLog }

destructor TPrefixLog.Destroy;
begin
  self.prefixBuilder := nil;
  self.targetLog := nil;
  inherited Destroy;
end;

constructor TPrefixLog.Create(logTo: ILog; prefix: TPrefixBuilder);
begin
  inherited Create();
  self.targetLog := logTo;
  self.prefixBuilder := prefix;
end;

procedure TPrefixLog.print(const messageText: string);
var
  newMessage: string;
  prefixMessage: string;
begin
  prefixMessage := prefixBuilder();
  newMessage := prefixMessage + messageText;
  targetLog.print(newMessage);
end;

procedure TPrefixLog.println(const messageText: string);
var
  newMessage: string;
  prefixMessage: string;
begin
  prefixMessage := prefixBuilder();
  newMessage := prefixMessage + messageText;
  targetLog.println(newMessage);
end;

{ TConstPrefixLog }

constructor TConstPrefixLog.Create(text: string);
begin
  inherited Create();
  self.prefix := text;
end;

destructor TConstPrefixLog.Destroy;
begin
  inherited Destroy();
end;

function TConstPrefixLog.getMessage: string;
begin
  result := self.prefix;
end;

var
  prefixTest : TConstPrefixLog;

{ TDateTimePrefixLog }

constructor TDateTimePrefixLog.Create;
begin
  inherited Create();
end;

destructor TDateTimePrefixLog.Destroy;
begin
  inherited Destroy();
end;

function TDateTimePrefixLog.getMessage: string;
var
  time: TDateTime;
begin
  time := now();
  result := DateToStr(time) + ' ' + TimeToStr(time);
end;

initialization
  prefixTest := TConstPrefixLog.Create('[prefix] ');

  log := TFileLog.Create(GetCurrentDir()+'\app.log', false);
  log := TPrefixLog.Create(log, TConstPrefixLog.Create('[prefix] ').getMessage);
  
  log.println('start logging');

end.
