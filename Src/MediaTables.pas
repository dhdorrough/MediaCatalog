unit MediaTables;

interface

uses MyTables, MyTables_Decl, MyUtils, DB, Classes;

type

  TLocationsTable = class(TMyTable)
  protected
  public
    fldLocationID: TField;
    fldLocationName: TField;
    fldLocationType: TField;
    procedure InitFieldPtrs; override;
  end;

  TVolumesTable = class(TMyTable)
  private
    procedure VolumesTableCalcFields(DataSet: TDataSet);
    procedure LoadLocationsList;
    function GetLocationsList: TStringList;
  protected
  public
    fldMedia_ID: TField;
    fldLocation: TField;
    fldLocationID: TField;
    fldVolumeLabel: TField;
    fldPublisher: TField;
    fldKey: TField;
    fldComment: TField;
    fldMedia: TField;
    fldDateAdded: TField;
    fldDateUpdated: TField;
    fldVolumeSerialNumber: TField;
    fldVolumeShortName: TField;
    fldVolumeDate: TField;

    fLocationsList: TStringList;
    fLocationsTable: TLocationsTable;
    procedure AddFields; override;
    Constructor Create( aOwner: TComponent;
                        aDBFilePathName, aTableName: string;
                        Options: TPhotoTableOptions); override;
    Destructor Destroy; override;
    procedure InitFieldPtrs; override;
    procedure DoBeforePost; override;
    procedure DoAfterInsert; override;
  published
    property LocationsList: TStringList
             read GetLocationsList;
  end;

  TLocationsInfo = record
                     Location_ID: integer;
                     LocationName: string;
                   end;

  TLocationsInfoArray = array of TLocationsInfo;

  TFileInfoTable = class(TMyTable)
  private
    fLocationsInfoArray: TLocationsInfoArray;
    fDisableCalculatedFields: boolean;
    procedure FileInfoTableCalcFields(DataSet: TDataSet);
    function GetDisableCalculatedFields: boolean;
    procedure SetDisableCalculatedFields(const Value: boolean);
  protected
  public
    fldID: TField;
    fldParentFolder_ID: TField;
    fldMedia_ID: TField;
    fldDateTimeModified: TField;
    fldFileSize: TField;
    fldShortFileName: TField;
    fldLongFileName: TField;
    fldIsAFolder: TField;
    fldThisFolders_ID: TField;
    fldFileName: TField;
    fldLocation_ID: TField;
    fldLocationName: TField;
    fldFILE_SIZE: TField;       // "999,999,999,999"

    fVolumesTable: TVolumesTable;
    fLocationsTable: TLocationsTable;
    procedure AddFields; override;
    Constructor Create( aOwner: TComponent;
                        aDBFilePathName, aTableName: string;
                        Options: TPhotoTableOptions); override;
    procedure InitFieldPtrs; override;
    function LocateFileByName(Media_ID, ParentFolder_ID: integer;
      const HashName, LongFileName: string): Boolean;
    function VolumesTable: TVolumesTable;
    function LocationsTable: TLocationsTable;
    property DisableCalculatedFields: boolean
             read GetDisableCalculatedFields
             write SetDisableCalculatedFields;
  end;

  function MediaCatalogFilters: string;

implementation

uses
  Variants, MediaSettingsFile, MediaCatalog_Decl, SysUtils;

  function MediaCatalogFilters: string;
  begin { MediaCatalogFilters }
    result := Format('Access 2007 Database (*.%s)|*.%s|Access 2007 Database (*.%s)|*.%s',
                     [ACCESS_2007_EXT, ACCESS_2007_EXT, ACCESS_2000_EXT, ACCESS_2000_EXT]);

  end;  { MediaCatalogFilters }

{ TVolumesTable }

procedure TVolumesTable.AddFields;
begin
  inherited;
  AddField(self, LOCATION_NAME, LOCATION_NAME, TStringField,  fkCalculated, 30, 30);
end;

procedure TVolumesTable.LoadLocationsList;
begin
  if not Assigned(fLocationsList) then
    begin
      fLocationsList  := TStringList.Create;
      fLocationsTable := TLocationsTable.Create(self, MediaSettings.DBFilePathName, LOCATIONS_TABLE_NAME, []);
      fLocationsTable.AddFields;
      fLocationsTable.Active := true;
      try
        with fLocationsTable do
          begin
            First;
            while not Eof do
              begin
                fLocationsList.AddObject(fldLocationName.AsString, TObject(fldLocationID.AsInteger));
                Next;
              end;
          end;
      finally
        fLocationsTable.Free;
      end;
    end;
end;


procedure TVolumesTable.VolumesTableCalcFields(DataSet: TDataSet);
var
  Idx: integer;
begin
  if not fldLocationID.IsNull then
    begin
      Idx := fLocationsList.IndexOfObject(TObject(fldLocationID.AsInteger));
      if Idx >= 0 then
        fldLocation.AsString := fLocationsList[Idx];
    end;
end;


procedure TVolumesTable.InitFieldPtrs;
begin
  inherited;

  fldMedia_ID           := FieldByName(MEDIA_ID_FIELD_NAME);
  fldLocationID         := FieldByName(LOCATION_ID);
  fldVolumeLabel        := FieldByName(VOLUME_LABEL);
  fldPublisher          := FieldByName('Publisher');
  fldKey                := FieldByName('Key');
  fldComment            := FieldByName('Comment');
  fldMedia              := FieldByName('Media');
  fldDateAdded          := FieldByName('DateAdded');
  fldDateUpdated        := FindField('DateUpdated');
  fldVolumeSerialNumber := FieldByName(VOLUME_SERIAL_NUMBER);
  fldVolumeShortName    := FieldByName(VOLUME_SHORT_NAME);
  fldVolumeDate         := FieldByName('Volume Date');

  // calculated fields
  fldLocation           := FindField(LOCATION_NAME); // *** was 'Location'
end;

constructor TVolumesTable.Create(aOwner: TComponent; aDBFilePathName,
  aTableName: string; Options: TPhotoTableOptions);
begin
  inherited;
  LoadLocationsList;
  OnCalcFields := VolumesTableCalcFields;
end;

destructor TVolumesTable.Destroy;
begin
  FreeAndNil(fLocationsList);
  inherited;
end;

procedure TVolumesTable.DoBeforePost;
begin
  inherited;
  fldDateUpdated.AsDateTime := Now;
end;

procedure TVolumesTable.DoAfterInsert;
begin
  inherited;
  if fldDateAdded.IsNull then
    fldDateAdded.AsDateTime := Now;
end;

function TVolumesTable.GetLocationsList: TStringList;
begin
  if not Assigned(fLocationsList) then
    fLocationsList := TStringList.Create;
  result := fLocationsList;
end;

{ TFileInfoTable }

procedure TFileInfoTable.AddFields;
begin
  inherited;
  AddField(self, 'FileName',  'FileName',  TStringField,  fkCalculated, 100, 100);
  AddField(self, LOCATION_ID, LOCATION_ID, TIntegerField, fkCalculated, 5,  0);
  AddField(self, LOCATION_NAME, LOCATION_NAME, TStringField, fkCalculated, 30, 30);
  AddField(selF, FILE_SIZE,     FILE_SIZE,     TStringField,  fkCalculated, 15, 15);
end;

procedure TFileInfoTable.FileInfoTableCalcFields(DataSet: TDataSet);
begin
  if not fDisableCalculatedFields then
    begin
      if not Empty(fldLongFileName.AsString) then
        fldFileName.AsString := fldLongFileName.AsString
      else
        fldFileName.AsString := fldShortFileName.AsString;

      if not fldMedia_ID.IsNull then
        if fldMedia_ID.AsInteger < Length(fLocationsInfoArray) then
          with fLocationsInfoArray[fldMedia_ID.AsInteger] do
            begin
              fldLocation_ID.AsInteger := Location_ID;
              fldLocationName.AsString := LocationName;
            end;
      if fldFileSize.AsInteger = 0 then
        fldFILE_SIZE.AsString := ''
      else if fldFileSize.AsInteger > 0 then
        fldFILE_SIZE.AsString := ScaledSize(fldFileSize.AsInteger * 1.0)
      else
        fldFILE_SIZE.AsString := '> 2Gb';
    end
  else
    begin
      fldFileName.AsString  := fldShortFileName.AsString;
      fldFILE_SIZE.AsString := IntTostr(fldFileSize.AsInteger);
    end;

end;

constructor TFileInfoTable.Create(aOwner: TComponent; aDBFilePathName,
  aTableName: string; Options: TPhotoTableOptions);
var
  RecCount: integer;
begin
  inherited;
  OnCalcFields := FileInfoTableCalcFields;
  with VolumesTable do
    begin
      AddFields;
      Active := true;
      RecCount := 0;
      First;
      While not Eof do
        begin
          if fldMedia_ID.AsInteger > RecCount then
            RecCount := fldMedia_ID.AsInteger;
          Next;
        end;
      SetLength(fLocationsInfoArray, RecCount+1);
      First;
      while not Eof do
        begin
          if not fldMedia_ID.IsNull then
            with fLocationsInfoArray[fldMedia_ID.AsInteger] do
              begin
                Location_ID  := fldLocationID.AsInteger;
                LocationName := fldLocation.AsString;
              end;
          Next;
        end;
    end;
end;

procedure TFileInfoTable.InitFieldPtrs;
begin
  inherited;
  fldID               := FieldByName('ID');
  fldMedia_ID         := FieldByName(MEDIA_ID_FIELD_NAME);
  fldParentFolder_ID  := FieldByName(PARENTFOLDER_ID);
  fldDateTimeModified := FieldByName('DateTimeModified');
  fldFileSize         := FieldByName('FileSize');
  fldShortFileName    := FieldByName('ShortFileName');
  fldLongFileName     := FieldByName('LongFileName');
  fldIsAFolder        := FieldByName('IsAFolder');
  fldThisFolders_ID   := FieldByName(THISFOLDERS_ID);
//fldDateRecordAdded  := FieldByName('DateRecordAdded');
  fldFileName         := FindField('FileName');  // calculated field- may not be created until later
  fldLocation_ID      := FindField(LOCATION_ID);
  fldLocationName     := FindField(LOCATION_NAME);
  fldFILE_SIZE        := FindField(FILE_SIZE);     // "999,999,999,999"
end;

function TFileInfoTable.LocateFileByName(Media_ID, ParentFolder_ID: integer; const HashName, LongFileName: string): Boolean;
begin
  result := Locate('Media_ID;ParentFolder_ID;ShortFileName', VarArrayOf([Media_ID, ParentFolder_ID, HashName]), []);
  if result then  // if Length(HashedName) <= HASHED_NAME_LENGTH then the LongFileName is not stored
    begin
      if Length(HashName) > HASHED_NAME_LENGTH then
        begin
          while (fldShortFileName.AsString = HashName) and (fldLongFileName.AsString <> LongFileName) and (not eof) do
            Next;
          result := fldLongFileName.AsString = LongFileName;
        end
    end;
end;

function TFileInfoTable.VolumesTable: TVolumesTable;
begin
  if not Assigned (fVolumesTable) then
    begin
      fVolumesTable := TVolumesTable.Create(self, fDBFilePathName, VOLUMES_TABLE_NAME, []);
//    fVolumesTable.Active := true;
    end;
  result := fVolumesTable;
end;

function TFileInfoTable.LocationsTable: TLocationsTAble;
begin
  if not Assigned(fLocationsTable) then
    begin
      fLocationsTable := TLocationsTable.Create(self, fDBFilePathNAme, LOCATIONS_TABLE_NAME, [optReadOnly]);
      fLocationsTable.IndexName := 'ID';
      fLocationsTable.AddFields;
      fLocationsTable.Active := true;
    end;
  result := fLocationsTable;
end;

function TFileInfoTable.GetDisableCalculatedFields: boolean;
begin
  result := fDisableCalculatedFields;
end;

procedure TFileInfoTable.SetDisableCalculatedFields(const Value: boolean);
begin
  if fDisableCalculatedFields <> Value then
    begin
      fDisableCalculatedFields := Value;
      Refresh;
    end;
end;

{ TLocationsTable }

procedure TLocationsTable.InitFieldPtrs;
begin
  inherited;

  fldLocationID   := FieldByName('ID');
  fldLocationName := FieldByName('Location Name');
  fldLocationType := FieldByName('Location Type');
end;

end.
