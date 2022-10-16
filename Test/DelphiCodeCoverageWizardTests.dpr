program DelphiCodeCoverageWizardTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  Test_uProjectSettings in 'Test_uProjectSettings.pas',
  uProjectSettings in '..\Source\uProjectSettings.pas',
  XmlTestRunner2 in 'DUnit_addon\XmlTestRunner2.pas';

{R *.RES}

begin
  Application.Initialize;
  if IsConsole then
  {$IFDEF XML_OUTPUT}
    with XmlTestRunner2.RunRegisteredTests do
  {$ELSE}
    with TextTestRunner.RunRegisteredTests do
  {$ENDIF}
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

