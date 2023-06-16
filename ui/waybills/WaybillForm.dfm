object WaybillController: TWaybillController
  Left = 612
  Top = 142
  Width = 426
  Height = 576
  Caption = 'WaybillController'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object outcomeDatetimeEdit: TLabeledEdit
    Left = 8
    Top = 24
    Width = 185
    Height = 21
    EditLabel.Width = 71
    EditLabel.Height = 13
    EditLabel.Caption = #1042#1088#1077#1084#1103' '#1074#1099#1077#1079#1076#1072
    TabOrder = 0
  end
  object incomeDatetimeEdit: TLabeledEdit
    Left = 200
    Top = 24
    Width = 201
    Height = 21
    EditLabel.Width = 101
    EditLabel.Height = 13
    EditLabel.Caption = #1042#1088#1077#1084#1103' '#1074#1086#1079#1074#1088#1072#1097#1077#1085#1080#1103
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 8
    Top = 48
    Width = 393
    Height = 233
    TabOrder = 2
    object Splitter1: TSplitter
      Left = 186
      Top = 1
      Height = 231
    end
    object dispatcherGroupBox: TGroupBox
      Left = 1
      Top = 1
      Width = 185
      Height = 231
      Align = alLeft
      Caption = #1044#1080#1089#1087#1077#1090#1095#1077#1088
      TabOrder = 0
      object dispatchersListBox: TListBox
        Left = 2
        Top = 40
        Width = 181
        Height = 189
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
      end
      object dispatcherPanel: TPanel
        Left = 2
        Top = 15
        Width = 181
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          181
          25)
        object dispatcherFindButton: TButton
          Left = 115
          Top = 1
          Width = 61
          Height = 21
          Anchors = [akTop, akRight]
          Caption = #1053#1072#1081#1090#1080
          TabOrder = 0
        end
        object dispatcherEdit: TEdit
          Left = 4
          Top = 1
          Width = 108
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          Text = '%'
        end
      end
    end
    object driverGroupBox: TGroupBox
      Left = 189
      Top = 1
      Width = 203
      Height = 231
      Align = alClient
      Caption = #1042#1086#1076#1080#1090#1077#1083#1100
      TabOrder = 1
      object driversListBox: TListBox
        Left = 2
        Top = 40
        Width = 199
        Height = 189
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
      end
      object driverFindPanel: TPanel
        Left = 2
        Top = 15
        Width = 199
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          199
          25)
        object driverFindButton: TButton
          Left = 133
          Top = 1
          Width = 61
          Height = 21
          Anchors = [akTop, akRight]
          Caption = #1053#1072#1081#1090#1080
          TabOrder = 0
        end
        object driverEdit: TEdit
          Left = 4
          Top = 1
          Width = 125
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          Text = '%'
        end
      end
    end
  end
  object carGroupBox: TGroupBox
    Left = 8
    Top = 288
    Width = 393
    Height = 153
    Caption = 'carGroupBox'
    TabOrder = 3
    DesignSize = (
      393
      153)
    object carEdit: TEdit
      Left = 8
      Top = 16
      Width = 301
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = '%'
    end
    object carsListBox: TListBox
      Left = 8
      Top = 40
      Width = 377
      Height = 105
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 1
    end
    object carFindButton: TButton
      Left = 312
      Top = 16
      Width = 73
      Height = 20
      Anchors = [akTop, akRight]
      Caption = #1053#1072#1081#1090#1080
      TabOrder = 2
    end
  end
  object wearEdit: TLabeledEdit
    Left = 8
    Top = 464
    Width = 185
    Height = 21
    EditLabel.Width = 59
    EditLabel.Height = 13
    EditLabel.Caption = #1056#1072#1089#1090#1088#1086#1103#1085#1080#1077
    TabOrder = 4
  end
  object fuelConsEdit: TLabeledEdit
    Left = 200
    Top = 464
    Width = 201
    Height = 21
    EditLabel.Width = 112
    EditLabel.Height = 13
    EditLabel.Caption = #1055#1086#1090#1088#1077#1073#1083#1077#1085#1080#1077' '#1090#1086#1087#1083#1080#1074#1072
    TabOrder = 5
  end
  object okButton: TButton
    Left = 320
    Top = 496
    Width = 75
    Height = 25
    Caption = 'okButton'
    TabOrder = 6
    OnClick = okButtonClick
  end
end
