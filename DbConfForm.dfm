object DbConfController: TDbConfController
  Left = 1198
  Top = 174
  Width = 413
  Height = 377
  Caption = 'DbConfController'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    397
    338)
  PixelsPerInch = 96
  TextHeight = 13
  object passwordLabel: TLabel
    Left = 8
    Top = 120
    Width = 37
    Height = 13
    Caption = #1055#1072#1088#1086#1083#1100
  end
  object passwordEdit: TEdit
    Left = 8
    Top = 137
    Width = 376
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    PasswordChar = '*'
    TabOrder = 0
    Text = 'passwordEdit'
  end
  object userNameEdit: TLabeledEdit
    Left = 8
    Top = 81
    Width = 376
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 72
    EditLabel.Height = 13
    EditLabel.Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
    TabOrder = 1
  end
  object connectionStringEdit: TLabeledEdit
    Left = 8
    Top = 25
    Width = 376
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 194
    EditLabel.Height = 13
    EditLabel.Caption = #1057#1090#1088#1086#1082#1072' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103' / Connection string'
    TabOrder = 2
  end
  object testConnectionButton: TButton
    Left = 8
    Top = 176
    Width = 177
    Height = 25
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1077
    TabOrder = 3
    OnClick = testConnectionButtonClick
  end
  object applyButton: TButton
    Left = 246
    Top = 176
    Width = 137
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 4
  end
  object closeButton: TButton
    Left = 246
    Top = 208
    Width = 137
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 5
  end
  object ADOConnectionTest: TADOConnection
    Left = 16
    Top = 224
  end
end
