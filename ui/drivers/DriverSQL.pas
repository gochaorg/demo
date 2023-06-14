unit DriverSQL;

interface

uses
  SysUtils,
  DMLOperation,
  Validation;

type

// Ошибка создания/валидации при построение операций
EDriverDataBuilder = class(Exception);

// Шаблон строитель
// для создания либо запроса insert либо update
IDriverDataBuilder = interface
  // Сброс состояния, надо заново указать значения
  procedure Reset;

  procedure setName(name:WideString);
  procedure setBirthDay(date:WideString); overload;
  procedure setBirthDay(date:TDateTime); overload;

  // Проверка данных перед INSERT
  function ValidateInsert: IDataValidation;

  // Создает операцию INSERT.
  // Если какие данные указаны не верно,
  //   то генерирует исключение EDriverDataBuilder
  function BuildInsert: IDMLOperation;

  // Проверка данных перед UPDATE
  function ValidateUpdate: IDataValidation;

  // Создает операцию UPDATE.
  // Если какие данные указаны не верно,
  //   то генерирует исключение EDriverDataBuilder
  function BuildUpdate: IDMLOperation;
end;

implementation

end.
