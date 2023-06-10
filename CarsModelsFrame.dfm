object CarsModelsController: TCarsModelsController
  Left = 0
  Top = 0
  Width = 548
  Height = 329
  TabOrder = 0
  object _topPanel: TPanel
    Left = 0
    Top = 0
    Width = 548
    Height = 41
    Align = alTop
    TabOrder = 0
    object _refreshButton: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 0
      OnClick = _refreshButtonClick
    end
    object _newButton: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
      OnClick = _newButtonClick
    end
    object _editButton: TButton
      Left = 168
      Top = 8
      Width = 97
      Height = 25
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      TabOrder = 2
      OnClick = _editButtonClick
    end
    object _deleteButton: TButton
      Left = 272
      Top = 8
      Width = 75
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 3
    end
  end
  object _carModelDBGrid: TDBGrid
    Left = 0
    Top = 41
    Width = 548
    Height = 288
    Align = alClient
    DataSource = _DataSource
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnTitleClick = _carModelDBGridTitleClick
  end
  object _DataSource: TDataSource
    AutoEdit = False
    DataSet = ADOQuery1
    Left = 200
    Top = 160
  end
  object ADOQuery1: TADOQuery
    CursorLocation = clUseServer
    Parameters = <>
    SQL.Strings = (
      'select * from cars_model')
    Left = 256
    Top = 96
  end
end
