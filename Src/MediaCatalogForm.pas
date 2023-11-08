unit MediaCatalogForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, BrowserUnit, MediaTables, MediaSettingsFile, MediaBrowser,
  FileInfoBrowser, ComCtrls, StdCtrls, OleServer, ADOX_TLB, ADODB, DB,
  MediaCatalog_Decl, MyTables, MyTables_Decl, VolumeInfo;

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
    N1: TMenuItem;
    Exit1: TMenuItem;
    Tables1: TMenuItem;
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
    ScanVolume2: TMenuItem;
    OpenMediaCatalog1: TMenuItem;
    OpenMediaCatalog2: TMenuItem;
    BrowseLocations1: TMenuItem;
    ADOConnection1: TADOConnection;
    ADOCommand1: TADOCommand;
    AppendMediaCatalog1: TMenuItem;
    N3: TMenuItem;
    Edit1: TMenuItem;
    Settings1: TMenuItem;
    CloseMediaCatalog1: TMenuItem;
    Utilities1: TMenuItem;
    DEleteAllfilerecordsforavolume1: TMenuItem;
    SaveDialog2: TSaveDialog;
    procedure Exit1Click(Sender: TObject);
    procedure BrowseMediaCatalog1Click(Sender: TObject);
    procedure BrowseFiles1Click(Sender: TObject);
    procedure ImportImportDirectoryListingTextFile1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure D1Click(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure F1Click(Sender: TObject);
    procedure ScanVolume2Click(Sender: TObject);
    procedure OpenMediaCatalog2Click(Sender: TObject);
    procedure BrowseLocations1Click(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure Tables1Click(Sender: TObject);
    procedure TreeView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CloseMediaCatalog1Click(Sender: TObject);
    procedure DEleteAllfilerecordsforavolume1Click(Sender: TObject);
    procedure SaveDialog2TypeChange(Sender: TObject);
  private
    fDatabaseIsOpen: boolean;
    fErrCount: integer;
    fFilesProcessed: integer;
    fLastReadTime: double;
    fVolumeDate: TDateTime;
    fLineCount: integer;
    fLineWithinFile: integer;
    fLocationsBrowser: TLocationsBrowser;
    fVolumesTable: TVolumesTable;
    fFileInfoTable: TFileInfoTable;
    fLocationsTable: TLocationsTable;
    fFolderCount: integer;
    fRecsAdded: integer;
    fLogFile: TextFile;
    fLogFileIsOpen: boolean;
    fLogFileName: string;
    fTempFileInfoTable: TFileInfoTable;
    function GetVolumesBrowser: TfrmVolumesBrowser;
    function GetVolumesTable: TVolumesTable;
    function GetFileInfoTable: TFileInfoTable;
    function GetFileInfoBrowser: TFrmFileInfoBrowser;
    procedure ScanSingleTextFile(const FullFileName: string; Media_ID: integer);
    procedure InitScan(FileName: string);
    procedure FinishScan;
    procedure LogError(Msg: string; Args: array of const);
    procedure LogNote (Msg: string; Args: array of const);
    procedure CloseFiles;
    procedure OpenLogFile;
    procedure CloseLogFile;
    function GetLocationsBrowser: TLocationsBrowser;
    function GetLocationsTable: TLocationsTable;
    function TempFileInfoTable: TFileInfoTable;
    function TheVolumeInfoForm: TfrmVolumeInfo;
  protected
    procedure WMBuildTreeView(Var Message: TMessage); message WM_BuildTreeView;
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
    destructor Destroy; override;
  end;

var
  frmMediaCatalog: TfrmMediaCatalog;

implementation

uses MyUtils, DateUtils,
  DeviceUtils, LabelTheDisk, SelectDrive, MediaSettingsForm,
  ScanVolume, MyDelimitedParser, uGetString;

{$R *.dfm}

const
  ACCESS_2000_INDEX = 1;
  ACCESS_2007_INDEX = 2;

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
//    fVolumesTable.IndexName := LOCATION_AND_LABEL;
      fVolumesTable.IndexName := MEDIA_ID_FIELD_NAME;
      fVolumesTable.Active := true;
    end;
  result := fVolumesTable;
end;

function TfrmMediaCatalog.GetFileInfoTable: TFileInfoTable;
begin
  if not Assigned(fFileInfoTable) then
    begin
      fFileInfoTable := TFileInfoTable.Create(self, MediaSettings.DBFilePathName, FILEINFO_TABLE_NAME, []);
      fFileInfoTable.AddFields;
      fFileInfoTable.IndexName := 'FullIndex';
      try
        fFileInfoTable.Active := true;
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

function TfrmMediaCatalog.TheVolumeInfoForm: TfrmVolumeInfo;
begin
  if not Assigned(frmVolumeInfo) then
    frmVolumeInfo := TfrmVolumeInfo.Create(self);
  result := frmVolumeInfo;
end;

procedure TfrmMediaCatalog.ScanSingleTextFile( const FullFileName: string;
                                               Media_ID: integer);
var
  InFile: TextFile;
  Line, VolumeName, VolumeSerialNumber, FolderName, FileName: string;
  RootFolder: TFolderList;
  RootTree: TTreeNode;
  NextFolderNumber: integer;
  OK, CreateOneNow, Media_IDChanged: boolean;
  NewFileName, CD_Contents_Path: string;

  procedure ReadLine;
  begin
    ReadLn(InFile, Line);  Inc(fLineCount); Inc(fLineWithinFile);
    if Pos('Burmer', Line) > 0 then
      Line := Line; // a nice place for a breakpoint
    if ((fLineCount mod 100) = 0) or
       ((fFilesProcessed mod 100) = 0) or
       (MilliSecondsBetween(Now, fLastReadTime) > 1000) then
      begin
        lblStatus.Caption := Format('%d files processed; %0.n lines read; %d errors; %0.n records added',
                                  [fFilesProcessed, fLineCount*1.0, fErrCount, fRecsAdded*1.0]);
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
    Temp: string;
    IsAFolder: boolean;
    FileSize: double;
  begin { ProcessFolder }
    FolderName      := Copy(Line, 18, MAXFILENAMELEN);
    CurrentFolder   := FindFolder(RootFolder, FolderName);
    ParentFolder_ID := CurrentFolder.Folder_ID;

//  CurrentTreeNode := nil;
//  if SingleFileOnly then
//    CurrentTreeNode := FindTreeNode(RootTree, FolderName);

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
          if DateTime > fVolumeDate then
            fVolumeDate := DateTime;
          DirStr      := Copy(Line, 25, 5);
          FileName    := Trim(Copy(Line, 40, MAXFILENAMELEN));
          FileSizeStr := CleanUpString(Trim(Copy(Line, 25, 40-25)), DIGITS, #0);
          IsAFolder   := DirStr = '<DIR>';
          SubFolder   := nil;

          if IsAFolder then
            begin
              if not ((FileName = '.') or (FileName = '..')) then  // not the parent directory or self
                begin
                  if Pos('SHINING by the RIVER Collections Volume', FileName) > 0 then
                    IsAFolder := IsAFolder;  // nice place for a breakpoint
                  SubFolder := FindFolder(CurrentFolder, FileName);  // add a sub-folder for this directory
//                if SubFolder = CurrentFolder then
//                  IsAFolder := IsAFolder;  // nice place for a breakpoint

//                if SingleFileOnly then
//                  FindTreeNode(CurrentTreeNode, FileName);   // create the tree node if it doesn't already exist
                end
              else
                Continue;
            end;

          with FileInfoTable do
            begin
              HashName := HashedFileName(FileName, HASHED_NAME_LENGTH);

              Append;
              Inc(fRecsAdded);
              MediaSettings.FileInfoRecs := MediaSettings.FileInfoRecs + 1;

              if IsAFolder then
                temp := Format('%4d', [CurrentFolder.Folder_ID])
              else
                temp := '    ';

              LogNote('Added Record. Media_ID=%d, ParentFolder_ID=%4d, Folder_ID=%4s, HashName="%-16s", FullName="%s"',
                      [Media_ID, ParentFolder_ID, temp, HashName, FileName]);

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
//      Edit;
        fldVolumeShortName.AsString    := VolumeName;
        fldVolumeSerialNumber.AsString := VolumeSerialNumber;
        fldMedia.AsString              := 'D';   // assume DVD
      end;
  end;  { ProcessHeader }

begin { ScanSingleTextFile }
  FileName := ExtractFileBase(FullFileName);
  lblFileName.Caption := Format('Now Scanning: %s', [FullFileName]);
  Application.ProcessMessages;
  NextFolderNumber := 0;
  fLineWithinFile  := 0;
  TreeView1.Items.Clear;

  OK := VolumesTable.Locate(MEDIA_ID_FIELD_NAME, Media_ID, []);  // Check that Volumes table record exists for this volume
  CreateOneNow := false; Media_IDChanged := false;
  if OK then
    VolumesTable.Edit
  else
    begin
      CreateOneNow := YesFmt(
'No volume record exists for volume %d. Do you want to create one now (Media_ID may be changed)?',
                             [Media_ID]);
      if CreateOneNow then
        begin
          VolumesTable.Append;
          VolumesTable.Post;
          Media_IDChanged := Media_ID <> VolumesTable.fldMedia_ID.AsInteger;
          Media_ID        := VolumesTable.fldMedia_ID.AsInteger;
          VolumesTable.Edit;
        end;
      OK := CreateOneNow;
    end;

  if OK then
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
                ProcessFolder;
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

      if CreateOneNow then // Create the volume record
        with VolumesTable do
          begin
            fldDateAdded.AsDateTime := Now;

            TheVolumeInfoForm.VolumeLabel      := VolumeName;
            TheVolumeInfoForm.VolumeName       := VolumeName;
            TheVolumeInfoForm.VolumeLocationID := -1; // unknown
            TheVolumeInfoForm.KEY              := VolumesTable.fldKey.AsString;
            TheVolumeInfoForm.Comment          := VolumesTable.fldComment.AsString;
            TheVolumeInfoForm.Media            := VolumesTable.fldMedia.AsString;
            TheVolumeInfoForm.VolumeSerialNumber := VolumesTable.fldVolumeSerialNumber.AsString;
            TheVolumeInfoForm.DirListingFile   := FullFileName;
            TheVolumeInfoForm.VolumeLocation   := MediaSettings.VolumeLocation;
            OK := TheVolumeInfoForm.ShowModal = mrOK;
            if OK then
              begin
                fldLocationID.AsInteger        := TheVolumeInfoForm.VolumeLocationID;
                fldVolumeLabel.AsString        := TheVolumeInfoForm.VolumeLabel;
                fldPublisher.AsString          := TheVolumeInfoForm.Publisher;
                fldKey.AsString                := TheVolumeInfoForm.KEY;
                fldComment.AsString            := TheVolumeInfoForm.Comment;
                fldMedia.AsString              := TheVolumeInfoForm.Media;
                fldVolumeSerialNumber.AsString := TheVolumeInfoForm.VolumeSerialNumber;
                fldVolumeShortName.AsString    := TheVolumeInfoForm.VolumeName;

                if fVolumeDate <> BAD_DATE then
                  fldVolumeDate.AsDateTime     := fVolumeDate;

                Post;
              end;
          end;

      with VolumesTable do
        begin
          if Media_ID <> fldMedia_ID.AsInteger then
            AlertFmt('System error: VolumesTable position has changed! %d <> %d',
                     [Media_ID, fldMedia_ID.AsInteger]);
          if Media_IDChanged then
            begin
              CD_Contents_Path  := ForceBackSlash(MediaSettings.CDContentsFolder);
              NewFileName := CD_Contents_Path + 'VOL' + Rzero(Media_ID, 4) + '.txt';
              RenameFile(FullFileName, NewFileName);
              with frmLabelTheDisk do
                begin
                  VolumeID.Caption := IntToStr(Media_ID);
                  ShowModal;
                end;
            end;
        end;
    end
  else
    LogError('Error processing file "%s". No record exists in the Volumes table for Media_ID=%d',
             [FullFileName, Media_ID]);
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
  fLineCount        := 0;
  fFilesProcessed   := 0;
  fErrCount         := 0;
  fLastReadTime     := Now;
  fVolumeDate       := BAD_DATE;
  OpenLogFile;
  WriteLn(fLogFile, Format('Log File Created on %s', [DateTimeToStr(Now)]));
  WriteLn(fLogFile);
end;

procedure TfrmMediaCatalog.FinishScan;
begin
  CloseLogFile;
  lblStatus.Caption := Format('COMPLETE. %d files processed; %d lines read; %d Errors; %d records added',
                              [fFilesProcessed, fLineCount, fErrCount, fRecsAdded]);
  Application.ProcessMessages;
end;


procedure TfrmMediaCatalog.ImportImportDirectoryListingTextFile1Click(
  Sender: TObject);
var
  FileBase, Temp: string;
  Media_ID: integer;
begin
  with OpenDialog1 do
    begin
      InitialDir := MediaSettings.CDContentsFolder;
      DefaultExt := 'txt';
      FileName   := '*.txt';
      if Execute then
        begin
          MediaSettings.CDContentsFolder := ExtractFilePath(FileName);
          if GetString('Media ID to assign', 'Media ID', temp, 7) then
            begin
              Media_ID := StrToIntSafe(temp);
              if Media_ID = 0 then
                Exit;
            end
          else
            Exit;

          FileBase := ExtractFileBase(FileName);
          fLogFileName := MediaSettings.LogFilePathName + 'LogOf_' + FileBase + '.txt';
          InitScan(fLogFileName);
          ScanSingleTextFile(FileName, Media_ID);
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

procedure TfrmMediaCatalog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if not Empty(gSettingsFileName) then
    MediaSettings.SaveToFile(gSettingsFileName);
end;

constructor TfrmMediaCatalog.Create(aOwner: TComponent);
begin                                                    
  inherited;
  if Empty(ParamStr(1)) then
    gSettingsFileName := ExtractFilePath(ParamStr(0)) + 'MediaCatalog.ini'
  else
    begin
      gSettingsFileName := ParamStr(1);
      MessageFmt('Using debug .ini file: %s', [gSettingsFileName]);
    end;

  if FileExists(gSettingsFileName) then
    begin
      MediaSettings.LoadFromFile(gSettingsFileName);
      Caption := 'Media Catalog of ' + MediaSettings.DBFilePathName;
    end;
  lblFileName.Caption := '';
  lblStatus.Caption   := '';
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

procedure TfrmMediaCatalog.ScanVolume2Click(Sender: TObject);
const
  W1 = 6;
  W2 = 5;
  W3 = 11;
  W4 = 11;
  W5 = 12;
  W6 = 10;

  UNKNOWN = 'Unknown';
var
  FolderPath: string;
  DOSErr: integer;
  SavedCursor: TCursor;
  xMedia_ID: integer;
  dummy: integer;
  IncludeAllExtensions: boolean;
  ExtensionNames: string;
  ExtensionList: TStringList;
  i: integer;
  ExtensionCount: integer;
  Delimited_Info : TDelimited_Info;
  Fields: TFieldArray;
  OutFile: TextFile;
  OutFileName: string;
  DriveLetter: string;
  OK: boolean;
  TheSerialNumber: string;

  procedure ProcessFolder( FolderPath: string;
                           ParentFolder_ID: integer;
                           var TheFolderNumber: integer;
                           var FilesFoundInFolderAndSubFolders: integer);
  var
    CurrentFolderNumber, aFolderNumber: integer;
    SearchRec: TSearchRec;
    Ext: string;
    FilesFoundInThisFolder, FilesFoundInSubFolders: integer;

    procedure ProcessFile(FolderPath: string; const SearchRec: TSearchRec; IsAFolder: boolean; ParentFolder_ID, TheFolderNumber: integer);
    var
      LongFileName, HashName, FilePath: string;
      DateTime: TDateTime;
    begin { ProcessFile }
      FilePath     := FolderPath + SearchRec.Name;
      DateTime     := FileDateToDateTime(SearchRec.Time);
      if DateTime > fVolumeDate then  // track the latest date/time on the volume. Call it the volume date
        fVolumeDate := DateTime;
      LongFileName := ExtractFileName(FilePath);
      if not Empty(LongFileName) then
        begin
          HashName := HashedFileName(LongFileName, HASHED_NAME_LENGTH);
          with FileInfoTable do
            begin
              Append;
              inc(fRecsAdded);
              MediaSettings.FileInfoRecs     := MediaSettings.FileInfoRecs + 1;

              fldParentFolder_ID.AsInteger   := ParentFolder_ID;
              fldMedia_ID.AsInteger          := xMedia_ID;
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

              WriteLn(OutFile, ParentFolder_ID:W1, ' ',
                               xMedia_ID:W2, ' ',
                               DateToStr(fldDateTimeModified.AsDateTime):W3, ' ',
                               TimeToStr(fldDateTimeModified.AsDateTime):W4, ' ',
                               fldFileSize.ASInteger:W5, ' ',
                               IIF(IsAFolder, Format('Fold %d', [TheFolderNumber]), ''):W6, ' ',
                               LongFileName);

              Post;
            end;

          if ((fFilesProcessed mod 100) = 0) or (MilliSecondsBetween(Now, fLastReadTime) > 1000) then
            begin
              lblStatus.Caption := Format('%0.n files processed; %d errors; %0.n records added',
                                        [fFilesProcessed*1.0, fErrCount, fRecsAdded*1.0]);
              lblFileName.Caption := FilePath;
              Application.ProcessMessages;
            end;
          fLastReadTime := Now;
        end;
    end;  { ProcessFile }

  begin { ProcessFolder }
    CurrentFolderNumber := fFolderCount + 1;
    TheFolderNumber     := CurrentFolderNumber;
    FilesFoundInThisFolder          := 0;
    FilesFoundInFolderAndSubFolders := 0;

    Inc(fFolderCount);

    FolderPath := ForceBackSlash(FolderPath);

    // first process the sub-folders
    DOSErr := FindFirst(FolderPath + '*.*', faDirectory, SearchRec);
    try
      while DOSErr = 0 do
        begin
          if ((SearchRec.Attr and faDirectory) <> 0) and (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
            begin
              ProcessFolder(FolderPath + SearchRec.Name, CurrentFolderNumber, aFolderNumber, FilesFoundInSubFolders);
              if FilesFoundInSubFolders > 0 then // only record the folder if it contains any files that we are looking for
                ProcessFile(FolderPath, SearchRec, true, CurrentFolderNumber, aFolderNumber);  // Its a folder but its also a file
              inc(fFilesProcessed);
              Inc(FilesFoundInFolderAndSubFolders, FilesFoundInSubFolders);
            end;
          DOSErr := FindNext(SearchRec);
        end;
    finally
      FindClose(SearchRec);
    end;

    DOSErr := FindFirst(FolderPath + '*.*', faAnyFile-faDirectory, SearchRec);
    // then process the files in this folder
    try
      FilesFoundInThisFolder := 0;
      while DOSErr = 0 do
        begin
          if (SearchRec.Attr and faDirectory) = 0 then  // "not a directory" - probably unnecessary
            begin
              if IncludeAllExtensions then
                begin
                  ProcessFile(FolderPath, SearchRec, false, CurrentFolderNumber, TheFolderNumber);
                  inc(FilesFoundInThisFolder);
                end
              else
                begin
                  Ext := LowerCase(MyExtractFileExt(SearchRec.Name));
                  if ExtensionList.IndexOf(Ext) >= 0 then
                    begin
                      ProcessFile(FolderPath, SearchRec, false, CurrentFolderNumber, TheFolderNumber);
                      inc(FilesFoundInThisFolder);
                    end;
                end;
            end;
          inc(fFilesProcessed);
          DOSErr := FindNext(SearchRec);
        end;
    finally
      FindClose(SearchRec);
      Inc(FilesFoundInFolderAndSubFolders, FilesFoundInThisFolder);
    end;
  end;  { ProcessFolder }

  function GetVolumeLabel(DriveChar: Char; var TheSerialNumber: string): string;
  var
    NotUsed:     DWORD;
    VolumeFlags: DWORD;
    VolumeSerialNumber: DWORD;
    Buf: array [0..MAX_PATH] of Char;
  begin { GetVolumeLabel }
    VolumeFlags := 0;
    VolumeSerialNumber := 0;
    FillChar(Buf, SizeOf(Buf), 0);
    if GetVolumeInformation(PChar(DriveChar + ':\'), Buf, MAX_PATH+1, @VolumeSerialNumber, NotUsed, VolumeFlags, nil, 0) then
      begin
        SetString(Result, Buf, StrLen(Buf));   { Set return result }
        TheSerialNumber := IntToHex(HiWord(VolumeSerialNumber), 4) + '-' +
                           IntToHex(LoWord(VolumeSerialNumber), 4);
      end
    else
      result := UNKNOWN;;
  end;  { GetVolumeLabel }

  function GetMediaFromDriveLetter( DriveLetter: string): string;
  var
    dt: integer;
  begin { GetMediaAndVolumeLabelFromDriveLetter }
    dt := GetDriveType(PAnsiChar(DriveLetter));
    case dt of
     DRIVE_UNKNOWN:
       result       := '?';
     DRIVE_NO_ROOT_DIR, DRIVE_REMOTE: // a folder from a network drive
       result       := 'N';   // Network drive
     DRIVE_CDROM:
       result       := 'D';   // DVD/CD/Blu-Ray drive
     else
       result       := 'H';   // Hard drive
    end;
  end;  { GetMediaAndVolumeLabelFromDriveLetter }


begin { TfrmMediaCatalog.ScanVolume2Click }
  FolderPath := 'D:\';
  if frmScanVolume.ShowModal = mrOk then
    begin
      IncludeAllExtensions := frmScanVolume.cbExtensions.ItemIndex = 0;
      FolderPath           := frmScanVolume.leFolderToBeScanned.Text;

      with VolumesTable do
        begin
          Ok := Locate(MEDIA_ID_FIELD_NAME, xMedia_ID, []);
          if not Ok then    // couldn't find it so append one
            begin
              Append;
              with TheVolumeInfoForm do
                begin
                  Memo1.Visible      := false;
                  DriveLetter        := ExtractFileDrive(FolderPath);
                  Media              := GetMediaFromDriveLetter(DriveLetter);
                  VolumeName         := GetVolumeLabel(DriveLetter[1], TheSerialNumber);
                  VolumeLabel        := Format('%s [%s] on %s', [DriveLetter, VolumeName, ComputerName]);
                  VolumeSerialNumber := TheSerialNumber;
                  if ShowModal = mrOK then
                    begin
                      fldVolumeLabel.AsString        := VolumeLabel;
                      fldVolumeSerialNumber.AsString := VolumeSerialNumber;
                      fldVolumeShortName.AsString    := VolumeName;
                      fldMedia.AsString              := Media;
                      fldLocationID.AsInteger        := VolumeLocationID;
                    end;

                  Post;  // Update the Media_ID

                  xMedia_ID   := fldMedia_ID.AsInteger;

                  Edit;
                end;
            end
          else
            with TheVolumeInfoForm do
              begin
                VolumeName         := fldVolumeLabel.AsString;
                VolumeSerialNumber := fldVolumeSerialNumber.AsString;
                VolumeLocationID   := fldLocationID.AsInteger;
                Publisher          := fldPublisher.AsString;
                Comment            := fldComment.AsString;
                KEY                := fldKey.AsString;
                Media              := fldMedia_ID.AsString;
              end;
        end;

        try
          ExtensionList := nil;
          if not IncludeAllExtensions then
            begin
              ExtensionNames := frmScanVolume.mmoExtensions.Text;
              Delimited_Info.QuoteChar       := #0;
              Delimited_Info.Field_Seperator := ' ';
              Parse_Delimited_Line( ExtensionNames, Fields, ExtensionCount, Delimited_Info);
              ExtensionList := TStringList.Create;
              ExtensionList.Sorted := true;
              for i := 0 to ExtensionCount-1 do
                ExtensionList.Add(LowerCase(Fields[i]));
            end;
          OutFileName     := UniqueFileName(Format('%sVOL%s.txt', [MediaSettings.CDContentsFolder, RZero(xMedia_ID, 5)]));
          AssignFile(OutFile, OutFileName);
          ReWrite(OutFile);
          WriteLn(OutFile, 'Parent':W1, ' ', 'Media':W2, ' ', 'File Date':W3, ' ', 'File Time':W4, ' ', 'File Size':W5, ' ', 'Folder #':W6, ' ', 'FileName');
          try
            SavedCursor     := Screen.Cursor;
            Screen.Cursor   := crHourGlass;
            fFilesProcessed := 0;
            fErrCount       := 0;
            fRecsAdded      := 0;
            fFolderCount    := 0;
            fLastReadTime   := Now;
            fVolumeDate     := BAD_DATE;

            lblStatus.Caption := Format('Scan Starting. %0.n files processed; %d errors; %0.n records added',
                                      [fFilesProcessed*1.0, fErrCount, fRecsAdded*1.0]);
            Application.ProcessMessages;
            try
              ProcessFolder(FolderPath, 0, dummy, dummy);  // Process folder and all descendent children
            finally
              with VolumesTable do
                if Locate(MEDIA_ID_FIELD_NAME, xMedia_ID, []) then
                  begin     // update the Volume Date for the volume
                    Edit;
                    fldVolumeDate.AsDateTime := fVolumeDate;
                    Post;
                  end;
              lblStatus.Caption := Format('COMPLETED. %0.n files processed; %d errors; %0.n records added',
                                        [fFilesProcessed*1.0, fErrCount, fRecsAdded*1.0]);
              Screen.Cursor := SavedCursor;
              CloseLogFile;
              if fErrCount > 0 then
                begin
                  if not ExecAndWait('NotePad.exe', fLogFileName, true) then
                    AlertFmt('Unable to open "%s"', [fLogFileName]);
                end;
            end;
          finally
            CloseLogFile;
            if TheVolumeInfoForm.EjectNeeded then
              begin
                with frmLabelTheDisk do
                  begin
                    DriveLetter := ExtractFileDrive(FolderPath);
                    InitLocationsDropDown(LocationsTable, VolumesTable.fldLocationID.AsInteger);
                    EjectDrive(DriveLetter, _OPEN);
                    VolumeID.Caption := IntToStr(xMedia_ID);
                    edtLabelOnTheDisk.Text := VolumesTable.fldVolumeLabel.AsString;
                    if ShowModal = mrOk then
                      with VolumesTable do
                        if Locate(MEDIA_ID_FIELD_NAME, xMedia_ID, []) then
                          begin     // update the Volume Date for the volume
                            Edit;
                            fldVolumeLabel.AsString := edtLabelOnTheDisk.Text;
                            Post;
                          end;
                  end;
              end;
//          if not ExecAndWait('NotePad.exe', OutFileName, true) then
//            AlertFmt('Unable to open "%s"', [OutFileName]);
          end;
        finally
          FreeAndNil(ExtensionList);
        end;
    end;
end;  { TfrmMediaCatalog.ScanVolume2Click` }

procedure TfrmMediaCatalog.CloseLogFile;
begin
  if fLogFileIsOpen then
    begin
      CloseFile(fLogFile);
      fLogFileIsOpen := false;
      if YesFmt('Do you want to view the logfile [%s]?', [fLogFileName]) then
        EditTextFile(fLogFileName);
    end;
end;


procedure TfrmMediaCatalog.CloseFiles;
begin
  FreeAndNil(fVolumesTable);
  FreeAndNil(fFileInfoTable);
  FreeAndNil(fLocationsTable);
  FreeAndNil(frmFileInfoBrowser);
  FreeAndNil(frmVolumesBrowser);
  FreeAndNil(fLocationsBrowser);
  
  lblFileName.Caption := '';
  lblStatus.Caption   := '';
  fDatabaseIsOpen     := false;
end;

procedure TfrmMediaCatalog.OpenMediaCatalog2Click(Sender: TObject);
var
  FilePath: string;
begin
  CloseFiles;
  FilePath := MediaSettings.DBFilePathName;
  if BrowseForFile('Locate MediaCatalog.ACCDB', FilePath, '*', MediaCatalogFilters) then // ought to convert to .ACCDB
    begin
      fDatabaseIsOpen      := true;
      MediaSettings.DBFilePathName := FilePath;
      Caption := 'Media Catalog of ' + FilePath;
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
        fLocationsTable.Active := true;;
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

procedure TfrmMediaCatalog.Settings1Click(Sender: TObject);
begin
  if not Assigned(frmMediaSettings) then
    begin
      frmMediaSettings := TfrmMediaSettings.Create(self);
      frmMediaSettings.Caption := Format('Media Settings [%s]', [gSettingsFileName]);
    end;

  with frmMediaSettings do
    begin
      leDBFilePathName.Text   := MediaSettings.DBFilePathName;
      leLogFilePathName.Text  := MediaSettings.LogFilePathName;
      leFileInfoRecordCount.Text := IntToStr(MediaSettings.FileInfoRecs);
      Drive                   := MediaSettings.CDDriveLetter;
      if ShowModal = mrOk then
        begin
          MediaSettings.DBFilePathName   := leDBFilePathName.Text;
          MediaSettings.LogFilePathName  := leLogFilePathName.Text;
          MediaSettings.CDDriveLetter    := Drive;
          MediaSettings.FileInfoRecs     := StrToInt(leFileInfoRecordCount.Text);
        end;
    end;
end;

procedure TfrmMediaCatalog.File1Click(Sender: TObject);
begin
  ImportImportDirectoryListingTextFile1.Enabled := fDatabaseIsOpen;
  OpenMediaCatalog2.Enabled                     := not fDatabaseIsOpen;
  CloseMediaCatalog1.Enabled                    := fDatabaseIsOpen;
  ScanVolume2.Enabled                           := fDatabaseIsOpen;
  AppendMediaCatalog1.Enabled                   := fDataBaseIsOpen;
end;

function TfrmMediaCatalog.TempFileInfoTable: TFileInfoTable;
begin
  if not Assigned(fTempFileInfoTable) then
    begin
      fTempFileInfoTable := TFileInfoTable.Create(self, MediaSettings.DBFilePathName, FILEINFO_TABLE_NAME, []);
      with fTempFileInfoTable do
        begin
          AddFields;
          IndexName := PARENTFOLDER_ID;
          Active    := true;
        end;
    end;
  result := fTempFileInfoTable;
end;

procedure TfrmMediaCatalog.WMBuildTreeView(var Message: TMessage);
var
  FileInfoID, Parent_ID, Media_ID: integer;
  ParentNode, RootNode: TTreeNode;
  Saved_Cursor: TCursor;
  VolumeName, NodeName: string;

  procedure AddSubNodes(ParentNode: TTreeNode; ParentNodeID: integer; Media_ID: integer; TargetID: integer);
  var
    ChildNode: TTreeNode;
    FileInfoID: integer;
    NodeCaption: string;
  begin { AddSubNodes }
    with TempFileInfoTable do
      begin
        if Locate(PARENTFOLDER_ID, ParentNodeID, []) then    // does this need to also include filter on location?
          begin
            while (not Eof) and (fldParentFolder_ID.AsInteger = ParentNodeID) do
              begin
                if (fldMedia_ID.AsInteger = Media_ID) {and (not fldIsAFolder.AsBoolean)} then
                  begin
                    FileInfoID := fldID.AsInteger;
                    NodeCaption := IIF(fldIsAFolder.AsBoolean, '['+fldFileName.AsString+']', fldFileName.AsString);
                    ChildNode := TreeView1.Items.AddChild(ParentNode, NodeCaption);
                    if FileInfoID = TargetID then
                      TreeView1.Selected := ChildNode;
                    ChildNode.Data := Pointer(FileInfoID);
                  end;
                Next;
              end;
          end;
      end;
  end;  { AddSubNodes }

  procedure BuildPathFromRoot(FileInfoID: integer; Media_ID: integer);
  const
    KEY_FIELDS = THISFOLDERS_ID + ';' + MEDIA_ID_FIELD_NAME;
  var
    FolderName: string;
  begin { BuildPathFromRoot }
    with TempFileInfoTable do
      begin
        lblStatus.Caption := Format('Locate(%d,%d)', [FileInfoID, Media_ID]);
        Application.ProcessMessages;
        
        if Locate(KEY_FIELDS, VarArrayOF([FileInfoID, Media_ID]), []) and fldIsAFolder.AsBoolean then
          begin
            FolderName := fldFileName.AsString;
            BuildPathFromRoot(fldParentFolder_ID.AsInteger, Media_ID);
          end
        else
          FolderName := VolumeName;

        ParentNode := TreeView1.Items.AddChild(ParentNode, FolderName); // Build the tree as we unravel the recursion
        if not Assigned(RootNode) then
          RootNode := ParentNode;
        ParentNode.Data := Pointer(FileInfoID);
      end;
  end;  { BuildPathFromRoot }

begin { TfrmMediaCatalog.WMBuildTreeView }
  Saved_Cursor  := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    RootNode   := nil;
    FileInfoID := Message.WParam;
    TreeView1.Items.Clear;

    ParentNode := nil;
    with TempFileInfoTable do
      begin
        if Locate('ID', FileInfoID, []) then
          begin
            Media_ID := TempFileInfoTable.fldMedia_ID.AsInteger;
            if VolumesTable.Locate('Media_ID', Media_ID, []) then
              begin
                NodeName   := Format('%s (%d)', [VolumesTable.fldVolumeShortName.AsString, VolumesTable.fldLocationID.AsInteger]);
                ParentNode := TreeView1.Items.AddChild(nil, NodeName);
(*
              if LocationsTable.Locate('LocationID', VolumesTable.fldLocationID.AsInteger, []) then
                ParentNode := TreeView1.Items.AddChild(RootNode, LocationsTable.fldLocationName.AsString)
*)
              end;
            Parent_ID  := fldParentFolder_ID.AsInteger;
//          Media_ID   := fldMedia_ID.AsInteger;
            VolumeName := fldLocationName.AsString;
            
            BuildPathFromRoot(Parent_ID, Media_ID);

            // locate all of the records that have the same record for a parent and add them as children at the lowest level
            if Assigned(ParentNode) then
              AddSubNodes(ParentNode, Parent_ID, Media_ID, FileInfoID);

            if Assigned(RootNode) then
              RootNode.Expand(true);
          end
        else
          AlertFmt('Unable to locate FileInfo ID %d', [FileInfoID]);
      end
  finally
    Screen.Cursor := Saved_Cursor;
  end;
end;  { TfrmMediaCatalog.WMBuildTreeView }

procedure TfrmMediaCatalog.Tables1Click(Sender: TObject);
begin
  BrowseMediaCatalog1.Enabled := fDatabaseIsOpen;
  BrowseFiles1.Enabled        := fDataBaseIsOpen;
  BrowseLocations1.Enabled    := fDataBaseIsOpen;
end;

destructor TfrmMediaCatalog.Destroy;
begin
  FreeAndNil(fTempFileInfoTable);
  inherited;
end;

procedure TfrmMediaCatalog.TreeView1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
  FileInfoID: integer;
begin
  Node := TreeView1.GetNodeAt(X, Y);
  if Assigned(Node) then
    begin
      FileInfoID := integer(Node.Data);
      lblStatus.Caption := Format('FileInfoID=%d', [FileInfoID]);
    end;
end;

procedure TfrmMediaCatalog.CloseMediaCatalog1Click(Sender: TObject);
begin
  CloseFiles;
end;

procedure TfrmMediaCatalog.DeleteAllfilerecordsforavolume1Click(
  Sender: TObject);
var
  VolString: string;
  Media_ID, Saved_RecNo, Count: integer;
  OK: boolean;
begin
  OK := false;
  Media_ID := -1;
  repeat
    if GetString('Select volume', 'Media ID #', VolString, 6) then
      begin
        try
          Media_ID := StrToInt(VolString);
          if not VolumesTable.Locate('Media_ID', Media_ID, []) then
            OK := YesFmt('No volume having the Media ID %d was found in the volumes table. Proceed anyway?', [Media_ID])
          else
            OK := true;
        except
          on e:Exception do
            begin
              ErrorFmt('Invalid volume number: ', [VolString]);
              OK := false;
            end;
        end;
      end
    else
      Exit;
  until OK;

  with FileInfoTable do
    begin
      IndexName := MEDIA_ID_FIELD_NAME;
      Count := 0;
      if Locate(MEDIA_ID_FIELD_NAME, Media_ID, []) then
        begin
          while fldMedia_ID.AsInteger = Media_ID do
            begin
              Saved_RecNo := RecNo;
              Delete;
              Inc(Count);
              MediaSettings.FileInfoRecs := MediaSettings.FileInfoRecs - 1;
              if Saved_RecNo = RecNo then
                Next;
            end;
        end;
      MessageFmt('%d records were deleted', [Count]);
    end;
end;

procedure TfrmMediaCatalog.SaveDialog2TypeChange(Sender: TObject);
begin
  with Sender as TSaveDialog do
    begin
      case FilterIndex of
        ACCESS_2007_INDEX: { accdb }
          FileName := ForceExtension(FileName, ACCESS_2007_EXT);
        ACCESS_2000_INDEX: { mdb }
          FileName := ForceExtension(FileName, ACCESS_2000_EXT);
      end;
    end;
end;

end.
