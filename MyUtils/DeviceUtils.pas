unit DeviceUtils;

interface

type
  TCDAction = (_OPEN, _CLOSE);

function EjectCD(Drive : char) : boolean;
function EjectDrive(const ADriveLetter: string; Action: TCDAction): Boolean;
function IsDriveCD(Drive : char) : longbool;
function OpenCloseCDDrive(Drive: Char; Action: TCDAction): boolean;

implementation

uses
  MPlayer, Forms, Windows, Dialogs, Controls, MMSystem, ComObj;

function IsDriveCD(Drive : char) : longbool;
var
  DrivePath : string;
begin
  DrivePath := Drive + ':\';
  result := LongBool(GetDriveType(PChar(DrivePath)) and DRIVE_CDROM);
end;

function EjectCD(Drive : char) : boolean;
var
  mp : TMediaPlayer;
begin
  result := false;
  Application.ProcessMessages;
  if not IsDriveCD(Drive) then exit;
  mp := TMediaPlayer.Create(nil);
  mp.Visible := false;
  mp.Parent := Application.MainForm;
  mp.Shareable := true;
  mp.DeviceType := dtCDAudio;
  mp.FileName := Drive + ':';
  mp.Open;
  Application.ProcessMessages;
  mp.Eject;
  Application.ProcessMessages;
  mp.Close;
  Application.ProcessMessages;
  mp.free;
  result := true;
end;

function OpenCloseCDDrive(Drive: Char; Action: TCDAction): boolean;
{ func to eject or close the cdrom drive. Works on all Audio & }
{ Data CDs, even if there is no CDROM in the drive.            }
var
  mp : TMediaPlayer;
  mciResult: integer;
begin
  Result := False;
  Application.ProcessMessages;
  if not IsDriveCD(Drive) then
    begin
      MessageDlg(Drive + ':\ is not a CDROM drive.', mtError, [mbOK], 0);
      Exit;
    end;
  Screen.Cursor := crHourGlass;
  mp := TMediaPlayer.Create(nil);
  try
    mp.Visible := False;
    mp.Parent := Application.MainForm;
    mp.Shareable := True;
    mp.DeviceType := dtCDAudio;
    mp.FileName := Drive + ':';
    mp.Open;
    Application.ProcessMessages;
    mciResult := 0;
    case Action of
      _OPEN : mp.Eject;
      _CLOSE: mciResult := mciSendCommand(mp.DeviceID,
                                          MCI_SET, MCI_SET_DOOR_CLOSED, 0);
    end;
    Application.ProcessMessages;
    mp.Close;
    Application.ProcessMessages;
    case Action of
      _OPEN : Result := True;
      _CLOSE: Result := mciResult = 0;
    end;
  finally
    mp.Free;
    Screen.Cursor := crDefault;
  end;
end;

function EjectDrive(const ADriveLetter: string; Action: TCDAction): Boolean;
var
  WMP: Variant;
  CDROMs: Variant;
  Drive: Variant;
begin
  result := true;
  try
    WMP := CreateOleObject('WMPlayer.OCX.7');
    CDROMs := WMP.CDROMCollection;
    Drive  := CDROMs.GetByDriveSpecifier(ADriveLetter + ':');
    case Action of
      _Open: Drive.Eject;
      _Close: Drive.Load;
    end;
  except
    result := false;
  end;
end;

end.
