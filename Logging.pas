unit Logging;

interface

type
  // Запись лога
  ILog = interface
    procedure print( const messageText: string );
    procedure println( const messageText: string );
  end;

  // Фиктивная запись лога
  TDummyLog = class(TInterfacedObject,ILog)
    procedure print( const messageText: string ); virtual;
    procedure println( const messageText: string ); virtual;
  end;

  // Запись в лог файл
  TFileLog = class(TInterfacedObject,ILog)
    public
      constructor Create( fileName: WideString; appendFile:Boolean );
      destructor Close(); virtual;
      procedure print( const messageText: string ); virtual;
      procedure println( const messageText: string ); virtual;
    private
      textFile: TextFile;
  end;

  // Добавление префикса в сообщения лог файла
  TPrefixBuilder = function():string of object;
  TPrefixLog = class(TInterfacedObject,ILog)
    private
      needPrefix: boolean;
      prefixBuilder: TPrefixBuilder;
      targetLog: ILog;
    public
      constructor Create( logTo:ILog; prefix:TPrefixBuilder );
      destructor Destroy(); override;
      procedure print( const messageText: string ); virtual;
      procedure println( const messageText: string ); virtual;
  end;

  // Константное значение в префиксе лог записи
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

  // Текущая дата.время в префиксе лог записи
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

constructor TPrefixLog.Create(logTo: ILog; prefix: TPrefixBuilder);
begin
  inherited Create();
  self.targetLog := logTo;
  self.prefixBuilder := prefix;
  self.needPrefix := true;
end;

destructor TPrefixLog.Destroy;
begin
  self.prefixBuilder := nil;
  self.targetLog := nil;
  inherited Destroy;
end;

procedure TPrefixLog.print(const messageText: string);
var
  newMessage: string;
  prefixMessage: string;
begin
  if self.needPrefix then
    begin
      self.needPrefix := false;
      prefixMessage := prefixBuilder();
      newMessage := prefixMessage + messageText;
      targetLog.print(newMessage);
    end
  else
    begin
      targetLog.print(messageText);
    end;
end;

procedure TPrefixLog.println(const messageText: string);
var
  newMessage: string;
  prefixMessage: string;
begin
  if self.needPrefix then
    begin
      prefixMessage := prefixBuilder();
      newMessage := prefixMessage + messageText;
      targetLog.println(newMessage);
    end
  else
    begin
      targetLog.println(messageText);
      self.needPrefix := true;
    end;
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
  log := TFileLog.Create(GetCurrentDir()+'\app.log', false);
  log := TPrefixLog.Create(log, TDateTimePrefixLog.Create.getMessage);
  log := TPrefixLog.Create(log, TConstPrefixLog.Create(' >> ').getMessage);

  log.println('start logging');

end.
