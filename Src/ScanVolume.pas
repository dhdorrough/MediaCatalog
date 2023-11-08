unit ScanVolume;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, MediaTables, VolumeInfo;

type
  TfrmScanVolume = class(TForm)
    leFolderToBeScanned: TLabeledEdit;
    btnBrowse: TButton;
    mmoExtensions: TMemo;
    Label1: TLabel;
    btnCancel: TButton;
    btnOK: TButton;
    leComputerName: TLabeledEdit;
    cbExtensions: TComboBox;
    OpenDialog1: TOpenDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure cbIncludeAllExtensionsClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cbExtensionsChange(Sender: TObject);
  private
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
  end;

var
  frmScanVolume : TfrmScanVolume;

implementation

{$R *.dfm}

uses
  MediaSettingsFile, MyUtils, MediaCatalog_Decl;

const
  SOURCE_EXTENSIONS = 'pas dfm dpr prg bas txt bat dbf fpt cdx mdx ndx accdb mdb pjx dbt h inc';  

(*
function TfrmScanVolume.GetVolumesTable: TVolumesTable;
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
*)

procedure TfrmScanVolume.btnBrowseClick(Sender: TObject);
var
  Folder: string;
begin
  Folder := leFolderToBeScanned.Text;
  if BrowseForFolder('Select Volume to Scan', Folder) then
    begin
      leFolderToBeScanned.Text := Folder;
    end;
end;

constructor TfrmScanVolume.Create(aOwner: TComponent);
begin
  inherited;

  if not Empty(MediaSettings.IncludedExtensions) then
    mmoExtensions.Text := MediaSettings.IncludedExtensions
  else
    mmoExtensions.Text := SOURCE_EXTENSIONS;

  if MediaSettings.IncludeAllExtensions then
    cbExtensions.ItemIndex := 0;
  leComputerName.Text            := ComputerName;
  leFolderToBeScanned.Text       := MediaSettings.FolderToBeScanned;

end;

procedure TfrmScanVolume.cbIncludeAllExtensionsClick(Sender: TObject);
begin
  mmoExtensions.Enabled := not (cbExtensions.ItemIndex = 0);
end;

procedure TfrmScanVolume.btnOKClick(Sender: TObject);
begin
  MediaSettings.IncludedExtensions   := mmoExtensions.Text;
  MediaSettings.FolderToBeScanned    := leFolderToBeScanned.Text;
end;

procedure TfrmScanVolume.cbExtensionsChange(Sender: TObject);
begin
  with cbExtensions do
    begin
      case ItemIndex of
        0: mmoExtensions.Text := '';
        1: mmoExtensions.Text := SOURCE_EXTENSIONS;
        2: mmoExtensions.Text := 'mp4 mp3 mpg m2ts psh pds ppr mov rm rv wmv avi iso wav wma m4a 3gp mts jpg';
      end;
      mmoExtensions.Visible := ItemIndex <> 0;
    end;
end;

end.
