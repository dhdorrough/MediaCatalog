program MediaCatalog;

uses
  Forms,
  DateUtils in '..\..\..\source\rtl\common\DateUtils.pas',
  FilterOptions in '..\MyUtils\FilterOptions.pas' {frmFilterOptions},
  FileInfoBrowser in 'Src\FileInfoBrowser.pas',
  MediaCatalogForm in 'Src\MediaCatalogForm.pas' {frmMediaCatalog},
  SelectDrive in 'Src\SelectDrive.pas' {frmSelectDrive},
  LabelTheDisk in 'Src\LabelTheDisk.pas' {frmLabelTheDisk},
  MediaTables in 'Src\MediaTables.pas',
  MyTables in '..\MyUtils\MyTables.pas',
  MyTables_Decl in '..\MyUtils\MyTables_Decl.pas',
  MediaBrowser in 'Src\MediaBrowser.pas' {frmVolumesBrowser},
  SettingsFiles in '..\MyUtils\SettingsFiles.pas',
  VolumeInfo in 'Src\VolumeInfo.pas' {frmVolumeInfo},
  BrowserUnit in '..\MyUtils\BrowserUnit.pas' {frmDataSetBrowser},
  MyUtils in '..\MyUtils\MyUtils.pas',
  ScanVolume in 'Src\ScanVolume.pas' {frmScanVolume},
  RotImg in '..\Photo DB\Testing\RotImg.pas',
  MediaCatalog_Decl in 'Src\MediaCatalog_Decl.pas',
  uGetString in '..\MyUtils\uGetString.pas' {frmGetString},
  MediaSettingsFile in 'Src\MediaSettingsFile.pas',
  MediaSettingsForm in 'Src\MediaSettingsForm.pas' {frmMediaSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMediaCatalog, frmMediaCatalog);
  Application.CreateForm(TfrmSelectDrive, frmSelectDrive);
  Application.CreateForm(TfrmLabelTheDisk, frmLabelTheDisk);
  Application.CreateForm(TfrmScanVolume, frmScanVolume);
  Application.CreateForm(TfrmMediaSettings, frmMediaSettings);
  Application.Run;
end.
