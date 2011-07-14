unit fWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvWizard, JvWizardRouteMapNodes, JvExControls, StdCtrls, Mask,
  JvExMask, JvToolEdit, CheckLst, JvExCheckLst, JvCheckListBox, JvLabel,
  Buttons, JvExButtons, JvBitBtn, JvExStdCtrls, JvCheckBox, pngimage, ExtCtrls,
  JvExExtCtrls, JvImage;

type
  TWizardForm = class(TForm)
    JvWizard1: TJvWizard;
    JvWizardWelcomePage: TJvWizardWelcomePage;
    JvWizardSourcePage: TJvWizardInteriorPage;
    JvWizardExecutablePage: TJvWizardInteriorPage;
    JvWizardRouteMapNodes1: TJvWizardRouteMapNodes;
    JvWizardSettingsPage: TJvWizardInteriorPage;
    JvWizardGeneratePage: TJvWizardInteriorPage;
    JvDirectoryEdit_DelphiSourceFiles: TJvDirectoryEdit;
    JvLabel1: TJvLabel;
    lbSelectedFilesForCoverage: TJvCheckListBox;
    JvLabel2: TJvLabel;
    editProgramToAnalyze: TJvFilenameEdit;
    JvLabel3: TJvLabel;
    JvLabel4: TJvLabel;
    editProgramMapping: TJvFilenameEdit;
    btnGenerate: TJvBitBtn;
    JvWizardOutputPage: TJvWizardInteriorPage;
    JvLabel5: TJvLabel;
    JvLabel6: TJvLabel;
    cbMakeFoldersRelativeToExe: TJvCheckBox;
    labelExecutablePathReminder: TJvLabel;
    editScriptOutput: TJvDirectoryEdit;
    editCoverageReport: TJvDirectoryEdit;
    btnRunCoverage: TJvBitBtn;
    imageWelcome: TJvImage;
    procedure JvDirectoryEdit_DelphiSourceFilesAfterDialog(Sender: TObject; var AName: string;
      var AAction: Boolean);
    procedure editProgramToAnalyzeAfterDialog(Sender: TObject; var AName: string;
      var AAction: Boolean);
    procedure btnGenerateClick(Sender: TObject);
    procedure JvWizardExecutablePageNextButtonClick(Sender: TObject;
      var Stop: Boolean);
    procedure editScriptOutputAfterDialog(Sender: TObject; var AName: string;
      var AAction: Boolean);
    procedure btnRunCoverageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure JvWizardOutputPageNextButtonClick(Sender: TObject;
      var Stop: Boolean);
    procedure JvWizard1HelpButtonClick(Sender: TObject);
    procedure imageWelcomeDblClick(Sender: TObject);
    procedure JvWizard1CancelButtonClick(Sender: TObject);
  private
    { Private declarations }
    SourceFileList : TStrings;
    procedure GenerateDCovExecuteFile(const AScriptsFolder, AReportFolder : string);
    procedure GenerateDCovUnitsAndPathFiles(const AScriptsFolder : string);
  public
    { Public declarations }
  end;

var
  WizardForm: TWizardForm;

implementation

{$R *.dfm}

uses
  JclFileUtils, ShellApi;


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
procedure BuildFileList(const ARootFolder: string; AFileList : TStrings);
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

procedure TWizardForm.JvDirectoryEdit_DelphiSourceFilesAfterDialog(Sender: TObject;
  var AName: string; var AAction: Boolean);
var
  MyString : string;
begin
  // Exit is user cancel dialog
  if(AAction = False) then exit;
  // If list is not empty, ask confirmation to clear the list
  if(lbSelectedFilesForCoverage.Count <> 0) then
  begin
    if(MessageDlg('File list selected for coverage is not empty.'+#13+#10
    +'Changing delphi source file directory will clear the list.'
    +#13+#10+'Press OK to continue.', mtWarning, [mbOK, mbCancel], 0) = mrCancel) then exit
    else lbSelectedFilesForCoverage.Clear;
  end;
  // Fill the list with '*.pas' files found
  SourceFileList := TStringList.Create;
  BuildFileList(AName + '\', SourceFileList);
  for MyString in SourceFileList do
  begin
    lbSelectedFilesForCoverage.AddItem(ExtractRelativePath(AName + '\', MyString), nil);
    lbSelectedFilesForCoverage.CheckAll;
  end;
end;

procedure TWizardForm.JvWizard1CancelButtonClick(Sender: TObject);
begin
  // Ask to close application
  if(MessageDlg('Are you sure you want to quit the application ?', mtWarning, [mbOK, mbCancel], 0) = mrOk) then
    Close;
end;

procedure TWizardForm.JvWizard1HelpButtonClick(Sender: TObject);
begin
  MessageDlg('DelphiCodeCoverage by TridenT.', mtInformation, [mbOK], 0);
end;

procedure TWizardForm.JvWizardExecutablePageNextButtonClick(Sender: TObject;
  var Stop: Boolean);
begin
  if(Sender = JvWizardExecutablePage) then
  begin
    // Propagate Executable folder to source folder
    JvDirectoryEdit_DelphiSourceFiles.InitialDir := ExtractFilePath(editProgramToAnalyze.FileName);
    //
    editScriptOutput.InitialDir := ExtractFilePath(editProgramToAnalyze.FileName);
  end;

end;

procedure TWizardForm.JvWizardOutputPageNextButtonClick(Sender: TObject;
  var Stop: Boolean);
begin
  if(Sender = JvWizardOutputPage) then
  begin
    // Propagate Scripts folder to path reminder
    labelExecutablePathReminder.Caption := ExtractFilePath(editScriptOutput.Directory);
  end;
end;

procedure TWizardForm.btnGenerateClick(Sender: TObject);
var
  ScriptsPath : string;
  ReportPath : string;
begin
  ScriptsPath := editScriptOutput.Directory + '\';
  ReportPath := editCoverageReport.Directory + '\';
  // Generate
  GenerateDCovExecuteFile(ScriptsPath, ReportPath);
  GenerateDCovUnitsAndPathFiles(ScriptsPath);
  MessageDlg(Format('Scripts generated in [%s] folder.',[ScriptsPath]), mtInformation, [mbOK], 0);
end;

procedure TWizardForm.btnRunCoverageClick(Sender: TObject);
var
  ScriptFilename : string;
begin
  // Execute
  ScriptFilename := editScriptOutput.Directory + '\' + 'dcov_execute.bat';
  ShellExecute(Handle, 'OPEN', PChar('explorer.exe')
   , PChar('/select, "' + ScriptFilename + '"'), nil, SW_NORMAL) ;
end;

procedure TWizardForm.editProgramToAnalyzeAfterDialog(Sender: TObject;
  var AName: string; var AAction: Boolean);
var
  PossibleMappingFilename : string;
begin
  // Exit is user cancel dialog
  if(AAction = False) then exit;
  // test EXE file exists
  if(FileExists(AName)) then
  begin
    PossibleMappingFilename := ChangeFileExt(AName, '.map');
    if(FileExists(PossibleMappingFilename)) then
     editProgramMapping.FileName := PossibleMappingFilename;
  end;
end;

procedure TWizardForm.editScriptOutputAfterDialog(Sender: TObject;
  var AName: string; var AAction: Boolean);
begin
  // Exit is user cancel dialog
  if(AAction = False) then exit;
  // Propagate Script output to Report
  editCoverageReport.Directory := AName + '\report';
  editCoverageReport.InitialDir := AName;
end;

procedure TWizardForm.FormShow(Sender: TObject);
begin
  //
  Caption := Application.Title + ' v0.1';
end;

procedure TWizardForm.GenerateDCovExecuteFile(const AScriptsFolder, AReportFolder : string);
const
  DCOV_EXECUTE_FORMAT = 'CodeCoverage.exe -e %s -m %s -uf dcov_units.lst -spf dcov_paths.lst -od %sreport -lt';
var
  DCovExecuteText : TStringList;
begin
  // Create 'dcov_execute.bat'
  DCovExecuteText := TStringList.Create;
  // Fill
  DCovExecuteText.Add(Format(DCOV_EXECUTE_FORMAT, [editProgramToAnalyze.FileName, editProgramMapping.FileName, AReportFolder]));
  // Save
  DCovExecuteText.SaveToFile(AScriptsFolder + 'dcov_execute.bat');
  FreeAndNil(DCovExecuteText);
end;

procedure TWizardForm.GenerateDCovUnitsAndPathFiles(const AScriptsFolder : string);
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
  CheckedUnitList := lbSelectedFilesForCoverage.GetChecked;
  for UnitFilename in CheckedUnitList do
  begin
    // Add Unit name
    DCovUnitsText.Add(ChangeFileExt(ExtractFileName(UnitFilename), ''));
    // Add unit path
    DCovPathsText.Add(JvDirectoryEdit_DelphiSourceFiles.Directory + '\' + ExtractFilePath(UnitFilename));
  end;
  // Save
  DCovUnitsText.SaveToFile(AScriptsFolder + 'dcov_units.lst');
  DCovPathsText.SaveToFile(AScriptsFolder + 'dcov_paths.lst');
  // Free
  FreeAndNil(DCovUnitsText);
  FreeAndNil(DCovPathsText);
end;

procedure TWizardForm.imageWelcomeDblClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://code.google.com/p/delphi-code-coverage-wizard',nil,nil, SW_SHOWNORMAL) ;
end;

end.
