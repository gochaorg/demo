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
  object MainMenu1: TMainMenu
    Left = 24
    Top = 16
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
end
