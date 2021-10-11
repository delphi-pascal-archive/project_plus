object Form2: TForm2
  Left = 425
  Top = 165
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1042#1099#1073#1086#1088' '#1087#1088#1086#1077#1082#1090#1072
  ClientHeight = 189
  ClientWidth = 330
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 166
    Width = 128
    Height = 13
    Caption = 'C:\...\ART - Laboratory\P+'
  end
  object Label2: TLabel
    Left = 168
    Top = 10
    Width = 40
    Height = 13
    Caption = #1060#1072#1081#1083#1099':'
  end
  object SpeedButton1: TSpeedButton
    Left = 256
    Top = 162
    Width = 65
    Height = 25
    Caption = 'OK'
    OnClick = SpeedButton1Click
  end
  object DirectoryListBox1: TDirectoryListBox
    Left = 8
    Top = 32
    Width = 153
    Height = 129
    DirLabel = Label1
    FileList = FileListBox1
    ItemHeight = 16
    TabOrder = 0
  end
  object DriveComboBox1: TDriveComboBox
    Left = 8
    Top = 8
    Width = 153
    Height = 19
    DirList = DirectoryListBox1
    TabOrder = 1
  end
  object FileListBox1: TFileListBox
    Left = 168
    Top = 32
    Width = 153
    Height = 129
    ItemHeight = 13
    TabOrder = 2
  end
end
