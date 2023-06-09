unit Log;

interface

type
  // ������ ����
  ILog = interface
    procedure print( const messageText: string );
  end;

  // ��������� ������ ����
  TDummyLog = class(TInterfacedObject,ILog)
    procedure print( const messageText: string ); virtual;
  end;

  // ������ � ��� ����
  TFileLog = class(TInterfacedObject,ILog)
    public
      constructor Create( fileName: WideString );
      destructor Close(); virtual;
      procedure print( const messageText: string ); virtual;
    private
      textFile: TextFile;  
  end;

implementation

{ TDummyLog }

procedure TDummyLog.print(const messageText: string);
begin
  // no operation  
end;

{ TFileLog }

constructor TFileLog.Create(fileName: WideString);
begin
  AssignFile( textFile, fileName );
  Append( textFile );
end;

destructor TFileLog.Close;
begin
  CloseFile( textFile );
end;

procedure TFileLog.print(const messageText: string);
begin
  Write( textFile, messageText );
  Flush( textFile );
end;

end.
 