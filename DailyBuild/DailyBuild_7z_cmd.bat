rem Here is the command to compress the dailybuild package
"C:\Program Files\7-Zip\7z.exe" a -tzip delphi-code-coverage-wizard.zip @../DailyBuild_FileList.txt -xr!*.svn -scsWIN

