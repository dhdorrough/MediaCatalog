unit VolumeInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ExtCtrls, MediaTables;

type
  TfrmVolumeInfo = class(TForm)
    DataSource1: TDataSource;
    Memo1: TMemo;
    btnOK: TButton;
    btnCancel: TButton;
    leVolumeName: TLabeledEdit;
    leSerialNumber: TLabeledEdit;
    leVolumeLabel: TLabeledEdit;
    lePublisher: TLabeledEdit;
    leComment: TLabeledEdit;
    leKey: TLabeledEdit;
    Label1: TLabel;
    cbMedia: TComboBox;
    cbLocation: TComboBox;
    Label2: TLabel;
    btnAddLocation: TButton;
    procedure btnAddLocationClick(Sender: TObject);
    procedure leVolumeLabelKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbLocationClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    fLocationsTable: TLocationsTable;
    fLocationSpecified: boolean;
    fSavedVolumeLabel: string;
    fEjectNeeded: boolean;
    procedure SetDirListingFile(const Value: string);
    function GetVolumeName: string;
    function GetVolumeSerialNumber: string;
    procedure SetVolumeName(const Value: string);
    procedure SetVolumeSerialNumber(const Value: string);
    function GetVolumeLocation: string;
    procedure SetVolumeLocation(const Value: string);
    function GetPublisher: string;
    function GetVolumeLabel: string;
    procedure SetPublisher(const Value: string);
    procedure SetVolumeLabel(const Value: string);
    function GetComment: string;
    procedure SetComment(const Value: string);
    function GetKEY: string;
    procedure SetKEY(const Value: string);
    function GetMedia: string;
    procedure SetMedia(const Value: string);
    function GetLocationsTable: TLocationsTable;
    function GetVolumeLocationID: integer;
    procedure SetVolumeLocationID(const Value: integer);
    procedure InitLocationsDropDown;
    procedure Enable_Buttons;
    { Private declarations }
  public
    { Public declarations }

    Constructor Create(aOwner: TComponent); override;
    Destructor Destroy; override;
    property LocationsTable: TLocationsTable
             read GetLocationsTable;
    property DirListingFile: string
             write SetDirListingFile;
    property VolumeName: string
             read GetVolumeName
             write SetVolumeName;
    property VolumeSerialNumber: string
             read GetVolumeSerialNumber
             write SetVolumeSerialNumber;
    property VolumeLocation: string
             read GetVolumeLocation
             write SetVolumeLocation;
    property VolumeLocationID: integer
             read GetVolumeLocationID
             write SetVolumeLocationID;
    property VolumeLabel: string
             read GetVolumeLabel
             write SetVolumeLabel;
    property Publisher: string
             read GetPublisher
             write SetPublisher;
    property Comment: string
             read GetComment
             write SetComment;
    property KEY: string
             read GetKEY
             write SetKEY;
    property Media: string
             read GetMedia
             write SetMedia;
    property EjectNeeded: boolean
             read fEjectNeeded;
  end;

var
  frmVolumeInfo: TfrmVolumeInfo;

implementation

uses MediaSettingsFile, MediaCatalog_Decl, uGetString, MyUtils;

{$R *.dfm}

{ TfrmVolumeInfo }

procedure TfrmVolumeInfo.Enable_Buttons;
begin

end;


procedure TfrmVolumeInfo.InitLocationsDropDown;
begin
  cbLocation.Clear;
  cbLocation.Items.AddObject('(Specify Location)', TObject(-2));
  fLocationSpecified := false;
  Enable_Buttons;

  with LocationsTable do
    begin
      try
        IndexName := 'Location Name';
        Active := true;
        First;
        while not Eof do
          begin
            cbLocation.Items.AddObject(Format('%d: %s', [fldLocationId.AsInteger, fldLocationName.AsString]),
                                       TObject(fldLocationID.AsInteger));
            Next;
          end;
      except
        on e:Exception do
          AlertFmt('Error loading locations DropDown [%s]', [e.message]);
      end;
    end;
end;


constructor TfrmVolumeInfo.Create(aOwner: TComponent);
begin
  inherited;
  InitLocationsDropDown;
end;

function TfrmVolumeInfo.GetComment: string;
begin
  result := leComment.Text;
end;

function TfrmVolumeInfo.GetKEY: string;
begin
  result := leKEY.Text;
end;

function TfrmVolumeInfo.GetLocationsTable: TLocationsTable;
begin
  if not Assigned(fLocationsTable) then
    begin
      fLocationsTable := TLocationsTable.Create(self, MediaSettings.DBFilePathName, LOCATIONS_TABLE_NAME, []);
      fLocationsTable.AddFields;
      fLocationsTable.Active := true;
    end;
  result := fLocationsTable;
end;

function TfrmVolumeInfo.GetMedia: string;
begin
  with cbMedia do
    if ItemIndex >= 0 then
      result := Copy(Items[ItemIndex], 1, 1)
    else
      result := '';
end;

function TfrmVolumeInfo.GetPublisher: string;
begin
  result := lePublisher.Text;
end;

function TfrmVolumeInfo.GetVolumeLabel: string;
begin
  result := leVolumeLabel.Text;
  fSavedVolumeLabel := leVolumeLabel.Text;
end;

function TfrmVolumeInfo.GetVolumeLocation: string;
begin
  with cbLocation do
    begin
      if ItemIndex >= 0 then
        result := Items[ItemIndex]
      else
        result := 'Unknown';
    end;
end;

function TfrmVolumeInfo.GetVolumeName: string;
begin
  result := leVolumeName.Text;
end;

function TfrmVolumeInfo.GetVolumeSerialNumber: string;
begin
  result := leSerialNumber.Text;
end;

procedure TfrmVolumeInfo.SetComment(const Value: string);
begin
  leComment.Text := Value;
end;

procedure TfrmVolumeInfo.SetDirListingFile(const Value: string);
begin
  Memo1.Lines.LoadFromFile(Value);
end;

procedure TfrmVolumeInfo.SetKEY(const Value: string);
begin
  leKEY.Text := Value;
end;

procedure TfrmVolumeInfo.SetMedia(const Value: string);
var
  i: integer;
begin
  with cbMedia do
    begin
      for i := 0 to Items.Count-1 do
        if Items[i][1] = Value[1] then
          begin
            ItemIndex := i;
            break;
          end;
    end;
end;

procedure TfrmVolumeInfo.SetPublisher(const Value: string);
begin
  lePublisher.Text := Value;
end;

procedure TfrmVolumeInfo.SetVolumeLabel(const Value: string);
begin
  leVolumeLabel.Text := Value;
end;

procedure TfrmVolumeInfo.SetVolumeLocation(const Value: string);
begin
  with cbLocation do
    ItemIndex := Items.IndexOf(Value);
  fLocationSpecified := true;
end;

procedure TfrmVolumeInfo.SetVolumeName(const Value: string);
begin
  leVolumeName.Text := Value
end;

procedure TfrmVolumeInfo.SetVolumeSerialNumber(const Value: string);
begin
  leSerialNumber.Text := Value;
end;

procedure TfrmVolumeInfo.btnAddLocationClick(Sender: TObject);
var
  Result: string;
begin
  if GetString('Add Location', 'Location Name', Result) then
    with LocationsTable do
      begin
        Append;
        fldLocationName.AsString := Result;
        Post;
        InitLocationsDropDown;
        Application.ProcessMessages;
        with cbLocation do
          begin
            ItemIndex := Items.IndexOfObject(TObject(Items.Count - 1));
            fLocationSpecified := true;
          end;
      end;
end;

destructor TfrmVolumeInfo.Destroy;
begin
  FreeAndNil(fLocationsTable);
  inherited;
end;

procedure TfrmVolumeInfo.leVolumeLabelKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_f11 then
    leVolumeLabel.Text := fSavedVolumeLabel;
end;

procedure TfrmVolumeInfo.cbLocationClick(Sender: TObject);
begin
  fLocationSpecified := true;
end;

procedure TfrmVolumeInfo.btnOKClick(Sender: TObject);
begin
  if (Length(cbMedia.Text) > 0) and (cbMedia.Text[1] in ['C' {CD}, 'D' {DVD}, '3', '5', 'B']) then
    fEjectNeeded := true;
  if not fLocationSpecified then
    begin
      Alert('Location must be specified');
      ModalResult := mrNone;
    end;
end;

function TfrmVolumeInfo.GetVolumeLocationID: integer;
begin
  with cbLocation do
    begin
      if ItemIndex >= 0 then
        result := Integer(Items.Objects[ItemIndex])
      else
        result := -1;
    end;
end;

procedure TfrmVolumeInfo.SetVolumeLocationID(const Value: integer);
begin
  with cbLocation do
    begin
      if Value >= 0 then
        ItemIndex := Items.IndexOfObject(TObject(Value))
      else
        ItemIndex := 0;
    end;
end;

end.
