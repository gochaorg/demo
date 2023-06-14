object DriverController: TDriverController
  Left = 1133
  Top = 207
  Width = 383
  Height = 193
  Caption = 'DriverController'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    367
    154)
  PixelsPerInch = 96
  TextHeight = 13
  object nameEdit: TLabeledEdit
    Left = 8
    Top = 24
    Width = 345
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 44
    EditLabel.Height = 13
    EditLabel.Caption = 'nameEdit'
    TabOrder = 0
  end
  object birthDayEdit: TLabeledEdit
    Left = 8
    Top = 72
    Width = 345
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 59
    EditLabel.Height = 13
    EditLabel.Caption = 'birthDayEdit'
    TabOrder = 1
  end
  object okButton: TButton
    Left = 280
    Top = 104
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'okButton'
    TabOrder = 2
  end
end
