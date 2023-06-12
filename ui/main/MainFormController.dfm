object MainForm: TMainForm
  Left = 517
  Top = 343
  Width = 688
  Height = 471
  Caption = 'MainForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 672
    Height = 412
    ActivePage = TabSheet4
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #1055#1091#1090#1077#1074#1099#1077' '#1083#1080#1089#1090#1099
    end
    object TabSheet2: TTabSheet
      Caption = #1042#1086#1076#1080#1090#1077#1083#1080
      ImageIndex = 1
    end
    object TabSheet3: TTabSheet
      Caption = #1044#1080#1089#1087#1077#1090#1095#1077#1088#1072
      ImageIndex = 2
    end
    object TabSheet4: TTabSheet
      Caption = #1040#1074#1090#1086
      ImageIndex = 3
      inline carsController: TCarsController
        Left = 0
        Top = 0
        Width = 664
        Height = 384
        Align = alClient
        TabOrder = 0
        inherited topPanel: TPanel
          Width = 664
        end
        inherited carsDBGrid: TDBGrid
          Width = 664
          Height = 343
        end
        inherited carsDataSource: TDataSource
          Left = 200
        end
        inherited carsADOQuery: TADOQuery
          Connection = ADOMainConnection
        end
      end
    end
    object TabSheet5: TTabSheet
      Caption = #1052#1086#1076#1077#1083#1080' '#1072#1074#1090#1086
      ImageIndex = 4
      inline carsModelsController: TCarsModelsController
        Left = 0
        Top = 0
        Width = 664
        Height = 384
        Align = alClient
        TabOrder = 0
        inherited _topPanel: TPanel
          Width = 664
        end
        inherited _carModelDBGrid: TDBGrid
          Width = 664
          Height = 343
        end
        inherited ADOQuery1: TADOQuery
          Connection = ADOMainConnection
        end
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 288
    Top = 224
    object configMenu: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      object configDBMenuItem: TMenuItem
        Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1057#1059#1041#1044
        OnClick = configDBMenuItemClick
      end
    end
    object dbConnectMenu: TMenuItem
      Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1041#1044
      object connectToDBMenuItem: TMenuItem
        Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1041#1044
        OnClick = connectToDBMenuItemClick
      end
    end
  end
  object ADOMainConnection: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Persist Security Info=False;User ID=test;Ini' +
      'tial Catalog=test1;Data Source=localhost;'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 364
    Top = 128
  end
end