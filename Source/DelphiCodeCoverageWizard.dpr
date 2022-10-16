program DelphiCodeCoverageWizard;

uses
  Forms,
  fWizard in 'fWizard.pas' {WizardForm},
  uApplicationController in 'uApplicationController.pas',
  uProjectSettings in 'uProjectSettings.pas',
  uScriptsGenerator in 'uScriptsGenerator.pas',
  uManageToolsMenu in 'uManageToolsMenu.pas',
  AddIDETool in 'AddIDEToolsMenu\AddIDETool.pas',
  ConfigurationSelectionForm in 'AddIDEToolsMenu\ConfigurationSelectionForm.pas' {ConfigSelectionForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'DelphiCodeCoverageWizard';
  Application.CreateForm(TWizardForm, WizardForm);
  Application.CreateForm(TConfigSelectionForm, ConfigSelectionForm);
  Application.Run;
end.
