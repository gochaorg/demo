object DriversController: TDriversController
  Left = 0
  Top = 0
  Width = 427
  Height = 240
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 427
    Height = 41
    Align = alTop
    TabOrder = 0
    object refreshButton: TButton
      Left = 16
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 0
    end
    object newButton: TButton
      Left = 96
      Top = 8
      Width = 75
      Height = 25
      Caption = #1053#1086#1074#1099#1081
      TabOrder = 1
    end
    object editButton: TButton
      Left = 176
      Top = 8
      Width = 97
      Height = 25
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      TabOrder = 2
    end
    object deleteButton: TButton
      Left = 280
      Top = 8
      Width = 75
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 3
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 41
    Width = 427
    Height = 199
    Align = alClient
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
end
