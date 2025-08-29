object Form1: TForm1
  Left = 192
  Top = 114
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Shredder Files & Folders'
  ClientHeight = 552
  ClientWidth = 431
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object Label1: TLabel
    Left = 112
    Top = 485
    Width = 36
    Height = 13
    Caption = '000000'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 24
    Top = 485
    Width = 87
    Height = 13
    Caption = 'Shredder Blocks $'
  end
  object Label3: TLabel
    Left = 24
    Top = 8
    Width = 314
    Height = 39
    Caption = 'Shredder Files && Folders'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'Impact'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 40
    Top = 45
    Width = 301
    Height = 13
    Caption = 'An example of how to completely remove files and entire folders.'
  end
  object ProgressBar1: TProgressBar
    Left = 24
    Top = 504
    Width = 386
    Height = 17
    TabOrder = 0
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 533
    Width = 431
    Height = 19
    Panels = <
      item
        Text = 'File Count :'
        Width = 70
      end
      item
        Text = '0'
        Width = 50
      end
      item
        Text = 'Size :'
        Width = 40
      end
      item
        Text = '0 bytes'
        Width = 120
      end
      item
        Text = 'ready.'
        Width = 50
      end>
    ExplicitTop = 514
    ExplicitWidth = 427
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 64
    Width = 417
    Height = 130
    Caption = ' File '
    TabOrder = 2
    object RadioGroup1: TRadioGroup
      Left = 16
      Top = 59
      Width = 289
      Height = 62
      Caption = ' Buffer '
      Columns = 2
      ItemIndex = 2
      Items.Strings = (
        '1024 (slow)'
        '2048'
        '4096'
        '8192 (fast)')
      TabOrder = 0
    end
    object Edit1: TEdit
      Left = 16
      Top = 24
      Width = 353
      Height = 21
      TabStop = False
      ReadOnly = True
      TabOrder = 1
    end
    object Button1: TButton
      Left = 327
      Top = 96
      Width = 75
      Height = 25
      Caption = 'Shredder'
      TabOrder = 2
      TabStop = False
      OnClick = Button1Click
    end
    object Button4: TButton
      Left = 375
      Top = 23
      Width = 27
      Height = 24
      Caption = '...'
      TabOrder = 3
      TabStop = False
      OnClick = Button4Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 200
    Width = 417
    Height = 193
    Caption = ' Folder '
    TabOrder = 3
    object Button2: TButton
      Left = 327
      Top = 159
      Width = 75
      Height = 25
      Caption = 'Shredder'
      TabOrder = 0
      TabStop = False
      OnClick = Button2Click
    end
    object ListBox1: TListBox
      Left = 16
      Top = 24
      Width = 386
      Height = 129
      TabStop = False
      Style = lbOwnerDrawFixed
      TabOrder = 1
      OnDrawItem = ListBox1DrawItem
    end
    object Button3: TButton
      Left = 16
      Top = 159
      Width = 75
      Height = 25
      Caption = 'Folder'
      TabOrder = 2
      TabStop = False
      OnClick = Button3Click
    end
    object Button5: TButton
      Left = 97
      Top = 159
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 3
      TabStop = False
      OnClick = Button5Click
    end
  end
  object RadioButton2: TRadioButton
    Left = 24
    Top = 430
    Width = 117
    Height = 17
    Hint = 
      'This function shreds every single bit of a byte, which takes lon' +
      'ger but is more accurate.'
    Caption = 'Shredder Bits (slow)'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnClick = RadioButton2Click
  end
  object RadioButton1: TRadioButton
    Left = 24
    Top = 407
    Width = 129
    Height = 17
    Hint = 'This feature shreds bytes in blocks to speed up the process.'
    Caption = 'Shredder Blocks (fast)'
    Checked = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    TabStop = True
    OnClick = RadioButton1Click
  end
  object CheckBox1: TCheckBox
    Left = 249
    Top = 407
    Width = 120
    Height = 17
    Hint = 
      'This function overwrites the directory separator so that the pat' +
      'h can no longer be determined.'
    Caption = 'Shredder Seperators'
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 6
  end
  object CheckBox2: TCheckBox
    Left = 249
    Top = 430
    Width = 104
    Height = 17
    Hint = 
      'This function manipulates the file attributes so that it does no' +
      't allow for subsequent comparison.'
    Caption = 'Set File Attributes'
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 7
  end
  object Terminate: TButton
    Left = 335
    Top = 473
    Width = 75
    Height = 25
    Caption = 'Terminate'
    TabOrder = 8
    TabStop = False
    OnClick = TerminateClick
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Any File (*.*)|*.*'
    Left = 64
    Top = 248
  end
end
