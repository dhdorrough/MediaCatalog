object frmFilterOptions: TfrmFilterOptions
  Left = 623
  Top = 356
  Width = 592
  Height = 269
  Caption = 'Filter Options'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    576
    230)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 383
    Top = 178
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 479
    Top = 178
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 24
    Top = 24
    Width = 536
    Height = 139
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Filter Settings'
    TabOrder = 2
    DesignSize = (
      536
      139)
    object leHighDate: TLabeledEdit
      Left = 136
      Top = 53
      Width = 89
      Height = 21
      EditLabel.Width = 58
      EditLabel.Height = 13
      EditLabel.Caption = 'High Date'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -11
      EditLabel.Font.Name = 'MS Sans Serif'
      EditLabel.Font.Style = [fsBold]
      EditLabel.ParentFont = False
      TabOrder = 2
    end
    object leLowDate: TLabeledEdit
      Left = 16
      Top = 53
      Width = 89
      Height = 21
      EditLabel.Width = 55
      EditLabel.Height = 13
      EditLabel.Caption = 'Low Date'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -11
      EditLabel.Font.Name = 'MS Sans Serif'
      EditLabel.Font.Style = [fsBold]
      EditLabel.ParentFont = False
      TabOrder = 1
    end
    object leFilter: TLabeledEdit
      Left = 142
      Top = 103
      Width = 208
      Height = 21
      Anchors = [akLeft, akRight, akBottom]
      EditLabel.Width = 114
      EditLabel.Height = 13
      EditLabel.Caption = 'Generic String Filter'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -11
      EditLabel.Font.Name = 'MS Sans Serif'
      EditLabel.Font.Style = [fsBold]
      EditLabel.ParentFont = False
      EditLabel.Layout = tlBottom
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      LabelPosition = lpLeft
      LabelSpacing = 10
      ParentFont = False
      TabOrder = 0
    end
    object btnExpression: TButton
      Left = 357
      Top = 101
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Expression'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = btnExpressionClick
    end
    object btnClearAll: TButton
      Left = 439
      Top = 102
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Clear All'
      TabOrder = 4
      OnClick = btnClearAllClick
    end
  end
end
