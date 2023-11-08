unit LabelTheDisk;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, MyTables, MediaTables;

type
  TfrmLabelTheDisk = class(TForm)
    Label1: TLabel;
    VolumeID: TLabel;
    btnOk: TButton;
    edtLabelOnTheDisk: TLabeledEdit;
    btnCancel: TButton;
    cbLocation: TComboBox;
    btnAddLocation: TButton;
    Label2: TLabel;
    procedure btnAddLocationClick(Sender: TObject);
  private
    fLocationsTable: TLocationsTable;
    { Private declarations }
  public
    { Public declarations }
    procedure InitLocationsDropDown(LocationsTable: TLocationsTable; LocationID: integer);
  end;

var
  frmLabelTheDisk: TfrmLabelTheDisk;

implementation

uses MyUtils, uGetString;

procedure TfrmLabelTheDisk.InitLocationsDropDown(LocationsTable: TLocationsTable; LocationID: integer);
var
  idx: integer;
begin
  cbLocation.Clear;
  cbLocation.Items.AddObject('(Specify Location)', TObject(-2));
  fLocationsTable := LocationsTable;
  with LocationsTable do
    begin
      IndexName := 'Location Name';
      Active := true;
      First;
      while not Eof do
        begin
          cbLocation.Items.AddObject(Format('%d: %s', [fldLocationId.AsInteger, fldLocationName.AsString]),
                                     TObject(fldLocationID.AsInteger));
          Next;
        end;
    end;
  with cbLocation do
    begin
      Idx := Items.IndexOfObject(TObject(LocationID));
      if Idx >= 0 then
        ItemIndex := Idx;
    end;
end;

{$R *.dfm}

procedure TfrmLabelTheDisk.btnAddLocationClick(Sender: TObject);
var
  Result: string;
begin
  if GetString('Add Location', 'Location Name', Result) then
    begin
      with fLocationsTable do
        begin
          Append;
          fldLocationName.AsString := Result;
          Post;
          InitLocationsDropDown(fLocationsTable, fldLocationID.AsInteger);
          Application.ProcessMessages;
         end;
    end;
end;

end.
