unit Unit1;

interface

uses
    Winapi.Windows, Winapi.Messages, SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    Vcl.ComCtrls, Vcl.Shell.ShellCtrls, Vcl.FileCtrl, XPMan,
    Vcl.StdCtrls, ShellApi, Vcl.ExtCtrls;

const
  {$IFDEF LINUX}
  PathSeparator   = '/';
  {$ENDIF LINUX}
  {$IFDEF WIN32}
  DriveLetters    = ['a'..'z', 'A'..'Z'];
  PathDevicePrefix = '\\.\';
  PathSeparator   = '\';
  PathUncPrefix   = '\\';
  {$ENDIF WIN32}

type
  TDelTreeProgress = function (const FileName: string; Attr: DWORD): Boolean;


type
  TForm1 = class(TForm)
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    RadioGroup1: TRadioGroup;
    Edit1: TEdit;
    Button1: TButton;
    Button4: TButton;
    Label3: TLabel;
    GroupBox2: TGroupBox;
    Button2: TButton;
    ListBox1: TListBox;
    Button3: TButton;
    Button5: TButton;
    RadioButton2: TRadioButton;
    RadioButton1: TRadioButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Terminate: TButton;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure TerminateClick(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    function DelTree(const Path: string): Boolean;
    function PathRemoveSeparator(const Path: string): string;
    function BuildFileList(const Path: string; const Attr: Integer; const List: TStrings): Boolean;
    function DelTreeEx(const Path: string; AbortOnFailure: Boolean; Progress: TDelTreeProgress): Boolean;
  end;

type
  TStringDynArray = array of string;

var
  Form1: TForm1;
  Dir : string;
  FileCount: Cardinal = 0;
  Files : TStringDynArray = nil;
  stop : string;  // do not change string or Terminate not works

implementation

{$R *.dfm}
function FileGetSize(const FileName: string): Integer;
var
  SearchRec: TSearchRec;
{$IFDEF MSWINDOWS}
  OldMode: Cardinal;
{$ENDIF MSWINDOWS}
begin
  Result := -1;
{$IFDEF MSWINDOWS}
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
{$ENDIF MSWINDOWS}
    if FindFirst(FileName, faAnyFile, SearchRec) = 0 then
    begin
      Result := SearchRec.Size;
      SysUtils.FindClose(SearchRec);
    end;
{$IFDEF MSWINDOWS}
  finally
    SetErrorMode(OldMode);
  end;
{$ENDIF MSWINDOWS}
end;

function ExtractDirName(Path:string):string;
var
  i:integer;
begin
  // Check if last Char is \
  if Pos('\', Path[Length(Path)]) = 1 then
    Path:=Copy(Path,1,Length(Path) - 1);
  // ExtractDirName
  for i:=Length(Path) downto 0 do
    if Pos('\', Path[i]) = 1 then
    begin
      Result:=Copy(Path,i+1,Length(Path)-i);
      Exit;
    end;
end;

function DirectoryIsEmpty(Directory: string): Boolean;
var
  SR: TSearchRec;
  i: Integer;
begin
  Result := False;
  FindFirst(IncludeTrailingPathDelimiter(Directory) + '*', faAnyFile, SR);
  for i := 1 to 2 do
    if (SR.Name = '.') or (SR.Name = '..') then
      Result := FindNext(SR) <> 0;
  FindClose(SR);
end;

function FileSize(const aFilename: String): Int64;
  var
    info: TWin32FileAttributeData;
  begin
    result := -1;

    if NOT GetFileAttributesEx(PChar(aFileName), GetFileExInfoStandard, @info) then
      EXIT;

    result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
  end;

function Get_File_Size4(const S: string): Int64;
var
  FD: TWin32FindData;
  FH: THandle;
begin
  FH := FindFirstFile(PChar(S), FD);
  if FH = INVALID_HANDLE_VALUE then Result := 0
  else
    try
      Result := FD.nFileSizeHigh;
      Result := Result shl 32;
      Result := Result + FD.nFileSizeLow;
    except
      CloseHandle(FH);
    end;
end;

function FindAllFiles(RootFolder: string; Mask: string = '*.*'; Recurse: Boolean
  = True): TStringDynArray;
var
  wfd : TWin32FindData;
  hFile : THandle;
begin
  if AnsiLastChar(RootFolder)^ <> '\' then
    RootFolder := RootFolder + '\';
  if Recurse then
  begin
    hFile := FindFirstFile(PChar(RootFolder + '*.*'), wfd);
    if hFile <> INVALID_HANDLE_VALUE then
    try
      repeat
        if wfd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY =
          FILE_ATTRIBUTE_DIRECTORY then
          if (string(wfd.cFileName) <> '.') and (string(wfd.cFileName) <> '..')
            then
            FindAllFiles(RootFolder + wfd.cFileName, Mask, Recurse);
      until FindNextFile(hFile, wfd) = False;
    finally
      //windows.FindClose(hFile);
    end;
  end;                        // Specify the files to search here
  hFile := FindFirstFile(PChar(RootFolder + '*.*'), wfd);
  if hFile <> INVALID_HANDLE_VALUE then
  try
    repeat
      if wfd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <>
        FILE_ATTRIBUTE_DIRECTORY then
      begin
        FileCount := length(Files)+1;
        Setlength(Files, FileCount);
        Files[FileCount - 1] := RootFolder + String(wfd.cFileName);
      end;
    until FindNextFile(hFile, wfd) = False;
  finally
    //Windows.FindClose(hFile);
  end;
end;

procedure IcoToBmpA(Ico: TIcon; Bmp: TBitmap; SmallIcon: Boolean);
var
  WH: Byte; // Width and Height
begin
  with Bmp do
  begin
    //Canvas.Brush.Color := clFuchsia;
    //TransparentColor := clFuchsia;
    Width := 16; Height := 16;
    Canvas.Draw(0, 0, Ico);

    if SmallIcon then
      WH := 16
    else
      WH := 32;
    Canvas.StretchDraw(Rect(0, 0, WH, WH), Bmp);
    Width := WH; Height := WH;
    Transparent :=  True;
  end;
end;

procedure GetIconFromFileB(const FileName: String; Icon: TIcon;
  SmallIcon: Boolean);
var
  sfi: TSHFILEINFO;
const
  uFlags : array[Boolean] of DWord = (SHGFI_LARGEICON, SHGFI_SMALLICON);
begin
  if SHGetFileInfo(PChar(FileName), 0, sfi, SizeOf(sfi), SHGFI_ICON or
     uFlags[SmallIcon]) <> 0 then
    Icon.Handle := sfi.hIcon;
end;

procedure DrawListBoxExtra(Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
const
  Col1: array [Boolean] of TColor = ($00F8F8F8, clWindow);
  Col2: array [Boolean] of TColor = (clInactiveCaptionText, clWindowText);
var
  Icon: TIcon;
  Bmp: TBitmap;
begin
  with (Control as TListbox) do
  begin
    Icon := TIcon.Create;
    Bmp := TBitmap.Create;
    try
      if odSelected in State then
        Canvas.Font.Color := clCaptionText
      else
      begin
        Bmp.Canvas.Brush.Color := Canvas.Brush.Color;
        Canvas.Brush.Color := Col1[Odd(Index)];
        Canvas.Font.Color := Col2[(Control as TListBox).Enabled];
      end;
      GetIconFromFileB(Items[Index], Icon, True);
      IcoToBmpA(Icon, Bmp, True);
      Canvas.TextRect(Rect, Rect.Left + Bmp.Width + 2, Rect.Top + 2, Items[Index]);
      Canvas.Draw(Rect.Left, Rect.Top, Bmp);
    finally
      Bmp.Free;
      Icon.Free;
    end;
  end;
end;

procedure ShredFile(const FileName: string; Times: Integer);
const
  //BUFSIZE = 4096; // Enter only for fixed units
  ODD_FILL = $C1;
  EVEN_FILL = $3E;
var
  BUFSIZE : integer;
  Fs : TFileStream;
  Size : Integer;
  N : Integer;
  ContentPtr: Pointer;
begin
  case Form1.RadioGroup1.ItemIndex of
      0 : BUFSIZE := 1024;
      1 : BUFSIZE := 2048;
      2 : BUFSIZE := 4098;
      3 : BUFSIZE := 8192;
  end;

  Size := FileGetSize(FileName);
  if Size > 0 then
  begin
    if Times < 0 then
      Times := 2
    else
      Times := Times * 2;
    ContentPtr := nil;
    Fs := TFileStream.Create(FileName, fmOpenReadWrite);
    try
      GetMem(ContentPtr, BUFSIZE);
      while Times > 0 do
      begin

      if stop  = 's' then Exit;

        if Times mod 2 = 0 then
          FillMemory(ContentPtr, BUFSIZE, EVEN_FILL)
        else
        FillMemory(ContentPtr, BUFSIZE, ODD_FILL);
        Fs.Seek(0, soFromBeginning);
        N := Size div BUFSIZE;

        while N > 0 do
        begin
          if n mod 50 = 0 then

          if Form1.ListBox1.Items.Count > -1 then begin
          Form1.Label1.Caption := IntToStr(size);
          end;

          if Form1.Edit1.Text > '' then begin
            Form1.Label1.Caption := IntToStr(n);
            Form1.ProgressBar1.Position := n;
            if stop = 's' then Exit;
          end;

          Application.ProcessMessages;

          Fs.Write(ContentPtr^, BUFSIZE);
          Dec(N);
        end;
        N := Size mod BUFSIZE;
        if N > 0 then
          Fs.Write(ContentPtr^, N);
        FlushFileBuffers(Fs.Handle);
        Dec(Times);
      end;
    finally
      if ContentPtr <> nil then
        FreeMem(ContentPtr, Size);
      Fs.Free;
      DeleteFile(FileName);
    end;
  end
  else
    DeleteFile(FileName);

    if Form1.ListBox1.Items.Count > -1 then begin
    Form1.ProgressBar1.Position := Form1.ProgressBar1.Position + 1;
    end;

    if Form1.Edit1.Text > '' then begin
    Form1.Label1.Caption := '000000';
    Form1.StatusBar1.Panels[4].Text := 'finish.';
    Form1.StatusBar1.Panels[3].Text := '0 bytes';
    Form1.ProgressBar1.Position := 0;
    Form1.Button1.Enabled := true;
    end;
end;

function TForm1.DelTree(const Path: string): Boolean;
begin
  Result := DelTreeEx(Path, False, nil);
end;

function TForm1.DelTreeEx(const Path: string; AbortOnFailure: Boolean; Progress: TDelTreeProgress): Boolean;
var
  Files: TStringList;
  LPath: string;      // writable copy of Path
  FileName: string;
  i : Integer;
  PartialResult: Boolean;
  Attr: DWORD;
begin
  Result := True;
  Files := TStringList.Create;
  try
    LPath := PathRemoveSeparator(Path);
    BuildFileList(LPath + '\*.*', faAnyFile, Files);
    for i := 0 to Files.Count - 1 do
    begin
      if stop  = 's' then Exit;
      FileName := LPath + '\' + Files[I];
      PartialResult := True;

      Form1.ProgressBar1.Position := i;
      Form1.Label1.Caption := IntToStr(i);
      Application.ProcessMessages;

      // If the current file is itself a directory then recursively delete it
      if Form1.CheckBox2.Checked = true then begin
      Attr := GetFileAttributes(PChar(FileName));
      end;

      if (Attr <> DWORD(-1)) and ((Attr and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
        PartialResult := DelTreeEx(FileName, AbortOnFailure, Progress)
      else
      begin
        if Assigned(Progress) then
          PartialResult := Progress(FileName, Attr);
        if PartialResult then
        begin
          // Set attributes to normal in case it's a readonly file
          PartialResult := SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);
          if PartialResult then
            PartialResult := DeleteFile(FileName);
        end;
      end;
      if not PartialResult then
      begin
        Result := False;
        if AbortOnFailure then
          Break;
      end;
    end;
  finally
    FreeAndNil(Files);
  end;
  if Result then
  begin
    // Finally remove the directory itself
    Result := SetFileAttributes(PChar(LPath), FILE_ATTRIBUTE_NORMAL);
    if Result then
    begin
      {$I-}
      RmDir(LPath);
      {$I+}
      Result := IOResult = 0;
    end;
  end;
  Form1.ProgressBar1.Position := 0;
  Form1.Label1.Caption := '000000';
  Form1.StatusBar1.Panels[4].Text := 'finish.';
  Form1.StatusBar1.Panels[3].Text := '0 bytes';
  Form1.StatusBar1.Panels[1].Text := '0';
  Form1.Button2.Enabled := true;
  Form1.ListBox1.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DoubleBuffered := true;
end;

procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  DrawListBoxExtra(Control, Index, Rect, State);
end;

function TForm1.PathRemoveSeparator(const Path: string): string;
var
  L: Integer;
begin
  L := Length(Path);

  if CheckBox1.Checked = true then begin
    if (L <> 0) and (AnsiLastChar(Path) = PathSeparator) then begin
      Result := Copy(Path, 1, L - 1); end else begin Result := Path;
    end;
  end;

  if CheckBox1.Checked = false then begin
    if (L <> 0) and (AnsiLastChar(Path) = PathSeparator) then begin
      Result := Copy(Path, 0, L - 0); end else begin Result := Path;
    end;
  end;

end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  Label2.Caption := 'Shredder Blocks $';
end;

procedure TForm1.RadioButton2Click(Sender: TObject);
begin
  Label2.Caption := 'Shredder Bits      $';
end;

function TForm1.BuildFileList(const Path: string; const Attr: Integer;
  const List: TStrings): Boolean;
var
  SearchRec: TSearchRec;
  R: Integer;
begin
  Assert(List <> nil);
  R := FindFirst(Path, Attr, SearchRec);
  Result := R = 0;
  if Result then
  begin
    while R = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      List.Add(SearchRec.Name);
      R := FindNext(SearchRec);
      Application.ProcessMessages;

    end;
    Result := R = ERROR_NO_MORE_FILES;
    SysUtils.FindClose(SearchRec);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Edit1.Text = '' then begin
      MessageDlg('No File loaded',mtInformation, [mbOK], 0);
      Exit;
  end;


  IF MessageDlg('ATTENTION !'+#13+
                'This will Shredder File : "' + ExtractFileName(Edit1.Text) + '"' + #13 +
                'are you sure?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes THEN
    BEGIN
      StatusBar1.Panels[4].Text := 'Processing, please wait..';
      Button1.Enabled := false;

      if RadioButton1.Checked = true then begin
      ShredFile(Edit1.Text, 1);
      end;

      if RadioButton2.Checked = true then begin
      ShredFile(Edit1.Text, 8);
      end;
    END;
    StatusBar1.SetFocus;
end;

procedure TForm1.Button2Click(Sender: TObject);
var i : integer;
begin
    if ListBox1.Items.Count < 1 then begin
      MessageDlg('No Files loaded',mtInformation, [mbOK], 0);
      Exit;
    end;

    IF MessageDlg('ATTENTION !'+#13+
                'This will Shredder Folder : "' + ExtractDirName(Dir) + '"' + #13 +
                'And all subfolders with all files contained therein,' + #13 +
                'are you sure?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes THEN
    BEGIN
      StatusBar1.Panels[4].Text := 'Processing, please wait..';
      stop := 'a';
      Button2.Enabled := false;

      if RadioButton1.Checked = true then begin
          if DirectoryExists(Dir) then
           begin
             DELTREE(Dir);
           end;
       end;

       if RadioButton2.Checked = true then begin
         for i := 0 to ListBox1.Items.Count-1 do begin
            if stop = 's' then Exit;
            ShredFile(ListBox1.Items.Strings[i], 10);
          end;
          if stop = 's' then Exit;
          DELTREE(Dir);
       end;
      END;
end;

procedure TForm1.Button3Click(Sender: TObject);
var  i, s, f  : Integer;
begin
  s := 0;
  Dir := '';

  if SelectDirectory('Select directory', '', Dir) then begin

    if DirectoryIsEmpty(Dir) then begin
      MessageDlg('This Folder is Empty!',mtInformation, [mbOK], 0);
      Exit;
    end;
  end;

  try
    Edit1.Clear;
    Files := nil;
    ListBox1.Clear;
    FindAllFiles(Dir, '*.*', True);
    ProgressBar1.Position := 0;
  except
  end;

  for i := 0 to length(Files) - 1 do
  begin
    Listbox1.Items.Add(Files[i]);
    f := FileSize(Files[i]);
    s := s + f;
  end;

  StatusBar1.Panels[1].Text := IntToStr(ListBox1.Items.Count);
  ProgressBar1.Max := ListBox1.Items.Count;
  StatusBar1.Panels[3].Text := IntToStr(s) + ' bytes';
  ListBox1.Perform(WM_VSCROLL, SB_BOTTOM, 0);
  StatusBar1.SetFocus;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
  stop := 'a';
  ProgressBar1.Position := 0;
  ProgressBar1.Max := 100;
  Edit1.Text := OpenDialog1.FileName;
  ListBox1.Clear;
  StatusBar1.Panels[3].Text :=  IntToStr(FileSize(Edit1.Text)) + ' bytes';
  end;
  StatusBar1.SetFocus;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  ListBox1.Clear;
  Dir := '';
end;

procedure TForm1.TerminateClick(Sender: TObject);
begin
  stop  := 's';
  Button1.Enabled := true;
  Button2.Enabled := true;
end;

end.
