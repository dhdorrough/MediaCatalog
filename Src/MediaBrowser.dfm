inherited frmVolumesBrowser: TfrmVolumesBrowser
  Left = 509
  Top = 386
  Caption = 'Media Browser'
  PixelsPerInch = 96
  TextHeight = 14
  inherited DBGrid1: TDBGrid
    OnDblClick = nil
  end
  inherited DBNavigator1: TDBNavigator
    Hints.Strings = ()
    BeforeAction = DBNavigator1BeforeAction
  end
  inherited MainMenu1: TMainMenu
    inherited Navigate1: TMenuItem
      object N1: TMenuItem
        Caption = '-'
      end
      object OrderBy1: TMenuItem
        Caption = 'Order By'
        object MediaID1: TMenuItem
          Caption = 'Media ID'
          OnClick = MediaID1Click
        end
        object BookCDLabel1: TMenuItem
          Caption = 'Location/CD Label'
          OnClick = BookCDLabel1Click
        end
        object CDLabel1: TMenuItem
          Caption = 'CD Label'
          OnClick = CDLabel1Click
        end
        object VolumeDate1: TMenuItem
          Caption = 'Volume Date'
          OnClick = VolumeDate1Click
        end
        object rECnO1: TMenuItem
          Caption = 'RecNo'
          OnClick = rECnO1Click
        end
      end
    end
    object uTILITIES1: TMenuItem
      Caption = 'Utilities'
      object CountSelectedRecords1: TMenuItem
        Caption = 'Count Selected Records'
        OnClick = CountSelectedRecords1Click
      end
      object rEcALChASHEDfILEnAMES1: TMenuItem
        Caption = 'ReCalc Hashed File Names'
      end
      object DeleteSelectedRecords1: TMenuItem
        Caption = 'Delete Selected Records...'
        OnClick = DeleteSelectedRecords1Click
      end
    end
    object Reports1: TMenuItem
      Caption = 'Reports'
      object ListSelectedRecords1: TMenuItem
        Caption = 'List Selected Records...'
        OnClick = ListSelectedRecords1Click
      end
    end
  end
  object DataSource2: TDataSource
    AutoEdit = False
    DataSet = ADOTable2
    Left = 792
    Top = 96
  end
  object ADOTable2: TADOTable
    Connection = ADOConnection2
    CursorLocation = clUseServer
    TableDirect = True
    TableName = 'Volumes'
    Left = 744
    Top = 96
  end
  object ADOConnection2: TADOConnection
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
end
