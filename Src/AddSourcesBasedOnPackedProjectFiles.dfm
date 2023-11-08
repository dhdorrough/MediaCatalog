object frmAddSourcesBasedOnPackedProjectFiles: TfrmAddSourcesBasedOnPackedProjectFiles
  Left = 625
  Top = 306
  Width = 775
  Height = 611
  Caption = 'Add Sources Based on Packed Project Files'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    759
    573)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 192
    Width = 86
    Height = 13
    Caption = 'Source Folders'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 16
    Top = 53
    Width = 105
    Height = 13
    Caption = 'Files to Search for'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 16
    Top = 352
    Width = 66
    Height = 13
    Caption = 'Found Files'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblFilesToSearchFor: TLabel
    Left = 553
    Top = 53
    Width = 88
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = 'Files to Search For'
  end
  object lblFileCount: TLabel
    Left = 594
    Top = 349
    Width = 47
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = 'File Count'
  end
  object lePackedProjectFilesFolder: TLabeledEdit
    Left = 16
    Top = 24
    Width = 625
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 157
    EditLabel.Height = 13
    EditLabel.Caption = 'Packed Project Files Folder'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -11
    EditLabel.Font.Name = 'MS Sans Serif'
    EditLabel.Font.Style = [fsBold]
    EditLabel.ParentFont = False
    TabOrder = 0
  end
  object btnBrowsePackedProjectFilesFolder: TBitBtn
    Left = 648
    Top = 24
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowsePackedProjectFilesFolderClick
  end
  object btnProcess: TButton
    Left = 496
    Top = 536
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Process'
    TabOrder = 2
    OnClick = btnProcessClick
  end
  object Button2: TButton
    Left = 664
    Top = 536
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object lbSourceFolders: TListBox
    Left = 16
    Top = 208
    Width = 625
    Height = 137
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 4
  end
  object btnAddFolder: TButton
    Left = 648
    Top = 208
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Add Folder'
    TabOrder = 5
    OnClick = btnAddFolderClick
  end
  object btnDeleteFolder: TButton
    Left = 648
    Top = 240
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete Folder'
    TabOrder = 6
    OnClick = btnDeleteFolderClick
  end
  object lvFilesToSearchFor: TListView
    Left = 16
    Top = 69
    Width = 625
    Height = 113
    Anchors = [akLeft, akTop, akRight]
    Columns = <>
    TabOrder = 7
    ViewStyle = vsList
  end
  object btnDeleteFile: TButton
    Left = 648
    Top = 72
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete File'
    Enabled = False
    TabOrder = 8
  end
  object btnClearFiles: TButton
    Left = 648
    Top = 104
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Clear'
    TabOrder = 9
    OnClick = btnClearFilesClick
  end
  object btnRefresh: TButton
    Left = 648
    Top = 136
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    TabOrder = 10
    OnClick = btnRefreshClick
  end
  object Memo1: TMemo
    Left = 16
    Top = 368
    Width = 625
    Height = 153
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 11
  end
  object OK: TButton
    Left = 584
    Top = 536
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 12
  end
  object btnClearFolders: TButton
    Left = 648
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Clear'
    TabOrder = 13
    OnClick = btnClearFoldersClick
  end
end
