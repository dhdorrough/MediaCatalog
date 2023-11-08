object frmMediaSettings: TfrmMediaSettings
  Left = 925
  Top = 293
  Width = 654
  Height = 237
  Caption = 'Media Catalog Settings'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    638
    198)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 98
    Width = 137
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Load Disk into Drive (default)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblFileInfoRecordCount: TLabel
    Left = 120
    Top = 160
    Width = 145
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Record count must be numeric'
    Color = clYellow
    ParentColor = False
  end
  object leDBFilePathName: TLabeledEdit
    Left = 16
    Top = 24
    Width = 513
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 90
    EditLabel.Height = 13
    EditLabel.Caption = 'DB File Path Name'
    TabOrder = 0
  end
  object btnCancel: TBitBtn
    Left = 545
    Top = 161
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    TabOrder = 1
    Kind = bkCancel
  end
  object btnOk: TBitBtn
    Left = 449
    Top = 161
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    TabOrder = 5
    Kind = bkOK
  end
  object btnBrowse1: TButton
    Left = 544
    Top = 24
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 6
    OnClick = btnBrowse1Click
  end
  object btnBrowse2: TButton
    Left = 544
    Top = 112
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 7
  end
  object cbDrive: TComboBox
    Left = 16
    Top = 114
    Width = 161
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    TabOrder = 3
    Items.Strings = (
      'C'
      'D'
      'E'
      'F'
      'G'
      'H')
  end
  object leFileInfoRecordCount: TLabeledEdit
    Left = 16
    Top = 156
    Width = 89
    Height = 21
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 142
    EditLabel.Height = 13
    EditLabel.Caption = 'Approx File Info Record Count'
    MaxLength = 10
    TabOrder = 4
    OnChange = leFileInfoRecordCountChange
  end
  object leLogFilePathName: TLabeledEdit
    Left = 16
    Top = 63
    Width = 513
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 93
    EditLabel.Height = 13
    EditLabel.Caption = 'Log File Path Name'
    TabOrder = 2
  end
  object btnBrowseLogFilePathName: TButton
    Left = 544
    Top = 63
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 8
    OnClick = btnBrowseLogFilePathNameClick
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'MDB'
    Filter = 'Media Catalog (*.mdb)|*.mdb'
    Left = 608
    Top = 16
  end
  object OpenDialog3: TOpenDialog
    DefaultExt = 'MDB'
    Filter = 'Media Catalog (*.mdb)|*.mdb'
    Left = 600
    Top = 96
  end
end
