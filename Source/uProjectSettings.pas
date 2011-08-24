unit uProjectSettings;

interface

uses
  SysUtils, Generics.Collections, Classes;

type

  TProgramSourceFileItem = class
  private
    FFilename: string;
    FSelected: Boolean;
  public
    constructor Create(const AFilename : string);
    property Filename : string read FFilename write FFilename;
    property Selected : Boolean read FSelected write FSelected;
  end;

  TProgramSourceFiles = class
  private
    FBasePath: TFilename;
    FItemList : TObjectList<TProgramSourceFileItem>;
  public
    property BasePath : TFilename read FBasePath write FBasePath;
    constructor Create;
    destructor Destroy; override;
    procedure AddFile(const AItemFilename : TFilename);
    procedure GetCheckedItemsList(const ACheckedList : TStrings);
  end;


  TProjectSettings = class
  private
    FProgramToAnalyze: TFilename;
    FProgramMapping: TFilename;
    FProgramSourceFiles: TProgramSourceFiles;
    FScriptsPath: TFilename;
    FReportPath: TFilename;
    FApplicationPath: TFilename;
    function GetProgramToAnalyze: TFilename;
    function GetProgramMapping: TFilename;
    function GetProgramSourcePath: TFilename;
    procedure SetProgramToAnalyze(const Value: TFilename);
    procedure SetProgramSourcePath(const Value: TFilename);
  public
    property ProgramToAnalyze : TFilename read GetProgramToAnalyze write SetProgramToAnalyze;
    property ProgramMapping : TFilename read GetProgramMapping write FProgramMapping;
    property ProgramSourcePath : TFilename read GetProgramSourcePath write SetProgramSourcePath;
    property ProgramSourceFiles : TProgramSourceFiles read FProgramSourceFiles write FProgramSourceFiles;
    property ScriptsPath : TFilename read FScriptsPath write FScriptsPath;
    property ReportPath : TFilename read FReportPath write FReportPath;
    property ApplicationPath : TFilename read FApplicationPath;
    constructor Create(const AApplicationPath : TFilename); virtual;
    destructor Destroy; override;
  end;

implementation

uses
  JvCheckListBox;

{ TProjectSettings }

constructor TProjectSettings.Create(const AApplicationPath : TFilename);
begin
  FApplicationPath := AApplicationPath;
  FProgramSourceFiles := TProgramSourceFiles.Create;
end;

destructor TProjectSettings.Destroy;
begin
  FreeAndNil(FProgramSourceFiles);
  inherited;
end;

function TProjectSettings.GetProgramMapping: TFilename;
begin
  Result := FProgramMapping;
end;

function TProjectSettings.GetProgramSourcePath: TFilename;
begin
  Result := FProgramSourceFiles.FBasePath;
end;

function TProjectSettings.GetProgramToAnalyze: TFilename;
begin
  Result := FProgramToAnalyze;
end;

procedure TProjectSettings.SetProgramSourcePath(const Value: TFilename);
begin
  FProgramSourceFiles.FBasePath := Value;
end;

procedure TProjectSettings.SetProgramToAnalyze(const Value: TFilename);
var
  PossibleMappingFilename : TFilename;
begin
  FProgramToAnalyze := Value;
  // test EXE file exists
  if(FileExists(Value)) then
  begin
    PossibleMappingFilename := ChangeFileExt(Value, '.map');
    if(FileExists(PossibleMappingFilename)) then
     FProgramMapping := PossibleMappingFilename;
  end;
end;

{ TProgramSourceFiles }

procedure TProgramSourceFiles.AddFile(const AItemFilename: TFilename);
var
  NewItem : TProgramSourceFileItem;
  NewItemRelativePath : TFilename;
begin
  NewItemRelativePath := ExtractRelativePath(FBasePath, AItemFilename);
  NewItem := TProgramSourceFileItem.Create(NewItemRelativePath);
  FItemList.Add(NewItem);
end;

constructor TProgramSourceFiles.Create;
begin
  inherited;
  FItemList := TObjectList<TProgramSourceFileItem>.Create(True);
end;

destructor TProgramSourceFiles.Destroy;
begin
  FreeAndNil(FItemList);
end;

procedure TProgramSourceFiles.GetCheckedItemsList(const ACheckedList: TStrings);
var
  SourceFileItem: TProgramSourceFileItem;
begin
  ACheckedList.Clear;
  ACheckedList.BeginUpdate;
  for SourceFileItem in FItemList do
  begin
    if(SourceFileItem.Selected) then
     ACheckedList.Add(SourceFileItem.Filename);
  end;
  ACheckedList.EndUpdate;
end;

{ TProgramSourceFileItem }

constructor TProgramSourceFileItem.Create(const AFilename: string);
begin
  FFilename := AFilename;
  FSelected := True;
end;

end.
