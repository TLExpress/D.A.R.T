object fPrcsSettingsForm: TfPrcsSettingsForm
  Left = 113
  Top = 57
  BorderStyle = bsDialog
  Caption = 'Processing settings'
  ClientHeight = 624
  ClientWidth = 888
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblSettingDescription: TLabel
    Left = 576
    Top = 8
    Width = 93
    Height = 13
    Caption = 'Setting description:'
  end
  object grdEndOfCentralDirectory: TGroupBox
    Left = 8
    Top = 200
    Width = 561
    Height = 105
    Caption = 'End of central directory'
    TabOrder = 1
    object bvlEOCDSplit: TBevel
      Left = 8
      Top = 72
      Width = 545
      Height = 9
      Shape = bsTopLine
    end
    object cbIgnoreEndOfCentralDirectory: TCheckBox
      Tag = 100
      Left = 8
      Top = 24
      Width = 169
      Height = 17
      Caption = 'Ignore end of central directory'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object cbIgnoreDiskSplit: TCheckBox
      Tag = 101
      Left = 192
      Top = 24
      Width = 97
      Height = 17
      Caption = 'Ignore disk split'
      TabOrder = 1
      OnClick = CheckBoxClick
    end
    object cbIgnoreNumberOfEntries: TCheckBox
      Tag = 102
      Left = 376
      Top = 24
      Width = 145
      Height = 17
      Caption = 'Ignore number of entries'
      TabOrder = 2
      OnClick = CheckBoxClick
    end
    object cbIgnoreCentralDirectoryOffset: TCheckBox
      Tag = 103
      Left = 8
      Top = 48
      Width = 169
      Height = 17
      Caption = 'Ignore central directory offset'
      TabOrder = 3
      OnClick = CheckBoxClick
    end
    object cbIgnoreComment: TCheckBox
      Tag = 104
      Left = 192
      Top = 48
      Width = 105
      Height = 17
      Caption = 'Ignore comment'
      TabOrder = 4
      OnClick = CheckBoxClick
    end
    object cbLimitSearch: TCheckBox
      Left = 8
      Top = 80
      Width = 185
      Height = 17
      Caption = 'Limit search to one buffer (~1MiB)'
      TabOrder = 5
    end
  end
  object grbCentralDirectoryHeaders: TGroupBox
    Left = 8
    Top = 312
    Width = 561
    Height = 145
    Caption = 'Central directory headers'
    TabOrder = 2
    object cbCDIgnoreCentralDirectory: TCheckBox
      Tag = 200
      Left = 8
      Top = 24
      Width = 137
      Height = 17
      Caption = 'Ignore central directory'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreSignature: TCheckBox
      Tag = 201
      Left = 192
      Top = 24
      Width = 137
      Height = 17
      Caption = 'Ignore header signature'
      TabOrder = 1
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreVersions: TCheckBox
      Tag = 202
      Left = 376
      Top = 24
      Width = 97
      Height = 17
      Caption = 'Ignore versions'
      TabOrder = 2
      OnClick = CheckBoxClick
    end
    object cbCDClearEncryptionFlags: TCheckBox
      Tag = 203
      Left = 8
      Top = 48
      Width = 129
      Height = 17
      Caption = 'Clear encryption flags'
      TabOrder = 3
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreCompressionMethod: TCheckBox
      Tag = 204
      Left = 192
      Top = 48
      Width = 161
      Height = 17
      Caption = 'Ignore compression method'
      TabOrder = 4
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreModTime: TCheckBox
      Tag = 205
      Left = 376
      Top = 48
      Width = 121
      Height = 17
      Caption = 'Ignore last mod time'
      TabOrder = 5
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreModDate: TCheckBox
      Tag = 206
      Left = 8
      Top = 72
      Width = 121
      Height = 17
      Caption = 'Ignore last mod date'
      TabOrder = 6
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreCRC32: TCheckBox
      Tag = 207
      Left = 192
      Top = 72
      Width = 89
      Height = 17
      Caption = 'Ignore CRC32'
      TabOrder = 7
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreSizes: TCheckBox
      Tag = 208
      Left = 376
      Top = 72
      Width = 81
      Height = 17
      Caption = 'Ignore sizes'
      TabOrder = 8
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreInternalFileAttributes: TCheckBox
      Tag = 209
      Left = 8
      Top = 96
      Width = 161
      Height = 17
      Caption = 'Ignore internal file attributes'
      TabOrder = 9
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreExternalFileAttributes: TCheckBox
      Tag = 210
      Left = 192
      Top = 96
      Width = 169
      Height = 17
      Caption = 'Ignore external file attributes'
      TabOrder = 10
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreLocalHeaderOffset: TCheckBox
      Tag = 211
      Left = 376
      Top = 96
      Width = 145
      Height = 17
      Caption = 'Ignore local header offset'
      TabOrder = 11
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreExtraField: TCheckBox
      Tag = 212
      Left = 8
      Top = 120
      Width = 105
      Height = 17
      Caption = 'Ignore extra field'
      TabOrder = 12
      OnClick = CheckBoxClick
    end
    object cbCDIgnoreFileComment: TCheckBox
      Tag = 213
      Left = 192
      Top = 120
      Width = 121
      Height = 17
      Caption = 'Ignore file comment'
      TabOrder = 13
      OnClick = CheckBoxClick
    end
  end
  object grbLocalHeaders: TGroupBox
    Left = 8
    Top = 464
    Width = 561
    Height = 153
    Caption = 'Local headers'
    TabOrder = 3
    object bvlLHSplit: TBevel
      Left = 8
      Top = 120
      Width = 545
      Height = 9
      Shape = bsTopLine
    end
    object cbLHIgnoreSignature: TCheckBox
      Tag = 301
      Left = 192
      Top = 24
      Width = 137
      Height = 17
      Caption = 'Ignore header signature'
      TabOrder = 1
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreVersions: TCheckBox
      Tag = 302
      Left = 376
      Top = 24
      Width = 97
      Height = 17
      Caption = 'Ignore versions'
      TabOrder = 2
      OnClick = CheckBoxClick
    end
    object cbLHClearEncryptionFlags: TCheckBox
      Tag = 303
      Left = 8
      Top = 48
      Width = 129
      Height = 17
      Caption = 'Clear encryption flags'
      TabOrder = 3
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreCompressionMethod: TCheckBox
      Tag = 304
      Left = 192
      Top = 48
      Width = 153
      Height = 17
      Caption = 'Ignore compression method'
      TabOrder = 4
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreModTime: TCheckBox
      Tag = 305
      Left = 376
      Top = 48
      Width = 121
      Height = 17
      Caption = 'Ignore last mod time'
      TabOrder = 5
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreModDate: TCheckBox
      Tag = 306
      Left = 8
      Top = 72
      Width = 121
      Height = 17
      Caption = 'Ignore last mod date'
      TabOrder = 6
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreCRC32: TCheckBox
      Tag = 307
      Left = 192
      Top = 72
      Width = 89
      Height = 17
      Caption = 'Ignore CRC32'
      TabOrder = 7
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreSizes: TCheckBox
      Tag = 308
      Left = 376
      Top = 72
      Width = 81
      Height = 17
      Caption = 'Ignore sizes'
      TabOrder = 8
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreExtraField: TCheckBox
      Tag = 310
      Left = 192
      Top = 96
      Width = 113
      Height = 17
      Caption = 'Ignore extra field'
      TabOrder = 10
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreDataDescriptor: TCheckBox
      Tag = 311
      Left = 8
      Top = 128
      Width = 129
      Height = 17
      Caption = 'Ignore data descriptor'
      TabOrder = 11
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreLocalHeaders: TCheckBox
      Tag = 300
      Left = 8
      Top = 24
      Width = 121
      Height = 17
      Caption = 'Ignore local headers'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object cbLHIgnoreFileName: TCheckBox
      Tag = 309
      Left = 8
      Top = 96
      Width = 105
      Height = 17
      Caption = 'Ignore file name'
      TabOrder = 9
      OnClick = CheckBoxClick
    end
  end
  object btnAccept: TButton
    Left = 680
    Top = 592
    Width = 97
    Height = 25
    Caption = 'Accept'
    TabOrder = 4
    OnClick = btnAcceptClick
  end
  object btnClose: TButton
    Left = 784
    Top = 592
    Width = 97
    Height = 25
    Caption = 'Close'
    TabOrder = 5
    OnClick = btnCloseClick
  end
  object grbGeneral: TGroupBox
    Left = 8
    Top = 8
    Width = 561
    Height = 185
    Caption = 'General settings'
    TabOrder = 0
    object bvlGeneralhorSplit: TBevel
      Left = -176
      Top = 126
      Width = 729
      Height = 9
      Shape = bsTopLine
    end
    object vblGeneralHorSplit_File: TBevel
      Left = 8
      Top = 46
      Width = 545
      Height = 9
      Shape = bsTopLine
    end
    object lblFile: TLabel
      Left = 8
      Top = 24
      Width = 26
      Height = 13
      Caption = 'lblFile'
      Constraints.MaxWidth = 393
    end
    object cbIgnoreFileSignature: TCheckBox
      Left = 8
      Top = 136
      Width = 121
      Height = 17
      Caption = 'Ignore file signature'
      TabOrder = 4
      OnClick = CheckBoxClick
    end
    object cbAssumeCompressionMethods: TCheckBox
      Left = 192
      Top = 136
      Width = 169
      Height = 17
      Caption = 'Assume compression methods'
      TabOrder = 5
      OnClick = CheckBoxClick
    end
    object rbRebuild: TRadioButton
      Left = 8
      Top = 56
      Width = 97
      Height = 17
      Caption = 'Rebuild archive'
      TabOrder = 0
      OnClick = RepairMethodClick
    end
    object rbExtract: TRadioButton
      Tag = 1
      Left = 112
      Top = 56
      Width = 97
      Height = 17
      Caption = 'Extract archive'
      TabOrder = 1
      OnClick = RepairMethodClick
    end
    object lbleData: TLabeledEdit
      Left = 8
      Top = 96
      Width = 520
      Height = 21
      EditLabel.Width = 27
      EditLabel.Height = 13
      EditLabel.Caption = 'Data:'
      TabOrder = 2
      OnChange = lbleDataChange
    end
    object btnBrowse: TButton
      Left = 528
      Top = 96
      Width = 25
      Height = 21
      Caption = '...'
      TabOrder = 3
      OnClick = btnBrowseClick
    end
    object cbInMemoryProcessing: TCheckBox
      Left = 376
      Top = 136
      Width = 129
      Height = 17
      Caption = 'In memory processing'
      TabOrder = 6
    end
    object cbIgnoreProcessingErrors: TCheckBox
      Left = 8
      Top = 160
      Width = 145
      Height = 17
      Caption = 'Ignore processing errors'
      TabOrder = 7
    end
  end
  object meHint: TMemo
    Left = 576
    Top = 24
    Width = 305
    Height = 561
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'Move cursor over specific setting to see '
      'its description.')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object diaSaveDialog: TSaveDialog
    DefaultExt = '.scs'
    Filter = 
      'SCS mod archive (*.scs)|*.scs|ZIP archive (*.zip)|*.zip|All file' +
      's (*.*)|*.*'
    Left = 856
  end
end
