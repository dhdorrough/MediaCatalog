unit MediaBrowser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BrowserUnit, Menus, StdCtrls, ExtCtrls, DBCtrls, Grids, DBGrids,
  DB, ADODB, VolumeInfo;

type
  TfrmVolumesBrowser = class(TfrmDataSetBrowser)
    N1: TMenuItem;
    OrderBy1: TMenuItem;
    MediaID1: TMenuItem;
    CDLabel1: TMenuItem;
    BookCDLabel1: TMenuItem;
    uTILITIES1: TMenuItem;
    CountSelectedRecords1: TMenuItem;
    rEcALChASHEDfILEnAMES1: TMenuItem;
    DeleteSelectedRecords1: TMenuItem;
    DataSource2: TDataSource;
    ADOTable2: TADOTable;
    ADOConnection2: TADOConnection;
    Reports1: TMenuItem;
    ListSelectedRecords1: TMenuItem;
    VolumeDate1: TMenuItem;
    rECnO1: TMenuItem;
    procedure MediaID1Click(Sender: TObject);
    procedure BookCDLabel1Click(Sender: TObject);
    procedure CDLabel1Click(Sender: TObject);
    procedure CountSelectedRecords1Click(Sender: TObject);
    procedure DeleteSelectedRecords1Click(Sender: TObject);
    procedure ListSelectedRecords1Click(Sender: TObject);
    procedure VolumeDate1Click(Sender: TObject);
    procedure rECnO1Click(Sender: TObject);
//  procedure DBNavigator1BeforeAction(Sender: TObject;
//    Button: TNavigateBtn);
//private
//    function TheVolumeInfoForm: TfrmVolumeInfo;
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent; DataSet: TDataSet; DataSetName: string = ''); override;
  end;

var
  frmVolumesBrowser: TfrmVolumesBrowser;

implementation

uses MediaTables, MediaCatalog_Decl, MyUtils;

{$R *.dfm}

procedure TfrmVolumesBrowser.MediaID1Click(Sender: TObject);
begin
  inherited;
  (DataSet as TVolumesTable).IndexName := MEDIA_ID_FIELD_NAME;
end;

procedure TfrmVolumesBrowser.BookCDLabel1Click(Sender: TObject);
begin
  inherited;
  (DataSet as TVolumesTable).IndexName := 'LocationAndLabel';
end;

procedure TfrmVolumesBrowser.CDLabel1Click(Sender: TObject);
begin
  inherited;
  (DataSet as TVolumesTable).IndexName := 'CDLabel';
end;

constructor TfrmVolumesBrowser.Create(aOwner: TComponent;
  DataSet: TDataSet; DataSetName: string);
begin
  inherited;                          

end;

procedure TfrmVolumesBrowser.CountSelectedRecords1Click(Sender: TObject);
var
  SavedRecNo, RecCount: integer;
  SavedIndexName: string;
begin
  inherited;
  with DataSet as TVolumesTable do
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


procedure TfrmVolumesBrowser.DeleteSelectedRecords1Click(Sender: TObject);
var
  RecCount: integer;
  SavedIndexName: string;
begin
  inherited;
  if Yes('Do you really want to delete all of the selected records?') then
    begin
      with DataSet as TVolumesTable do
        begin
          DisableControls;
          SavedIndexName := IndexName;
          IndexName      := '';
          RecCount := 0;
          try
            First;
            while not Eof do
              begin
                Delete;
                if (RecCount Mod 1000) = 0 then
                  begin
                    lblStatus.Caption := Format('%0.n records deleted', [RecCount*1.0]);
                    Application.ProcessMessages;
                  end;
                Inc(RecCount);
              end;
          finally
            lblStatus.Caption := Format('%0.n records deleted', [RecCount*1.0]);
            EnableControls;
            IndexName := SavedIndexName;
          end;
        end;
    end;
end;

procedure TfrmVolumesBrowser.ListSelectedRecords1Click(Sender: TObject);
(*
var
  SavedRecNo: integer;
  SavedIndexName: string;
*)
begin
  inherited;
(*
  with DataSet as TVolumesTable do
    begin
      DisableControls;
      SavedRecno     := RecNo;
      SavedIndexName := IndexName;
      IndexName      := '';
      DataSource2.DataSet := DataSet;
      try
        ppReport2.OnPreviewFormCreate := ppReportPreviewFormCreate;
        lblExpression.Caption         := SelectivityParser.Condition;
        ppReport2.Print;
      finally
        EnableControls;
        IndexName := SavedIndexName;
        RecNo     := SavedRecNo;
      end;
    end;
*)
end;

procedure TfrmVolumesBrowser.VolumeDate1Click(Sender: TObject);
begin
  inherited;
  (DataSet as TVolumesTable).IndexName := 'Volume Date';
end;

procedure TfrmVolumesBrowser.RecNo1Click(Sender: TObject);
begin
  inherited;
  (DataSet as TVolumesTable).IndexName := '';
end;

(*
procedure TfrmVolumesBrowser.DBNavigator1BeforeAction(Sender: TObject;
  Button: TNavigateBtn);
begin
  case Button of
    nbInsert:
      begin
        with TheVolumeInfoForm do
          begin
            if ShowModal = mrOK then
              begin
                with fDataSet as TVolumesTable do
                  begin
                    Append;

//                  fldMedia_ID
//                  fldLocation.AsString      := TheVolumeInfoForm.Location;
//                  fldLocationID.AsInteger   := TheVolumeInfoForm.LocationID;
                    fldVolumeLabel.AsString   := TheVolumeInfoForm.VolumeLabel;
                    fldPublisher.AsString     := TheVolumeInfoForm.Publisher;
                    fldKey.AsString           := TheVolumeInfoForm.KEY;
                    fldComment.AsString       := TheVolumeInfoForm.Comment;
                    fldMedia.AsString         := TheVolumeInfoForm.Media;
                    fldDateAdded.AsDateTime   := Now;
                    fldDateUpdated.AsDateTime := Now;
                    fldVolumeSerialNumber.AsString := TheVolumeInfoForm.leSerialNumber.Text;
//                  fldVolumeShortName.AsString    := TheVolumeInfoForm.
//                  fldVolumeDate.AsDateTime  := ?;

                    Post;
                  end;
              end;
          end;
        SysUtils.Abort;
      end
    else
      inherited;
  end
end;
*)

(*
function TfrmVolumesBrowser.TheVolumeInfoForm: TfrmVolumeInfo;
begin
  if not Assigned(frmVolumeInfo) then
    frmVolumeInfo := TfrmVolumeInfo.Create(self);
  result := frmVolumeInfo;
end;
*)


end.
