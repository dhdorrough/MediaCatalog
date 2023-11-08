inherited frmFileInfoBrowser: TfrmFileInfoBrowser
  Left = 444
  Top = 351
  Width = 1128
  Height = 390
  Caption = 'FileInfo Browser'
  PixelsPerInch = 96
  TextHeight = 14
  inherited lblStatus: TLabel
    Left = 982
    Top = 311
  end
  inherited DBGrid1: TDBGrid
    Width = 1109
    Height = 300
    Font.Height = -13
    Font.Name = 'Courier New'
    PopupMenu = PopupMenu1
    Columns = <
      item
        Expanded = False
        FieldName = 'ID'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Media_ID'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Courier New'
        Title.Font.Style = []
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ParentFolder_ID'
        Title.Caption = 'Parent Folder ID'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Courier New'
        Title.Font.Style = []
        Width = 95
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'FileName'
        ReadOnly = True
        Title.Caption = 'File Name'
        Title.Font.Charset = ANSI_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Courier New'
        Title.Font.Style = []
        Width = 247
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DateTimeModified'
        Title.Caption = 'Date Modified'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Courier New'
        Title.Font.Style = []
        Width = 170
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'FileSize'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Courier New'
        Title.Font.Style = []
        Width = 3
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'File_Size'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Courier New'
        Title.Font.Style = []
        Width = 125
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'IsAFolder'
        Title.Caption = 'Is A Folder'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Courier New'
        Title.Font.Style = []
        Width = 88
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ThisFolders_ID'
        Title.Caption = 'This Folders ID'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Courier New'
        Title.Font.Style = []
        Width = 115
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Location ID'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Location Name'
        Width = 182
        Visible = True
      end>
  end
  inherited DBNavigator1: TDBNavigator
    Left = 7
    Top = 304
    Hints.Strings = ()
  end
  inherited btnClose: TButton
    Left = 1033
    Top = 305
  end
  object cbDisableCalculatedFields: TCheckBox [4]
    Left = 345
    Top = 307
    Width = 147
    Height = 18
    Anchors = [akLeft, akBottom]
    Caption = 'Disable Calculated Fields'
    TabOrder = 3
    OnClick = cbDisableCalculatedFieldsClick
  end
  inherited MainMenu1: TMainMenu
    inherited Edit1: TMenuItem
      object N2: TMenuItem
        Caption = '-'
      end
      object CopyPathName1: TMenuItem
        Caption = 'Copy Path\Name'
        OnClick = CopyPathName1Click
      end
    end
    inherited Navigate1: TMenuItem
      object N1: TMenuItem
        Caption = '-'
      end
      object OrderBy1: TMenuItem
        Caption = 'Order By'
        object RecNo1: TMenuItem
          Caption = 'RecNo'
          RadioItem = True
          OnClick = RecNo1Click
        end
        object MediaIDParentFolderShortFileName1: TMenuItem
          Caption = 'Media_ID_ParentFolder+ShortFileName'
          RadioItem = True
          OnClick = MediaIDParentFolderShortFileName1Click
        end
        object FileName1: TMenuItem
          Caption = 'FileName'
          RadioItem = True
          OnClick = FileName1Click
        end
        object MediaID1: TMenuItem
          Caption = 'Media_ID'
          RadioItem = True
          OnClick = MediaID1Click
        end
        object ParentFolderID1: TMenuItem
          Caption = 'ParentFolder_ID'
          RadioItem = True
          OnClick = ParentFolderID1Click
        end
        object PrimaryKey1: TMenuItem
          Caption = 'PrimaryKey'
          RadioItem = True
          OnClick = PrimaryKey1Click
        end
        object ThisFoldersID1: TMenuItem
          Caption = 'ThisFolders_ID'
          RadioItem = True
          OnClick = ThisFoldersID1Click
        end
        object ID1: TMenuItem
          Caption = 'ID'
          RadioItem = True
          OnClick = ID1Click
        end
      end
    end
    object Utilities1: TMenuItem
      Caption = 'Utilities'
      object CountSelectedRecords1: TMenuItem
        Caption = 'Count Selected Records'
        OnClick = CountSelectedRecords1Click
      end
      object ClearFilenameMemoifDuplicate1: TMenuItem
        Caption = 'Clear Filename Memo if Duplicate'
        OnClick = ClearFilenameMemoifDuplicate1Click
      end
      object ReCalcHashedFileNAme1: TMenuItem
        Caption = 'ReCalc Hashed FileName'
        OnClick = ReCalcHashedFileNAme1Click
      end
      object UpdateVolumeDate1: TMenuItem
        Caption = 'Update Volume Date'
        OnClick = UpdateVolumeDate1Click
      end
    end
    object Reports1: TMenuItem
      Caption = 'Reports'
      object ListSelectedRecords1: TMenuItem
        Caption = 'List Selected Records'
        OnClick = ListSelectedRecords1Click
      end
    end
  end
  object DataSource1: TDataSource
    AutoEdit = False
    DataSet = ADOTable1
    Left = 792
    Top = 96
  end
  object ADOTable1: TADOTable
    Connection = ADOConnection1
    CursorLocation = clUseServer
    TableName = 'FileInfo'
    Left = 744
    Top = 96
  end
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=G:\MediaCatalog.mdb' +
      ';Persist Security Info=False;'
    CursorLocation = clUseServer
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 696
    Top = 96
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 360
    Top = 112
    object SelectthisRecordbuildtree1: TMenuItem
      Caption = 'Select this Record, build tree'
      OnClick = SelectthisRecordbuildtree1Click
    end
  end
end
