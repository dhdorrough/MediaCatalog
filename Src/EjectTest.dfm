object Form1: TForm1
  Left = 598
  Top = 342
  Width = 741
  Height = 355
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object rgSelectDrive: TRadioGroup
    Left = 24
    Top = 24
    Width = 89
    Height = 105
    Caption = 'SelectDrive'
    TabOrder = 0
  end
  object rbD: TRadioButton
    Left = 40
    Top = 48
    Width = 43
    Height = 17
    Caption = 'D:'
    TabOrder = 1
  end
  object rbE: TRadioButton
    Left = 40
    Top = 76
    Width = 43
    Height = 17
    Caption = 'E:'
    TabOrder = 2
  end
  object rbF: TRadioButton
    Left = 40
    Top = 104
    Width = 43
    Height = 17
    Caption = 'F:'
    TabOrder = 3
  end
  object btnOpen: TButton
    Left = 240
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 4
    OnClick = btnOpenClick
  end
  object btnClose: TButton
    Left = 240
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 5
    OnClick = btnCloseClick
  end
end
