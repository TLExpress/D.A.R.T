{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit DART_ProcessingSettings;

{$INCLUDE DART_defs.inc}

interface

type
  TFileType = (atUnknown,atSCS_sig,atSCS_frc,atZIP_sig,atZIP_frc,atZIP_dft);
  TRepairMethod = (rmUnknown,rmRebuild,rmExtract,rmConvert);

const
  FileTypeStrArr: array[TFileType] of String =
    ('Unknown','SCS#','SCS# (forced)','ZIP','ZIP (forced)','ZIP (defaulted)');

  RepairerMethodStrArr: array[TRepairMethod] of String =
    ('Unknown','Rebuild archive','Extract archive','Convert archive');

//--- Common processing settings -----------------------------------------------

type
  TCommonSettings = record
    FilePath:               String;
    OriginalFileType:       TFileType;
    FileType:               TFileType;
    RepairMethod:           TRepairMethod;
    TargetPath:             String;
    IgnoreFileSignature:    Boolean;
    InMemoryProcessing:     Boolean;
    IgnoreErroneousEntries: Boolean;
  end;

  TOtherSettings = record
    InMemoryProcessingAllowed:  Boolean;
  end;

//--- ZIP-specific processing settings -----------------------------------------

  TZIP_EndOfCentralDirectoryProcessingSettings = record
    IgnoreEndOfCentralDirectory:    Boolean;
    IgnoreDiskSplit:                Boolean;
    IgnoreNumberOfEntries:          Boolean;
    IgnoreCentralDirectoryOffset:   Boolean;
    IgnoreComment:                  Boolean;
    LimitSearch:                    Boolean;
  end;

  TZIP_CentralDirectoryProcessingSettings = record
    IgnoreCentralDirectory:       Boolean;
    IgnoreSignature:              Boolean;
    IgnoreVersions:               Boolean;
    ClearEncryptionFlags:         Boolean;
    IgnoreCompressionMethod:      Boolean;
    IgnoreModTime:                Boolean;
    IgnoreModDate:                Boolean;
    IgnoreCRC32:                  Boolean;
    IgnoreSizes:                  Boolean;
    IgnoreInternalFileAttributes: Boolean;
    IgnoreExternalFileAttributes: Boolean;
    IgnoreLocalHeaderOffset:      Boolean;
    IgnoreExtraField:             Boolean;
    IgnoreFileComment:            Boolean;
  end;

  TZIP_LocalHeaderProcessingSettings = record
    IgnoreLocalHeaders:       Boolean;
    IgnoreSignature:          Boolean;
    IgnoreVersions:           Boolean;
    ClearEncryptionFlags:     Boolean;
    IgnoreCompressionMethod:  Boolean;
    IgnoreModTime:            Boolean;
    IgnoreModDate:            Boolean;
    IgnoreCRC32:              Boolean;
    IgnoreSizes:              Boolean;
    IgnoreFileName:           Boolean;
    IgnoreExtraField:         Boolean;
    IgnoreDataDescriptor:     Boolean;
  end;

  TZIP_Settings = record
    AssumeCompressionMethods: Boolean;
    EndOfCentralDirectory:    TZIP_EndOfCentralDirectoryProcessingSettings;
    CentralDirectory:         TZIP_CentralDirectoryProcessingSettings;
    LocalHeader:              TZIP_LocalHeaderProcessingSettings;
  end;

//--- SCS#-specific processing settings ----------------------------------------

  TSCS_EntrySettings = record
    IgnoreCRC32:            Boolean;
    IgnoreCompressionFlag:  Boolean;
    IgnoreDictionaryID:     Boolean;
  end;

  TSCS_PathResolveSettings = record
    AssumeCityHash:             Boolean;
    UsePredefinedPaths:         Boolean;
    ExtractedUnresolvedEntries: Boolean;
    CustomPaths:                array of AnsiString;
    HelpFiles:                  array of String;
    // content parsing -----------------------------
    ParseContent:               Boolean;
    ParseEverything:            Boolean;
    ParseHelpFiles:             Boolean;
    ParseHelpFilesEverything:   Boolean;
    ParseLimitedCharacterSet:   Boolean;
    ParseBinaryThreshold:       Integer;
    // brute force resolving -----------------------
    BruteForceResolve:          Boolean;
    BruteForceMultiSearch:      Boolean;
    BruteForceMultithread:      Boolean;
    BruteForcePrintableASCII:   Boolean;
    BruteForceLimitedAlphabet:  Boolean;
    BruteForceLengthLimit:      Word;
  end;

  TSCS_Settings = record
    Entry:        TSCS_EntrySettings;
    PathResolve:  TSCS_PathResolveSettings;
  end;

//--- Main structure -----------------------------------------------------------

  TFileProcessingSettings = record
    Common:       TCommonSettings;
    Other:        TOtherSettings;
    ZIPSettings:  TZIP_Settings;
    SCSSettings:  TSCS_Settings;
  end;

//==============================================================================

const
  DefaultFileProcessingSettings: TFileProcessingSettings = (
    Common: (
      FilePath:               '';
      OriginalFileType:       atUnknown;
      FileType:               atUnknown;
      RepairMethod:           rmRebuild;
      TargetPath:             '';
      IgnoreFileSignature:    True;
      InMemoryProcessing:     False;
      IgnoreErroneousEntries: False);
    Other: (
      InMemoryProcessingAllowed: False);
    ZIPSettings: (
      AssumeCompressionMethods: False;
      EndOfCentralDirectory: (
        IgnoreEndOfCentralDirectory:  False;
        IgnoreDiskSplit:              True;
        IgnoreNumberOfEntries:        False;
        IgnoreCentralDirectoryOffset: False;
        IgnoreComment:                True;
        LimitSearch:                  True);
      CentralDirectory: (
        IgnoreCentralDirectory:       False;
        IgnoreSignature:              True;
        IgnoreVersions:               True;
        ClearEncryptionFlags:         True;
        IgnoreCompressionMethod:      True;
        IgnoreModTime:                False;
        IgnoreModDate:                False;
        IgnoreCRC32:                  True;
        IgnoreSizes:                  False;
        IgnoreInternalFileAttributes: False;
        IgnoreExternalFileAttributes: False;
        IgnoreLocalHeaderOffset:      False;
        IgnoreExtraField:             True;
        IgnoreFileComment:            True);
      LocalHeader: (
        IgnoreLocalHeaders:           False;
        IgnoreSignature:              True;
        IgnoreVersions:               True;
        ClearEncryptionFlags:         True;
        IgnoreCompressionMethod:      True;
        IgnoreModTime:                False;
        IgnoreModDate:                False;
        IgnoreCRC32:                  True;
        IgnoreSizes:                  True;
        IgnoreFileName:               False;
        IgnoreExtraField:             True;
        IgnoreDataDescriptor:         False));
    SCSSettings: (
      Entry: (
        IgnoreCRC32:                False;
        IgnoreCompressionFlag:      False;
        IgnoreDictionaryID:         False);
      PathResolve:(
        AssumeCityHash:             False;
        UsePredefinedPaths:         True;
        ExtractedUnresolvedEntries: False;
        CustomPaths:                nil;
        HelpFiles:                  nil;
        ParseContent:               False;
        ParseEverything:            False;
        ParseHelpFiles:             False;
        ParseHelpFilesEverything:   False;
        ParseLimitedCharacterSet:   True;
        ParseBinaryThreshold:       5;
        BruteForceResolve:          False;
        BruteForceMultiSearch:      True;
        BruteForceMultithread:      True;
        BruteForcePrintableASCII:   True;
        BruteForceLimitedAlphabet:  True;
        BruteForceLengthLimit:      32)));

implementation

end.
