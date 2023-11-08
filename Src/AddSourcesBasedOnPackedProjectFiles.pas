unit AddSourcesBasedOnPackedProjectFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, VideoProjectsManager_Decl;

type
  TfrmAddSourcesBasedOnPackedProjectFiles = class(TForm)
    lePackedProjectFilesFolder: TLabeledEdit;
    btnBrowsePackedProjectFilesFolder: TBitBtn;
    btnProcess: TButton;
    Button2: TButton;
    lbSourceFolders: TListBox;
    Label1: TLabel;
    btnAddFolder: TButton;
    btnDeleteFolder: TButton;
    lvFilesToSearchFor: TListView;
    Label2: TLabel;
    btnDeleteFile: TButton;
    btnClearFiles: TButton;
    btnRefresh: TButton;
    Memo1: TMemo;
    Label3: TLabel;
    lblFilesToSearchFor: TLabel;
    lblFileCount: TLabel;
    OK: TButton;
    btnClearFolders: TButton;
    procedure btnBrowsePackedProjectFilesFolderClick(Sender: TObject);
    procedure btnAddFolderClick(Sender: TObject);
    procedure btnDeleteFolderClick(Sender: TObject);
    procedure btnClearFilesClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnProcessClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnClearFoldersClick(Sender: TObject);
  private
    fSourcesList: TStringList;
    procedure RefreshListOfFilesToProcess(Folder: string);
    procedure UpdateStatus;
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
    Destructor Destroy; override;
    property SourcesList: TStringList
             read fSourcesList
             write fSourcesList;
  end;

implementation

uses MyUtils, CommCtrl, VideoProjectsSettings;

{$R *.dfm}

procedure TfrmAddSourcesBasedOnPackedProjectFiles.btnBrowsePackedProjectFilesFolderClick(
  Sender: TObject);
var
  Folder: string;
begin
  Folder := lePackedProjectFilesFolder.Text;
  if BrowseForFolder('Packed Project Files Folder', Folder) then
    begin
      lePackedProjectFilesFolder.Text := Folder;
      RefreshListOfFilesToProcess(Folder);
    end;
end;

procedure TfrmAddSourcesBasedOnPackedProjectFiles.UpdateStatus;
begin
  lblFilesToSearchFor.Caption := Format('%d files', [lvFilesToSearchFor.Items.Count]);
  lblFileCount.Caption := Format('%d files', [Memo1.Lines.Count]);
end;


procedure TfrmAddSourcesBasedOnPackedProjectFiles.RefreshListOfFilesToProcess(Folder: string);
var
  DosErr: integer;
  ListItem: TListItem;
  SearchRec: TSearchRec;
begin
  lvFilesToSearchFor.Clear;
  UpdateStatus;

  DosErr := FindFirst(Folder+'*.*', faAnyFile-faDirectory, SearchRec);
  try
    while DosErr = 0 do
      begin
        ListItem := lvFilesToSearchFor.Items.Add;
        UpdateStatus;
        ListItem.Caption := SearchRec.Name;
        DosErr := FindNext(SearchRec);
      end;
  finally
    FindClose(SearchRec);
  end;
  ListView_SetColumnWidth(lvFilesToSearchFor.Handle, 0, 300);
end;


procedure TfrmAddSourcesBasedOnPackedProjectFiles.btnAddFolderClick(
  Sender: TObject);
var
  Folder: string;  
begin
  if BrowseForFolder('Select a Source Files Folder', Folder) then
    begin
      lbSourceFolders.Items.Add(Folder);
    end;
end;

procedure TfrmAddSourcesBasedOnPackedProjectFiles.btnDeleteFolderClick(
  Sender: TObject);
begin
  with lbSourceFolders do
    begin
      if ItemIndex >= 0 then
        Items.Delete(ItemIndex);
    end;
end;

procedure TfrmAddSourcesBasedOnPackedProjectFiles.btnClearFilesClick(
  Sender: TObject);
begin
  lvFilesToSearchFor.Clear;
  UpdateStatus;
end;

procedure TfrmAddSourcesBasedOnPackedProjectFiles.btnRefreshClick(
  Sender: TObject);
begin
  RefreshListOfFilesToProcess(lePackedProjectFilesFolder.Text);
end;

procedure TfrmAddSourcesBasedOnPackedProjectFiles.btnProcessClick(
  Sender: TObject);
var
  j: integer;

  procedure FindFiles(const Path: string);
  var
    SearchRec: TSearchRec;
    DosErr, NeededFile: integer;
    CurrentFileName: string;
    Temp: string;
    FilePathName: string;

    function IsFileNeeded(FileName: string): integer;
    var
      i: integer;
    begin { IsFileNeeded }
      result := -1;
      for i := 0 to lvFilesToSearchFor.Items.Count-1 do
        if SameText(FileName, lvFilesToSearchFor.Items[i].Caption) then
          begin
            result := i;
            break;
          end;
    end;  { IsFileNeeded }

  begin { FindFiles }
    Temp   := Path + '*.*';
    DosErr := FindFirst(Temp, faAnyFile-faDirectory, SearchRec);
    try
      while (DosErr = 0) and (lvFilesToSearchFor.Items.Count > 0) do
        begin
          CurrentFileName := SearchRec.Name;
          NeededFile      := IsFileNeeded(CurrentFileName);
          if NeededFile >= 0 then
            with lvFilesToSearchFor do
              begin
                FilePathName := Path + Items[NeededFile].Caption;
                SourcesList.AddObject(FilePathName, TObject(NeededFile));
                Items.Delete(NeededFile);
                UpdateStatus;
                Memo1.Lines.AddObject(FilePathName, TObject(NeededFile));
                UpdateStatus;
              end;
          DosErr := FindNext(SearchRec);
        end;
      FindClose(SearchRec);

      if (lvFilesToSearchFor.Items.Count > 0) then // not all found -- process the subfolders
        begin
          Temp   := Path + '*.*';
          DosErr := FindFirst(Temp, faDirectory, SearchRec);
          while (lvFilesToSearchFor.Items.Count > 0) and (DosErr = 0) do
            begin
              if (not ((SearchRec.Name = '.') or (SearchRec.Name = '..'))) and ((SearchRec.Attr and faDirectory) <> 0) then
                begin
                  Temp   := ForceBackSlash(Path + SearchRec.Name);
                  FindFiles(Temp);
                end;
              if (lvFilesToSearchFor.Items.Count > 0) then
                DosErr := FindNext(SearchRec)
              else
                Exit;
            end;
        end;

    finally
      FindClose(SearchRec);
    end;
  end;  { FindFiles }

begin { TfrmAddSourcesBasedOnPackedProjectFiles.btnProcessClick }
  Memo1.Clear;
  fSourcesList.Clear;

  for j := 0 to lbSourceFolders.Items.Count-1 do
    FindFiles(ForceBackSlash(lbSourceFolders.Items[j]));
end;  { TfrmAddSourcesBasedOnPackedProjectFiles.btnProcessClick }

constructor TfrmAddSourcesBasedOnPackedProjectFiles.Create(
  aOwner: TComponent);
begin
  inherited;
  SourcesList := TStringList.Create;
end;

destructor TfrmAddSourcesBasedOnPackedProjectFiles.Destroy;
begin
  FreeAndNil(fSourcesList);
  inherited;
end;

procedure TfrmAddSourcesBasedOnPackedProjectFiles.FormShow(
  Sender: TObject);
begin
  UpdateStatus;
end;

procedure TfrmAddSourcesBasedOnPackedProjectFiles.btnClearFoldersClick(
  Sender: TObject);
begin
  lbSourceFolders.Clear;
end;

end.
