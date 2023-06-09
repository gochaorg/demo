unit Config;

interface

uses SysUtils;

type
  // ������������ ��
  IDbConfig = interface
    // ��� ������������ DB
    function getDbUsername: WideString;
    procedure setDbUsername( user_name: WideString );
    property dbUsername : WideString
      read getDbUsername
      write setDbUsername;

    // ������ ������������ DB
    function getDbPassword: WideString;
    procedure setDbPassword( password: WideString );
    property dbPassword : WideString
      read getDbPassword
      write setDbPassword;

    // ������ ����������� � DB
    function getDbConnectionString: WideString;
    procedure setDbConnectionString( str:WideString );
    property dbConnectionString : WideString
      read getDbConnectionString
      write setDbConnectionString;
  end;

  // ���������� ������������
  IConfigSave = interface
    // ���������� �������� � ���� config.ini � ������� ��������
    // ������
    //   � ������ ������ ���������� ���������� EConfigSave
    procedure Save();
  end;

  IConfig = interface(IDbConfig)
    // ���������� ���-�� ������ - ���� �������
    function getRefCount: Integer;
  end;

  TConfig = class(TInterfacedObject, IConfig, IConfigSave)
  private
    // ��� ������������ DB
    dbUserNameValue : WideString;

    // ������ ������������ DB
    dbPasswordValue : WideString;

    // ������ ����������� � DB
    dbConnectionStringValue : WideString;
  public
    // �������� ������� �� ���������� �� ���������
    constructor Create();

    // ����������� �����������
    // ���������
    //   - sample - ������ ��� �����������
    constructor Copy( const sample: TConfig );

    // ���������� ��������
    // ���������
    //  - fileName - ��� �����
    // ������
    //   � ������ ������ ���������� ���������� EConfigSave
    procedure Save( const fileName: WideString ); overload;

    // ���������� �������� � ���� config.ini � ������� ��������
    // ������
    //   � ������ ������ ���������� ���������� EConfigSave
    procedure Save(); overload;

    // ������ ��������
    // ���������
    //  - fileName - ��� �����
    // ������
    //   � ������ ������ ���������� ���������� EConfigLoad
    procedure Load( const fileName: WideString ); overload;

    // ������ �������� �� ����� config.ini � ������� ��������
    // ���� ���� ����������� ������������ �������� �� ���������
    // ������
    //   � ������ ������ ���������� ���������� EConfigLoad
    procedure Load(); overload;

    // �������� dbUsername
    function getDbUsername: WideString;
    procedure setDbUsername( userName: WideString );

    // �������� dbPassword
    function getDbPassword: WideString;
    procedure setDbPassword( password: WideString );

    // �������� dbConnectionString
    function getDbConnectionString: WideString;
    procedure setDbConnectionString( str:WideString );
    
    function getRefCount(): Integer;
  end;

  // ������ ���������� �������
  EConfigSave = class(Exception);

  // ������ ������ �������
  EConfigLoad = class(Exception);

const
  DEFAULT_DB_USERNAME = 'username';
  DEFAULT_DB_CONNECTION_STRING = 'Provider=SQLOLEDB.1;'+
    'Persist Security Info=False;'+
    'User ID=username;'+
    'Initial Catalog=db_name;Data Source=host';
  DEFAULT_DB_PASSWORD = 'password';
  DEFAULT_CONFIG_FILENAME = 'config.init';

// ���������� �������  
var
  applicationConfigObj : TConfig;
  applicationConfigItf : IConfig;
  applicationConfigSaveItf : IConfigSave;

implementation

uses
   IniFiles, Dialogs;

const
  DB_SECTION = 'db';
  DB_USERNAME_KEY = 'user-name';
  DB_PASSWORD_KEY = 'password';
  DB_CONNECTION_STRING_KEY = 'connection-string';

{ TConfig }

constructor TConfig.Copy(const sample: TConfig);
begin
  Inherited Create();
  dbConnectionStringValue := sample.dbConnectionStringValue;
  dbUserNameValue := sample.dbUserNameValue;
  dbPasswordValue := sample.dbPasswordValue;
end;

constructor TConfig.Create;
begin
  Inherited Create();
  dbConnectionStringValue := DEFAULT_DB_CONNECTION_STRING;
  dbUserNameValue := DEFAULT_DB_USERNAME;
  dbPasswordValue := DEFAULT_DB_PASSWORD;
end;

procedure TConfig.Load(const fileName: WideString);
var
  iniFile: TIniFile;
begin
  try
    try
      iniFile := TIniFile.Create(fileName);
      dbConnectionStringValue := iniFile.ReadString(DB_SECTION, DB_CONNECTION_STRING_KEY, DEFAULT_DB_CONNECTION_STRING);
      dbUserNameValue := iniFile.ReadString(DB_SECTION, DB_USERNAME_KEY, DEFAULT_DB_USERNAME);
      dbPasswordValue := iniFile.ReadString(DB_SECTION, DB_PASSWORD_KEY, DEFAULT_DB_PASSWORD);
    except
      on e: EIniFileException do raise EConfigLoad.Create(e.Message);
    end;    
  finally
    FreeAndNil( iniFile );
  end;
end;

procedure TConfig.Save(const fileName: WideString);
var
  iniFile: TIniFile;
begin
  try
    try
      iniFile := TIniFile.Create(fileName);
      iniFile.WriteString(DB_SECTION, DB_CONNECTION_STRING_KEY, dbConnectionStringValue);
      iniFile.WriteString(DB_SECTION, DB_USERNAME_KEY, dbUserNameValue);
      iniFile.WriteString(DB_SECTION, DB_PASSWORD_KEY, dbPasswordValue);
    except
      on e: EIniFileException do raise EConfigSave.Create(e.Message);
    end;  
  finally
    FreeAndNil( iniFile );
  end;
end;

procedure TConfig.Save;
begin
  Save( GetCurrentDir() + '\\' + 'config.ini' );
end;

procedure TConfig.Load;
begin
  Load( GetCurrentDir() + '\\' + 'config.ini' );
end;

// �������� dbConnectionString

function TConfig.getDbConnectionString: WideString;
begin
  result := self.dbConnectionStringValue;
end;

procedure TConfig.setDbConnectionString(str: WideString);
begin
  self.dbConnectionStringValue := str;
end;

// �������� dbPassword

function TConfig.getDbPassword: WideString;
begin
  result := self.dbPasswordValue;
end;

procedure TConfig.setDbPassword(password: WideString);
begin
  self.dbPasswordValue := password;
end;

// �������� DbUsername

function TConfig.getDbUsername: WideString;
begin
  result := self.dbUserNameValue;
end;

procedure TConfig.setDbUsername(userName: WideString);
begin
  self.dbUserNameValue := userName;
end;

function TConfig.getRefCount: Integer;
begin
  result := RefCount;
end;

initialization
applicationConfigObj := TConfig.Create();

applicationConfigItf := applicationConfigObj;
applicationConfigSaveItf := applicationConfigObj;

end.
 