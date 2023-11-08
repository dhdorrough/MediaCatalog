object frmLabelTheDisk: TfrmLabelTheDisk
  Left = 709
  Top = 320
  Width = 691
  Height = 325
  Caption = 'Label the Disk'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    675
    286)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 137
    Height = 20
    Caption = 'Label the disk as'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object VolumeID: TLabel
    Left = 16
    Top = 56
    Width = 217
    Height = 56
    Caption = 'VolumeID'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -48
    Font.Name = 'MVSans'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 24
    Top = 201
    Width = 79
    Height = 13
    Caption = 'Volume Location'
  end
  object btnOk: TButton
    Left = 490
    Top = 247
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
  end
  object edtLabelOnTheDisk: TLabeledEdit
    Left = 24
    Top = 128
    Width = 465
    Height = 21
    EditLabel.Width = 83
    EditLabel.Height = 13
    EditLabel.Caption = 'Label on the Disk'
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 579
    Top = 247
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object cbLocation: TComboBox
    Left = 24
    Top = 217
    Width = 273
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
  end
  object btnAddLocation: TButton
    Left = 320
    Top = 217
    Width = 97
    Height = 25
    Caption = 'Add Location'
    TabOrder = 4
    OnClick = btnAddLocationClick
  end
end
