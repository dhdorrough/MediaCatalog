unit MediaCatalog_Decl;

interface

uses
  Messages;

const
  FILEINFO_TABLE_NAME      = 'FileInfo';
  VOLUMES_TABLE_NAME       = 'Volumes';
  LOCATION_AND_LABEL       = 'LocationAndLabel';
  LOCATIONS_TABLE_NAME     = 'Locations';
  VOLUME_SERIAL_NUMBER     = 'Volume Serial Number';
  VOLUME_SHORT_NAME        = 'Volume Short Name';
  VOLUME_LABEL             = 'Volume Label';
  MEDIA_DATABASE_EXTENSION = 'ACCDB';
  MEDIA_ID_FIELD_NAME      = 'Media_ID';
  THISFOLDERS_ID           = 'ThisFolders_ID';
  PARENTFOLDER_ID          = 'ParentFolder_ID';
  LOCATION_NAME            = 'Location Name';
  LOCATION_ID              = 'Location ID';
  FILE_SIZE                = 'File_Size';     // as a string "999,999,999"
  BAD_DATE                 = -1;

  MAXFILENAMELEN = 127;
  HASHED_NAME_LENGTH = 16;

  WM_BuildTreeView   = WM_APP + 1;


implementation

end.
