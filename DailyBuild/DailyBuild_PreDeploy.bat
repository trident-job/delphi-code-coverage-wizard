rem #Create Dir(s)
md tmp
rem #Compress
cd ..\Exe
"C:\Program Files\7-Zip\7z.exe" a -tzip ..\dailybuild\tmp\delphi-code-coverage-wizard.zip @../DailyBuild/DailyBuild_FileList.txt -xr!*.svn -scsWIN
