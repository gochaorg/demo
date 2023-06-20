object waybillsController: TwaybillsController
  Left = 0
  Top = 0
  Width = 611
  Height = 265
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 611
    Height = 41
    Align = alTop
    TabOrder = 0
    object newButton: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Caption = #1053#1086#1074#1099#1081
      Enabled = False
      TabOrder = 0
      OnClick = newButtonClick
    end
    object editButton: TButton
      Left = 168
      Top = 8
      Width = 97
      Height = 25
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      Enabled = False
      TabOrder = 1
      OnClick = editButtonClick
    end
    object deleteButton: TButton
      Left = 272
      Top = 8
      Width = 75
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Enabled = False
      TabOrder = 2
      OnClick = deleteButtonClick
    end
    object refreshButton: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Enabled = False
      TabOrder = 3
      OnClick = refreshButtonClick
    end
    object showHistoryCheckBox: TCheckBox
      Left = 352
      Top = 16
      Width = 68
      Height = 17
      Caption = #1048#1089#1090#1086#1088#1080#1103
      TabOrder = 4
      OnClick = showHistoryCheckBoxClick
    end
  end
  object waybillsDBGrid: TDBGrid
    Left = 0
    Top = 41
    Width = 611
    Height = 224
    Align = alClient
    DataSource = waybillsDataSource
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnColEnter = waybillsDBGridColEnter
    OnDrawColumnCell = waybillsDBGridDrawColumnCell
  end
  object waybillsDataSource: TDataSource
    AutoEdit = False
    DataSet = waybillsADOQuery
    Left = 96
    Top = 112
  end
  object waybillsADOQuery: TADOQuery
    Parameters = <>
    SQL.Strings = (
      'select '
      #9'w.id,'
      #9'w.car as car_id,'
      #9'c.model as car_model_id,'
      #9'cm.name as car_model_name,'
      
        #9'(select sum(wear) from waybills where car = w.car) + c.wear as ' +
        'car_total_wear,'
      #9'c.legal_number as car_legal_number,'
      #9'w.driver as driver_id,'
      #9'dr.name as driver_name,'
      #9'w.dispatcher as dispatcher_id,'
      #9'ds.name as dispatcher_name,'
      #9'w.outcome_date,'
      
        #9'convert( nvarchar(100), w.outcome_date, 23 ) + '#39' '#39' + convert( n' +
        'varchar(50), w.outcome_date, 108 ) as outcome_date_s,'
      #9'w.income_date,'
      
        #9'convert( nvarchar(100), w.income_date, 23 ) + '#39' '#39' + convert( nv' +
        'archar(50), w.income_date, 108 ) as income_date_s,'
      #9'w.fuel_cons,'
      #9'w.wear'
      'from '
      #9'waybills w'
      #9'left join drivers dr on (dr.id = w.driver)'
      #9'left join dispatchers ds on (ds.id = w.dispatcher)'
      #9'left join cars c on (c.id = w.car)'
      #9'left join cars_model cm on (c.model = cm.id)')
    Left = 192
    Top = 72
  end
end
