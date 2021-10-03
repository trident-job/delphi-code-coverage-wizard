unit fWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvWizard, JvWizardRouteMapNodes, JvExControls, StdCtrls, Mask,
  JvExMask, JvToolEdit, CheckLst, JvExCheckLst, JvCheckListBox, JvLabel,
  Buttons, JvExButtons, JvBitBtn, JvExStdCtrls, JvCheckBox, pngimage, ExtCtrls,
  JvExExtCtrls, JvImage, JvGroupBox, JvMemo, JvRadioGroup;

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
    cbMakeRelativeToScriptPath: TJvCheckBox;
    labelScriptPathReminder: TJvLabel;
    editScriptOutput: TJvDirectoryEdit;
    editCoverageReport: TJvDirectoryEdit;
    btnRunCoverage: TJvBitBtn;
    imageWelcome: TJvImage;
    JvGroupBox1: TJvGroupBox;
    cbOutputFormat_EMMA: TJvCheckBox;
    cbOutputFormat_META: TJvCheckBox;
    cbOutputFormat_XML: TJvCheckBox;
    cbOutputFormat_HTML: TJvCheckBox;
    memoPreview: TJvMemo;
    JvLabel7: TJvLabel;
    JvLabel8: TJvLabel;
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
    procedure cbOutputFormat_EMMAClick(Sender: TObject);
    procedure JvWizardSettingsPageNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure cbMakeRelativeToScriptPathClick(Sender: TObject);
  private
    { Private declarations }
    procedure NewSourceFile(Sender: TObject; const AFilename : string);
    function FGetRelativePath(const APath: string): string;
  public
    { Public declarations }
  end;

var
  WizardForm: TWizardForm;

implementation

{$R *.dfm}

uses
  JclFileUtils, ShellApi, System.UITypes,
  uApplicationController, uProjectSettings,
  uManageToolsMenu;


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
    labelScriptPathReminder.Caption := editScriptOutput.Directory;

    // Save OutputFormat settings
    ApplicationController.ProjectSettings.OutputFormat := [];
    // EMMA
    if(cbOutputFormat_EMMA.Checked) then ApplicationController.ProjectSettings.OutputFormat :=
     ApplicationController.ProjectSettings.OutputFormat + [ofEMMA];
    // META
    if(cbOutputFormat_META.Checked) then ApplicationController.ProjectSettings.OutputFormat :=
     ApplicationController.ProjectSettings.OutputFormat + [ofMETA];
    // XML
    if(cbOutputFormat_XML.Checked) then ApplicationController.ProjectSettings.OutputFormat :=
     ApplicationController.ProjectSettings.OutputFormat + [ofXML];
    // HTML
    if(cbOutputFormat_HTML.Checked) then ApplicationController.ProjectSettings.OutputFormat :=
     ApplicationController.ProjectSettings.OutputFormat + [ofHTML];
  end;
end;

procedure TWizardForm.JvWizardSettingsPageNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  if(Sender = JvWizardSettingsPage) then
  begin
    ApplicationController.ProjectSettings.RelativeToScriptPath := cbMakeRelativeToScriptPath.Checked;
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

procedure TWizardForm.cbMakeRelativeToScriptPathClick(Sender: TObject);
begin
  if(cbMakeRelativeToScriptPath.Checked) then
  begin
    memoPreview.Lines.Add('DelphiCoverage.exe: [' + FGetRelativePath(ApplicationController.ProjectSettings.ApplicationPath) + ']');
    memoPreview.Lines.Add('ProgramToAnalyze: [' + FGetRelativePath(ApplicationController.ProjectSettings.ProgramToAnalyze) + ']');
    memoPreview.Lines.Add('ProgramMapping: [' + FGetRelativePath(ApplicationController.ProjectSettings.ProgramMapping) + ']');
    memoPreview.Lines.Add('ProgramSourcePath: [' + FGetRelativePath(ApplicationController.ProjectSettings.ProgramSourcePath) + ']');
    memoPreview.Lines.Add('ReportPath: [' + FGetRelativePath(ApplicationController.ProjectSettings.ReportPath) + ']');
  end
  else memoPreview.Clear;
end;

procedure TWizardForm.cbOutputFormat_EMMAClick(Sender: TObject);
begin
  if(not cbOutputFormat_EMMA.Checked) then cbOutputFormat_META.Checked := False;
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
var
  ToolsManager : TToolsMenuManager;
begin
  // Manage IDE "Tools" menu integration if applicable
  ToolsManager := TToolsMenuManager.Create;
  try
    ToolsManager.CheckAndSetIDEToolsEntry(self);
  finally
    ToolsManager.Free;
  end;

  Caption := ApplicationController.Title;
end;

procedure TWizardForm.imageWelcomeDblClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://code.google.com/p/delphi-code-coverage-wizard',nil,nil, SW_SHOWNORMAL) ;
end;

function TWizardForm.FGetRelativePath(const APath: string): string;
begin
  // Extract path relative to scripts relative
  Result := ExtractRelativepath(ApplicationController.ProjectSettings.ScriptsPath , APath)
end;

end.
