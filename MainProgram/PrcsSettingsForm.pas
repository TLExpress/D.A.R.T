{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit PrcsSettingsForm;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Repairer;

type
  TfPrcsSettingsForm = class(TForm)
    diaSaveDialog: TSaveDialog;
    grbGeneral: TGroupBox;
    lblFile: TLabel;
    rbRebuild: TRadioButton;
    rbExtract: TRadioButton;
    vblGeneralHorSplit_File: TBevel;
    lbleData: TLabeledEdit;
    btnBrowse: TButton;
    bvlGeneralhorSplit: TBevel;
    cbIgnoreFileSignature: TCheckBox;
    cbAssumeCompressionMethods: TCheckBox;
    cbInMemoryProcessing: TCheckBox;
    cbIgnoreProcessingErrors: TCheckBox;       
    grdEndOfCentralDirectory: TGroupBox;
    cbIgnoreEndOfCentralDirectory: TCheckBox;
    cbIgnoreDiskSplit: TCheckBox;
    cbIgnoreNumberOfEntries: TCheckBox;
    cbIgnoreCentralDirectoryOffset: TCheckBox;
    cbIgnoreComment: TCheckBox;
    bvlEOCDSplit: TBevel;
    cbLimitSearch: TCheckBox;
    grbCentralDirectoryHeaders: TGroupBox;
    cbCDIgnoreCentralDirectory: TCheckBox;
    cbCDIgnoreSignature: TCheckBox;
    cbCDIgnoreVersions: TCheckBox;
    cbCDClearEncryptionFlags: TCheckBox;
    cbCDIgnoreCompressionMethod: TCheckBox;
    cbCDIgnoreModTime: TCheckBox;
    cbCDIgnoreModDate: TCheckBox;
    cbCDIgnoreCRC32: TCheckBox;
    cbCDIgnoreSizes: TCheckBox;
    cbCDIgnoreInternalFileAttributes: TCheckBox;
    cbCDIgnoreExternalFileAttributes: TCheckBox;
    cbCDIgnoreLocalHeaderOffset: TCheckBox;
    cbCDIgnoreExtraField: TCheckBox;
    cbCDIgnoreFileComment: TCheckBox;
    grbLocalHeaders: TGroupBox;
    cbLHIgnoreLocalHeaders: TCheckBox;
    cbLHIgnoreSignature: TCheckBox;
    cbLHIgnoreVersions: TCheckBox;
    cbLHClearEncryptionFlags: TCheckBox;
    cbLHIgnoreCompressionMethod: TCheckBox;
    cbLHIgnoreModTime: TCheckBox;
    cbLHIgnoreModDate: TCheckBox;
    cbLHIgnoreCRC32: TCheckBox;
    cbLHIgnoreSizes: TCheckBox;
    cbLHIgnoreFileName: TCheckBox;
    cbLHIgnoreExtraField: TCheckBox;
    bvlLHSplit: TBevel;
    cbLHIgnoreDataDescriptor: TCheckBox;
    lblSettingDescription: TLabel;
    meSettingDescription: TMemo;
    btnDefault: TButton;    
    btnAccept: TButton;
    btnClose: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbleDataChange(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
  private
    fFilePath:              String;
    fProcessingSettings:    TProcessingSettings;
    fLoading:               Boolean;
    fAccepted:              Boolean;
    fSettingsDescriptions:  array[0..79] of String;
  protected
    procedure LoadSettingsDescriptions;
  public
    procedure SettingsToForm;
    procedure FormToSettings;
    procedure ShowProcessingSettings(const FilePath: String; var ProcessingSettings: TProcessingSettings);
  published  
    procedure RepairMethodClick(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure SettingsMouseMove(Sender: TObject; {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure GroupBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  end;

var
  fPrcsSettingsForm: TfPrcsSettingsForm;

implementation

{$IFDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}  

uses
  Windows, StrUtils,
{$IFDEF FPC}
  FileUtil;
{$ELSE}
{$WARN UNIT_PLATFORM OFF}
  FileCtrl;
{$WARN UNIT_PLATFORM ON}
{$ENDIF}

{$R '.\Resources\SettDescr.res'}

//==============================================================================

procedure TfPrcsSettingsForm.LoadSettingsDescriptions;
var
  ResourceStream: TResourceStream;
  TempStrList:    TStringList;
  i:              Integer;
  TagIdx:         Integer;
  NextTagIdx:     Integer;
  Tag:            Integer;
  TempStr:        String;

  Function FindNextTag(Start: Integer): Integer;
  begin
    For Result := Start to Pred(TempStrList.Count) do
      If AnsiStartsText('#',TempStrList[Result]) then Exit;
    Result := TempStrList.Count;
  end;

begin
For i := Low(fSettingsDescriptions) to High(fSettingsDescriptions) do
  fSettingsDescriptions[i] := Format('no description (%d)',[i]);
TempStrList := TStringList.Create;
try
  ResourceStream := TResourceStream.Create(hInstance,'SettDescr',RT_RCDATA);
  try
    TempStrList.LoadFromStream(ResourceStream);
  finally
    ResourceStream.Free;
  end;
  // load individual descriptions
  TagIdx := FindNextTag(0);
  while TagIdx < TempStrList.Count do
    begin
      NextTagIdx := FindNextTag(TagIdx + 1);    
      Tag := StrToIntDef(Copy(TempStrList[TagIdx],2,Length(TempStrList[TagIdx])),-1);
      If (Tag >= Low(fSettingsDescriptions)) and (Tag <= High(fSettingsDescriptions)) then
        begin
          TempStr := '';
          For i := Succ(TagIdx) to Pred(NextTagIdx) do
            If i > Succ(TagIdx) then
              TempStr := TempStr + sLineBreak + TempStrList[i]
            else
              TempStr := TempStrList[i];
          fSettingsDescriptions[Tag] := TempStr;  
        end;
      TagIdx := NextTagIdx;  
    end;
finally
  TempStrList.Free;
end;
end;

//==============================================================================

procedure TfPrcsSettingsForm.SettingsToForm;
begin
case fProcessingSettings.RepairMethod of
  rmRebuild:  rbRebuild.Checked := True;
  rmExtract:  rbExtract.Checked := True;
end;
lbleData.Text := fProcessingSettings.RepairData;
cbIgnoreFileSignature.Checked := fProcessingSettings.IgnoreFileSignature;
cbAssumeCompressionMethods.Checked := fProcessingSettings.AssumeCompressionMethods;
cbInMemoryProcessing.Checked := fProcessingSettings.InMemoryProcessing;
cbInMemoryProcessing.Enabled := fProcessingSettings.OtherSettings.InMemoryProcessingAllowed;
cbIgnoreProcessingErrors.Checked := fProcessingSettings.IgnoreProcessingErrors;
//eocd
cbIgnoreEndOfCentralDirectory.Checked := fProcessingSettings.EndOfCentralDirectory.IgnoreEndOfCentralDirectory;
cbIgnoreDiskSplit.Checked := fProcessingSettings.EndOfCentralDirectory.IgnoreDiskSplit;
cbIgnoreNumberOfEntries.Checked := fProcessingSettings.EndOfCentralDirectory.IgnoreNumberOfEntries;
cbIgnoreCentralDirectoryOffset.Checked := fProcessingSettings.EndOfCentralDirectory.IgnoreCentralDirectoryOffset;
cbIgnoreComment.Checked := fProcessingSettings.EndOfCentralDirectory.IgnoreComment;
cbLimitSearch.Checked := fProcessingSettings.EndOfCentralDirectory.LimitSearch;
//central directory
cbCDIgnoreCentralDirectory.Checked := fProcessingSettings.CentralDirectory.IgnoreCentralDirectory;
cbCDIgnoreSignature.Checked := fProcessingSettings.CentralDirectory.IgnoreSignature;
cbCDIgnoreVersions.Checked := fProcessingSettings.CentralDirectory.IgnoreVersions;
cbCDClearEncryptionFlags.Checked := fProcessingSettings.CentralDirectory.ClearEncryptionFlags;
cbCDIgnoreCompressionMethod.Checked := fProcessingSettings.CentralDirectory.IgnoreCompressionMethod;
cbCDIgnoreModTime.Checked := fProcessingSettings.CentralDirectory.IgnoreModTime;
cbCDIgnoreModDate.Checked := fProcessingSettings.CentralDirectory.IgnoreModDate;
cbCDIgnoreCRC32.Checked := fProcessingSettings.CentralDirectory.IgnoreCRC32;
cbCDIgnoreSizes.Checked := fProcessingSettings.CentralDirectory.IgnoreSizes;
cbCDIgnoreInternalFileAttributes.Checked := fProcessingSettings.CentralDirectory.IgnoreInternalFileAttributes;
cbCDIgnoreExternalFileAttributes.Checked := fProcessingSettings.CentralDirectory.IgnoreExternalFileAttributes;
cbCDIgnoreLocalHeaderOffset.Checked := fProcessingSettings.CentralDirectory.IgnoreLocalHeaderOffset;
cbCDIgnoreExtraField.Checked := fProcessingSettings.CentralDirectory.IgnoreExtraField;
cbCDIgnoreFileComment.Checked := fProcessingSettings.CentralDirectory.IgnoreFileComment;
//local headers
cbLHIgnoreLocalHeaders.Checked := fProcessingSettings.LocalHeader.IgnoreLocalHeaders;
cbLHIgnoreSignature.Checked := fProcessingSettings.LocalHeader.IgnoreSignature;
cbLHIgnoreVersions.Checked := fProcessingSettings.LocalHeader.IgnoreVersions;
cbLHClearEncryptionFlags.Checked := fProcessingSettings.LocalHeader.ClearEncryptionFlags;
cbLHIgnoreCompressionMethod.Checked := fProcessingSettings.LocalHeader.IgnoreCompressionMethod;
cbLHIgnoreModTime.Checked := fProcessingSettings.LocalHeader.IgnoreModTime;
cbLHIgnoreModDate.Checked := fProcessingSettings.LocalHeader.IgnoreModDate;
cbLHIgnoreCRC32.Checked := fProcessingSettings.LocalHeader.IgnoreCRC32;
cbLHIgnoreSizes.Checked := fProcessingSettings.LocalHeader.IgnoreSizes;
cbLHIgnoreFileName.Checked := fProcessingSettings.LocalHeader.IgnoreFileName;
cbLHIgnoreExtraField.Checked := fProcessingSettings.LocalHeader.IgnoreExtraField;
//data descriptor
cbLHIgnoreDataDescriptor.Checked := fProcessingSettings.LocalHeader.IgnoreDataDescriptor;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.FormToSettings;
begin
If rbRebuild.Checked then
  begin
    fProcessingSettings.RepairMethod := rmRebuild;
  {$IFDEF FPC}
    fProcessingSettings.RepairData := ExpandFileNameUTF8(lbleData.Text);
  {$ELSE}
    fProcessingSettings.RepairData := ExpandFileName(lbleData.Text);
  {$ENDIF}
  end;
If rbExtract.Checked then
  begin
    fProcessingSettings.RepairMethod := rmExtract;
  {$IFDEF FPC}
    fProcessingSettings.RepairData := IncludeTrailingPathDelimiter(ExpandFileNameUTF8(lbleData.Text));
  {$ELSE}
    fProcessingSettings.RepairData := IncludeTrailingPathDelimiter(ExpandFileName(lbleData.Text));
  {$ENDIF}
  end;
fProcessingSettings.IgnoreFileSignature := cbIgnoreFileSignature.Checked;
fProcessingSettings.AssumeCompressionMethods := cbAssumeCompressionMethods.Checked;
fProcessingSettings.InMemoryProcessing := cbInMemoryProcessing.Checked;
fProcessingSettings.IgnoreProcessingErrors := cbIgnoreProcessingErrors.Checked;
//eocd
fProcessingSettings.EndOfCentralDirectory.IgnoreEndOfCentralDirectory := cbIgnoreEndOfCentralDirectory.Checked;
fProcessingSettings.EndOfCentralDirectory.IgnoreDiskSplit := cbIgnoreDiskSplit.Checked;
fProcessingSettings.EndOfCentralDirectory.IgnoreNumberOfEntries := cbIgnoreNumberOfEntries.Checked;
fProcessingSettings.EndOfCentralDirectory.IgnoreCentralDirectoryOffset := cbIgnoreCentralDirectoryOffset.Checked;
fProcessingSettings.EndOfCentralDirectory.IgnoreComment := cbIgnoreComment.Checked;
fProcessingSettings.EndOfCentralDirectory.LimitSearch := cbLimitSearch.Checked;
//central directory
fProcessingSettings.CentralDirectory.IgnoreCentralDirectory := cbCDIgnoreCentralDirectory.Checked;
fProcessingSettings.CentralDirectory.IgnoreSignature := cbCDIgnoreSignature.Checked;
fProcessingSettings.CentralDirectory.IgnoreVersions := cbCDIgnoreVersions.Checked;
fProcessingSettings.CentralDirectory.ClearEncryptionFlags := cbCDClearEncryptionFlags.Checked;
fProcessingSettings.CentralDirectory.IgnoreCompressionMethod := cbCDIgnoreCompressionMethod.Checked;
fProcessingSettings.CentralDirectory.IgnoreModTime := cbCDIgnoreModTime.Checked;
fProcessingSettings.CentralDirectory.IgnoreModDate := cbCDIgnoreModDate.Checked;
fProcessingSettings.CentralDirectory.IgnoreCRC32 := cbCDIgnoreCRC32.Checked;
fProcessingSettings.CentralDirectory.IgnoreSizes := cbCDIgnoreSizes.Checked;
fProcessingSettings.CentralDirectory.IgnoreInternalFileAttributes := cbCDIgnoreInternalFileAttributes.Checked;
fProcessingSettings.CentralDirectory.IgnoreExternalFileAttributes := cbCDIgnoreExternalFileAttributes.Checked;
fProcessingSettings.CentralDirectory.IgnoreLocalHeaderOffset := cbCDIgnoreLocalHeaderOffset.Checked;
fProcessingSettings.CentralDirectory.IgnoreExtraField := cbCDIgnoreExtraField.Checked;
fProcessingSettings.CentralDirectory.IgnoreFileComment := cbCDIgnoreFileComment.Checked;
//local headers
fProcessingSettings.LocalHeader.IgnoreLocalHeaders := cbLHIgnoreLocalHeaders.Checked;
fProcessingSettings.LocalHeader.IgnoreSignature := cbLHIgnoreSignature.Checked;
fProcessingSettings.LocalHeader.IgnoreVersions := cbLHIgnoreVersions.Checked;
fProcessingSettings.LocalHeader.ClearEncryptionFlags := cbLHClearEncryptionFlags.Checked;
fProcessingSettings.LocalHeader.IgnoreCompressionMethod := cbLHIgnoreCompressionMethod.Checked;
fProcessingSettings.LocalHeader.IgnoreModTime := cbLHIgnoreModTime.Checked;
fProcessingSettings.LocalHeader.IgnoreModDate := cbLHIgnoreModDate.Checked;
fProcessingSettings.LocalHeader.IgnoreCRC32 := cbLHIgnoreCRC32.Checked;
fProcessingSettings.LocalHeader.IgnoreSizes := cbLHIgnoreSizes.Checked;
fProcessingSettings.LocalHeader.IgnoreFileName := cbLHIgnoreFileName.Checked;
fProcessingSettings.LocalHeader.IgnoreExtraField := cbLHIgnoreExtraField.Checked;
//data descriptor
fProcessingSettings.LocalHeader.IgnoreDataDescriptor := cbLHIgnoreDataDescriptor.Checked;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.ShowProcessingSettings(const FilePath: String; var ProcessingSettings: TProcessingSettings);
begin
fFilePath := FilePath;
fProcessingSettings := ProcessingSettings;
lblFile.Caption := ExtractFileName(FilePath);
fLoading := True;
try
  SettingsToForm;
finally
  fLoading := False;
end;
cbIgnoreEndOfCentralDirectory.OnClick(cbIgnoreEndOfCentralDirectory);
cbCDIgnoreCentralDirectory.OnClick(cbCDIgnoreCentralDirectory);
cbLHIgnoreLocalHeaders.OnClick(cbLHIgnoreLocalHeaders);
fAccepted := False;
ShowModal;
FormToSettings;
If fAccepted then
  ProcessingSettings := fProcessingSettings;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.RepairMethodClick(Sender: TObject);
begin
If Sender is TRadioButton then
  begin
    btnBrowse.Tag := TRadioButton(Sender).Tag;
    case TRadioButton(Sender).Tag of
      2:  begin
            lbleData.EditLabel.Caption := 'Output file:';
            fProcessingSettings.RepairData := ExtractFilePath(fFilePath) + 'unlocked_' + ExtractFileName(fFilePath);
            cbIgnoreProcessingErrors.Enabled := False;
          end;
      3:  begin
            lbleData.EditLabel.Caption := 'Extract into:';
            fProcessingSettings.RepairData := IncludeTrailingPathDelimiter(ChangeFileExt(fFilePath,''));
            cbIgnoreProcessingErrors.Enabled := True;
          end;
    else
      cbIgnoreProcessingErrors.Enabled := False;    
    end;
    lbleData.Text := fProcessingSettings.RepairData;
  end;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.CheckBoxClick(Sender: TObject);
begin
If (Sender is TCheckBox) and not fLoading then
  begin
    case TCheckBox(Sender).Tag of
       20:  begin
              cbIgnoreDiskSplit.Enabled := not cbIgnoreEndOfCentralDirectory.Checked;
              cbIgnoreNumberOfEntries.Enabled := not cbIgnoreEndOfCentralDirectory.Checked;
              cbIgnoreCentralDirectoryOffset.Enabled := not cbIgnoreEndOfCentralDirectory.Checked;
              cbIgnoreComment.Enabled := not cbIgnoreEndOfCentralDirectory.Checked;
              cbLimitSearch.Enabled := not cbIgnoreEndOfCentralDirectory.Checked;
            end;
       40:  begin
              cbCDIgnoreSignature.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreVersions.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDClearEncryptionFlags.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreCompressionMethod.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreModTime.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreModDate.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreCRC32.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreSizes.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreInternalFileAttributes.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreExternalFileAttributes.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreLocalHeaderOffset.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreExtraField.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              cbCDIgnoreFileComment.Enabled := not cbCDIgnoreCentralDirectory.Checked;
              If TCheckBox(Sender).Checked and cbLHIgnoreCompressionMethod.Checked then
                cbLHIgnoreSizes.Checked := False;
              If TCheckBox(Sender).Checked then
                begin
                  cbLHIgnoreLocalHeaders.Checked := False;
                  cbLHIgnoreFileName.Checked := False;
                end;
            end;
       44:  If TCheckBox(Sender).Checked and cbLHIgnoreSizes.Checked and cbLHIgnoreCompressionMethod.Checked then
              cbCDIgnoreSizes.Checked := False;
       48:  If TCheckBox(Sender).Checked and cbLHIgnoreSizes.Checked and cbLHIgnoreCompressionMethod.Checked then
              cbCDIgnoreCompressionMethod.Checked := False;
       51:  If TCheckBox(Sender).Checked then
              cbLHIgnoreLocalHeaders.Checked := False;
       60:  begin
              cbLHIgnoreSignature.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHIgnoreVersions.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHClearEncryptionFlags.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHIgnoreCompressionMethod.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHIgnoreModTime.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHIgnoreModDate.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHIgnoreCRC32.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHIgnoreSizes.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHIgnoreFileName.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHIgnoreExtraField.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              cbLHIgnoreDataDescriptor.Enabled := not cbLHIgnoreLocalHeaders.Checked;
              If TCheckBox(Sender).Checked then
                begin
                  cbCDIgnoreCentralDirectory.Checked := False;
                  cbCDIgnoreLocalHeaderOffset.Checked := False;
                end;
            end;
       64:  If cbCDIgnoreCentralDirectory.Checked then
              begin
                If TCheckBox(Sender).Checked then
                  cbLHIgnoreSizes.Checked := False;
              end
            else
              If cbCDIgnoreSizes.Checked and cbCDIgnoreCompressionMethod.Checked and TCheckBox(Sender).Checked then
                cbLHIgnoreSizes.Checked := False;
       68:  If cbCDIgnoreCentralDirectory.Checked then
              begin
                If TCheckBox(Sender).Checked then
                  cbLHIgnoreCompressionMethod.Checked := False;
              end
            else
              If cbCDIgnoreSizes.Checked and cbCDIgnoreCompressionMethod.Checked and TCheckBox(Sender).Checked then
                cbLHIgnoreCompressionMethod.Checked := False;
       69:  If TCheckBox(Sender).Checked then
              cbCDIgnoreCentralDirectory.Checked := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.SettingsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
If Sender is TControl then
  If meSettingDescription.Tag <> TControl(Sender).Tag then
    begin
      meSettingDescription.Tag := TControl(Sender).Tag;
      If (TControl(Sender).Tag >= Low(fSettingsDescriptions)) and
         (TControl(Sender).Tag <= High(fSettingsDescriptions)) then
        meSettingDescription.Text := fSettingsDescriptions[TControl(Sender).Tag]
      else
        meSettingDescription.Text := 'unknown #' + IntToStr(TControl(Sender).Tag);
    end;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.GroupBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Control:  TControl;

{$IFDEF FPC}
  Function Point(X,Y: Integer): TPoint;
  begin
    Result.x := X;
    Result.y := Y;
  end;
{$ENDIF}

begin
If Sender is TGroupBox then
  begin
    Control := TGroupBox(Sender).ControlAtPos(Point(X,Y),True,True);
    If Assigned(Control) and (Control is TCheckBox) then
      SettingsMouseMove(Control,Shift,X,Y);
  end;
end;

//==============================================================================

procedure TfPrcsSettingsForm.FormCreate(Sender: TObject);
begin
LoadSettingsDescriptions;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.FormShow(Sender: TObject);
begin
meSettingDescription.Text := 'Move cursor over specific setting to see its description.';
btnClose.SetFocus;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.lbleDataChange(Sender: TObject);
begin
lbleData.ShowHint := Canvas.TextWidth(lbleData.Text) > (lbleData.Width - 6);
If lbleData.ShowHint then
  lbleData.Hint := lbleData.Text
end;
  
//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.btnBrowseClick(Sender: TObject);
var
  TempStr:  String;
begin
case btnBrowse.Tag of
  2:  begin
      {$IFDEF FPC}
        TempStr := ExpandFileNameUTF8(lbleData.Text);
        If DirectoryExistsUTF8(ExtractFileDir(TempStr)) then
      {$ELSE}
        TempStr := ExpandFileName(lbleData.Text);
        If DirectoryExists(ExtractFileDir(TempStr)) then
      {$ENDIF}
          diaSaveDialog.InitialDir := ExtractFileDir(TempStr);
        diaSaveDialog.FileName := TempStr;  
        If diaSaveDialog.Execute then
          lbleData.Text := diaSaveDialog.FileName;
      end;
  3:  begin
      {$IFDEF FPC}
        TempStr := ExpandFileNameUTF8(IncludeTrailingPathDelimiter(lbleData.Text));
        If DirectoryExistsUTF8(ExtractFileDir(TempStr)) then TempStr := ExtractFileDir(TempStr)
          else If DirectoryExistsUTF8(ExtractFileDir(ExpandFileNameUTF8(TempStr + '..\'))) then
            TempStr := ExtractFileDir(ExpandFileNameUTF8(TempStr + '..\'))
          else
            TempStr := ExtractFileDir(ParamStr(0));
        with TSelectDirectoryDialog.Create(Self) do
          begin
            Title := 'Select folder for archive extraction.';
            InitialDir := TempStr;
            If Execute then
              lbleData.Text := FileName;
          end;
      {$ELSE}
        TempStr := ExpandFileName(IncludeTrailingPathDelimiter(lbleData.Text));
        If DirectoryExists(ExtractFileDir(TempStr)) then TempStr := ExtractFileDir(TempStr)
          else If DirectoryExists(ExtractFileDir(ExpandFileName(TempStr + '..\'))) then
            TempStr := ExtractFileDir(ExpandFileName(TempStr + '..\'))
          else
            TempStr := ExtractFileDir(ParamStr(0));
        If SelectDirectory('Select folder for archive extraction.','',TempStr) then
          lbleData.Text := IncludeTrailingPathDelimiter(TempStr);
      {$ENDIF}
      end;
end;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.btnDefaultClick(Sender: TObject);
var
  TempMemoryAvailable:  Boolean;
begin
If MessageDlg('Are you sure you want to load default settings?',mtWarning,[mbYes,mbNo],0) = mrYes then
  begin
    TempMemoryAvailable := fProcessingSettings.OtherSettings.InMemoryProcessingAllowed;
    fProcessingSettings := DefaultProcessingSettings;
    fProcessingSettings.RepairData := ExtractFilePath(fFilePath) + 'unlocked_' + Name;
    fProcessingSettings.OtherSettings.InMemoryProcessingAllowed := TempMemoryAvailable;
    fLoading := True;
    try
      SettingsToForm;
    finally
      fLoading := False;
    end;
    cbIgnoreEndOfCentralDirectory.OnClick(cbIgnoreEndOfCentralDirectory);
    cbCDIgnoreCentralDirectory.OnClick(cbCDIgnoreCentralDirectory);
    cbLHIgnoreLocalHeaders.OnClick(cbLHIgnoreLocalHeaders);
  end;
end;

//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.btnCloseClick(Sender: TObject);
begin
Close;
end;
 
//------------------------------------------------------------------------------

procedure TfPrcsSettingsForm.btnAcceptClick(Sender: TObject);
var
  MsgStr: String;
begin
If lbleData.Text <> '' then
  begin
    fAccepted := True;
    Close;
  end
else
  begin
    If rbRebuild.Checked then MsgStr := 'No output file selected.'
      else If rbExtract.Checked then MsgStr := 'No folder for extraction selected.'
        else MsgStr := 'No output selected.';
    MessageDlg(MsgStr,mtInformation,[mbOK],0);
  end;
end;

end.
