unit FileInfoBrowser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BrowserUnit, Menus, StdCtrls, ExtCtrls, DBCtrls, Grids, DBGrids,
  DB, MediaTables, ADODB;

type
  TfrmFileInfoBrowser = class(TfrmDataSetBrowser)
    N1: TMenuItem;
    OrderBy1: TMenuItem;
    FileName1: TMenuItem;
    MediaID1: TMenuItem;
    ParentFolderID1: TMenuItem;
    PrimaryKey1: TMenuItem;
    ThisFoldersID1: TMenuItem;
    MediaIDParentFolderShortFileName1: TMenuItem;
    Utilities1: TMenuItem;
    CountSelectedRecords1: TMenuItem;
    ClearFilenameMemoifDuplicate1: TMenuItem;
    ReCalcHashedFileNAme1: TMenuItem;
    Reports1: TMenuItem;
    ListSelectedRecords1: TMenuItem;
    DataSource1: TDataSource;
    ADOTable1: TADOTable;
    ADOConnection1: TADOConnection;
    UpdateVolumeDate1: TMenuItem;
    PopupMenu1: TPopupMenu;
    SelectthisRecordbuildtree1: TMenuItem;
    ID1: TMenuItem;
    RecNo1: TMenuItem;
    N2: TMenuItem;
    CopyPathName1: TMenuItem;
    cbDisableCalculatedFields: TCheckBox;
    procedure MediaIDParentFolderShortFileName1Click(Sender: TObject);
    procedure FileName1Click(Sender: TObject);
    procedure MediaID1Click(Sender: TObject);
    procedure ParentFolderID1Click(Sender: TObject);
    procedure PrimaryKey1Click(Sender: TObject);
    procedure ThisFoldersID1Click(Sender: TObject);
    procedure CountSelectedRecords1Click(Sender: TObject);
    procedure ClearFilenameMemoifDuplicate1Click(Sender: TObject);
    procedure ReCalcHashedFileNAme1Click(Sender: TObject);
    procedure ListSelectedRecords1Click(Sender: TObject);
    procedure UpdateVolumeDate1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure SelectthisRecordbuildtree1Click(Sender: TObject);
    procedure ID1Click(Sender: TObject);
    procedure RecNo1Click(Sender: TObject);
    procedure CopyPathName1Click(Sender: TObject);
    procedure cbDisableCalculatedFieldsClick(Sender: TObject);
  private
    function GetVolumesTable: TVolumesTable;
  private
    fErrCount: integer;
    fFileInfoID: integer;
    fLogFileIsOpen: boolean;
    fLogFile: TextFile;
    fLogFileName: string;
    fTempFileInfoTable: TFileInfoTable;
    fTempVolumesTable: TVolumesTable;
    procedure ppReportPreviewFormCreate(Sender: TObject);
    procedure LogError(Msg: string; Args: array of const);
    procedure OpenLogFile;
    function GetTempFileInfoTable: TFileInfoTable;
    { Private declarations }
    property TempFileInfoTable: TFileInfoTable
             read GetTempFileInfoTable;
    property TempVolumesTable: TVolumesTable
             read GetVolumesTable;
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent; DataSet: TDataSet; DataSetName: string = ''); override;
    Destructor Destroy; override;
  end;

var
  frmFileInfoBrowser: TfrmFileInfoBrowser;

implementation

uses MyUtils, Clipbrd, MediaCatalog_Decl;

{$R *.dfm}

procedure TfrmFileInfoBrowser.MediaIDParentFolderShortFileName1Click(
  Sender: TObject);
begin
  inherited;
  with DataSet as TFileInfoTable do
    IndexName := 'FullIndex';   // Media_ID + ParentFolder_ID + ShortFileName
  MediaIDParentFolderShortFileName1.Checked := true;
end;

procedure TfrmFileInfoBrowser.FileName1Click(Sender: TObject);
begin
  inherited;
  with DataSet as TFileInfoTable do
    IndexName := 'FileName';  // i.e., 'ShortFileName'
  FileName1.Checked := true;
end;

procedure TfrmFileInfoBrowser.MediaID1Click(Sender: TObject);
begin
  inherited;
  with DataSet as TFileInfoTable do
    IndexName := MEDIA_ID_FIELD_NAME;  // 'Media_ID'
end;

procedure TfrmFileInfoBrowser.ParentFolderID1Click(Sender: TObject);
begin
  inherited;
  with DataSet as TFileInfoTable do
    IndexName := 'ParentFolder_ID';
  ParentFolderID1.Checked := true;
end;

procedure TfrmFileInfoBrowser.PrimaryKey1Click(Sender: TObject);
begin
  inherited;
  with DataSet as TFileInfoTable do
    IndexName := 'PrimaryKey';
  PrimaryKey1.Checked := true;
end;

procedure TfrmFileInfoBrowser.ThisFoldersID1Click(Sender: TObject);
begin
  inherited;
  with DataSet as TFileInfoTable do
    IndexName := 'ThisFolders_ID';
  ThisFoldersID1.Checked := true;
end;

procedure TfrmFileInfoBrowser.CountSelectedRecords1Click(Sender: TObject);
var
  SavedRecNo, RecCount: integer;
  SavedIndexName: string;
begin
  inherited;
  with DataSet as TFileInfoTable do
    begin
      DisableControls;
      SavedRecno     := RecNo;
      SavedIndexName := IndexName;
      IndexName      := '';
      RecCount := 0;
      try
        First;
        while not Eof do
          begin
            if (RecCount Mod 1000) = 0 then
              begin
                lblStatus.Caption := Format('%0.n records', [RecCount*1.0]);
                Application.ProcessMessages;
              end;
            Inc(RecCount);
            Next;
          end;
      finally
        lblStatus.Caption := Format('%0.n records', [RecCount*1.0]);
        EnableControls;
        IndexName := SavedIndexName;
        RecNo     := SavedRecNo;
      end;
    end;
end;

procedure TfrmFileInfoBrowser.ClearFilenameMemoifDuplicate1Click(
  Sender: TObject);
var
  SavedRecNo, RecCount, UpdatedCount: integer;
  SavedIndexName: string;
begin
  inherited;
  with DataSet as TFileInfoTable do
    begin
      DisableControls;
      SavedRecno     := RecNo;
      SavedIndexName := IndexName;
      IndexName      := '';
      RecCount       := 0;
      UpdatedCount   := 0;
      try
        First;
        while not Eof do
          begin
            if (RecCount Mod 1000) = 0 then
              begin
                lblStatus.Caption := Format('%0.n/%0.n records', [RecCount*1.0, UpdatedCount*1.0]);
                Application.ProcessMessages;
              end;
            inc(RecCount);
            if fldShortFileName.AsString = fldLongFileName.AsString then
              begin
                Edit;
                fldLongFileName.Clear;
                Post;
                inc(UpdatedCount);
              end;
            Next;
          end;
      finally
        lblStatus.Caption := Format('%0.n/%0.n records', [RecCount*1.0, UpdatedCount*1.0]);
        EnableControls;
        IndexName := SavedIndexName;
        RecNo     := SavedRecNo;
      end;
    end;
end;

procedure TfrmFileInfoBrowser.ReCalcHashedFileNAme1Click(Sender: TObject);
var
  SavedRecNo, RecCount, UpdatedCount: integer;
  SavedIndexName, HashedName: string;
begin
  inherited;
  with DataSet as TFileInfoTable do
    begin
      DisableControls;
      SavedRecno     := RecNo;
      SavedIndexName := IndexName;
      IndexName      := '';
      RecCount       := 0;
      UpdatedCount   := 0;
      try
        First;
        while not Eof do
          begin
            if (RecCount Mod 1000) = 0 then
              begin
                lblStatus.Caption := Format('Updated %0.n/%0.n records', [UpdatedCount*1.0, RecCount*1.0]);
                Application.ProcessMessages;
              end;
            inc(RecCount);
            if not fldLongFileName.IsNull then
              begin
                HashedName := HashedFileName(fldLongFileName.AsString, HASHED_NAME_LENGTH);
                if fldShortFileName.AsString = fldLongFileName.AsString then
                  begin
                    Edit;
                    fldShortFileName.AsString := HashedName;
                    Post;
                    inc(UpdatedCount);
                  end;
              end;
            Next;
          end;
      finally
        lblStatus.Caption := Format('%0.n/%0.n records', [RecCount*1.0, UpdatedCount*1.0]);
        EnableControls;
        IndexName := SavedIndexName;
        RecNo     := SavedRecNo;
      end;
    end;
end;


procedure TfrmFileInfoBrowser.ListSelectedRecords1Click(Sender: TObject);
var
  SavedRecNo: integer;
  SavedIndexName: string;
begin
  inherited;
(*
  with DataSet as TFileInfoTable do
    begin
      DisableControls;
      SavedRecno     := RecNo;
      SavedIndexName := IndexName;
      IndexName      := '';
      DataSource1.DataSet := DataSet;
      try
        ppReport1.OnPreviewFormCreate := ppReportPreviewFormCreate;
        lblExpression.Caption         := SelectivityParser.Condition;
        ppReport1.Print;
      finally
        EnableControls;
        IndexName := SavedIndexName;
        RecNo     := SavedRecNo;
      end;
    end;
*)
end;

procedure TfrmFileInfoBrowser.ppReportPreviewFormCreate(Sender: TObject);
begin
(*
  with Sender as TppReport do
    PreviewForm.WindowState := wsMaximized;
*)
end;


procedure TfrmFileInfoBrowser.OpenLogFile;
begin
  if not fLogFileIsOpen then
    begin
      AssignFile(fLogFile, fLogFileName);
      Rewrite(fLogFile);
      fLogFileIsOpen := true;
    end;
end;

procedure TfrmFileInfoBrowser.LogError(Msg: string; Args: array of const);
var
  ErrMsg: string;
begin
  OpenLogFile;
  ErrMsg := Format(Msg, Args);
  lblStatus.Caption := ErrMsg;
  lblStatus.Color   := clYellow;
  WriteLn(fLogFile, fErrCount:3, '. ', ErrMsg);
end;

procedure TfrmFileInfoBrowser.UpdateVolumeDate1Click(Sender: TObject);
var
  SavedRecNo: integer;
  SavedINdexName: string;
  RecCount: integer;
  VolumeDate: TDateTime;
  LastMediaID: integer;
  RecsUpdated: integer;
begin
  inherited;
  with DataSet as TFileInfoTable do
    begin
      DisableControls;
      SavedRecno     := RecNo;
      SavedIndexName := IndexName;
      IndexName      := MEDIA_ID_FIELD_NAME;
      RecCount       := 0;
      RecsUpdated    := 0;
      fLogFileName   := TempPath + 'UpdateVolumeDates.txt';
      try
        First;
        VolumeDate  := fldDateTimeModified.AsDateTime;
        LastMediaID := fldMedia_ID.AsInteger;
        while not Eof do
          begin
            // Have we moved to a different volume? If so, record it and reset everything.
            if fldMedia_ID.AsInteger <> LastMediaID then
              begin
                if VolumesTable.Locate(MEDIA_ID_FIELD_NAME, LastMediaID, []) then
                  begin
                    VolumesTable.Edit;
                    VolumesTable.fldVolumeDate.AsDateTime := VolumeDate;
                    VolumesTable.Post;
                    inc(RecsUpdated);
                  end
                else
                  LogError('Unable to find volume %d', [LastMediaID]);

                VolumeDate  := fldDateTimeModified.AsDateTime;
                LastMediaID := fldMedia_ID.AsInteger;
              end
            else
              begin
                if fldDateTimeModified.AsDateTime > VolumeDate then
                  VolumeDate := fldDateTimeModified.AsDateTime;
              end;

            if (RecCount Mod 1000) = 0 then
              begin
                lblStatus.Caption := Format('%0.n records processed. %0.n records updated', [RecCount*1.0, RecsUpdated*1.0]);
                Application.ProcessMessages;
              end;

            Inc(RecCount);
            Next;
          end;
      finally
        if fLogFileIsOpen then
          CloseFile(fLogFile);
        lblStatus.Caption := Format('COMPLETE. %0.n records processed. %0.n records updated', [RecCount*1.0, RecsUpdated*1.0]);
        EnableControls;
        IndexName := SavedIndexName;
        RecNo     := SavedRecNo;
      end;
    end;
end;

constructor TfrmFileInfoBrowser.Create(aOwner: TComponent;
  DataSet: TDataSet; DataSetName: string);
begin
  inherited;

end;

procedure TfrmFileInfoBrowser.PopupMenu1Popup(Sender: TObject);
begin
  inherited;
  fFileInfoID := (DataSet as TFileInfoTable).fldID.AsInteger;
end;

procedure TfrmFileInfoBrowser.SelectthisRecordbuildtree1Click(
  Sender: TObject);
begin
  inherited;
  (Owner as TForm).Perform(WM_BuildTreeView, fFileInfoID, 0)
end;

procedure TfrmFileInfoBrowser.ID1Click(Sender: TObject);
begin
  inherited;
  with DataSet as TFileInfoTable do
    IndexName := 'ID';
  ID1.Checked := true;
end;

procedure TfrmFileInfoBrowser.RecNo1Click(Sender: TObject);
begin
  inherited;
  with DataSet as TFileInfoTable do
    IndexName := '';
  RecNo1.Checked := true;
end;

procedure TfrmFileInfoBrowser.CopyPathName1Click(Sender: TObject);
var
  FileName, FilePath: string;
  RecID: integer;
  Media_ID: integer;
  ParentFolder_ID: integer;
  WasFound: boolean;
  MediaName: string;
  Saved_Cursor: TCursor;
begin
  inherited;
  Saved_Cursor  := Screen.Cursor;
  Screen.Cursor := crSQLWait;
  Application.ProcessMessages;

  try
    with DataSet as TFileInfoTable do
      begin
        RecID            := fldID.AsInteger;
        Media_ID         := fldMedia_ID.AsInteger;
      end;

    with TempFileInfoTable do
      begin
        WasFound := Locate('ID', RecID, []);
        if WasFound then
          begin
            FileName        := fldFileName.AsString;
            FilePath        := '';
            ParentFolder_ID := fldParentFolder_ID.AsInteger;
            WasFound        := Locate('Media_ID;ThisFolders_ID', VarArrayOf([Media_ID, ParentFolder_ID]), []);
            while WasFound do
              begin
                if not Empty(FilePath) then
                  FilePath        := FilePath + '\' + fldFileName.AsString
                else
                  FilePath        := fldFileName.AsString;
                ParentFolder_ID := fldParentFolder_ID.AsInteger;
                WasFound        := Locate('Media_ID;ThisFolders_ID', VarArrayOf([Media_ID, ParentFolder_ID]), []);
              end;
            if not Empty(FileName) then
              begin
                if TempVolumesTable.Locate('Media_ID', Media_ID, []) then
                  MediaName := TempVolumesTable.fldVolumeLabel.AsString + ' (' + TempVolumesTable.fldLocation.AsString + ')'
                else
                  MediaName := '';
              end;
            Clipboard.AsText := Format('[%s] %s\%s', [MediaName, FilePath, FileName]);
          end
        else
          Alert('System error: ID [%s] could not be found in TempFileInfoTable');
      end;
  finally
    Screen.Cursor := Saved_Cursor;
  end;
end;

function TfrmFileInfoBrowser.GetTempFileInfoTable: TFileInfoTable;
begin
  if not Assigned(fTempFileInfoTable) then
    begin
      with DataSet as TFileInfoTable do
        fTempFileInfoTable := TFileInfoTable.Create(self, DBFilePathName, TableName, []);
      fTempFileInfoTable.AddFields;
      fTempFileInfoTable.Active := true;
    end;
  result := fTempFileInfoTable;
end;


destructor TfrmFileInfoBrowser.Destroy;
begin
  FreeAndNil(fTempFileInfoTable);
  FreeAndNil(fTempFileInfoTable);
  inherited;
end;

function TfrmFileInfoBrowser.GetVolumesTable: TVolumesTable;
begin
  if not Assigned(fTempVolumesTable) then
    begin
      with DataSet as TFileInfoTable do
        begin
          fTempVolumesTable := TVolumesTable.Create(self, DBFilePathName, VOLUMES_TABLE_NAME, []);
          fTempVolumesTable.AddFields;
          fTempVolumesTable.Active := true;
        end;
    end;
  result := fTempVolumesTable;
end;

procedure TfrmFileInfoBrowser.cbDisableCalculatedFieldsClick(Sender: TObject);
begin
  inherited;
  with DataSet as TFileInfoTable do
    DisableCalculatedfields := cbDisableCalculatedFields.Checked;
  if cbDisableCalculatedFields.Checked then
    DbGrid1.Columns[3].Title.Caption := 'Hashed File Name'
  else
    DBGrid1.Columns[3].Title.Caption := 'File Name';
end;


end.
