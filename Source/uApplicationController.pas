unit uApplicationController;

interface

uses
  Classes, SysUtils,
  uProjectSettings;

type
  TOnNewSourceFile = procedure(Sender: TObject; const AFilename : string) of object;

  TApplicationController = class
  private
    FProjectSettings: TProjectSettings;
    FTitle: string;
    FOnNewSourceFile: TOnNewSourceFile;
    procedure ReadExeVersion;
    procedure FBuildFileList(const ARootFolder: string; AFileList : TStrings);
    procedure GenerateDCovExecuteFile;
    procedure GenerateDCovUnitsAndPathFiles;
  public
    property ProjectSettings  : TProjectSettings read FProjectSettings write FProjectSettings;
    property Title : string read FTitle;
    constructor Create;
    destructor Destroy; override;
    procedure BuildSourceList(const ASourcePath : TFilename);
    property OnNewSourceFile : TOnNewSourceFile read FOnNewSourceFile write FOnNewSourceFile;
    procedure Generate;
  end;

var
  ApplicationController : TApplicationController;

implementation

uses
  Forms, JvVersionInfo, JclFileUtils;

{ TApplicationController }

{*------------------------------------------------------------------------------
  Test if file is Pascal source file
  Function is defined as JclUtilsFile needs : TFileMatchFunc =
   function(const Attr: Integer; const FileInfo: TSearchRec): Boolean;
  @param Attr Attribute of file
  @param FileInfo Search record holding the search context
  @return TRUE if extension match with '*.pas filter', FALSE otherwise
-------------------------------------------------------------------------------}
function PasMatchFunc(const Attr: Integer; const FileInfo: TSearchRec): Boolean;
const
  PAS_FILE_EXT = '.pas';
begin
  Result := ((Attr and FileInfo.Attr) <> 0)
   and SameText(ExtractFileExt(FileInfo.Name),PAS_FILE_EXT);
end;

{*------------------------------------------------------------------------------
  Build a file list filtered with PAS extension
  Start is the input directory, and eventually the sub-directories,
  it then add all matching files in the FileList.
  @param RootFolder Starting folder to build list from
-------------------------------------------------------------------------------}
procedure TApplicationController.FBuildFileList(const ARootFolder: string; AFileList : TStrings);
const
  PAS_FILE_FILTER : string = '*.pas';
  FA_ALL_FILES_EX = faNormalFile +
    faReadOnly + faHidden + faSysFile + faArchive + faTemporary + faSparseFile
    + faReparsePoint + faCompressed + faOffline + faNotContentIndexed + faEncrypted;
begin
  // $80 must be added because if the file's archive attribute is not set,
  // then FindFirst return [FindoInfo.Attr = 128]  ...
  AdvBuildFileList(ARootFolder + PAS_FILE_FILTER, FA_ALL_FILES_EX, AFileList,{amAny} amCustom,
    [flRecursive, flFullNames], '', {nil}PasMatchFunc);
end;

procedure TApplicationController.Generate;
begin
  // Generate
  GenerateDCovExecuteFile();
  GenerateDCovUnitsAndPathFiles();
end;

procedure TApplicationController.GenerateDCovExecuteFile;
const
  DCOV_EXECUTE_FORMAT = 'CodeCoverage.exe -e %s -m %s -uf dcov_units.lst -spf dcov_paths.lst -od %sreport -lt';
var
  DCovExecuteText : TStringList;
begin
  // Create 'dcov_execute.bat'
  DCovExecuteText := TStringList.Create;
  // Fill
  DCovExecuteText.Add(Format(DCOV_EXECUTE_FORMAT, [ProjectSettings.ProgramToAnalyze, ProjectSettings.ProgramMapping, ProjectSettings.ReportPath]));
  // Save
  DCovExecuteText.SaveToFile(ProjectSettings.ScriptsPath + 'dcov_execute.bat');
  FreeAndNil(DCovExecuteText);
end;

procedure TApplicationController.GenerateDCovUnitsAndPathFiles;
var
  DCovUnitsText : TStringList;
  DCovPathsText : TStringList;
  CheckedUnitList : TStrings;
  UnitFilename: string;
begin
  // Create 'dcov_execute.bat'
  DCovUnitsText := TStringList.Create;
  DCovUnitsText.Sorted := True;
  DCovUnitsText.Duplicates := dupIgnore;

  DCovPathsText := TStringList.Create;
  DCovPathsText.Sorted := True;
  DCovPathsText.Duplicates := dupIgnore;

  // Get Checked unit list
  CheckedUnitList := TStringList.Create;
  ProjectSettings.ProgramSourceFiles.GetCheckedItemsList(CheckedUnitList);

  for UnitFilename in CheckedUnitList do
  begin
    // Add Unit name
    DCovUnitsText.Add(ChangeFileExt(ExtractFileName(UnitFilename), ''));
    // Add unit path
    DCovPathsText.Add(ProjectSettings.ProgramSourcePath + ExtractFilePath(UnitFilename));
  end;
  // Save
  DCovUnitsText.SaveToFile(ProjectSettings.ScriptsPath + 'dcov_units.lst');
  DCovPathsText.SaveToFile(ProjectSettings.ScriptsPath + 'dcov_paths.lst');
  // Free
  FreeAndNil(CheckedUnitList);
  FreeAndNil(DCovUnitsText);
  FreeAndNil(DCovPathsText);
end;

constructor TApplicationController.Create;
begin
  FProjectSettings := TProjectSettings.Create;
  ReadExeVersion();
end;

destructor TApplicationController.Destroy;
begin
  FreeAndNil(FProjectSettings);
  inherited;
end;

procedure TApplicationController.BuildSourceList(const ASourcePath : TFilename);
var
  SourceFileList : TStringList;
  MyString : string;
begin
  ProjectSettings.ProgramSourcePath := ASourcePath + '\';

  SourceFileList := TStringList.Create;
  FBuildFileList(ASourcePath + '\', SourceFileList);
  for MyString in SourceFileList do
  begin
    ProjectSettings.ProgramSourceFiles.AddFile(MyString);
    if(assigned(FOnNewSourceFile)) then FOnNewSourceFile(self, MyString);
  end;
  FreeAndNil(SourceFileList);
end;

procedure TApplicationController.ReadExeVersion;
var
  AppVersionInfo : TJvVersionInfo;
begin
  // Get version info
  AppVersionInfo := TJvVersionInfo.Create(Application.ExeName);
  FTitle := 'DelphiCodeCoverageWizard' + ' v' + AppVersionInfo.FileVersion;
  FreeAndNil(AppVersionInfo);
end;

initialization
  ApplicationController := TApplicationController.Create;

finalization
  FreeAndNil(ApplicationController);

end.
