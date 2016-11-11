object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 353
  ClientWidth = 657
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 104
    Top = 32
    Width = 105
    Height = 49
    Caption = 'server/version GET'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 48
    Top = 136
    Width = 105
    Height = 49
    Caption = 'Auth POST'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 184
    Top = 136
    Width = 89
    Height = 49
    Caption = 'Send POST'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 104
    Top = 216
    Width = 121
    Height = 65
    Caption = 'Enable Presence POST'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 272
    Top = 216
    Width = 105
    Height = 65
    Caption = 'Presence GET'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 408
    Top = 232
    Width = 89
    Height = 33
    Caption = 'Disable POST'
    TabOrder = 5
    OnClick = Button6Click
  end
end
