object MainForm: TMainForm
  Left = 765
  Top = 146
  Width = 760
  Height = 486
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
    Width = 744
    Height = 427
    ActivePage = TabSheet3
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
    end
    object TabSheet5: TTabSheet
      Caption = #1052#1086#1076#1077#1083#1080' '#1072#1074#1090#1086
      ImageIndex = 4
      object autoModelDBGrid: TDBGrid
        Left = 0
        Top = 41
        Width = 736
        Height = 358
        Align = alClient
        DataSource = autoModelDataSource
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 736
        Height = 41
        Align = alTop
        Caption = 'Panel1'
        TabOrder = 1
        object Button1: TButton
          Left = 16
          Top = 8
          Width = 75
          Height = 25
          Caption = 'Button1'
          TabOrder = 0
          OnClick = Button1Click
        end
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 600
    Top = 312
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
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Left = 668
    Top = 48
  end
  object autoModelDataSource: TDataSource
    AutoEdit = False
    Left = 540
    Top = 144
  end
end
