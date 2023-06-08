unit Config;

interface

uses SysUtils;

type
  TConfig = class(TObject)
  public
    // Имя пользователя DB
    dbUserName : WideString;

    // Пароль пользователя DB
    dbPassword : WideString;

    // Строка подключения к DB
    dbConnectionString : WideString;
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
    //   В стучае ошибки генерирует исключение EConfigLoad
    procedure Save(); overload;

    // Чтение настроек
    // Аргументы
    //  - fileName - имя файла
    // Ошибки
    //   В стучае ошибки генерирует исключение EConfigSave
    procedure Load( const fileName: WideString ); overload;

    // Чтение настроек из файла config.ini в текущем каталоге
    // если файл отсуствуюет используется значения по умолчанию
    // Ошибки
    //   В стучае ошибки генерирует исключение EConfigLoad
    procedure Load(); overload;
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

implementation

uses
   IniFiles;

const
  DB_SECTION = 'db';
  DB_USERNAME_KEY = 'user-name';
  DB_PASSWORD_KEY = 'password';
  DB_CONNECTION_STRING_KEY = 'connection-string';

{ TConfig }

constructor TConfig.Copy(const sample: TConfig);
begin
  Inherited Create();
  dbConnectionString := sample.dbConnectionString;
  dbUserName := sample.dbUserName;
  dbPassword := sample.dbPassword;
end;

constructor TConfig.Create;
begin
  Inherited Create();
  DbConnectionString := DEFAULT_DB_CONNECTION_STRING;
  DbUserName := DEFAULT_DB_USERNAME;
  DbPassword := DEFAULT_DB_PASSWORD;
end;

procedure TConfig.Load(const fileName: WideString);
var
  iniFile: TIniFile;
begin
  try
    try
      iniFile := TIniFile.Create(fileName);
      DbConnectionString := iniFile.ReadString(DB_SECTION, DB_CONNECTION_STRING_KEY, DEFAULT_DB_CONNECTION_STRING);
      DbUserName := iniFile.ReadString(DB_SECTION, DB_USERNAME_KEY, DEFAULT_DB_USERNAME);
      DbPassword := iniFile.ReadString(DB_SECTION, DB_PASSWORD_KEY, DEFAULT_DB_PASSWORD);
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
      iniFile.WriteString(DB_SECTION, DB_CONNECTION_STRING_KEY, DbConnectionString);
      iniFile.WriteString(DB_SECTION, DB_USERNAME_KEY, DbUserName);
      iniFile.WriteString(DB_SECTION, DB_PASSWORD_KEY, DbPassword);
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

end.
 