{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ProcSettingsSCSFrame;

{$INCLUDE 'Source\DART_defs.inc'}

interface

uses
  {$IFNDEF FPC}Windows,{$ENDIF} SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Spin, Menus,
  DART_ProcessingSettings;

type
  TSettingsHintEvent = procedure(Sender: TObject; HintTag: Integer) of object;

type
  TfrmProcSettingsSCS = class(TFrame)
    pnlBackground: TPanel;
    gbEntries: TGroupBox;
    cbIgnoreCRC32: TCheckBox;
    cbIgnoreCompressionFlag: TCheckBox;
    cbIgnoreDictID: TCheckBox;
    gbPathResolve: TGroupBox;
    cbAssumeCityHash: TCheckBox;
    cbUsePredefinedPaths: TCheckBox;
    cbExtractUnresolvedEntries: TCheckBox;
    lblCustomPaths: TLabel;
    meCustomPaths: TMemo;
    lblHelpFiles: TLabel;
    pmHelpFiles: TPopupMenu;
    miHelpFiles_Browse: TMenuItem;
    diaHelpFilesOpen: TOpenDialog;
    btnBrowseHelpFiles: TButton;    
    meHelpFiles: TMemo;
    miHelpFiles_N1: TMenuItem;
    miHelpFiles_ETS2: TMenuItem;
    miHelpFiles_ATS: TMenuItem;
    gbContentParsing: TGroupBox;
    cbParseContent: TCheckBox;
    cbParseEverything: TCheckBox;
    cbParseHelpFiles: TCheckBox;
    cbParseHelpFilesEverything: TCheckBox;
    cbLimitedCharSet: TCheckBox;
    seBinaryThreshold: TSpinEdit;
    lblBinaryThreshold: TLabel;
    gbBruteForce: TGroupBox;
    cbAllowBruteForce: TCheckBox;
    cbMultiSearch: TCheckBox;
    cbMultithread: TCheckBox;
    cbPrintableASCII: TCheckBox;
    cbLimitedAlphabet: TCheckBox;
    lblLengthLimit: TLabel;
    seLengthLimit: TSpinEdit;
    procedure btnBrowseHelpFilesClick(Sender: TObject);
    procedure miHelpFiles_BrowseClick(Sender: TObject);
  private
    fFileProcessingSettings:  TFileProcessingSettings;
    fProcessingSettings:      TSCS_Settings;
    fLoading:                 Boolean;
    fGameInstallDirs:         array of String;
    fOnSettingsHint:          TSettingsHintEvent;
  protected
    procedure GetInstalledGames;
  public
    procedure Initialize;
    procedure SettingsToFrame;
    procedure FrameToSettings;
    procedure ShowProcessingSettings(FileProcessingSettings: TFileProcessingSettings);
    Function RetrieveProcessingSettings: TSCS_Settings;
  published
    procedure CheckBoxClick(Sender: TObject);
    procedure SettingsMouseMove(Sender: TObject; {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure GroupBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure LoadGameFiles(Sender: TObject);
    property OnSettingsHint: TSettingsHintEvent read fOnSettingsHint write fOnSettingsHint;
  end;

implementation

{$IFDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}  

uses
  Registry
{$IFDEF FPC_NonUnicode}
  , LazUTF8
  {$IFDEF FPC_NonUnicode_NoUTF8RTL}
  , LazFileUtils
  {$ENDIF}
{$ENDIF};

//==============================================================================

procedure TfrmProcSettingsSCS.GetInstalledGames;
type
  TKnownGameItem = record
    RegistryRoot: HKEY;
    RegistryKey:  String;
    ValueName:    String;
  end;
const
{
   Note steam installations are not included.
   If anyone knows a reliable way of how to obtain where individual games are
   installed by steam, please let me know.
}
  KnownGamesInfoArray: array[0..1] of TKnownGameItem = (
    (RegistryRoot: HKEY_LOCAL_MACHINE;
     RegistryKey:  '\SOFTWARE\SCS Software\Euro Truck Simulator 2';
     ValueName:    'InstallDir'),
    (RegistryRoot: HKEY_LOCAL_MACHINE;
     RegistryKey:  '\SOFTWARE\SCS Software\American Truck Simulator';
     ValueName:    'InstallDir'));
var
  Reg:  TRegistry;
  i:    Integer;
begin
SetLength(fGameInstallDirs,Length(KnownGamesInfoArray));
Reg := TRegistry.Create;
try
  For i := Low(KnownGamesInfoArray) to High(KnownGamesInfoArray) do
    begin
      Reg.RootKey := KnownGamesInfoArray[i].RegistryRoot;
      If Reg.KeyExists(KnownGamesInfoArray[i].RegistryKey) then
        If Reg.OpenKeyReadOnly(KnownGamesInfoArray[i].RegistryKey) then
          begin
            If Reg.ValueExists(KnownGamesInfoArray[i].ValueName) then
              fGameInstallDirs[i] := Reg.ReadString(KnownGamesInfoArray[i].ValueName);
            Reg.CloseKey;
          end;
    end;
finally
  Reg.Free;
end;
end;

//==============================================================================

procedure TfrmProcSettingsSCS.Initialize;
var
  i:  Integer;

  Function GetGameFilesMenuItem(IDX: Integer): TMenuItem;
  begin
    case IDX of
      0:  Result := miHelpFiles_ETS2;
      1:  Result := miHelpFiles_ATS;
    else
      Result := nil;
    end;
  end;

begin
{$IFDEF FPC_NonUnicode}
diaHelpFilesOpen.InitialDir := ExtractFileDir(SysToUTF8(ParamStr(0)));
{$ELSE}
diaHelpFilesOpen.InitialDir := ExtractFileDir(ParamStr(0));
{$ENDIF}
GetInstalledGames;
For i := Low(fGameInstallDirs) to High(fGameInstallDirs) do
  If fGameInstallDirs[i] <> '' then
    begin
      with GetGameFilesMenuItem(i) do
        begin
          Visible := True;
          Tag := i;
        end;
      miHelpFiles_N1.Visible := True;
    end;
end;

//------------------------------------------------------------------------------

procedure TfrmProcSettingsSCS.SettingsToFrame;
var
  i:  Integer;
begin
// entry
cbIgnoreCRC32.Checked := fProcessingSettings.Entry.IgnoreCRC32;
cbIgnoreCompressionFlag.Checked := fProcessingSettings.Entry.IgnoreCompressionFlag;
cbIgnoreDictID.Checked := fProcessingSettings.Entry.IgnoreDictionaryID;
// path resolve
cbAssumeCityHash.Checked := fProcessingSettings.PathResolve.AssumeCityHash;
cbUsePredefinedPaths.Checked := fProcessingSettings.PathResolve.UsePredefinedPaths;
cbExtractUnresolvedEntries.Checked := fProcessingSettings.PathResolve.ExtractedUnresolvedEntries;
// custom paths
meCustomPaths.Lines.BeginUpdate;
try
  meCustomPaths.Clear;
  For i := Low(fProcessingSettings.PathResolve.CustomPaths) to High(fProcessingSettings.PathResolve.CustomPaths) do
    meCustomPaths.Lines.Add(fProcessingSettings.PathResolve.CustomPaths[i]);
finally
  meCustomPaths.Lines.EndUpdate;
end;
// help files
meHelpFiles.Lines.BeginUpdate;
try
  meHelpFiles.Clear;
  For i := Low(fProcessingSettings.PathResolve.HelpFiles) to High(fProcessingSettings.PathResolve.HelpFiles) do
    meHelpFiles.Lines.Add(fProcessingSettings.PathResolve.HelpFiles[i]);
finally
  meHelpFiles.Lines.EndUpdate;
end;
// content parsing
cbParseContent.Checked := fProcessingSettings.PathResolve.ParseContent;
cbParseEverything.Checked := fProcessingSettings.PathResolve.ParseEverything;
cbParseHelpFiles.Checked := fProcessingSettings.PathResolve.ParseHelpFiles;
cbParseHelpFilesEverything.Checked := fProcessingSettings.PathResolve.ParseHelpFilesEverything;
cbLimitedCharSet.Checked := fProcessingSettings.PathResolve.ParseLimitedCharacterSet;
seBinaryThreshold.Value := fProcessingSettings.PathResolve.ParseBinaryThreshold;
// brute force
cbAllowBruteForce.Checked := fProcessingSettings.PathResolve.BruteForceResolve;
cbMultiSearch.Checked := fProcessingSettings.PathResolve.BruteForceMultiSearch;
cbMultithread.Checked := fProcessingSettings.PathResolve.BruteForceMultithread;
cbPrintableASCII.Checked := fProcessingSettings.PathResolve.BruteForcePrintableASCII;
cbLimitedAlphabet.Checked := fProcessingSettings.PathResolve.BruteForceLimitedAlphabet;
seLengthLimit.Value := fProcessingSettings.PathResolve.BruteForceLengthLimit;
end;
 
//------------------------------------------------------------------------------

procedure TfrmProcSettingsSCS.FrameToSettings;
var
  i,Count:  Integer;
begin
// entry
fProcessingSettings.Entry.IgnoreCRC32 := cbIgnoreCRC32.Checked;
fProcessingSettings.Entry.IgnoreCompressionFlag := cbIgnoreCompressionFlag.Checked;
fProcessingSettings.Entry.IgnoreDictionaryID := cbIgnoreDictID.Checked;
// path resolve
fProcessingSettings.PathResolve.AssumeCityHash := cbAssumeCityHash.Checked;
fProcessingSettings.PathResolve.UsePredefinedPaths := cbUsePredefinedPaths.Checked;
fProcessingSettings.PathResolve.ExtractedUnresolvedEntries := cbExtractUnresolvedEntries.Checked;
// custom paths
Count := 0;
SetLength(fProcessingSettings.PathResolve.CustomPaths,meCustomPaths.Lines.Count);
For i := 0 to Pred(meCustomPaths.Lines.Count) do
  If Length(meCustomPaths.Lines[i]) > 0 then
    begin
      fProcessingSettings.PathResolve.CustomPaths[Count] := meCustomPaths.Lines[i];
      Inc(Count);
    end;
SetLength(fProcessingSettings.PathResolve.CustomPaths,Count);
// help files
Count := 0;
SetLength(fProcessingSettings.PathResolve.HelpFiles,meHelpFiles.Lines.Count);
For i := 0 to Pred(meHelpFiles.Lines.Count) do
  If Length(meHelpFiles.Lines[i]) > 0 then
    begin
      fProcessingSettings.PathResolve.HelpFiles[Count] := meHelpFiles.Lines[i];
      Inc(Count);
    end;
SetLength(fProcessingSettings.PathResolve.HelpFiles,Count);
// content parsing
fProcessingSettings.PathResolve.ParseContent := cbParseContent.Checked;
fProcessingSettings.PathResolve.ParseEverything := cbParseEverything.Checked;
fProcessingSettings.PathResolve.ParseHelpFiles := cbParseHelpFiles.Checked;
fProcessingSettings.PathResolve.ParseHelpFilesEverything := cbParseHelpFilesEverything.Checked;
fProcessingSettings.PathResolve.ParseLimitedCharacterSet := cbLimitedCharSet.Checked;
fProcessingSettings.PathResolve.ParseBinaryThreshold := seBinaryThreshold.Value;
// brute force
fProcessingSettings.PathResolve.BruteForceResolve := cbAllowBruteForce.Checked;
fProcessingSettings.PathResolve.BruteForceMultiSearch := cbMultiSearch.Checked;
fProcessingSettings.PathResolve.BruteForceMultithread := cbMultithread.Checked;
fProcessingSettings.PathResolve.BruteForcePrintableASCII := cbPrintableASCII.Checked;
fProcessingSettings.PathResolve.BruteForceLimitedAlphabet := cbLimitedAlphabet.Checked;
fProcessingSettings.PathResolve.BruteForceLengthLimit := seLengthLimit.Value;
end;
 
//------------------------------------------------------------------------------

procedure TfrmProcSettingsSCS.ShowProcessingSettings(FileProcessingSettings: TFileProcessingSettings);
begin
fFileProcessingSettings := FileProcessingSettings;
fProcessingSettings := FileProcessingSettings.SCSSettings;
fLoading := True;
try
  SettingsToFrame;
finally
  fLoading := False;
end;
// enable/disable
cbParseContent.OnClick(cbParseContent);
cbParseHelpFiles.OnClick(cbParseHelpFiles);
cbAllowBruteForce.OnClick(cbAllowBruteForce);
end;
 
//------------------------------------------------------------------------------

Function TfrmProcSettingsSCS.RetrieveProcessingSettings: TSCS_Settings;
begin
FrameToSettings;
Result := fProcessingSettings;
end;

//==============================================================================

procedure TfrmProcSettingsSCS.CheckBoxClick(Sender: TObject);
begin
If (Sender is TCheckBox) and not fLoading then
  case TCheckBox(Sender).Tag of
    161:  begin // cbParseContent
            cbParseEverything.Enabled := TCheckBox(Sender).Checked;
            cbLimitedCharSet.Enabled := TCheckBox(Sender).Checked or cbParseHelpFiles.Checked;
            lblBinaryThreshold.Enabled := cbLimitedCharSet.Enabled;
            seBinaryThreshold.Enabled := cbLimitedCharSet.Enabled;
          end;
    163:  begin // cbParseHelpFiles
            cbParseHelpFilesEverything.Enabled := TCheckBox(Sender).Checked;
            cbLimitedCharSet.Enabled := TCheckBox(Sender).Checked or cbParseContent.Checked;
            lblBinaryThreshold.Enabled := cbLimitedCharSet.Enabled;
            seBinaryThreshold.Enabled := cbLimitedCharSet.Enabled;
          end;      
    171:  begin // cbBruteForceResolve
            cbMultiSearch.Enabled := TCheckBox(Sender).Checked;
            cbMultithread.Enabled := TCheckBox(Sender).Checked;
            cbPrintableASCII.Enabled := TCheckBox(Sender).Checked;
            cbLimitedAlphabet.Enabled := TCheckBox(Sender).Checked;
            lblLengthLimit.Enabled := TCheckBox(Sender).Checked;
            seLengthLimit.Enabled := TCheckBox(Sender).Checked;
          end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProcSettingsSCS.SettingsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
If (Sender is TControl) and Assigned(fOnSettingsHint) then
  fOnSettingsHint(Self,TControl(Sender).Tag);
end;

//------------------------------------------------------------------------------

procedure TfrmProcSettingsSCS.GroupBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Control:  TControl;
begin
If Sender is TGroupBox then
  begin
    Control := TGroupBox(Sender).ControlAtPos(Point(X,Y),True,True);
    If Assigned(Control) and ((Control is TCheckBox) or (Control is TSpinEdit)) then
      SettingsMouseMove(Control,Shift,X,Y);
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProcSettingsSCS.btnBrowseHelpFilesClick(Sender: TObject);
var
  PopupPoint: TPoint;
begin
PopupPoint := gbPathResolve.ClientToScreen(Point(btnBrowseHelpFiles.Left,btnBrowseHelpFiles.BoundsRect.Bottom));
pmHelpFiles.Popup(PopupPoint.X,PopupPoint.Y);
end;

//------------------------------------------------------------------------------

procedure TfrmProcSettingsSCS.miHelpFiles_BrowseClick(Sender: TObject);
var
  i:  Integer;
begin
If diaHelpFilesOpen.Execute then
  begin
    meHelpFiles.Lines.BeginUpdate;
    try
      For i := 0 to Pred(diaHelpFilesOpen.Files.Count) do
        If not AnsiSameText(diaHelpFilesOpen.Files[i],fFileProcessingSettings.Common.FilePath) and
          (meHelpFiles.Lines.IndexOf(diaHelpFilesOpen.Files[i]) < 0) then
          meHelpFiles.Lines.Add(diaHelpFilesOpen.Files[i]);
    finally
      meHelpFiles.Lines.EndUpdate;
    end
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmProcSettingsSCS.LoadGameFiles(Sender: TObject);
var
  FileList: TStringList;
  i:        Integer;

  procedure GetListing(const Path: String; Files: TStringList);
  var
    SearchRec: TSearchRec;
  begin
  {$IFDEF FPC_NonUnicode_NoUTF8RTL}
    If FindFirstUTF8(IncludeTrailingPathDelimiter(Path) + '*.scs',faAnyFile,SearchRec) = 0 then
    try
      repeat
        Files.Add(IncludeTrailingPathDelimiter(Path) + SearchRec.Name);
      until FindNextUTF8(SearchRec) <> 0;
    finally
      FindCloseUTF8(SearchRec);
    end;
  {$ELSE}
    If FindFirst(IncludeTrailingPathDelimiter(Path) + '*.scs',faAnyFile,SearchRec) = 0 then
    try
      repeat
        Files.Add(IncludeTrailingPathDelimiter(Path) + SearchRec.Name);
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  {$ENDIF}
  end;

begin
If Sender is TMenuItem then
  begin
    FileList := TStringList.Create;
    try
      GetListing(fGameInstallDirs[TMenuItem(Sender).Tag],FileList);
      meHelpFiles.Lines.BeginUpdate;
      try
        For i := 0 to Pred(FileList.Count) do
          If meHelpFiles.Lines.IndexOf(FileList[i]) < 0 then
            meHelpFiles.Lines.Add(FileList[i]);
      finally
        meHelpFiles.Lines.EndUpdate;
      end;
    finally
      FileList.Free;
    end;
  end;
end;

end.
