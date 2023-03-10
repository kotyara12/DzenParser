object frmImage: TfrmImage
  Left = 0
  Top = 0
  ActiveControl = edAlt
  BorderStyle = bsDialog
  Caption = #1048#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
  ClientHeight = 212
  ClientWidth = 489
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
    EditLabel.Width = 173
    EditLabel.Height = 13
    EditLabel.Caption = #1058#1077#1082#1091#1097#1072#1103' '#1089#1089#1099#1083#1082#1072' '#1085#1072' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077':'
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
  end
  object edNewLink: TLabeledEdit
    Left = 12
    Top = 68
    Width = 465
    Height = 21
    EditLabel.Width = 155
    EditLabel.Height = 13
    EditLabel.Caption = #1053#1086#1074#1072#1103' '#1089#1089#1099#1083#1082#1072' '#1085#1072' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
    TabOrder = 1
  end
  object edAlt: TLabeledEdit
    Left = 12
    Top = 112
    Width = 465
    Height = 21
    EditLabel.Width = 129
    EditLabel.Height = 13
    EditLabel.Caption = #1055#1086#1076#1087#1080#1089#1100' '#1082' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1102':'
    TabOrder = 2
  end
  object cbCaption: TCheckBox
    Left = 12
    Top = 139
    Width = 465
    Height = 17
    Caption = #1042#1099#1074#1086#1076#1080#1090#1100' '#1087#1086#1076#1087#1080#1089#1100' '#1082' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1102
    TabOrder = 3
  end
  object btnOk: TBitBtn
    Left = 253
    Top = 171
    Width = 109
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 4
  end
  object btnCancel: TBitBtn
    Left = 368
    Top = 171
    Width = 109
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 5
  end
end
