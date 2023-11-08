unit FolderBrowser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BrowserUnit, Menus, StdCtrls, ExtCtrls, DBCtrls, Grids, DBGrids;

type
  TfrmFolderBrowser = class(TfrmDataSetBrowser)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmFolderBrowser: TfrmFolderBrowser;

implementation

{$R *.dfm}

end.
