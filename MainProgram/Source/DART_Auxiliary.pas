{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit DART_Auxiliary;

{$INCLUDE DART_defs.inc}

interface

uses
  AuxTypes;

Function GetFileSize(const FilePath: String): Int64;

Function GetFileSignature(const FilePath: String): UInt32;

Function GetAvailableMemory: UInt64;

implementation

uses
  Windows, SysUtils, Classes
{$IFDEF FPC_NonUnicode}
  , LazUTF8
  {$IFDEF FPC_NonUnicode_NoUTF8RTL}
  , LazFileUtils
  {$ENDIF}
{$ENDIF};

Function GetFileSize(const FilePath: String): Int64;
var
  SearchResult: TSearchRec;
begin
{$IFDEF FPC_NonUnicode_NoUTF8RTL}
If FindFirstUTF8(FilePath,faAnyFile,SearchResult) = 0 then
{$ELSE}
If FindFirst(FilePath,faAnyFile,SearchResult) = 0 then
{$ENDIF}
  try
  {$WARN SYMBOL_PLATFORM OFF}
    Int64Rec(Result).Hi := SearchResult.FindData.nFileSizeHigh;
    Int64Rec(Result).Lo := SearchResult.FindData.nFileSizeLow;
  {$WARN SYMBOL_PLATFORM ON}
  finally
  {$IFDEF FPC_NonUnicode_NoUTF8RTL}
    FindCloseUTF8(SearchResult);
  {$ELSE}
    FindClose(SearchResult);
  {$ENDIF}
  end
else Result := 0;
end;

//------------------------------------------------------------------------------

Function GetFileSignature(const FilePath: String): UInt32;
begin
Result := 0;
{$IFDEF FPC_NonUnicode}
with TFileStream.Create(UTF8ToSys(FilePath),fmOpenRead or fmShareDenyWrite) do
{$ELSE}
with TFileStream.Create(FilePath,fmOpenRead or fmShareDenyWrite) do
{$ENDIF}
try
  If Read(Result,SizeOf(Result)) < SizeOf(Result) then
    Result := 0;
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

type
  TMemoryStatusEx = record
    dwLength:                 LongWord;
    dwMemoryLoad:             LongWord;
    ullTotalPhys:             UInt64;
    ullAvailPhys:             UInt64;
    ullTotalPageFile:         UInt64;
    ullAvailPageFile:         UInt64;
    ullTotalVirtual:          UInt64;
    ullAvailVirtual:          UInt64;
    ullAvailExtendedVirtual:  UInt64;
  end;
  PMemoryStatusEx = ^TMemoryStatusEx;

Function GlobalMemoryStatusEx(lpBuffer: PMemoryStatusEx): BOOL; stdcall; external kernel32;

//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---

Function GetAvailableMemory: UInt64;
var
  MemStat:  TMemoryStatusEx;
begin
FillChar({%H-}MemStat,SizeOf(TMemoryStatusEx),0);
MemStat.dwLength := SizeOf(TMemoryStatusEx);
If not GlobalMemoryStatusEx(@MemStat) then
  raise Exception.CreateFmt('GlobalMemoryStatusEx has failed with error 0x%.8x.',[GetLastError]);
{$IFNDEF 64bit}
If MemStat.ullTotalPhys > $0000000080000000 then
  Result := $0000000080000000
else
{$ENDIF}
  Result := MemStat.ullTotalPhys;
end;

end.
