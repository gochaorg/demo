unit DriverSQL;

interface

uses
  SysUtils,
  DMLOperation,
  Validation;

type

// ������ ��������/��������� ��� ���������� ��������
EDriverDataBuilder = class(Exception);

// ������ ���������
// ��� �������� ���� ������� insert ���� update
IDriverDataBuilder = interface
  // ����� ���������, ���� ������ ������� ��������
  procedure Reset;

  procedure setName(name:WideString);
  procedure setBirthDay(date:WideString); overload;
  procedure setBirthDay(date:TDateTime); overload;

  // �������� ������ ����� INSERT
  function ValidateInsert: IDataValidation;

  // ������� �������� INSERT.
  // ���� ����� ������ ������� �� �����,
  //   �� ���������� ���������� EDriverDataBuilder
  function BuildInsert: IDMLOperation;

  // �������� ������ ����� UPDATE
  function ValidateUpdate: IDataValidation;

  // ������� �������� UPDATE.
  // ���� ����� ������ ������� �� �����,
  //   �� ���������� ���������� EDriverDataBuilder
  function BuildUpdate: IDMLOperation;
end;

implementation

end.
