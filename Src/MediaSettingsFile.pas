unit MediaSettingsFile;

interface

uses
  SettingsFiles;

type

  TMediaSettingsFile = class(TSettingsFile)
  private
    fBatchFileName: string;
    fDBFilePathName: string;
    fCDContentsFolder: string;
    fCDDriveLetter: char;
    fVolumeLocation: string;
    fVolumeLocation_ID: integer;
    fIncludedExtensions: string;
    fFolderToBeScanned: string;
    fFileInfoRecs: integer;
    fLogFilePathName: string;
    function GetDBFilePathName: string;
    function GetCDContentsFolder: string;
    function GetBatchFileName: string;
    function GetCDDriveLetter: char;
    procedure SetBatchFileName(const Value: string);
    procedure SetCDContentsFolder(const Value: string);
    procedure SetCDDriveLetter(const Value: char);
    procedure SetDBFilePathName(const Value: string);
    function GetVolumeLocation: string;
    procedure SetVolumeLocation(const Value: string);
    function GetIncludeAllExtensions: boolean;
    function GetLogFilePathName: string;
    procedure SetLogFilePathName(const Value: string);
    function GetIncludedExtensions: string;
  public
    property IncludeAllExtensions: boolean
             read GetIncludeAllExtensions;
  protected
    procedure LoadSettings; override;
    procedure SaveSettings(const SettingsFileName: string); override;
    procedure ClearSettings; override;
  published
    property DBFilePathName: string
             read GetDBFilePathName
             write SetDBFilePathName;
    property CDContentsFolder: string
             read GetCDContentsFolder
             write SetCDContentsFolder;
    property BatchFileName: string
             read GetBatchFileName
             write SetBatchFileName;
    property CDDriveLetter: char
             read GetCDDriveLetter
             write SetCDDriveLetter;
    property VolumeLocation_ID: integer
             read fVolumeLocation_ID
             write fVolumeLocation_ID;
    property VolumeLocation: string
             read GetVolumeLocation
             write SetVolumeLocation;
    property IncludedExtensions: string
             read GetIncludedExtensions
             write fIncludedExtensions;
    property FolderToBeScanned: string
             read fFolderToBeScanned
             write fFolderToBeScanned;
    property FileInfoRecs: integer
             read fFileInfoRecs
             write fFileInfoRecs;
    property LogFilePathName: string
             read GetLogFilePathName
             write SetLogFilePathName;
  end;

function MediaSettings: TMediaSettingsFile;

implementation

uses
  MyUtils, SysUtils, ScanVolume;

var
  gMediaSettings: TMediaSettingsFile;

function MediaSettings: TMediaSettingsFile;
begin
  if not Assigned(gMediaSettings) then
    gMediaSettings := TMediaSettingsFile.Create(nil);
  result := gMediaSettings;
end;

{ TMediaSettingsFile }

procedure TMediaSettingsFile.ClearSettings;
begin
  inherited;
end;

function TMediaSettingsFile.GetBatchFileName: string;
begin
  if Empty(fBatchFileName) then
    result := TempPath + 'Dir.BAT'
  else
    result := fBatchFileName;
end;

function TMediaSettingsFile.GetCDContentsFolder: string;
var
  Temp: string;
begin
  Temp := 'F:\NDAS-I\CD Contents\';
  if Empty(fCDContentsFolder) then
    if BrowseForFolder('CD Contents Folder', Temp) then
      result := temp
    else
      raise Exception.Create('CD Contents Folder is not defined')
  else
    result := fCDContentsFolder;
end;

function TMediaSettingsFile.GetCDDriveLetter: char;
begin
  if Empty(fCDDriveLetter) then
    result := 'D'
  else
    result := fCDDriveLetter;
end;

function TMediaSettingsFile.GetDBFilePathName: string;
begin
  if Empty(fDBFilePathName) then
    result := 'MediaCatalog.*'  // place holder- replace
  else
    result := fDBFilePathName;
end;

function TMediaSettingsFile.GetIncludeAllExtensions: boolean;
begin
  Result := Empty(IncludedExtensions);
end;

function TMediaSettingsFile.GetIncludedExtensions: string;
begin
  Result := fIncludedExtensions;
end;

function TMediaSettingsFile.GetLogFilePathName: string;
begin
  if fLogFilePathName = '' then
    fLogFilePathName := 'C:\temp\';
  result := fLogFilePathName;
end;

function TMediaSettingsFile.GetVolumeLocation: string;
begin
  result := fVolumeLocation;
end;

procedure TMediaSettingsFile.LoadSettings;
begin
  inherited;
  Alert('TMediaSettingsFile.LoadSettings called');
end;

procedure TMediaSettingsFile.SaveSettings(const SettingsFileName: string);
begin
  inherited;
  Alert('TMediaSettingsFile.SaveSettings called');
end;

procedure TMediaSettingsFile.SetBatchFileName(const Value: string);
begin
  fBatchFileName := Value;
end;

procedure TMediaSettingsFile.SetCDContentsFolder(const Value: string);
begin
  fCDContentsFolder := Value;
end;

procedure TMediaSettingsFile.SetCDDriveLetter(const Value: char);
begin
  fCDDriveLetter := Value;
end;

procedure TMediaSettingsFile.SetDBFilePathName(const Value: string);
begin
  fDBFilePathName := Value;
end;

procedure TMediaSettingsFile.SetLogFilePathName(const Value: string);
begin

end;

procedure TMediaSettingsFile.SetVolumeLocation(const Value: string);
begin
  fVolumeLocation := Value;
end;

initialization
finalization
  FreeAndNil(gMediaSettings);
end.
