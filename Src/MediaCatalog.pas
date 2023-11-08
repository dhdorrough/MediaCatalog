unit MediaCatalog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, BrowserUnit, MediaTables, MediaSettingsFile, MediaBrowser,
  FileInfoBrowser, ComCtrls, StdCtrls, OleServer, ADOX_TLB, ADODB, DB;

type
  EContentError = class(Exception);
  
  TFolderList = class(TStringList)
  public
    FolderName: string;
    Folder_ID: integer;
    Destructor Destroy; override;
  end;

  TLocationsBrowser = class(TfrmDataSetBrowser)
  end;

  TfrmMediaCatalog = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    ImportImportDirectoryListingTextFile1: TMenuItem;
    ImportDirectoryListingTextFolder1: TMenuItem;
    ScanVolume1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    ables1: TMenuItem;
    BrowseMediaCatalog1: TMenuItem;
    BrowseFiles1: TMenuItem;
    OpenDialog1: TOpenDialog;
    TreeView1: TTreeView;
    lblStatus: TLabel;
    lblFileName: TLabel;
    mEDIA1: TMenuItem;
    Eject1: TMenuItem;
    D1: TMenuItem;
    E1: TMenuItem;
    F1: TMenuItem;
    N2: TMenuItem;
    DebugTest1: TMenuItem;
    ScanVolume2: TMenuItem;
    OpenMediaCatalog1: TMenuItem;
    OpenMediaCatalog2: TMenuItem;
    BrowseLocations1: TMenuItem;
    ADOConnection1: TADOConnection;
    ADOCommand1: TADOCommand;
    ADOXCatalog1: TADOXCatalog;
    NewMediaCatalog1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure BrowseMediaCatalog1Click(Sender: TObject);
    procedure BrowseFiles1Click(Sender: TObject);
    procedure ImportImportDirectoryListingTextFile1Click(Sender: TObject);
    procedure ImportDirectoryListingTextFolder1Click(Sender: TObject);
    procedure ScanVolume1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure D1Click(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure F1Click(Sender: TObject);
    procedure DebugTest1Click(Sender: TObject);
    procedure ScanVolume2Click(Sender: TObject);
    procedure OpenMediaCatalog2Click(Sender: TObject);
    procedure BrowseLocations1Click(Sender: TObject);
    procedure NewMediaCatalog1Click(Sender: TObject);
  private
    fErrCount: integer;
    fFilesProcessed: integer;
    fLastReadTime: double;
    fLineCount: integer;
    fLineWithinFile: integer;
    fLocationsBrowser: TLocationsBrowser;
    fVolumesTable: TVolumesTable;
    fFileInfoTable: TFileInfoTable;
    fLocationsTable: TLocationsTable;
    fFolderCount: integer;
    fRecsAdded: integer;
    fRecsUpdated: integer;
    fLogFile: TextFile;
    fLogFileIsOpen: boolean;
    fLogFileName: string;
    function GetVolumesBrowser: TfrmVolumesBrowser;
    function GetVolumesTable: TVolumesTable;
    function GetFileInfoTable: TFileInfoTable;
    function GetFileInfoBrowser: TFrmFileInfoBrowser;
    procedure ScanSingleTextFile(const FullFileName: string; SingleFileOnly, CompletelyRepopulate, AppendOnly: boolean);
    procedure InitScan(FileName: string);
    procedure FinishScan;
    procedure LogError(Msg: string; Args: array of const);
    procedure LogNote (Msg: string; Args: array of const);
    procedure CloseFiles;
    procedure OpenLogFile;
    procedure CloseLogFile;
    function GetLocationsBrowser: TLocationsBrowser;
    function GetLocationsTable: TLocationsTable;
    { Private declarations }
  public
    { Public declarations }
    property VolumesBrowser: TfrmVolumesBrowser
             read GetVolumesBrowser;
    property VolumesTable: TVolumesTable
             read GetVolumesTable;
    property FileInfoBrowser: TFrmFileInfoBrowser
             read GetFileInfoBrowser;
    property FileInfoTable: TFileInfoTable
             read GetFileInfoTable;
    property LocationsBrowser: TLocationsBrowser
             read GetLocationsBrowser;
    property LocationsTable: TLocationsTable
             read GetLocationsTable;
    constructor Create(aOwner: TComponent); override;
  end;

var
  frmMediaCatalog: TfrmMediaCatalog;

implementation

uses MyUtils, MediaCatalog_Decl, MyTables_Decl, DateUtils, PDB_Decl,
  VolumeInfo, DeviceUtils, LabelTheDisk, SelectDrive;

{$R *.dfm}

var
  gSettingsFileName: string;

procedure TfrmMediaCatalog.Exit1Click(Sender: TObject);
begin
  Close;
end;

function TfrmMediaCatalog.GetVolumesBrowser: TfrmVolumesBrowser;
begin
  if not Assigned(frmVolumesBrowser) then
    frmVolumesBrowser := TfrmVolumesBrowser.Create(self, VolumesTable, VOLUMES_TABLE_NAME);
  result := frmVolumesBrowser;
end;

function TfrmMediaCatalog.GetVolumesTable: TVolumesTable;
begin
  if not Assigned(fVolumesTable) then
    begin
      fVolumesTable := TVolumesTable.Create(self, MediaSettings.DBFilePathName, VOLUMES_TABLE_NAME, []);
      fVolumesTable.AddFields;
      fVolumesTable.IndexName := LOCATION_AND_LABEL;
      fVolumesTable.Active := true;
    end;
  result := fVolumesTable;                                                
end;

function TfrmMediaCatalog.GetFileInfoTable: TFileInfoTable;
begin
  if not Assigned(fFileInfoTable) then
    begin
      fFileInfoTable := TFileInfoTable.Create(self, MediaSettings.DBFilePathName, 'FileInfo', []);
      fFileInfoTable.AddFields;
      fFileInfoTable.IndexName := 'FullIndex';
      try
        fFileInfoTable.Open;
      except
        on e:Exception do
          begin
            FreeAndNil(fFileInfoTable);
            raise Exception.CreateFmt('Error when opening FileInfoTable [%s]', [e.Message]);
          end;
      end;
    end;
  result := fFileInfoTable;
end;

procedure TfrmMediaCatalog.BrowseMediaCatalog1Click(Sender: TObject);
begin
  VolumesBrowser.Show;
end;

procedure TfrmMediaCatalog.BrowseFiles1Click(Sender: TObject);
begin
  FileInfoBrowser.Show;
end;

function TfrmMediaCatalog.GetFileInfoBrowser: TFrmFileInfoBrowser;
begin
  if not Assigned(frmFileInfoBrowser) then
    frmFileInfoBrowser := TfrmFileInfoBrowser.Create(self, FileInfoTable, 'File Info');
  result := frmFileInfoBrowser;
end;

procedure TfrmMediaCatalog.ScanSingleTextFile(const FullFileName: string; SingleFileOnly, CompletelyRepopulate, AppendOnly: boolean);
var
  InFile: TextFile;
  Line, VolumeName, VolumeSerialNumber, FolderName, FileName: string;
  Media_ID: integer;
  RootFolder: TFolderList;
  RootTree: TTreeNode;
  NextFolderNumber: integer;
//TotalFileSize: double;

  procedure ReadLine;
  begin
    ReadLn(InFile, Line);  Inc(fLineCount); Inc(fLineWithinFile);
    if ((fLineCount mod 100) = 0) or (MilliSecondsBetween(Now, fLastReadTime) > 1000) then
      begin
        lblStatus.Caption := Format('%d files processed; %0.n lines read; %d errors; %0.n records added; %0.n records updated',
                                  [fFilesProcessed, fLineCount*1.0, fErrCount, fRecsAdded*1.0, fRecsUpdated*1.0]);
        Application.ProcessMessages;
      end;
    fLastReadTime := Now;
  end;

  function FindFolder(CurrentFolder: TFolderList; const FolderName: string): TFolderList;
  var
    bp: integer;
    IndexNumber: integer;
    Prefix, Tail: string;
    SubFolder: TFolderList;
  begin { FindFolder }
    result := nil;
    if Empty(FolderName) then
      begin
        result := RootFolder;
      end
    else
      begin
        bp := Pos('\', FolderName);
        if bp = 0 then
          begin
            IndexNumber := CurrentFolder.IndexOf(FolderName);
            if IndexNumber >= 0 then
              begin
                result := TFolderList(CurrentFolder.Objects[IndexNumber]);
              end
            else
              begin
                result := TFolderList.Create;
                result.FolderName := FolderName;
                result.Folder_ID  := NextFolderNumber;
                Inc(NextFolderNumber);
                CurrentFolder.AddObject(FolderName, result);
              end;
          end
        else
          begin
            Prefix      := Copy(FolderName, 1, bp-1);
            Tail        := Copy(FolderName, bp+1, MAXFILENAMELEN);
            SubFolder   := FindFolder(CurrentFolder, Prefix);
            if Assigned(SubFolder) then
              result := FindFolder(Subfolder, Tail)
          end;
      end;
  end;  { FindFolder }

  function FindTreeNode(CurrentTreeNode: TTreeNode; const FolderName: string): TTreeNode;
  var
    bp: integer;
    IndexNumber: integer;
    Prefix, Tail: string;
    SubTree: TTreeNode;
    mode: TSearch_Type; // (SEARCHING, SEARCH_FOUND, NOT_FOUND);
  begin { FindTreeNode }
    result := nil;
    if Empty(FolderName) then
      result := RootTree
    else
      begin
        bp := Pos('\', FolderName);
        if bp = 0 then
          begin
            IndexNumber := 0;
            mode := SEARCHING;   // can probably use a binary search here
            repeat
              if IndexNumber >= CurrentTreeNode.Count then
                mode := NOT_FOUND
              else
                if SameText(FolderName, CurrentTreeNode.Item[IndexNumber].Text) then
                  mode := SEARCH_FOUND
                else
                  inc(IndexNumber);
            until mode <> SEARCHING;

            if mode = SEARCH_FOUND then
              result := CurrentTreeNode[IndexNumber]
            else
              begin
                result := TreeView1.Items.AddChild(CurrentTreeNode, FolderName);
              end;
          end
        else
          begin
            Prefix      := Copy(FolderName, 1, bp-1);
            Tail        := Copy(FolderName, bp+1, MAXFILENAMELEN);
            SubTree     := FindTreeNode(CurrentTreeNode, Prefix);
            if Assigned(SubTree) then
              result := FindTreeNode(SubTree, Tail)
          end;
      end;
  end;  { FindTreeNode }

  procedure ProcessFolder;
  var
    DateStr, DateTimeStr, DirStr, FileName, FileSizeStr, HashName: string;
    DateTime: TDateTime;
    CurrentFolder, SubFolder: TFolderList;
    ParentFolder_ID: integer;
    CurrentTreeNode: TTreeNode;
    IsAFolder: boolean;
    FileSize: double;
  begin { ProcessFolder }
    FolderName      := Copy(Line, 18, MAXFILENAMELEN);
    CurrentFolder   := FindFolder(RootFolder, FolderName);
    ParentFolder_ID := CurrentFolder.Folder_ID;
    CurrentTreeNode := nil;  // otherwise compile will complain

    if SingleFileOnly then
      CurrentTreeNode := FindTreeNode(RootTree, FolderName);

    ReadLine;
    if not Empty(Line) then
      AlertFmt('Line following directory "%s" is not blank', [FolderName]);

    repeat
      ReadLine;
      DateStr     := Copy(Line, 1, 10);
      if not Empty(DateStr) then
        begin
          DateTimeStr := Copy(Line, 1, 24);
          try
            DateTime    := StrToDateTime(DateTimeStr);
          except
            DateTime    := BAD_DATE;
          end;
          DirStr      := Copy(Line, 25, 5);
          FileName    := Trim(Copy(Line, 40, MAXFILENAMELEN));
          FileSizeStr := CleanUpString(Trim(Copy(Line, 25, 40-25)), DIGITS, #0);
          IsAFolder   := DirStr = '<DIR>';
          SubFolder   := nil;

          if IsAFolder then
            begin
              if not ((FileName = '.') or (FileName = '..')) then  // not the parent directory or self
                begin
                  SubFolder := FindFolder(CurrentFolder, FileName);  // add a sub-folder for this directory

                  if SingleFileOnly then
                    FindTreeNode(CurrentTreeNode, FileName);   // create the tree node if it doesn't already exist
                end
              else
                Continue;
            end;

          with FileInfoTable do
            begin
              HashName := HashedFileName(FileName, HASHED_NAME_LENGTH);

              if CompletelyRepopulate then  // Completely rebuilding DB
                begin
                  Append;
                  Inc(fRecsAdded);
                end else
              if AppendOnly then // We known that these records do not exist
                begin
                  Append;
                  Inc(fRecsAdded);
                  LogNote('Added Record. Media_ID=%d, ParentFolder_ID=%d, HashName="%s", FullName="%s"',
                          [Media_ID, ParentFolder_ID, HashName, FileName]);
                end else
              if LocateFileByName(Media_ID, ParentFolder_ID, HashName, FileName) then // This record does exist
                begin
                  Edit;
                  Inc(fRecsUpdated);
                end
              else  // This record does NOT exist
                begin
                  Append;
                  Inc(fRecsAdded);
                end;

              fldMedia_ID.AsInteger          := Media_ID;
              fldParentFolder_ID.AsInteger   := ParentFolder_ID;
              if DateTime <> BAD_DATE then
                fldDateTimeModified.AsDateTime := DateTime;
              if not Empty(FileSizeStr) then
                begin
                  try
                    FileSize := StrToFloat(FileSizeStr);
                  except
                    FileSize := MAXLONGINT;
                  end;
                  fldFileSize.AsFloat := FileSize;
//                TotalFileSize := TotalFileSize + FileSize;
                end;
              fldShortFileName.AsString      := HashName;
              if fldLongFileName.AsString <> fldShortFileName.AsString then
                fldLongFileName.AsString       := FileName;
              fldIsAFolder.AsBoolean         := IsAFolder;
              if IsAFolder then
                fldThisFolders_ID.AsInteger  := SubFolder.Folder_ID;

              Post;
            end;
        end;
    until Empty(DateStr);
  end;  { ProcessFolder }

  procedure ProcessHeader;
  begin { ProcessHeader }          
    if SameText(Trim(Copy(Line, 1, 16)), 'Volume in drive') then
      begin
        VolumeName := Copy(Line, 23, MAXFILENAMELEN);
        ReadLine;
      end
    else
      raise EContentError.CreateFmt('Improperly formed header section in file "%s". [No Volume in Drive line]', [FullFileName]);

    if Trim(Copy(Line, 1, 25)) = 'Volume Serial Number is' then
      begin
        VolumeSerialNumber := Copy(Line, 26, 9);
        ReadLine;
      end
    else
      raise Exception.CreateFmt('Improperly formed header section in file "%s". [No Volume Serial Number Line]', [FullFileName]);

    with VolumesTable do
      begin
        Edit;
        fldVolumeShortName.AsString    := VolumeName;
        fldVolumeSerialNumber.AsString := VolumeSerialNumber;
        fldMedia.AsString              := 'D';   // assume DVD
        Post;
      end;
  end;  { ProcessHeader }

begin { ScanSingleTextFile }
  FileName := ExtractFileBase(FullFileName);
  lblFileName.Caption := Format('Now Scanning: %s', [FullFileName]);
  Application.ProcessMessages;
  NextFolderNumber := 0;
  fLineWithinFile  := 0;
  TreeView1.Items.Clear;
  if UpperCase(Copy(FileName, 1, 2)) = 'CD' then
    begin
      Media_ID := StrToInt(Copy(FileName, 3, 4));
      if VolumesTable.Locate('Media_ID', Media_ID, []) then  // Volumes table is positioned on the correct record
        begin
          inc(fFilesProcessed);
          AssignFile(InFile, FullFileName);
          Reset(InFile);
          repeat
            ReadLine;
          until SameText(Trim(Copy(Line, 1, 16)), 'Volume in drive') or Eof(InFile);

          try
            if Eof(InFile) then
              raise EContentError.CreateFmt('Improperly formed header section in file "%s". [No Volume in Drive line]', [FullFileName]);
//          TotalFileSize   := 0.00;
            ProcessHeader;
            RootFolder := TFolderList.Create;
            RootFolder.Folder_ID := NextFolderNumber;  // always 0?
            Inc(NextFolderNumber);
            RootTree   := TreeView1.Items.Add(nil, '');

            try
              while not Eof(InFile) do
                begin
                  if Trim(Copy(Line, 1, 14)) = 'Directory of' then
                    begin
                      ProcessFolder;
                    end;
                  ReadLine;
                end;
            finally
              FreeAndNil(RootFolder);
              CloseFile(InFile);
            end;
          except
            on e:Exception do
              begin
                LogError('Error processing file "%s" @ line %d [%s]', [FullFileName, fLineWithinFile, e.Message]);
                CloseFile(InFile);
              end;
          end;
        end
      else
        LogError('Error processing file "%s". No record exists in the Volumes table for Media_ID=%d',
                 [FullFileName, Media_ID]);
    end
  else
    ErrorFmt('Unexpected file "%s" in folder', [FileName]);
end;  { ScanSingleTextFile }

procedure TfrmMediaCatalog.OpenLogFile;
begin
  if not fLogFileIsOpen then
    begin
      AssignFile(fLogFile, fLogFileName);
      Rewrite(fLogFile);
      fLogFileIsOpen := true;
    end;
end;


procedure TfrmMediaCatalog.LogNote (Msg: string; Args: array of const);
begin
  OpenLogFile;
  WriteLn(fLogFile, Format(Msg, Args));
end;

procedure TfrmMediaCatalog.LogError(Msg: string; Args: array of const);
var
  ErrMsg: string;
begin
  Inc(fErrCount);
  OpenLogFile;
  ErrMsg := Format(Msg, Args);
  lblFileName.Caption := ErrMsg;
  lblFileName.Color := clYellow;
  WriteLn(fLogFile, fErrCount:3, '. ', ErrMsg);
end;


procedure TfrmMediaCatalog.InitScan(FileName: string);
begin
  fRecsAdded        := 0;
  fRecsUpdated      := 0;
  fLineCount        := 0;
  fFilesProcessed   := 0;
  fErrCount         := 0;
  fLastReadTime     := Now;
  OpenLogFile;
  WriteLn(fLogFile, Format('Log File Created on %s', [DateTimeToStr(Now)]));
  WriteLn(fLogFile);
end;

procedure TfrmMediaCatalog.FinishScan;
begin
  CloseLogFile;
  lblStatus.Caption := Format('COMPLETE. %d files processed; %d lines read; %d Errors; %d records added; %d records updated',
                              [fFilesProcessed, fLineCount, fErrCount, fRecsAdded, fRecsUpdated]);
  Application.ProcessMessages;
end;



procedure TfrmMediaCatalog.ImportImportDirectoryListingTextFile1Click(
  Sender: TObject);
var
  FileBase: string;
  AppendOnly: boolean;
begin
  with OpenDialog1 do
    begin
      InitialDir := MediaSettings.CDContentsFolder;
      DefaultExt := 'txt';
      FileName   := 'CD0040.txt';
      if Execute then
        begin
          AppendOnly := Yes('Yes = Append Records, No = Update Pre-existing records');
          FileBase := ExtractFileBase(FileName);
          fLogFileName := TempPath + 'LogOf_' + FileBase + '.txt';
          InitScan(fLogFileName);
          ScanSingleTextFile(FileName, true, false, AppendOnly);
          FinishScan;
        end;
    end;
end;

{ TFolderList }

destructor TFolderList.Destroy;
var
  i: integer;
begin
  for i := Count-1 downto 0 do
    Objects[i].Free;
  inherited;
end;

procedure TfrmMediaCatalog.ImportDirectoryListingTextFolder1Click(
  Sender: TObject);
var
  FolderName, WildPath, FileName: string;
  SearchRec: TSearchRec;
  DosErr: integer;
  DeletionCount: integer;
  SavedRecno: integer;
  CompletelyRepopulate: boolean;
begin
  FolderName := MediaSettings.CDContentsFolder;
  if BrowseForFolder('Browse for folder containing CDnnnnn.txt files', FolderName) then
    begin
      WildPath          := ForceBackSlash(FolderName) + 'CD*.txt';
      DosErr            := FindFirst(WildPath, 0, SearchRec);
      try

        CompletelyRepopulate := Yes('Completely repopulate the DB?');
        if CompletelyRepopulate then
          with FileInfoTable do
            begin
              DeletionCount := 0;
              First;
              while not Eof do
                begin
                  SavedRecno := RecNo;
                  Delete;
                  if SavedRecNo <> RecNo then
                    Next;
                  Inc(DeletionCount);
                  if (DeletionCount mod 100) = 0 then
                    begin
                      lblstatus.Caption := Format('%d records deleted', [DeletionCount]);
                      Application.ProcessMessages;
                    end;
                end;
            end;

        InitScan(TempPath + 'LogFile.txt');
        while DosErr = 0 do
          begin
            FileName := ForceBackSlash(FolderName) + SearchRec.Name;
            ScanSingleTextFile(FileName, false, CompletelyRepopulate, false);
            DosErr := FindNext(SearchRec);
          end;
      finally
        FinishScan;
        FindClose(SearchRec);
      end;
    end;
end;

procedure TfrmMediaCatalog.ScanVolume1Click(Sender: TObject);
var
  InFile: TextFile;
  Line: string;
  Volume_ID: integer;
  New_FileName: string;
  AppendOnly, OK: boolean;
  CD_Contents_Path: string;
  Old_FileName: string;
  BatchFileName: string;
  CD_Drive_Letter: char;
  RecordExists: boolean;

  function ScanHeader: boolean;

    procedure ReadLine;
    begin { ReadLine }
      ReadLn(InFile, Line);
    end;  { ReadLine }

  begin { ScanHeader }
    result := true;
    ReadLine;
    if SameText(Trim(Copy(Line, 1, 16)), 'Volume in drive') then
      begin
        frmVolumeInfo.VolumeName := Copy(Line, 23, MAXFILENAMELEN);
        ReadLine;
      end
    else
      begin
        AlertFmt('Improperly formed header section in file "%s". [No Volume in Drive line]', [Old_FileName]);
        result := false;
        Exit;
      end;

    if Trim(Copy(Line, 1, 25)) = 'Volume Serial Number is' then
      begin
        frmVolumeInfo.VolumeSerialNumber := Copy(Line, 26, 9);
        ReadLine;
      end
    else
      begin
        AlertFmt('Improperly formed header section in file "%s". [No Volume Serial Number Line]', [Old_FileName]);
        result := false;
        Exit;
      end;
  end;  { ScanHeader }

  procedure MakeBatchFile;
  var
    BatFile: TextFile;
  begin { MakeBatchFile }
    AssignFile(BatFile, BatchFileName);
    ReWrite(BatFile);
    WriteLn(BatFile, 'DIR ', CD_Drive_Letter, ':\*.* /S >"', Old_FileName, '"');
    CloseFile(BatFile);
  end;  { MakeBatchFile }

begin { TfrmMediaCatalog.ScanVolume1Click }
  CD_Contents_Path  := ForceBackSlash(MediaSettings.CDContentsFolder);
  BatchFileName     := MediaSettings.BatchFileName;
  CD_Drive_Letter   := MediaSettings.CDDriveLetter;

  with frmSelectDrive do
    begin
      DriveLetter := CD_Drive_Letter;
      if ShowModal = mrOk then
        begin
          CD_Drive_Letter := DriveLetter;
          MediaSettings.CDDriveLetter := DriveLetter;
        end
      else
        Exit;
    end;

  Old_FileName      := Format('%sCD%sXXX.txt', [CD_Contents_Path, CD_Drive_Letter]);
  if FileExists(Old_FileName) then
    OK := DeleteFile(Old_FileName)
  else
    OK := true;

  if OK then
    begin
      MakeBatchFile;
      if ExecAndWait(BatchFileName, '') then
        begin
          EjectDrive(CD_Drive_Letter, _OPEN);
          Assignfile(InFile, Old_FileName);
          try
            Reset(InFile);
            if not Assigned(frmVolumeInfo) then
              frmVolumeInfo := TfrmVolumeInfo.Create(self);
            try
              if not ScanHeader then
                begin
                  CloseFile(InFile);
                  Exit;
                end;

              with frmVolumeInfo do
                begin
                  RecordExists :=  VolumesTable.Locate(VOLUME_SERIAL_NUMBER, VolumeSerialNumber, []); // the record already exists
                  if RecordExists then
                    begin
                      VolumeLocationID := VolumesTable.fldLocationID.AsInteger;
                      VolumeLabel      := VolumesTable.fldVolumeLabel.AsString;
                      Publisher        := VolumesTable.fldPublisher.AsString;
                      KEY              := VolumesTable.fldKey.AsString;
                      Comment          := VolumesTable.fldComment.AsString;
                      Media            := VolumesTable.fldMedia.AsString;
                      VolumeSerialNumber := VolumesTable.fldVolumeSerialNumber.AsString;
                      VolumeName       := VolumesTable.fldVolumeShortName.AsString;
                      VolumesTable.Edit;
                    end
                  else
                    begin
                      VolumeLocation := MediaSettings.VolumeLocation;
                      VolumeLabel    := '';
                      Media          := 'D';  // DVD
                      VolumesTable.Append;
                    end;
                  DirListingFile := Old_FileName;
                end;

              if frmVolumeInfo.ShowModal = mrOK then
                begin
                  with VolumesTable do
                    begin
                      try
                        MediaSettings.VolumeLocation   := frmVolumeInfo.VolumeLocation;  // save for future use

//                      fldLocation.AsString           := frmVolumeInfo.VolumeLocation;
                        fldLocationID.AsInteger        := frmVolumeInfo.VolumeLocationID;
                        fldVolumeLabel.AsString        := frmVolumeInfo.VolumeLabel;
                        fldPublisher.AsString          := frmVolumeInfo.Publisher;
                        fldKey.AsString                := frmVolumeInfo.KEY;
                        fldComment.AsString            := frmVolumeInfo.Comment;
                        fldMedia.AsString              := frmVolumeInfo.Media;
                        fldVolumeSerialNumber.AsString := frmVolumeInfo.VolumeSerialNumber;
                        fldVolumeShortName.AsString    := frmVolumeInfo.VolumeName;
                        Post;
                      except
                        on e:Exception do
                          begin
                            ErrorFmt('Error while trying to post Volume Info record [%s]', [e.message]);
                            Exit;
                          end;
                      end;

                      Volume_ID                       := fldMedia_ID.AsInteger;

                      CloseFile(InFile);
                      New_FileName                   := CD_Contents_Path + 'CD' + Rzero(Volume_ID, 4) + '.txt';
                      ReNameFile(Old_FileName, New_FileName);

                      AppendOnly := Yes('Yes = Append Records, No = Update Pre-existing records');
                      fLogFileName := TempPath + 'LogOf_' + ExtractFileBase(New_FileName) + '.txt';
                      InitScan(fLogFileName);
                      ScanSingleTextFile(New_FileName, true, false, AppendOnly);
                      FinishScan;

                      with frmLabelTheDisk do
                        begin
                          VolumeID.Caption := IntToStr(Volume_ID);
                          ShowModal;
                        end;
                    end;
                end;
            finally
//            FreeAndNil(frmVolumeInfo);
            end;
          except
            on e:Exception do
              begin
                ErrorFmt('Error occurred while processing [%s]', [e.message]);
                CloseFile(InFile);
              end;
          end;
        end;
    end
  else
    AlertFmt('Unable to delete file %s', [Old_FileName]);
end;  { TfrmMediaCatalog.ScanVolume1Click }

procedure TfrmMediaCatalog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  MediaSettings.SaveToFile(gSettingsFileName);
end;

constructor TfrmMediaCatalog.Create(aOwner: TComponent);
begin
  inherited;
  gSettingsFileName := ExtractFilePath(ParamStr(0)) + 'MediaCatalog.ini';
  if FileExists(gSettingsFileName) then
    MediaSettings.LoadFromFile(gSettingsFileName);
end;

procedure TfrmMediaCatalog.D1Click(Sender: TObject);
begin
  EjectDrive('D', _open);
end;

procedure TfrmMediaCatalog.E1Click(Sender: TObject);
begin
  EjectDrive('E', _open);
end;

procedure TfrmMediaCatalog.F1Click(Sender: TObject);
begin
  EjectDrive('F', _open);
end;

procedure TfrmMediaCatalog.DebugTest1Click(Sender: TObject);
begin
  frmVolumeInfo := TfrmVolumeInfo.Create(self);
  with frmVolumeInfo do
    begin
      VolumeLocation := 'Demos/Tutorials';
      ShowModal;
      Free;
    end;

end;

procedure TfrmMediaCatalog.ScanVolume2Click(Sender: TObject);
var
  FolderPath: string;
  DOSErr: integer;
  SavedCursor: TCursor;
  Media_ID: integer;
  dummy: integer;
  AppendOnly: boolean;

  procedure ProcessFolder(FolderPath: string; ParentFolder_ID: integer; var TheFolderNumber: integer);
  var
    CurrentFolderNumber, aFolderNumber: integer;
    SearchRec: TSearchRec;

    procedure ProcessFile(FolderPath: string; const SearchRec: TSearchRec; IsAFolder: boolean; ParentFolder_ID, TheFolderNumber: integer);
    var
      LongFileName, HashName, FilePath: string;
    begin { ProcessFile }
      FilePath     := FolderPath + SearchRec.Name;
      LongFileName := ExtractFileName(FilePath);
      if not Empty(LongFileName) then
        begin
          HashName     := HashedFileName(LongFileName, HASHED_NAME_LENGTH);
          with FileInfoTable do
            begin
              if AppendOnly then
                begin
                  Append;
                  inc(fRecsAdded);
                end else
              if LocateFileByName(Media_ID, ParentFolder_ID, HashName, LongFileName) then
                begin
                  Edit;
                  inc(fRecsUpdated);
                end
              else
                begin
                  Append;
                  inc(fRecsAdded);
                end;

              fldParentFolder_ID.AsInteger   := ParentFolder_ID;
              fldMedia_ID.AsInteger          := Media_ID;
              try
                fldDateTimeModified.AsDateTime := FileDateToDateTime(SearchRec.Time);
              except
                on e:Exception do
                  LogError('Error converting FileDate to DateTime for file [%s]', [FilePath]);
              end;
              fldFileSize.AsFloat            := SearchRec.Size;
              fldShortFileName.AsString      := HashName;
              if LongFileName <> HashName then
                fldLongFileName.AsString     := LongFileName;
              fldIsAFolder.AsBoolean         := IsAFolder;
              if IsAFolder then
                fldThisFolders_ID.AsInteger  := TheFolderNumber;
//            fldDateRecordAdded.AsDatetime  := Now;

              Post;
            end;

          inc(fFilesProcessed);
          if ((fFilesProcessed mod 1000) = 0) or (MilliSecondsBetween(Now, fLastReadTime) > 1000) then
            begin
              lblStatus.Caption := Format('%0.n files processed; %d errors; %0.n records added; %0.n records updated',
                                        [fFilesProcessed*1.0, fErrCount, fRecsAdded*1.0, fRecsUpdated*1.0]);
              Application.ProcessMessages;
            end;
          fLastReadTime := Now;
        end;
    end;  { ProcessFile }

  begin { ProcessFolder }
    CurrentFolderNumber := fFolderCount + 1;
    TheFolderNumber     := CurrentFolderNumber;
    Inc(fFolderCount);

    FolderPath := ForceBackSlash(FolderPath);

    DOSErr := FindFirst(FolderPath + '*.*', faAnyFile-faDirectory, SearchRec);
    // Process the files first
    try
      while DOSErr = 0 do
        begin
          if (SearchRec.Attr and faDirectory) = 0 then  // probably unnecessary
            ProcessFile(FolderPath, SearchRec, false, CurrentFolderNumber, TheFolderNumber);
          DOSErr := FindNext(SearchRec);
        end;
    finally
      FindClose(SearchRec);
    end;

    // then process the folders
    DOSErr := FindFirst(FolderPath + '*.*', faDirectory, SearchRec);
    try
      while DOSErr = 0 do
        begin
          if ((SearchRec.Attr and faDirectory) <> 0) and (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
            begin
              ProcessFolder(FolderPath + SearchRec.Name, CurrentFolderNumber, aFolderNumber);
              ProcessFile(FolderPath, SearchRec, true, CurrentFolderNumber, aFolderNumber);  // Its a folder but its also a file
            end;
          DOSErr := FindNext(SearchRec);
        end;
    finally
      FindClose(SearchRec);
    end;
  end;  { ProcessFolder }

  function ProcessVolumeInfo: boolean;
  var
    DriveLetter: string;
    TheSerialNumber: string;

    function GetVolumeLabel(DriveChar: Char; var TheSerialNumber: string): string;
    var
      NotUsed:     DWORD;
      VolumeFlags: DWORD;
      VolumeSerialNumber: DWORD;
      Buf: array [0..MAX_PATH] of Char;
    begin
      GetVolumeInformation(PChar(DriveChar + ':\'), Buf, MAX_PATH+1, @VolumeSerialNumber, NotUsed, VolumeFlags, nil, 0);

      SetString(Result, Buf, StrLen(Buf));   { Set return result }
      TheSerialNumber := IntToHex(HiWord(VolumeSerialNumber), 4) + '-' +
                         IntToHex(LoWord(VolumeSerialNumber), 4);
    end;

  begin { ProcessVolumeInfo }
    if not Assigned(frmVolumeInfo) then
      frmVolumeInfo := TfrmVolumeInfo.Create(self);
    with frmVolumeInfo do
      begin
        DriveLetter := ExtractFileDrive(FolderPath);
        VolumeName  := GetVolumeLabel(DriveLetter[1], TheSerialNumber);
        fLogFileName := TempPath + 'Log of ' + VolumeName + '.txt';
        VolumeSerialNumber := TheSerialNumber;
        VolumeLocation     := ComputerName;
        VolumeLabel := Format('%s [%s] on %s', [DriveLetter, VolumeName, ComputerName]);
        Media       := 'H';   // Hard drive
        result := ShowModal = mrOk;
        if result then
          with VolumesTable do
            begin
              if AppendOnly then
                begin
                  Append;
                  inc(fRecsAdded);
                end else
              if VolumesTable.Locate('Volume Serial Number', VolumeSerialNumber, []) then
                begin
                  Edit;
                  inc(fRecsUpdated);
                end
              else
                begin
                  Append;
                  inc(fRecsAdded);
                end;

              fldLocationID.AsInteger        := VolumeLocationID;
              fldVolumeLabel.AsString        := VolumeLabel;
              fldPublisher.AsString          := Publisher;
              fldKey.AsString                := Key;
              fldComment.AsString            := Comment;
              fldMedia.AsString              := Media;
              fldDateAdded.AsDateTime        := Now;
              fldVolumeSerialNumber.AsString := VolumeSerialNumber;
              fldVolumeShortName.AsString    := VolumeName;

              Post;
              Media_ID                       := fldMedia_ID.AsInteger;
            end;
      end;
  end;  { ProcessVolumeInfo }

begin { TfrmMediaCatalog.ScanVolume2Click }
  FolderPath := 'O:\NewDell\NewDell-C\d5\Projects\';
  if BrowseForFolder('Select folder to be scanned', FolderPath) then
    begin
      AppendOnly      := Yes('Yes = Append Records, No = Update Pre-existing records');
      if ProcessVolumeInfo then
        begin
          SavedCursor     := Screen.Cursor;
          Screen.Cursor   := crHourGlass;
          fFilesProcessed := 0;
          fErrCount       := 0;
          fRecsAdded      := 0;
          fRecsUpdated    := 0;
          fFolderCount    := 0;
          fLastReadTime   := Now;

          try
            ProcessFolder(FolderPath, 0, dummy);
          finally
            lblStatus.Caption := Format('COMPLETED. %0.n files processed; %d errors; %0.n records added; %0.n records updated',
                                      [fFilesProcessed*1.0, fErrCount, fRecsAdded*1.0, fRecsUpdated*1.0]);
            Screen.Cursor := SavedCursor;
            CloseLogFile;
            if fErrCount > 0 then
              begin
                if not ExecAndWait('NotePad.exe', fLogFileName, true) then
                  AlertFmt('Unable to open "%s"', [fLogFileName]);
              end;
          end;
        end;
    end;
end;  { TfrmMediaCatalog.ScanVolume2Click }            

procedure TfrmMediaCatalog.CloseLogFile;
begin
  if fLogFileIsOpen then
    begin
      CloseFile(fLogFile);
      fLogFileIsOpen := false;
    end;
end;


procedure TfrmMediaCatalog.CloseFiles;
begin
  FreeAndNil(fVolumesTable);
  FreeAndNil(fFileInfoTable);
  FreeAndNil(frmFileInfoBrowser);
  FreeAndNil(frmVolumesBrowser);
end;

procedure TfrmMediaCatalog.OpenMediaCatalog2Click(Sender: TObject);
var
  FilePath: string;
begin
  CloseFiles;
  FilePath := MediaSettings.DBFilePathName;
  if BrowseForFile('Locate MediaCatalog.mdb', FilePath, 'mdb') then
    begin
      MediaSettings.DBFilePathName := FilePath;
    end;
end;

procedure TfrmMediaCatalog.BrowseLocations1Click(Sender: TObject);
begin
  LocationsBrowser.Show;
end;

function TfrmMediaCatalog.GetLocationsBrowser: TLocationsBrowser;
begin
  if not assigned(fLocationsBrowser) then
    fLocationsBrowser := TLocationsBrowser.Create(self, LocationsTable, LOCATIONS_TABLE_NAME);
  result := fLocationsBrowser;
end;

function TfrmMediaCatalog.GetLocationsTable: TLocationsTable;
begin
  if not Assigned(fLocationsTable) then
    begin
      fLocationsTable := TLocationsTable.Create(self, MediaSettings.DBFilePathName, LOCATIONS_TABLE_NAME, []);
      fLocationsTable.AddFields;
      fLocationsTable.IndexName := 'Location Name';
      try
        fLocationsTable.Open;
      except
        on e:Exception do
          begin
            FreeAndNil(fLocationsTable);
            raise Exception.CreateFmt('Error when opening LocationsTable [%s]', [e.Message]);
          end;
      end;
    end;
  result := fLocationsTable;
end;

procedure TfrmMediaCatalog.NewMediaCatalog1Click(Sender: TObject);
var
  ConnectionString: string;
  dbName, cs: string;
  OK: boolean;
begin
  dbName     := 'c:\MediaCatalog.mdb';

  if BrowseForFile('Specify new MediaCatalog.mdb file', dbName, '.mdb') then
    begin
      if FileExists(dbName) then
        begin
          OK := YesFmt('The file %s already exists. Do you want to overwrite it? ', [dbName]);
          if OK then
            begin
              OK := DeleteFile(dbName);
              if not OK then
                AlertFmt('Unable to delete file %s', [dbName]);
            end;
        end
      else
        OK := true;
      if OK then
        begin
          ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + dbName + ';Jet OLEDB:Engine Type=5';
          ADOXCatalog1.Create1(ConnectionString);
          ADOConnection1.ConnectionString := ConnectionString;
          ADOConnection1.LoginPrompt      := false;
          ADOCommand1.Connection          := ADOConnection1;

          cs := 'CREATE TABLE FileInfo (' +
                 'ID COUNTER,' +
                 'Media_ID INT,' +
                 'ParentFolder_ID INT,' +
                 'ShortFileName TEXT(16),' +
                 'LongFileName MEMO,' +
                 'DateTimeModified DATETIME,' +
                 'FileSize FLOAT,' +
                 'IsAFolder YESNO,' +
                 'ThisFolders_ID INT)';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX PrimaryKey ' +
                'ON FileInfo (ID) WITH PRIMARY';

          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX FileName ' +
                'ON FileInfo (ShortFileName)';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX MediaID ' +
                'ON FileInfo (Media_ID)';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX FullIndex ' +
                'ON FileInfo (Media_ID,ParentFolder_ID,ShortFileName)';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          cs := 'CREATE TABLE Volumes (' +
                 'Media_ID COUNTER,' +
                 '[Location ID] INT,' +
                 '[Volume Label] TEXT(100),' +
                 'PUBLISHER TEXT(25),' +
                 '[KEY] MEMO,' +
                 'COMMENT MEMO,' +
                 'Media TEXT(1),' +
                 'DateAdded DATETIME,' +
                 '[Volume Serial Number] TEXT(10),' +
                 '[Volume Short Name] TEXT(16)' +
                 ')';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX [Media_ID] ' +
                'ON Volumes ([Media_ID]) WITH PRIMARY';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX CDLabel ' +
                'ON Volumes ([Volume Label])';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX [Location ID] ' +
                'ON Volumes ([Location ID])';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX [LocationAndLabel] ' +
                'ON Volumes ([Location ID],[Volume Label])';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          cs := 'CREATE TABLE Locations (' +
                 'ID COUNTER,' +
                 '[Location Name] TEXT(23),' +
                 '[Location Type] TEXT(10)' +
                 ')';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX PrimaryKey ' +
                'ON Locations (ID) WITH PRIMARY';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

          CS := 'CREATE INDEX [Location Name] ' +
                'ON Locations ([Location Name])';
          ADOCommand1.CommandText := cs;
          ADOCommand1.Execute;

      end;
    end;

end;

end.
