unit MediaSettingsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TfrmMediaSettings = class(TForm)
    leDBFilePathName: TLabeledEdit;
    Label1: TLabel;
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    btnBrowse1: TButton;
    OpenDialog1: TOpenDialog;
    btnBrowse2: TButton;
    OpenDialog3: TOpenDialog;
    cbDrive: TComboBox;
    leFileInfoRecordCount: TLabeledEdit;
    lblFileInfoRecordCount: TLabel;
    leLogFilePathName: TLabeledEdit;
    btnBrowseLogFilePathName: TButton;
    procedure btnBrowse1Click(Sender: TObject);
    procedure leFileInfoRecordCountChange(Sender: TObject);
    procedure btnBrowseLogFilePathNameClick(Sender: TObject);
  private
    function GetDrive: char;
    procedure SetDrive(const Value: char);
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
    property Drive: char
             read GetDrive
             write SetDrive;
  end;

var
  frmMediaSettings: TfrmMediaSettings;

implementation

uses MyUtils, MediaSettingsFile;

{$R *.dfm}

procedure TfrmMediaSettings.btnBrowse1Click(Sender: TObject);
begin
  with OpenDialog1 do
    begin
      FileName := leDBFilePathName.Text;
      InitialDir := ExtractFilePath(leDBFilePathName.Text);
      DefaultExt := 'MDB';
      if Execute then
        leDBFilePathName.Text := FileName;
    end;
end;

function TfrmMediaSettings.GetDrive: char;
begin
  if cbDrive.ItemIndex >= 0 then
    result := cbDrive.Items[cbDrive.ItemIndex][1]
  else
    result := ' ';
end;

procedure TfrmMediaSettings.SetDrive(const Value: char);
begin
  cbDrive.ItemIndex := cbDrive.Items.IndexOf(Value)
end;

procedure TfrmMediaSettings.leFileInfoRecordCountChange(Sender: TObject);
begin
  if not IsPureNumeric(leFileInfoRecordCount.Text) then
    lblFileInfoRecordCount.Visible := true
  else
    lblFileInfoRecordCount.Visible := false;
end;

constructor TfrmMediaSettings.Create(aOwner: TComponent);
begin
  inherited;
end;

procedure TfrmMediaSettings.btnBrowseLogFilePathNameClick(Sender: TObject);
begin
  with OpenDialog1 do
    begin
      FileName   := leLogFilePathName.Text;
      InitialDir := ExtractFilePath(leLogFilePathName.Text);
      DefaultExt := 'txt';
      if Execute then
        begin
          leLogFilePathName.Text := FileName;
        end;
    end;
end;

end.
