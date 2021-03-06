object frmProcSettingsZIP: TfrmProcSettingsZIP
  Left = 0
  Top = 0
  Width = 561
  Height = 473
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object pnlBackground: TPanel
    Left = 0
    Top = 0
    Width = 561
    Height = 473
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = True
    TabOrder = 0
    object gbGeneral: TGroupBox
      Tag = 20
      Left = 0
      Top = 0
      Width = 561
      Height = 49
      Caption = 'General'
      TabOrder = 0
      OnMouseMove = GroupBoxMouseMove
      object cbAssumeCompressionMethods: TCheckBox
        Tag = 21
        Left = 8
        Top = 24
        Width = 169
        Height = 17
        Caption = 'Assume compression methods'
        TabOrder = 0
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
    end
    object grbCentralDirectoryHeaders: TGroupBox
      Tag = 60
      Left = 0
      Top = 168
      Width = 561
      Height = 145
      Caption = 'Central directory headers'
      TabOrder = 2
      OnMouseMove = GroupBoxMouseMove
      object cbCDIgnoreCentralDirectory: TCheckBox
        Tag = 61
        Left = 8
        Top = 24
        Width = 137
        Height = 17
        Caption = 'Ignore central directory'
        TabOrder = 0
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreSignature: TCheckBox
        Tag = 62
        Left = 192
        Top = 24
        Width = 137
        Height = 17
        Caption = 'Ignore header signature'
        TabOrder = 1
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreVersions: TCheckBox
        Tag = 63
        Left = 376
        Top = 24
        Width = 97
        Height = 17
        Caption = 'Ignore versions'
        TabOrder = 2
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDClearEncryptionFlags: TCheckBox
        Tag = 64
        Left = 8
        Top = 48
        Width = 129
        Height = 17
        Caption = 'Clear encryption flags'
        TabOrder = 3
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreCompressionMethod: TCheckBox
        Tag = 65
        Left = 192
        Top = 48
        Width = 161
        Height = 17
        Caption = 'Ignore compression method'
        TabOrder = 4
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreModTime: TCheckBox
        Tag = 66
        Left = 376
        Top = 48
        Width = 121
        Height = 17
        Caption = 'Ignore last mod time'
        TabOrder = 5
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreModDate: TCheckBox
        Tag = 67
        Left = 8
        Top = 72
        Width = 121
        Height = 17
        Caption = 'Ignore last mod date'
        TabOrder = 6
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreCRC32: TCheckBox
        Tag = 68
        Left = 192
        Top = 72
        Width = 89
        Height = 17
        Caption = 'Ignore CRC32'
        TabOrder = 7
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreSizes: TCheckBox
        Tag = 69
        Left = 376
        Top = 72
        Width = 81
        Height = 17
        Caption = 'Ignore sizes'
        TabOrder = 8
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreInternalFileAttributes: TCheckBox
        Tag = 70
        Left = 8
        Top = 96
        Width = 161
        Height = 17
        Caption = 'Ignore internal file attributes'
        TabOrder = 9
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreExternalFileAttributes: TCheckBox
        Tag = 71
        Left = 192
        Top = 96
        Width = 169
        Height = 17
        Caption = 'Ignore external file attributes'
        TabOrder = 10
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreLocalHeaderOffset: TCheckBox
        Tag = 72
        Left = 376
        Top = 96
        Width = 145
        Height = 17
        Caption = 'Ignore local header offset'
        TabOrder = 11
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreExtraField: TCheckBox
        Tag = 73
        Left = 8
        Top = 120
        Width = 105
        Height = 17
        Caption = 'Ignore extra field'
        TabOrder = 12
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbCDIgnoreFileComment: TCheckBox
        Tag = 74
        Left = 192
        Top = 120
        Width = 121
        Height = 17
        Caption = 'Ignore file comment'
        TabOrder = 13
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
    end
    object grbLocalHeaders: TGroupBox
      Tag = 80
      Left = 0
      Top = 320
      Width = 561
      Height = 153
      Caption = 'Local headers'
      TabOrder = 3
      OnMouseMove = GroupBoxMouseMove
      object bvlLHSplit: TBevel
        Left = 8
        Top = 120
        Width = 545
        Height = 9
        Shape = bsTopLine
      end
      object cbLHIgnoreSignature: TCheckBox
        Tag = 82
        Left = 192
        Top = 24
        Width = 137
        Height = 17
        Caption = 'Ignore header signature'
        TabOrder = 1
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreVersions: TCheckBox
        Tag = 83
        Left = 376
        Top = 24
        Width = 97
        Height = 17
        Caption = 'Ignore versions'
        TabOrder = 2
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHClearEncryptionFlags: TCheckBox
        Tag = 84
        Left = 8
        Top = 48
        Width = 129
        Height = 17
        Caption = 'Clear encryption flags'
        TabOrder = 3
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreCompressionMethod: TCheckBox
        Tag = 85
        Left = 192
        Top = 48
        Width = 153
        Height = 17
        Caption = 'Ignore compression method'
        TabOrder = 4
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreModTime: TCheckBox
        Tag = 86
        Left = 376
        Top = 48
        Width = 121
        Height = 17
        Caption = 'Ignore last mod time'
        TabOrder = 5
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreModDate: TCheckBox
        Tag = 87
        Left = 8
        Top = 72
        Width = 121
        Height = 17
        Caption = 'Ignore last mod date'
        TabOrder = 6
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreCRC32: TCheckBox
        Tag = 88
        Left = 192
        Top = 72
        Width = 89
        Height = 17
        Caption = 'Ignore CRC32'
        TabOrder = 7
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreSizes: TCheckBox
        Tag = 89
        Left = 376
        Top = 72
        Width = 81
        Height = 17
        Caption = 'Ignore sizes'
        TabOrder = 8
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreExtraField: TCheckBox
        Tag = 91
        Left = 192
        Top = 96
        Width = 113
        Height = 17
        Caption = 'Ignore extra field'
        TabOrder = 10
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreDataDescriptor: TCheckBox
        Tag = 92
        Left = 8
        Top = 128
        Width = 129
        Height = 17
        Caption = 'Ignore data descriptor'
        TabOrder = 11
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreLocalHeaders: TCheckBox
        Tag = 81
        Left = 8
        Top = 24
        Width = 121
        Height = 17
        Caption = 'Ignore local headers'
        TabOrder = 0
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLHIgnoreFileName: TCheckBox
        Tag = 90
        Left = 8
        Top = 96
        Width = 105
        Height = 17
        Caption = 'Ignore file name'
        TabOrder = 9
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
    end
    object grdEndOfCentralDirectory: TGroupBox
      Tag = 40
      Left = 0
      Top = 56
      Width = 561
      Height = 105
      Caption = 'End of central directory'
      TabOrder = 1
      OnMouseMove = GroupBoxMouseMove
      object bvlEOCDSplit: TBevel
        Left = 8
        Top = 72
        Width = 545
        Height = 9
        Shape = bsTopLine
      end
      object cbIgnoreEndOfCentralDirectory: TCheckBox
        Tag = 41
        Left = 8
        Top = 24
        Width = 169
        Height = 17
        Caption = 'Ignore end of central directory'
        TabOrder = 0
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbIgnoreDiskSplit: TCheckBox
        Tag = 42
        Left = 192
        Top = 24
        Width = 97
        Height = 17
        Caption = 'Ignore disk split'
        TabOrder = 1
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbIgnoreNumberOfEntries: TCheckBox
        Tag = 43
        Left = 376
        Top = 24
        Width = 145
        Height = 17
        Caption = 'Ignore number of entries'
        TabOrder = 2
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbIgnoreCentralDirectoryOffset: TCheckBox
        Tag = 44
        Left = 8
        Top = 48
        Width = 169
        Height = 17
        Caption = 'Ignore central directory offset'
        TabOrder = 3
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbIgnoreComment: TCheckBox
        Tag = 45
        Left = 192
        Top = 48
        Width = 105
        Height = 17
        Caption = 'Ignore comment'
        TabOrder = 4
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
      object cbLimitSearch: TCheckBox
        Tag = 46
        Left = 8
        Top = 80
        Width = 185
        Height = 17
        Caption = 'Limit search to one buffer (~1MiB)'
        TabOrder = 5
        OnClick = CheckBoxClick
        OnMouseMove = SettingsMouseMove
      end
    end
  end
end
