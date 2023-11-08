object frmScanVolume: TfrmScanVolume
  Left = 678
  Top = 389
  Width = 641
  Height = 292
  Caption = 'Scan Volume'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    625
    253)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 98
    Width = 101
    Height = 13
    Caption = 'Extensions to Include'
  end
  object leFolderToBeScanned: TLabeledEdit
    Left = 16
    Top = 28
    Width = 505
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 100
    EditLabel.Height = 13
    EditLabel.Caption = 'Folder to be scanned'
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 536
    Top = 25
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object mmoExtensions: TMemo
    Left = 16
    Top = 129
    Width = 593
    Height = 73
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'mmoExtensions')
    ParentFont = False
    TabOrder = 2
    Visible = False
  end
  object btnCancel: TButton
    Left = 544
    Top = 217
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnOK: TButton
    Left = 456
    Top = 217
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = btnOKClick
  end
  object leComputerName: TLabeledEdit
    Left = 16
    Top = 68
    Width = 121
    Height = 21
    EditLabel.Width = 76
    EditLabel.Height = 13
    EditLabel.Caption = 'Computer Name'
    TabOrder = 5
  end
  object cbExtensions: TComboBox
    Left = 128
    Top = 95
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 6
    OnChange = cbExtensionsChange
    Items.Strings = (
      'All'
      'Delphi Source'
      'Video Projects'
      'Specified Below')
  end
  object OpenDialog1: TOpenDialog
    Left = 552
    Top = 65528
  end
end
