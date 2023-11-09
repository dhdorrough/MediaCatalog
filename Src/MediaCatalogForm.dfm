object frmMediaCatalog: TfrmMediaCatalog
  Left = 655
  Top = 275
  Width = 807
  Height = 555
  Caption = 'Media Catalog'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  DesignSize = (
    791
    496)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 7
    Top = 477
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
  end
  object lblFileName: TLabel
    Left = 7
    Top = 458
    Width = 54
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblFileName'
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 513
    Height = 449
    Anchors = [akLeft, akTop, akBottom]
    AutoExpand = True
    Indent = 19
    TabOrder = 0
    OnMouseMove = TreeView1MouseMove
  end
  object MainMenu1: TMainMenu
    Left = 664
    Top = 88
    object File1: TMenuItem
      Caption = 'File'
      OnClick = File1Click
      object OpenMediaCatalog2: TMenuItem
        Caption = 'Open Media Catalog...'
        OnClick = OpenMediaCatalog2Click
      end
      object CloseMediaCatalog1: TMenuItem
        Caption = 'Close Media Catalog'
        OnClick = CloseMediaCatalog1Click
      end
      object OpenMediaCatalog1: TMenuItem
        Caption = '-'
      end
      object NewMediaCatalog1: TMenuItem
        Caption = 'New Media Catalog...'
        OnClick = NewMediaCatalog1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object ScanVolume2: TMenuItem
        Caption = 'Scan CD/DVD/HD Volume/Folder...'
        OnClick = ScanVolume2Click
      end
      object ImportImportDirectoryListingTextFile1: TMenuItem
        Caption = 'Import Single Directory Listing Text File...'
        OnClick = ImportImportDirectoryListingTextFile1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object AppendMediaCatalog1: TMenuItem
        Caption = 'Append Media Catalog...'
        Visible = False
      end
      object N1: TMenuItem
        Caption = '-'
        Visible = False
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Settings1: TMenuItem
        Caption = 'Settings...'
        OnClick = Settings1Click
      end
    end
    object Tables1: TMenuItem
      Caption = 'Tables'
      OnClick = Tables1Click
      object BrowseFiles1: TMenuItem
        Caption = 'Browse Files...'
        OnClick = BrowseFiles1Click
      end
      object BrowseMediaCatalog1: TMenuItem
        Caption = 'Browse Volumes...'
        OnClick = BrowseMediaCatalog1Click
      end
      object BrowseLocations1: TMenuItem
        Caption = 'Browse Locations...'
        OnClick = BrowseLocations1Click
      end
    end
    object Utilities1: TMenuItem
      Caption = 'Utilities'
      object DEleteAllfilerecordsforavolume1: TMenuItem
        Caption = 'Delete all file info records for a volume...'
        OnClick = DEleteAllfilerecordsforavolume1Click
      end
    end
    object mEDIA1: TMenuItem
      Caption = 'Media'
      object Eject1: TMenuItem
        Caption = 'Eject'
        object D1: TMenuItem
          Caption = 'D:'
          OnClick = D1Click
        end
        object E1: TMenuItem
          Caption = 'E:'
          OnClick = E1Click
        end
        object F1: TMenuItem
          Caption = 'F:'
          OnClick = F1Click
        end
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 696
    Top = 16
  end
  object ADOConnection1: TADOConnection
    Left = 616
    Top = 16
  end
  object ADOCommand1: TADOCommand
    Parameters = <>
    Left = 568
    Top = 16
  end
  object SaveDialog2: TSaveDialog
    DefaultExt = 'accdb'
    FileName = 'Project'
    Filter = 'Access 2000 (*.mdb)|*.mdb|Access 2007 (*.accdb)|*.accdb'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    OnTypeChange = SaveDialog2TypeChange
    Left = 528
    Top = 72
  end
  object ADOXCatalog1: TADOXCatalog
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 544
    Top = 128
  end
end
