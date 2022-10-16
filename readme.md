# DelphiCodeCoverageWizard #

## Introduction ##
**DelphiCodeCoverageWizard** is a simple wizard to setup and build scripts for [DelphiCodeCoverage](http://code.google.com/p/delphi-code-coverage) - a simple Code Coverage command-line tool for **Delphi**.

## Preconditions ##
  * A Delphi project executable (.exe)
  * A detailed mapping file for this project (.map).
_Note : The wizard has it own copy of DelphiCodeCoverage.exe_

## What help does it provide ##
DelphiCodeCoverageWizard will generate the command-line and additional files to run the coverage for this project.

You can also choose which unit to cover.

## Usage ##
Download the application.
Run it and follow the wizard !

## Output ##
### Script ###
A batch file (.bat) is created for a easier one-click coverage execution.

Two listing files (.lst) containing units list and units folder list will be created.

### Coverage output ###
The coverage report is from DelphiCodeCoverage. For further information, see the project page.

## Credit ##
A really big thanks to [Christer Fahlgren](http://christerblog.wordpress.com/) for his delphi-code-coverage release.

Find more here : https://sourceforge.net/projects/delphicodecoverage/

## Version history ##

### v0.4 ###
  * Improved error checking on inputs
  * allow direct inputs in most file/path edits

### v0.3 ###
  * Added DelphiCodeCoverage V1.0RC8 new switches for output format

### v0.2 ###
  * Fixed bugs
  * Refactored source code

### v0.1 ###
  * First prototype to validate the features.
  * It works with minimal features.
  * No error check.
  * Ugly code ;)