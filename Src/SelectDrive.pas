unit SelectDrive;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmSelectDrive = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    cbDrive: TComboBox;
    Label1: TLabel;
  private
    function GetDriveLetter: char;
    procedure SetDriveLetter(const Value: char);
    { Private declarations }
  public
    { Public declarations }
    property DriveLetter: char
             read GetDriveLetter
             write SetDriveLetter;
  end;

var
  frmSelectDrive: TfrmSelectDrive;

implementation

{$R *.dfm}

{ TfrmSelectDrive }

function TfrmSelectDrive.GetDriveLetter: char;
begin
  if cbDrive.ItemIndex >= 0 then
    result := cbDrive.Items[cbDrive.ItemIndex][1]
  else
    result := ' ';
end;

procedure TfrmSelectDrive.SetDriveLetter(const Value: char);
begin
  cbDrive.ItemIndex := cbDrive.Items.IndexOf(Value)
end;

end.
