unit Config;

interface

uses SysUtils;

type
  // Конфигурация БД
  IDbConfig = interface
    // Имя пользователя DB
    function getDbUsername: WideString;
    procedure setDbUsername( user_name: WideString );
    property dbUsername : WideString
      read getDbUsername
      write setDbUsername;

    // Пароль пользователя DB
    function getDbPassword: WideString;
    procedure setDbPassword( password: WideString );
    property dbPassword : WideString
      read getDbPassword
      write setDbPassword;

    // Строка подключения к DB
    function getDbConnectionString: WideString;
    procedure setDbConnectionString( str:WideString );
    property dbConnectionString : WideString
      read getDbConnectionString
      write setDbConnectionString;
  end;

  // Сохранение конфигурации
  IConfigSave = interface
    // Сохранение настроек в файл config.ini в текущем каталоге
    // Ошибки
    //   В стучае ошибки генерирует исключение EConfigSave
    procedure Save();
  end;

  IConfig = interface(IDbConfig)
    // Возвращает кол-во ссылок - цель отладка
    function getRefCount: Integer;
  end;

  TConfig = class(TInterfacedObject, IConfig, IConfigSave)
  private
    // Имя пользователя DB
    dbUserNameValue : WideString;

    // Пароль пользователя DB
    dbPasswordValue : WideString;

    // Строка подключения к DB
    dbConnectionStringValue : WideString;
  public
    // Создание конфига со значениями по умолчанию
    constructor Create();

    // Конструктор копирования
    // Аргументы
    //   - sample - пример для копирования
    constructor Copy( const sample: TConfig );

    // Сохранение настроек
    // Аргументы
    //  - fileName - имя файла
    // Ошибки
    //   В стучае ошибки генерирует исключение EConfigSave
    procedure Save( const fileName: WideString ); overload;

    // Сохранение настроек в файл config.ini в текущем каталоге
    // Ошибки
    //   В стучае ошибки генерирует исключение EConfigSave
    procedure Save(); overload;

    // Чтение настроек
    // Аргументы
    //  - fileName - имя файла
    // Ошибки
    //   В стучае ошибки генерирует исключение EConfigLoad
    procedure Load( const fileName: WideString ); overload;

    // Чтение настроек из файла config.ini в текущем каталоге
    // если файл отсуствуюет используется значения по умолчанию
    // Ошибки
    //   В стучае ошибки генерирует исключение EConfigLoad
    procedure Load(); overload;

    // свойство dbUsername
    function getDbUsername: WideString;
    procedure setDbUsername( userName: WideString );

    // свойство dbPassword
    function getDbPassword: WideString;
    procedure setDbPassword( password: WideString );

    // свойство dbConnectionString
    function getDbConnectionString: WideString;
    procedure setDbConnectionString( str:WideString );
    
    function getRefCount(): Integer;
  end;

  // Ошибка сохранения конфига
  EConfigSave = class(Exception);

  // Ошибка чтения конфига
  EConfigLoad = class(Exception);

const
  DEFAULT_DB_USERNAME = 'username';
  DEFAULT_DB_CONNECTION_STRING = 'Provider=SQLOLEDB.1;'+
    'Persist Security Info=False;'+
    'User ID=username;'+
    'Initial Catalog=db_name;Data Source=host';
  DEFAULT_DB_PASSWORD = 'password';
  DEFAULT_CONFIG_FILENAME = 'config.init';

// Глобальные объекты  
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

// свойство dbConnectionString

function TConfig.getDbConnectionString: WideString;
begin
  result := self.dbConnectionStringValue;
end;

procedure TConfig.setDbConnectionString(str: WideString);
begin
  self.dbConnectionStringValue := str;
end;

// свойство dbPassword

function TConfig.getDbPassword: WideString;
begin
  result := self.dbPasswordValue;
end;

procedure TConfig.setDbPassword(password: WideString);
begin
  self.dbPasswordValue := password;
end;

// свойство DbUsername

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
 