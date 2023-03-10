object frmLink: TfrmLink
  Left = 0
  Top = 0
  ActiveControl = edNewLink
  BorderStyle = bsDialog
  Caption = #1057#1089#1099#1083#1082#1072
  ClientHeight = 190
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object edOldLink: TLabeledEdit
    Left = 12
    Top = 24
    Width = 465
    Height = 21
    EditLabel.Width = 88
    EditLabel.Height = 13
    EditLabel.Caption = #1058#1077#1082#1091#1097#1072#1103' '#1089#1089#1099#1083#1082#1072':'
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
  end
  object edNewLink: TLabeledEdit
    Left = 12
    Top = 68
    Width = 465
    Height = 21
    EditLabel.Width = 74
    EditLabel.Height = 13
    EditLabel.Caption = #1053#1086#1074#1072#1103' '#1089#1089#1099#1083#1082#1072':'
    TabOrder = 1
  end
  object edText: TLabeledEdit
    Left = 12
    Top = 112
    Width = 465
    Height = 21
    EditLabel.Width = 33
    EditLabel.Height = 13
    EditLabel.Caption = #1058#1077#1082#1089#1090':'
    TabOrder = 2
  end
  object btnOk: TBitBtn
    Left = 253
    Top = 150
    Width = 109
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 3
  end
  object btnCancel: TBitBtn
    Left = 368
    Top = 150
    Width = 109
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 4
  end
end
