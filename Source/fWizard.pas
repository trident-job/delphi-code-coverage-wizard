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
    procedure lbSelectedFilesForCoverageClickCheck(Sender: TObject);
    procedure editCoverageReportAfterDialog(Sender: TObject; var AName: string;
      var AAction: Boolean);
  private
    { Private declarations }
    procedure NewSourceFile(Sender: TObject; const AFilename : string);
  public
    { Public declarations }
  end;

var
  WizardForm: TWizardForm;

implementation

{$R *.dfm}

uses
  JclFileUtils, ShellApi,
  uApplicationController, uProjectSettings;


procedure TWizardForm.JvDirectoryEdit_DelphiSourceFilesAfterDialog(Sender: TObject;
  var AName: string; var AAction: Boolean);
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

  ApplicationController.OnNewSourceFile := NewSourceFile;
  lbSelectedFilesForCoverage.Items.BeginUpdate;
  ApplicationController.BuildSourceList(AName);
  lbSelectedFilesForCoverage.CheckAll;
  lbSelectedFilesForCoverage.Items.EndUpdate();
end;

procedure TWizardForm.JvWizard1CancelButtonClick(Sender: TObject);
begin
  // Ask to close application
  if(MessageDlg('Are you sure you want to quit the application ?', mtWarning, [mbOK, mbCancel], 0) = mrOk) then
    Close;
end;

procedure TWizardForm.JvWizard1HelpButtonClick(Sender: TObject);
begin
  MessageDlg('DelphiCodeCoverageWizard by TridenT.', mtInformation, [mbOK], 0);
end;

procedure TWizardForm.JvWizardExecutablePageNextButtonClick(Sender: TObject;
  var Stop: Boolean);
begin
  if(Sender = JvWizardExecutablePage) then
  begin
    // Propagate Executable folder to source folder
    JvDirectoryEdit_DelphiSourceFiles.InitialDir := ExtractFilePath(ApplicationController.ProjectSettings.ProgramToAnalyze);
    editScriptOutput.InitialDir := ExtractFilePath(ApplicationController.ProjectSettings.ProgramToAnalyze);
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

procedure TWizardForm.lbSelectedFilesForCoverageClickCheck(Sender: TObject);
begin
  MessageDlg(lbSelectedFilesForCoverage.Items[lbSelectedFilesForCoverage.ItemIndex], mtWarning, [mbOK], 0);
end;

procedure TWizardForm.NewSourceFile(Sender: TObject; const AFilename: string);
begin
  lbSelectedFilesForCoverage.AddItem(ExtractRelativePath(ApplicationController.ProjectSettings.ProgramSourcePath, AFilename), nil);
end;

procedure TWizardForm.btnGenerateClick(Sender: TObject);
begin
  ApplicationController.Generate;
  MessageDlg(Format('Scripts generated in [%s] folder.',[ApplicationController.ProjectSettings.ScriptsPath]), mtInformation, [mbOK], 0);
end;

procedure TWizardForm.btnRunCoverageClick(Sender: TObject);
var
  ScriptFilename : string;
begin
  // Execute
  ScriptFilename := ApplicationController.ProjectSettings.ScriptsPath + 'dcov_execute.bat';
  ShellExecute(Handle, 'OPEN', PChar('explorer.exe')
   , PChar('/select, "' + ScriptFilename + '"'), nil, SW_NORMAL) ;
end;

procedure TWizardForm.editCoverageReportAfterDialog(Sender: TObject;
  var AName: string; var AAction: Boolean);
begin
  // Exit if user cancel dialog
  if(AAction = False) then exit;
  ApplicationController.ProjectSettings.ReportPath := AName + '\';
end;

procedure TWizardForm.editProgramToAnalyzeAfterDialog(Sender: TObject;
  var AName: string; var AAction: Boolean);
begin
  // Exit if user cancel dialog
  if(AAction = False) then exit;
  // Assign Program to analyze to settings
  ApplicationController.ProjectSettings.ProgramToAnalyze := AName;
  editProgramMapping.FileName := ApplicationController.ProjectSettings.ProgramMapping;
end;

procedure TWizardForm.editScriptOutputAfterDialog(Sender: TObject;
  var AName: string; var AAction: Boolean);
begin
  // Exit is user cancel dialog
  if(AAction = False) then exit;
  // Propagate Script output to Report
  ApplicationController.ProjectSettings.ScriptsPath := AName + '\';
  editCoverageReport.InitialDir := AName;
end;

procedure TWizardForm.FormShow(Sender: TObject);
begin
  Caption := ApplicationController.Title;
end;

procedure TWizardForm.imageWelcomeDblClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://code.google.com/p/delphi-code-coverage-wizard',nil,nil, SW_SHOWNORMAL) ;
end;

end.
