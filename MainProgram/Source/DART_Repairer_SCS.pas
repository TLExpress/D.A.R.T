{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit DART_Repairer_SCS;

{$INCLUDE DART_defs.inc}

interface

uses
  AuxTypes,
  WinSyncObjs,
  DART_ProcessingSettings, DART_Format_SCS, DART_Repairer;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TRepairer_SCS                                }
{------------------------------------------------------------------------------}
{==============================================================================}

const
  PROGSTAGEIDX_SCS_ArchiveHeaderLoading      = PROGSTAGEIDX_Max + 1;
  PROGSTAGEIDX_SCS_EntriesLoading            = PROGSTAGEIDX_Max + 2;
  PROGSTAGEIDX_SCS_PathsLoading              = PROGSTAGEIDX_Max + 3;
  PROGSTAGEIDX_SCS_PathsLoading_HelpFiles    = PROGSTAGEIDX_Max + 4;
  PROGSTAGEIDX_SCS_PathsLoading_ParseContent = PROGSTAGEIDX_Max + 5;
  PROGSTAGEIDX_SCS_PathsLoading_BruteForce   = PROGSTAGEIDX_Max + 6;
  PROGSTAGEIDX_SCS_PathsLoading_Local        = PROGSTAGEIDX_Max + 7;
  PROGSTAGEIDX_SCS_PathsLoading_DirsRect     = PROGSTAGEIDX_Max + 8;
  PROGSTAGEIDX_SCS_EntriesProcessing         = PROGSTAGEIDX_Max + 9;
  PROGSTAGEIDX_SCS_EntryProcessing           = PROGSTAGEIDX_Max + 10;
  PROGSTAGEIDX_SCS_EntryLoading              = PROGSTAGEIDX_Max + 11;
  PROGSTAGEIDX_SCS_EntryDecompressing        = PROGSTAGEIDX_Max + 12;
  PROGSTAGEIDX_SCS_EntrySaving               = PROGSTAGEIDX_Max + 13;
  PROGSTAGEIDX_SCS_Max                       = PROGSTAGEIDX_SCS_EntrySaving;

{==============================================================================}
{   TRepairer_SCS - class declaration                                          }
{==============================================================================}
type
  TRepairer_SCS = class(TRepairer)
  protected
    fProcessingSettings:  TSCS_Settings;
    fArchiveStructure:    TSCS_ArchiveStructure;
    fEntriesSorted:       Boolean;
    Function SCS_EntryFileNameHash(const EntryFileName: AnsiString): UInt64; virtual;
    Function SCS_HashName: String; virtual;
    Function SCS_HashCompare(A,B: UInt64): Integer; virtual;
    Function SCS_IndexOfEntry(Hash: UInt64): Integer; virtual;
    procedure SCS_PrepareEntryProgressInfo(EntryIndex: Integer; ProcessedBytes: UInt64); virtual;
    procedure SCS_LoadArchiveHeader; virtual;
    procedure SCS_LoadEntries; virtual;
    procedure SCS_SortEntries; virtual;
    procedure SCS_ForwardedProgressHandler(Sender: TObject; Progress: Single); virtual;
    procedure SCS_LoadPaths; virtual;
    procedure SCS_AssignPaths; virtual;
  //procedure SCS_ParseContent; virtual; // will implement later, maybe
    procedure SCS_BruteForceResolve; virtual;
    procedure RectifyFileProcessingSettings; override;
    procedure InitializeData; override;
    procedure InitializeProgress; override;
    procedure ArchiveProcessing; override;
  public
    class Function GetMethodNameFromIndex(MethodIndex: Integer): String; override;
    constructor Create(PauseControlObject: TEvent; FileProcessingSettings: TFileProcessingSettings; CatchExceptions: Boolean = True);
    property ArchiveStructure: TSCS_ArchiveStructure read fArchiveStructure;
  end;

implementation

uses
  SysUtils, Classes,
  BitOps, CITY, CRC32, 
  DART_Auxiliary, DART_MemoryBuffer, DART_AnsiStringList, DART_Format_ZIP,
  DART_Repairer_ZIP;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TRepairer_SCS                                }
{------------------------------------------------------------------------------}
{==============================================================================}

{==============================================================================}
{   TRepairer_SCS - class implementation                                       }
{==============================================================================}

{------------------------------------------------------------------------------}
{   TRepairer_SCS - protected methods                                          }
{------------------------------------------------------------------------------}

Function TRepairer_SCS.SCS_EntryFileNameHash(const EntryFileName: AnsiString): UInt64;
begin
Result := 0;
case fArchiveStructure.ArchiveHeader.HashType of
  SCS_HASH_City: Result := CityHash64(PAnsiChar(EntryFileName),Length(EntryFileName) * SizeOf(AnsiChar));
else
  DoError(100,'Unknown hashing algorithm (0x%.8x).',[fArchiveStructure.ArchiveHeader.HashType]);
end;
end;

//------------------------------------------------------------------------------

Function TRepairer_SCS.SCS_HashName: String;
begin
case fArchiveStructure.ArchiveHeader.HashType of
  SCS_HASH_City:  Result := 'CITY';
else
  Result := 'UNKN';
end;
end;

//------------------------------------------------------------------------------

Function TRepairer_SCS.SCS_HashCompare(A,B: UInt64): Integer;
begin
If Int64Rec(A).Hi <> Int64Rec(B).Hi then
  begin
    If Int64Rec(A).Hi < Int64Rec(B).Hi then Result := 2
      else Result := -2
  end
else
  begin
    If Int64Rec(A).Lo < Int64Rec(B).Lo then Result := 1
      else If Int64Rec(A).Lo > Int64Rec(B).Lo then Result := -1
        else Result := 0;
  end;
end;

//------------------------------------------------------------------------------

Function TRepairer_SCS.SCS_IndexOfEntry(Hash: UInt64): Integer;
var
  i,min,max:  Integer;
begin
Result := -1;
If fEntriesSorted then
  begin
    min := 0;
    max := High(fArchiveStructure.Entries);
    while max >= min do
      begin
        i := ((max - min) shr 1) + min;
        // i-th entry has lower hash than is requested
        If SCS_HashCompare(fArchiveStructure.Entries[i].Bin.Hash,Hash) > 0 then Min := i + 1
          // i-th entry has higher hash than is requested
          else If SCS_HashCompare(fArchiveStructure.Entries[i].Bin.Hash,Hash) < 0 then Max := i - 1
            else begin
              // i-th entry has the requested hash
              Result := i;
              Break{while};
            end;
      end;
  end
else
  begin
    For i := Low(fArchiveStructure.Entries) to High(fArchiveStructure.Entries) do
      If fArchiveStructure.Entries[i].Bin.Hash = Hash then
        begin
          Result := i;
          Break{For i};
        end;
  end;
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.SCS_PrepareEntryProgressInfo(EntryIndex: Integer; ProcessedBytes: UInt64);
begin
fProgressStages[PROGSTAGEIDX_SCS_EntryProcessing].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_EntriesProcessing].Offset +
  (ProcessedBytes / fArchiveStructure.DataBytes) *
  fProgressStages[PROGSTAGEIDX_SCS_EntriesProcessing].Range;
fProgressStages[PROGSTAGEIDX_SCS_EntryProcessing].Range :=
  (fArchiveStructure.Entries[EntryIndex].Bin.CompressedSize / fArchiveStructure.DataBytes) *
  fProgressStages[PROGSTAGEIDX_SCS_EntriesProcessing].Range;
fProgressStages[PROGSTAGEIDX_SCS_EntryLoading].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_EntryProcessing].Offset;
fProgressStages[PROGSTAGEIDX_SCS_EntryLoading].Range :=
  fProgressStages[PROGSTAGEIDX_SCS_EntryProcessing].Range * 0.4;
fProgressStages[PROGSTAGEIDX_SCS_EntryDecompressing].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_EntryLoading].Offset +
  fProgressStages[PROGSTAGEIDX_SCS_EntryLoading].Range;
fProgressStages[PROGSTAGEIDX_SCS_EntryDecompressing].Range :=
  fProgressStages[PROGSTAGEIDX_SCS_EntryProcessing].Range * 0.2;
fProgressStages[PROGSTAGEIDX_SCS_EntrySaving].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_EntryDecompressing].Offset +
  fProgressStages[PROGSTAGEIDX_SCS_EntryDecompressing].Range;
fProgressStages[PROGSTAGEIDX_SCS_EntrySaving].Range :=
  fProgressStages[PROGSTAGEIDX_SCS_EntryProcessing].Range * 0.4;
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.SCS_LoadArchiveHeader;
begin
DoProgress(PROGSTAGEIDX_SCS_ArchiveHeaderLoading,0.0);
If fArchiveStream.Size >= SizeOf(TSCS_ArchiveHeader) then
  begin
    fArchiveStream.Seek(0,soFromBeginning);
    fArchiveStream.ReadBuffer(fArchiveStructure.ArchiveHeader,SizeOf(TSCS_ArchiveHeader));
    If fFileProcessingSettings.Common.IgnoreFileSignature then
      fArchiveStructure.ArchiveHeader.Signature := SCS_FileSignature;
    If fFileProcessingSettings.SCSSettings.PathResolve.AssumeCityHash then
      fArchiveStructure.ArchiveHeader.HashType := SCS_HASH_City
    else
      If fArchiveStructure.ArchiveHeader.HashType <> SCS_HASH_City then
        DoError(101,'Unsupported hash algorithm (0x%.8x).',[fArchiveStructure.ArchiveHeader.HashType]);
  end
else DoError(101,'File is too small (%d bytes) to contain a valid archive header.',[fArchiveStream.Size]);
DoProgress(PROGSTAGEIDX_SCS_ArchiveHeaderLoading,1.0);
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.SCS_LoadEntries;
var
  i:  Integer;
begin
DoProgress(PROGSTAGEIDX_SCS_EntriesLoading,0.0);
SetLength(fArchiveStructure.Entries,fArchiveStructure.ArchiveHeader.Entries);
fArchiveStream.Seek(fArchiveStructure.ArchiveHeader.EntriesOffset,soFromBeginning);
For i := Low(fArchiveStructure.Entries) to High(fArchiveStructure.Entries) do
  with fArchiveStructure.Entries[i] do
    begin
      fArchiveStream.ReadBuffer(Bin,SizeOf(TSCS_EntryRecord));
      FileName := '';
      UtilityData.Resolved := False;
      If fProcessingSettings.Entry.IgnoreCRC32 then
        Bin.CRC32 := 0;
      If fProcessingSettings.Entry.IgnoreCompressionFlag then
        SetFlagState(Bin.Flags,SCS_FLAG_Compressed,Bin.UncompressedSize <> Bin.CompressedSize);
      DoProgress(PROGSTAGEIDX_SCS_EntriesLoading,(i + 1) / Length(fArchiveStructure.Entries));
    end;
DoProgress(PROGSTAGEIDX_SCS_EntriesLoading,1.0);
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.SCS_SortEntries;

  procedure QuickSort(LeftIdx,RightIdx: Integer);
  var
    Pivot:  UInt64;
    Idx,i:  Integer;

    procedure ExchangeEntries(Idx1,Idx2: Integer);
    var
      TempEntry:  TSCS_Entry;
    begin
      If (Idx1 <> Idx2) then
        begin
          If (Idx1 < Low(fArchiveStructure.Entries)) or (Idx1 > High(fArchiveStructure.Entries)) then
            DoError(103,'Index 1 (%d) out of bounds.',[Idx1]);
          If (Idx2 < Low(fArchiveStructure.Entries)) or (Idx2 > High(fArchiveStructure.Entries)) then
            DoError(103,'Index 2 (%d) out of bounds.',[Idx1]);
          TempEntry := fArchiveStructure.Entries[Idx1];
          fArchiveStructure.Entries[Idx1] := fArchiveStructure.Entries[Idx2];
          fArchiveStructure.Entries[Idx2] := TempEntry;
        end;
    end;
    
  begin
    DoProgress(PROGSTAGEIDX_NoProgress,0.0); // must be called at the start of this routine
    If LeftIdx < RightIdx then
      begin
        ExchangeEntries((LeftIdx + RightIdx) shr 1,RightIdx);
        Pivot := fArchiveStructure.Entries[RightIdx].Bin.Hash;
        Idx := LeftIdx;
        For i := LeftIdx to Pred(RightIdx) do
          If SCS_HashCompare(Pivot,fArchiveStructure.Entries[i].Bin.Hash) < 0 then
            begin
              ExchangeEntries(i,idx);
              Inc(Idx);
            end;
        ExchangeEntries(Idx,RightIdx);
        QuickSort(LeftIdx,Idx - 1);
        QuickSort(Idx + 1,RightIdx);
      end;
  end;
  
begin
If Length(fArchiveStructure.Entries) > 1 then
  QuickSort(0,High(fArchiveStructure.Entries));
fEntriesSorted := True;
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.SCS_ForwardedProgressHandler(Sender: TObject; Progress: Single);
begin
DoProgress(PROGSTAGEIDX_NoProgress,Progress);
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.SCS_LoadPaths;
var
  i:                  Integer;
  KnownPathsCount:    Integer;
  DirectoryList:      TAnsiStringList;
  CurrentLevel:       TAnsiStringList;
  EntryLines:         TAnsiStringList;  // used inside of nested function LoadPath
  DirCount:           Integer;
  ProcessedDirCount:  Integer;

//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---    

  procedure AddKnownPath(const Path: AnsiString);

    Function ContainsKnownPath: Boolean;
    var
      ii:       Integer;
      PathHash: TCRC32;
    begin
      Result := False;
      PathHash := AnsiStringCRC32(AnsiLowerCase(Path));
      For ii := Low(fArchiveStructure.KnownPaths) to Pred(KnownPathsCount) do
        If SameCRC32(PathHash,fArchiveStructure.KnownPaths[ii].Hash) then
          If AnsiSameText(Path,fArchiveStructure.KnownPaths[ii].Path) then
            begin
              Result := True;
              Break{For ii};
            end;
    end;

  begin
    If not ContainsKnownPath then
      begin
        If Length(fArchiveStructure.KnownPaths) <= KnownPathsCount then
          SetLength(fArchiveStructure.KnownPaths,Length(fArchiveStructure.KnownPaths) + 1024);
        fArchiveStructure.KnownPaths[KnownPathsCount].Path := Path;
        fArchiveStructure.KnownPaths[KnownPathsCount].Hash := AnsiStringCRC32(AnsiLowerCase(Path));
        Inc(KnownPathsCount);        
      end;
  end;

//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---    

  procedure LoadHelpFile(const FileName: String);
  var
    HelpFileProcSettings: TFileProcessingSettings;
    ArchiveSignature:     UInt32;
    HelpFileRepairer:     TRepairer;
    ii:                   Integer;
  begin
  {
    Creates local basic repairer that will load all possible paths from a help
    file without doing anything with it.
    Also, for SCS# archives, all paths found to this moment are passed as custom
    paths to the repairer.
    What repairer should be used is discerned by a file signature, when it
    matches signature of SCS# archive, then SCS repairer is used, otherwise ZIP
    repairer is used.
  }
    // discern what type the input archive is
    ArchiveSignature := GetFileSignature(FileName);
    // init processing settings for local repairer
    HelpFileProcSettings := DefaultFileProcessingSettings;
    HelpFileProcSettings.Common.FilePath := FileName;
    // explicitly turn off in-memory processing, as we do not know size of the file
    HelpFileProcSettings.Common.InMemoryProcessing := False;
    // do archive-type-specific processing
    case ArchiveSignature of
      SCS_FileSignature:  // - - - - - - - - - - - - - - - - - - - - - - - - - -
        begin
          // SCS# archive
          // file signature must be checked because we assume it is SCS# format
          HelpFileProcSettings.Common.IgnoreFileSignature := False;
          // copy already known paths
          SetLength(HelpFileProcSettings.SCSSettings.PathResolve.CustomPaths,Length(fArchiveStructure.KnownPaths));
          For ii := Low(fArchiveStructure.KnownPaths) to Pred(KnownPathsCount) do
            HelpFileProcSettings.SCSSettings.PathResolve.CustomPaths[ii] := fArchiveStructure.KnownPaths[ii].Path;
          HelpFileRepairer := TRepairer_SCS.Create(fPauseControlObject,HelpFileProcSettings,False);
          try
            HelpFileRepairer.OnProgress := SCS_ForwardedProgressHandler;
            HelpFileRepairer.Run;
            For ii := Low(TRepairer_SCS(HelpFileRepairer).ArchiveStructure.KnownPaths) to
                      High(TRepairer_SCS(HelpFileRepairer).ArchiveStructure.KnownPaths) do
              AddKnownPath(TRepairer_SCS(HelpFileRepairer).ArchiveStructure.KnownPaths[ii].Path);
          finally
            HelpFileRepairer.Free;
          end;
        end;
    else
     {ZIP_FileSignature:} // - - - - - - - - - - - - - - - - - - - - - - - - - -
      // other archive types (ZIP)
      HelpFileRepairer := TRepairer_ZIP.Create(fPauseControlObject,HelpFileProcSettings,False);
      try
        HelpFileRepairer.OnProgress := SCS_ForwardedProgressHandler;
        HelpFileRepairer.Run;
        For ii := Low(TRepairer_ZIP(HelpFileRepairer).ArchiveStructure.Entries) to
                  High(TRepairer_ZIP(HelpFileRepairer).ArchiveStructure.Entries) do
          with TRepairer_ZIP(HelpFileRepairer).ArchiveStructure.Entries[ii].CentralDirectoryHeader do
            If Length(FileName) > 0 then
              begin
                If FileName[Length(FileName)] = ZIP_PathDelim then
                  AddKnownPath(Copy(FileName,1,Length(FileName) - 1))
                else
                  AddKnownPath(FileName);
              end;
      finally
        HelpFileRepairer.Free;
      end;
    end;
  end;

//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---

  procedure LoadPath(const Path: AnsiString; Directories: TAnsiStringList);
  var
    Idx:          Integer;
    EntryString:  AnsiString;
    OutBuff:      Pointer;
    OutSize:      Integer;
    ii:           Integer;
  begin
    Idx := SCS_IndexOfEntry(SCS_EntryFileNameHash(Path));
    If Idx >= 0 then
      with fArchiveStructure.Entries[Idx] do
        If GetFlagState(Bin.Flags,SCS_FLAG_Directory) then
          begin
            // directory entry, load it...
            ReallocateMemoryBuffer(fCED_BUffer,Bin.CompressedSize);
            fArchiveStream.Seek(Bin.DataOffset,soFromBeginning);
            fArchiveStream.ReadBuffer(fCED_Buffer.Memory^,Bin.CompressedSize);
            SetLength(EntryString,Bin.UncompressedSize);
            If GetFlagState(Bin.Flags,SCS_FLAG_Compressed) then
              begin
                // data needs to be decompressed first
                ProgressedDecompressBuffer(fCED_Buffer.Memory,Bin.CompressedSize,OutBuff,OutSize,PROGSTAGEIDX_NoProgress,Path,WINDOWBITS_ZLib);
                try
                  If UInt32(OutSize) <> Bin.UncompressedSize then
                    DoError(104,'Decompressed size does not match for entry #%d ("%s").',
                    {$IFDEF Unicode}
                      [Idx,UTF8Decode(Path)]
                    {$ELSE}
                      {$IFDEF FPC}[Idx,Path]{$ELSE}[Idx,UTF8ToAnsi(Path)]{$ENDIF}
                    {$ENDIF});
                  Move(OutBuff^,PAnsiChar(EntryString)^,OutSize);
                finally
                  FreeMem(OutBuff,OutSize);
                end;
              end
            else Move(fCED_Buffer.Memory^,PAnsiChar(EntryString)^,Bin.CompressedSize);
            // ...and parse its content (new level of directories and files)
            EntryLines.Clear;
            EntryLines.Text := EntryString;
            For ii := 0 to Pred(EntryLines.Count) do
              If Length(EntryLines[ii]) > 0 then
                begin
                  If EntryLines[ii][1] = '*' then
                    begin
                      // directory
                      If Path <> '' then
                        Directories.Add(Path + SCS_PathDelim + Copy(EntryLines[ii],2,Length(EntryLines[ii])))
                      else
                        Directories.Add(Path + Copy(EntryLines[ii],2,Length(EntryLines[ii])));
                      AddKnownPath(Directories[Pred(Directories.Count)]);
                    end
                  else AddKnownPath(Path + SCS_PathDelim + EntryLines[ii]); // file
                end;
            Inc(ProcessedDirCount);
            If DirCount > 0 then
              DoProgress(PROGSTAGEIDX_SCS_PathsLoading_Local,ProcessedDirCount / DirCount);
          end;
  end;

begin
KnownPathsCount := 0;
// add root
AddKnownPath(SCS_RootPath);
// add predefined paths
If fProcessingSettings.PathResolve.UsePredefinedPaths then
  For i := Low(SCS_PredefinedPaths) to High(SCS_PredefinedPaths) do
    AddKnownPath(SCS_PredefinedPaths[i]);
// add user paths
with fProcessingSettings.PathResolve do
  For i := Low(CustomPaths) to High(CustomPaths) do
    AddKnownPath(CustomPaths[i]);
// load paths from help files
DoProgress(PROGSTAGEIDX_SCS_PathsLoading_HelpFiles,0.0);
For i := Low(fProcessingSettings.PathResolve.HelpFiles) to High(fProcessingSettings.PathResolve.HelpFiles) do
  begin
    LoadHelpFile(fProcessingSettings.PathResolve.HelpFiles[i]);
    DoProgress(PROGSTAGEIDX_SCS_PathsLoading_HelpFiles,(i + 1) / Length(fProcessingSettings.PathResolve.HelpFiles));
  end;
DoProgress(PROGSTAGEIDX_SCS_PathsLoading_HelpFiles,1.0);
// load all paths stored in the archive
DirectoryList := TAnsiStringList.Create;
try
  CurrentLevel := TAnsiStringList.Create;
  try
    DirectoryList.Capacity := KnownPathsCount;
    For i := Low(fArchiveStructure.KnownPaths) to Pred(KnownPathsCount) do
      DirectoryList.Add(fArchiveStructure.KnownPaths[i].Path);
    EntryLines := TAnsiStringList.Create;
    try
      // count directories (progress is using this number)
      DirCount := 0;
      ProcessedDirCount := 0;
      For i := Low(fArchiveStructure.Entries) to High(fArchiveStructure.Entries) do
        If GetFlagState(fArchiveStructure.Entries[i].Bin.Flags,SCS_FLAG_Directory) then Inc(DirCount);
      DoProgress(PROGSTAGEIDX_SCS_PathsLoading_Local,0.0);
      repeat
        CurrentLevel.Assign(DirectoryList);
        DirectoryList.Clear;
        For i := 0 to Pred(CurrentLevel.Count) do
          LoadPath(CurrentLevel[i],DirectoryList);
      until DirectoryList.Count <= 0;
      DoProgress(PROGSTAGEIDX_SCS_PathsLoading_Local,1.0);
    finally
      EntryLines.Free;
    end;
  finally
    CurrentLevel.Free;
  end;
finally
  DirectoryList.Free;
end;
SetLength(fArchiveStructure.KnownPaths,KnownPathsCount);
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.SCS_AssignPaths;
var
  i:    Integer;
  Idx:  Integer;
begin
For i := Low(fArchiveStructure.KnownPaths) to High(fArchiveStructure.KnownPaths) do
  begin
    Idx := SCS_IndexOfEntry(SCS_EntryFileNameHash(fArchiveStructure.KnownPaths[i].Path));
    If Idx >= 0 then
      begin
        fArchiveStructure.Entries[Idx].FileName := fArchiveStructure.KnownPaths[i].Path;
        fArchiveStructure.Entries[Idx].UtilityData.Resolved := True;
      end;
    DoProgress(PROGSTAGEIDX_NoProgress,0.0);  
  end;
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.SCS_BruteForceResolve;
begin
DoProgress(PROGSTAGEIDX_SCS_PathsLoading_BruteForce,0.0);
DoError(-1,'Brute-force resolve is not implemented in this build.');
DoProgress(PROGSTAGEIDX_SCS_PathsLoading_BruteForce,1.0);
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.RectifyFileProcessingSettings;
begin
fProcessingSettings := fFileProcessingSettings.SCSSettings;
fProcessingSettings.PathResolve.BruteForceResolve := False; 
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.InitializeData;
begin
FillChar(fArchiveStructure.ArchiveHeader,SizeOf(TSCS_ArchiveHeader),0);
SetLength(fArchiveStructure.Entries,0);
SetLength(fArchiveStructure.KnownPaths,0);
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.InitializeProgress;
var
  AvailableRange: Single;
  DirsRectRange:  Single;
begin
inherited;
SetLength(fProgressStages,Succ(PROGSTAGEIDX_SCS_Max));
AvailableRange := 1.0 - (fProgressStages[PROGSTAGEIDX_Loading].Range +
                  fProgressStages[PROGSTAGEIDX_Saving].Range);
// set progress info for loading of archive header
fProgressStages[PROGSTAGEIDX_SCS_ArchiveHeaderLoading].Offset :=
  fProgressStages[PROGSTAGEIDX_Loading].Range;
fProgressStages[PROGSTAGEIDX_SCS_ArchiveHeaderLoading].Range := 0.01 * AvailableRange;
// loading of entries
fProgressStages[PROGSTAGEIDX_SCS_EntriesLoading].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_ArchiveHeaderLoading].Offset +
  fProgressStages[PROGSTAGEIDX_SCS_ArchiveHeaderLoading].Range;
fProgressStages[PROGSTAGEIDX_SCS_EntriesLoading].Range := 0.04 * AvailableRange;
// loading of paths
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_EntriesLoading].Offset +
  fProgressStages[PROGSTAGEIDX_SCS_EntriesLoading].Range;
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Range := 0.05 * AvailableRange;
If fFileProcessingSettings.Common.RepairMethod in [rmRebuild,rmConvert] then
  DirsRectRange := 0.2 * fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Range
else
  DirsRectRange := 0.0;  
// entries processing
fProgressStages[PROGSTAGEIDX_SCS_EntriesProcessing].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Offset +
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Range;
fProgressStages[PROGSTAGEIDX_SCS_EntriesProcessing].Range := AvailableRange -
  (fProgressStages[PROGSTAGEIDX_SCS_ArchiveHeaderLoading].Range +
   fProgressStages[PROGSTAGEIDX_SCS_EntriesLoading].Range +
   fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Range);
// individual stages of paths loading
// help files loading
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_HelpFiles].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Offset;
If Length(fProcessingSettings.PathResolve.HelpFiles) > 0 then
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_HelpFiles].Range :=
    0.2 * fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Range;
// content parsing
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_ParseContent].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_HelpFiles].Offset +
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_HelpFiles].Range;
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_ParseContent].Range :=
  0.0 {0.2} * fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Range;
// brute force resolve
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_BruteForce].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_ParseContent].Offset +
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_ParseContent].Range;
If fProcessingSettings.PathResolve.BruteForceResolve then
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_BruteForce].Range :=
    0.2 * fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Range;
// actual loading from processed file
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_Local].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_BruteForce].Offset +
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_BruteForce].Range;
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_Local].Range :=
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading].Range -
  (fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_HelpFiles].Range +
   fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_ParseContent].Range +
   fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_BruteForce].Range + DirsRectRange);
// directories reconstruction
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_DirsRect].Offset :=
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_Local].Offset +
  fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_Local].Range;
fProgressStages[PROGSTAGEIDX_SCS_PathsLoading_DirsRect].Range := DirsRectRange;
end;

//------------------------------------------------------------------------------

procedure TRepairer_SCS.ArchiveProcessing;
var
  i:  Integer;
begin
SCS_LoadArchiveHeader;
SCS_LoadEntries;
SCS_SortEntries;  // <- this step is optional at this point, but provides better performance
DoProgress(PROGSTAGEIDX_SCS_PathsLoading,0.0);  // 1.0 is passed in descendants as there is specific path processing for each repair method 
SCS_LoadPaths;
SCS_AssignPaths;
//SCS_ParseContent;
If fProcessingSettings.PathResolve.BruteForceResolve then
  SCS_BruteForceResolve;
If Length(fArchiveStructure.Entries) <= 0 then
  DoError(102,'Input file does not contain any valid entries.');
// get amount of data in the archive (without directory entries) - used for progress
fArchiveStructure.DataBytes := 0;
For i := Low(fArchiveStructure.Entries) to High(fArchiveStructure.Entries) do
  If not GetFlagState(fArchiveStructure.Entries[i].Bin.Flags,SCS_FLAG_Directory) then
    Inc(fArchiveStructure.DataBytes,fArchiveStructure.Entries[i].Bin.CompressedSize);
end;

{------------------------------------------------------------------------------}
{   TRepairer_SCS - public methods                                             }
{------------------------------------------------------------------------------}

class Function TRepairer_SCS.GetMethodNameFromIndex(MethodIndex: Integer): String;
begin
case MethodIndex of
  100:  Result := 'SCS_EntryPathHash';
  101:  Result := 'SCS_LoadArchiveHeader';
  102:  Result := 'ArchiveProcessing';
  103:  Result := 'SCS_SortEntries.QuickSort.ExchangeEntries';
  104:  Result := 'SCS_LoadPaths.LoadPath';
else
  Result := inherited GetMethodNameFromIndex(MethodIndex);
end;
end;

//------------------------------------------------------------------------------

constructor TRepairer_SCS.Create(PauseControlObject: TEvent; FileProcessingSettings: TFileProcessingSettings; CatchExceptions: Boolean = True);
begin
inherited Create(PauseControlObject,FileProcessingSettings,CatchExceptions);
fExpectedSignature := SCS_FileSignature;
fEntriesSorted := False;
end;

end.
