object frmVolumeInfo: TfrmVolumeInfo
  Left = 850
  Top = 312
  Width = 676
  Height = 680
  Caption = 'Volume Information'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    660
    641)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 168
    Top = 208
    Width = 321
    Height = 13
    Caption = 'Media (C=CD, D=DVD, 5=5" floppy, 3=3"  floppy, H=HD, B=Blu-Ray'
  end
  object Label2: TLabel
    Left = 24
    Top = 48
    Width = 79
    Height = 13
    Caption = 'Volume Location'
  end
  object Memo1: TMemo
    Left = 16
    Top = 264
    Width = 608
    Height = 336
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 5
  end
  object btnOK: TButton
    Left = 456
    Top = 607
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 6
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 536
    Top = 607
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 7
  end
  object leVolumeName: TLabeledEdit
    Left = 24
    Top = 24
    Width = 121
    Height = 21
    EditLabel.Width = 66
    EditLabel.Height = 13
    EditLabel.Caption = 'Volume Name'
    ReadOnly = True
    TabOrder = 8
  end
  object leSerialNumber: TLabeledEdit
    Left = 176
    Top = 24
    Width = 121
    Height = 21
    EditLabel.Width = 66
    EditLabel.Height = 13
    EditLabel.Caption = 'Serial Number'
    ReadOnly = True
    TabOrder = 9
  end
  object leVolumeLabel: TLabeledEdit
    Left = 24
    Top = 104
    Width = 609
    Height = 21
    EditLabel.Width = 64
    EditLabel.Height = 13
    EditLabel.Caption = 'Volume Label'
    TabOrder = 0
    OnKeyUp = leVolumeLabelKeyUp
  end
  object lePublisher: TLabeledEdit
    Left = 24
    Top = 144
    Width = 609
    Height = 21
    EditLabel.Width = 43
    EditLabel.Height = 13
    EditLabel.Caption = 'Publisher'
    TabOrder = 1
  end
  object leComment: TLabeledEdit
    Left = 24
    Top = 184
    Width = 609
    Height = 21
    EditLabel.Width = 44
    EditLabel.Height = 13
    EditLabel.Caption = 'Comment'
    TabOrder = 2
  end
  object leKey: TLabeledEdit
    Left = 24
    Top = 224
    Width = 121
    Height = 21
    EditLabel.Width = 18
    EditLabel.Height = 13
    EditLabel.Caption = 'Key'
    TabOrder = 3
  end
  object cbMedia: TComboBox
    Left = 168
    Top = 224
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
    Items.Strings = (
      'C=CD'
      'D=DVD'
      'H=Hard Drive'
      '3=3" floppy'
      '5=5" floppy'
      'B=Blu Ray'
      'N=Network Drive')
  end
  object cbLocation: TComboBox
    Left = 24
    Top = 64
    Width = 273
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 10
    OnClick = cbLocationClick
  end
  object btnAddLocation: TButton
    Left = 320
    Top = 64
    Width = 97
    Height = 25
    Caption = 'Add Location'
    TabOrder = 11
    OnClick = btnAddLocationClick
  end
  object DataSource1: TDataSource
    Left = 24
    Top = 384
  end
end
