program DelphiCodeCoverageWizard;

uses
  Forms,
  fWizard in 'fWizard.pas' {WizardForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'DelphiCodeCoverageWizard';
  Application.CreateForm(TWizardForm, WizardForm);
  Application.Run;
end.
