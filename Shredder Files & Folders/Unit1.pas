unit Unit1;

interface

uses
    Windows, Winapi.Messages, SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    Vcl.ComCtrls, Vcl.Shell.ShellCtrls, Vcl.FileCtrl, XPMan,
    Vcl.StdCtrls, ShellApi, Vcl.ExtCtrls, Vcl.Menus,
    ActiveX, ShlObj, ComObj, Vcl.Grids;

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
    PopupMenu1: TPopupMenu;
    Properties1: TMenuItem;
    AllProperties1: TMenuItem;
    Owner1: TMenuItem;
    yp1: TMenuItem;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    CheckBox3: TCheckBox;
    Label9: TLabel;
    Label10: TLabel;
    N1: TMenuItem;
    SetNormal1: TMenuItem;
    SetArchive1: TMenuItem;
    SetOffline1: TMenuItem;
    N2: TMenuItem;
    SetReadonly1: TMenuItem;
    SetSystem1: TMenuItem;
    SetTemporary1: TMenuItem;
    StringGrid1: TStringGrid;
    SetHidden1: TMenuItem;
    Button6: TButton;
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
    procedure Properties1Click(Sender: TObject);
    procedure AllProperties1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Owner1Click(Sender: TObject);
    procedure yp1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure SetNormal1Click(Sender: TObject);
    procedure SetArchive1Click(Sender: TObject);
    procedure SetOffline1Click(Sender: TObject);
    procedure SetReadonly1Click(Sender: TObject);
    procedure SetSystem1Click(Sender: TObject);
    procedure SetTemporary1Click(Sender: TObject);
    procedure SetHidden1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private-Deklarationen }
    flbHorzScrollWidth: Integer;
    procedure EnableAllMenuItems(Popup: TPopupMenu);
    procedure DisableAllMenuItems(Popup: TPopupMenu);
  public
    { Public-Deklarationen }
    function DelTree(const Path: string): Boolean;
    function PathRemoveSeparator(const Path: string): string;
    function BuildFileList(const Path: string; const Attr: Integer; const List: TStrings): Boolean;
    function DelTreeEx(const Path: string; AbortOnFailure: Boolean; Progress: TDelTreeProgress): Boolean;
  end;

type
  TStringDynArray = array of string;

type
  TFileVersionInfo = record
    FileType,
    CompanyName,
    FileDescription,
    FileVersion,
    InternalName,
    LegalCopyRight,
    LegalTradeMarks,
    OriginalFileName,
    ProductName,
    ProductVersion,
    Comments,
    SpecialBuildStr,
    PrivateBuildStr,
    FileFunction: string;
    DebugBuild,
    PreRelease,
    SpecialBuild,
    PrivateBuild,
    Patched,
    InfoInferred: Boolean;
  end;

var
  Form1: TForm1;
  Dir : string;
  FileCount: Cardinal = 0;
  Files : TStringDynArray = nil;
  stop : string;  // do not change string or Terminate not works

const  // Data für die Art der Ermittlung des Zugriffs
  FILE_READ_DATA         = $0001; // file & pipe
  FILE_LIST_DIRECTORY    = $0001; // directory
  FILE_WRITE_DATA        = $0002; // file & pipe
  FILE_ADD_FILE          = $0002; // directory
  FILE_APPEND_DATA       = $0004; // file
  FILE_ADD_SUBDIRECTORY  = $0004; // directory
  FILE_CREATE_PIPE_INSTANCE = $0004; // named pipe
  FILE_READ_EA           = $0008; // file & directory
  FILE_WRITE_EA          = $0010; // file & directory
  FILE_EXECUTE           = $0020; // file
  FILE_TRAVERSE          = $0020; // directory
  FILE_DELETE_CHILD      = $0040; // directory
  FILE_READ_ATTRIBUTES   = $0080; // all
  FILE_WRITE_ATTRIBUTES  = $0100; // all
  FILE_ALL_ACCESS        = STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $1FF;
  FILE_GENERIC_READ      = STANDARD_RIGHTS_READ or FILE_READ_DATA or FILE_READ_ATTRIBUTES or FILE_READ_EA or SYNCHRONIZE;
  FILE_GENERIC_WRITE     = STANDARD_RIGHTS_WRITE or FILE_WRITE_DATA or FILE_WRITE_ATTRIBUTES or FILE_WRITE_EA or
    FILE_APPEND_DATA or SYNCHRONIZE;
  FILE_GENERIC_EXECUTE   = STANDARD_RIGHTS_EXECUTE or FILE_READ_ATTRIBUTES or FILE_EXECUTE or SYNCHRONIZE;

implementation

{$R *.dfm}
procedure TForm1.EnableAllMenuItems(Popup: TPopupMenu);
var
  i: Integer;
begin
  for i := 0 to Popup.Items.Count - 1 do
  begin
    Popup.Items[i].Enabled := true; // Oder .Visible := False;
  end;
end;

procedure TForm1.DisableAllMenuItems(Popup: TPopupMenu);
var
  i: Integer;
begin
  for i := 0 to Popup.Items.Count - 1 do
  begin
    Popup.Items[i].Enabled := false; // Oder .Visible := False;
  end;
end;

function FileVersionInfo(const sAppNamePath: TFileName): TFileVersionInfo;
var
  rSHFI: TSHFileInfo;
  iRet: Integer;
  VerSize: Integer;
  VerBuf: PChar;
  VerBufValue: Pointer;
  VerHandle: Cardinal;
  VerBufLen: Cardinal;
  VerKey: string;
  FixedFileInfo: PVSFixedFileInfo;

  // dwFileType, dwFileSubtype
  function GetFileSubType(FixedFileInfo: PVSFixedFileInfo): string;
  begin
    case FixedFileInfo.dwFileType of

      VFT_UNKNOWN: Result    := 'Unknown';
      VFT_APP: Result        := 'Application';
      VFT_DLL: Result        := 'DLL';
      VFT_STATIC_LIB: Result := 'Static-link Library';

      VFT_DRV:
        case
          FixedFileInfo.dwFileSubtype of
          VFT2_UNKNOWN: Result         := 'Unknown Driver';
          VFT2_DRV_COMM: Result        := 'Communications Driver';
          VFT2_DRV_PRINTER: Result     := 'Printer Driver';
          VFT2_DRV_KEYBOARD: Result    := 'Keyboard Driver';
          VFT2_DRV_LANGUAGE: Result    := 'Language Driver';
          VFT2_DRV_DISPLAY: Result     := 'Display Driver';
          VFT2_DRV_MOUSE: Result       := 'Mouse Driver';
          VFT2_DRV_NETWORK: Result     := 'Network Driver';
          VFT2_DRV_SYSTEM: Result      := 'System Driver';
          VFT2_DRV_INSTALLABLE: Result := 'InstallableDriver';
          VFT2_DRV_SOUND: Result       := 'Sound Driver';
        end;
      VFT_FONT:
        case FixedFileInfo.dwFileSubtype of
          VFT2_UNKNOWN: Result       := 'Unknown Font';
          VFT2_FONT_RASTER: Result   := 'Raster Font';
          VFT2_FONT_VECTOR: Result   := 'Vector Font';
          VFT2_FONT_TRUETYPE: Result := 'Truetype Font';
          else;
        end;
      VFT_VXD: Result := 'Virtual Defice Identifier = ' +
          IntToHex(FixedFileInfo.dwFileSubtype, 8);
    end;
  end;


  function HasdwFileFlags(FixedFileInfo: PVSFixedFileInfo; Flag: Word): Boolean;
  begin
    Result := (FixedFileInfo.dwFileFlagsMask and
      FixedFileInfo.dwFileFlags and
      Flag) = Flag;
  end;

  function GetFixedFileInfo: PVSFixedFileInfo;
  begin
    if not VerQueryValue(VerBuf, '', Pointer(Result), VerBufLen) then
      Result := nil
  end;

  function GetInfo(const aKey: string): string;
  begin
    Result := '';
    VerKey := Format('\StringFileInfo\%.4x%.4x\%s',
      [LoWord(Integer(VerBufValue^)),
      HiWord(Integer(VerBufValue^)), aKey]);
    if VerQueryValue(VerBuf, PChar(VerKey), VerBufValue, VerBufLen) then
      Result := StrPas(PWideChar(string(VerBufValue)));
  end;

  function QueryValue(const aValue: string): string;
  begin
    Result := '';
    // obtain version information about the specified file
    if GetFileVersionInfo(PChar(sAppNamePath), VerHandle, VerSize, VerBuf) and
      // return selected version information
      VerQueryValue(VerBuf, '\VarFileInfo\Translation', VerBufValue, VerBufLen) then
      Result := GetInfo(aValue);
  end;
begin
  // Initialize the Result
  with Result do
  begin
    FileType         := '';
    CompanyName      := '';
    FileDescription  := '';
    FileVersion      := '';
    InternalName     := '';
    LegalCopyRight   := '';
    LegalTradeMarks  := '';
    OriginalFileName := '';
    ProductName      := '';
    ProductVersion   := '';
    Comments         := '';
    SpecialBuildStr  := '';
    PrivateBuildStr  := '';
    FileFunction     := '';
    DebugBuild       := False;
    Patched          := False;
    PreRelease       := False;
    SpecialBuild     := False;
    PrivateBuild     := False;
    InfoInferred     := False;
  end;

  // Get the file type
  if SHGetFileInfo(PChar(sAppNamePath), 0, rSHFI, SizeOf(rSHFI),
    SHGFI_TYPENAME) <> 0 then
  begin
    Result.FileType := rSHFI.szTypeName;
  end;

  iRet := SHGetFileInfo(PChar(sAppNamePath), 0, rSHFI, SizeOf(rSHFI), SHGFI_EXETYPE);
  if iRet <> 0 then
  begin
    // determine whether the OS can obtain version information
    VerSize := GetFileVersionInfoSize(PChar(sAppNamePath), VerHandle);
    if VerSize > 0 then
    begin
      VerBuf := AllocMem(VerSize);
      try
        with Result do
        begin
          CompanyName      := QueryValue('CompanyName');
          FileDescription  := QueryValue('FileDescription');
          FileVersion      := QueryValue('FileVersion');
          InternalName     := QueryValue('InternalName');
          LegalCopyRight   := QueryValue('LegalCopyRight');
          LegalTradeMarks  := QueryValue('LegalTradeMarks');
          OriginalFileName := QueryValue('OriginalFileName');
          ProductName      := QueryValue('ProductName');
          ProductVersion   := QueryValue('ProductVersion');
          Comments         := QueryValue('Comments');
          SpecialBuildStr  := QueryValue('SpecialBuild');
          PrivateBuildStr  := QueryValue('PrivateBuild');
          // Fill the VS_FIXEDFILEINFO structure
          FixedFileInfo := GetFixedFileInfo;
          DebugBuild    := HasdwFileFlags(FixedFileInfo, VS_FF_DEBUG);
          PreRelease    := HasdwFileFlags(FixedFileInfo, VS_FF_PRERELEASE);
          PrivateBuild  := HasdwFileFlags(FixedFileInfo, VS_FF_PRIVATEBUILD);
          SpecialBuild  := HasdwFileFlags(FixedFileInfo, VS_FF_SPECIALBUILD);
          Patched       := HasdwFileFlags(FixedFileInfo, VS_FF_PATCHED);
          InfoInferred  := HasdwFileFlags(FixedFileInfo, VS_FF_INFOINFERRED);
          FileFunction  := GetFileSubType(FixedFileInfo);
        end;
      finally
        FreeMem(VerBuf, VerSize);
      end
    end;
  end
end;

function AddAccessRights(lpszFileName : PChar; lpszAccountName : PChar; dwAccessMask : DWORD) : boolean;
const
   HEAP_ZERO_MEMORY = $00000008;
   ACL_REVISION = 2;
   ACL_REVISION2 = 2;
   INHERITED_ACE = $10;

type

   ACE_HEADER = Record
      AceType,
      AceFlags : BYTE;
      AceSize : WORD;
   end;

   PACE_HEADER = ^ACE_HEADER;

   ACCESS_ALLOWED_ACE = Record
      Header : ACE_HEADER;
      Mask : ACCESS_MASK;
      SidStart : DWORD;
   end;

   PACCESS_ALLOWED_ACE = ^ACCESS_ALLOWED_ACE;

   ACL_SIZE_INFORMATION = Record
      AceCount,
      AclBytesInUse,
      AclBytesFree : DWORD;
   end;

   SetSecurityDescriptorControlFnPtr = function (pSecurityDescriptor : PSecurityDescriptor;
                                                 ControlBitsOfInterest : SECURITY_DESCRIPTOR_CONTROL;
                                                 ControlBitsToSet : SECURITY_DESCRIPTOR_CONTROL) : boolean; stdcall;

var
   // SID variables.
   snuType : SID_NAME_USE;
   szDomain : PChar;
   cbDomain : DWORD;
   pUserSID : Pointer;
   cbUserSID : DWORD;

   // File SD variables.
   pFileSD : PSecurityDescriptor;
   cbFileSD : DWORD;

   // New SD variables.
   newSD : TSecurityDescriptor;

   // ACL variables.
   ptrACL : PACL;
   fDaclPresent,
   fDaclDefaulted : BOOL;
   AclInfo : ACL_SIZE_INFORMATION;

   // New ACL variables.
   pNewACL : PACL;
   cbNewACL : DWORD;

   // Temporary ACE.
   pTempAce : Pointer;
   CurrentAceIndex,
   newAceIndex : UINT;

   // Assume function will fail.
   fResult,
   fAPISuccess : boolean;

   secInfo : SECURITY_INFORMATION;

   // New APIs available only in Windows 2000 and above for setting
   // SD control
   _SetSecurityDescriptorControl : SetSecurityDescriptorControlFnPtr;

   controlBitsOfInterest,
   controlBitsToSet,
   oldControlBits : SECURITY_DESCRIPTOR_CONTROL;
   dwRevision : DWORD;

   AceFlags : BYTE;


function myheapalloc(x : integer) : Pointer;
begin
   Result := HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, x);
end;

function myheapfree(x : Pointer) : boolean;
begin
   Result := HeapFree(GetProcessHeap(), 0, x);
end;

function SetFileSecurityRecursive(lpFileName: PChar; SecurityInformation: SECURITY_INFORMATION;
                                 pSecurityDescriptor: PSecurityDescriptor): BOOL;
var
  sr : TSearchRec;
begin
  Result := SetFileSecurity(lpFileName, SecurityInformation, pSecurityDescriptor);

  if Not Result then
      Exit;

  if (FileGetAttr(lpFileName) AND faDirectory) = faDirectory then
    begin
     // Rekursion beginnt
     if FindFirst(IncludeTrailingPathDelimiter(lpFileName) + '*', $EFFF, sr) = 0 then
       begin
        Repeat
         // msp 07.10.2004
         // if ((sr.Attr and faDirectory) = faDirectory) AND (sr.Name <> '.') AND (sr.Name <> '..') then
         if (sr.Name <> '.') AND (sr.Name <> '..') then
            SetFileSecurityRecursive(PChar(IncludeTrailingPathDelimiter(lpFileName) + sr.Name),
                                     SecurityInformation, pSecurityDescriptor);
        until FindNext(sr) <> 0;
        FindClose(sr);
       end;
    end;
end;

begin
   // Init
   szDomain := nil;
   cbDomain := 0;
   pUserSID := nil;
   cbUserSID := 0;

   // File SD variables.
   pFileSD := nil;
   cbFileSD := 0;

   // ACL variables.
   ptrACL := nil;

   // New ACL variables.
   pNewACL := nil;
   cbNewACL := 0;

   // Temporary ACE.
   pTempAce := nil;
   CurrentAceIndex := 0;

   newAceIndex := 0;

   // Assume function will fail.
   fResult := FALSE;

   secInfo := DACL_SECURITY_INFORMATION;

   // New APIs available only in Windows 2000 and above for setting
   // SD control
   _SetSecurityDescriptorControl := nil;

   // Delphi-Result
   Result := FALSE;

   try
      //
      // STEP 1: Get SID of the account name specified.
      //
      fAPISuccess := LookupAccountName(nil, lpszAccountName,
            pUserSID, cbUserSID, szDomain, cbDomain, snuType);

      // API should have failed with insufficient buffer.
      if (Not fAPISuccess) AND (GetLastError() <> ERROR_INSUFFICIENT_BUFFER) then
         raise Exception.Create('LookupAccountName Error=' + IntToStr(GetLastError()));

      pUserSID := myheapalloc(cbUserSID);
      if pUserSID = nil then
         raise Exception.Create('myheapalloc Error=' + IntToStr(GetLastError()));

      szDomain := PChar(myheapalloc(cbDomain * sizeof(PChar)));
      if szDomain = nil then
         raise Exception.Create('myheapalloc Error=' + IntToStr(GetLastError()));

      fAPISuccess := LookupAccountName(nil, lpszAccountName,
            pUserSID, cbUserSID, szDomain, cbDomain, snuType);
      if Not fAPISuccess then
         raise Exception.Create('LookupAccountName Error=' + IntToStr(GetLastError()));

      //
      // STEP 2: Get security descriptor (SD) of the file specified.
      //
      fAPISuccess := GetFileSecurity(lpszFileName,
            secInfo, pFileSD, 0, cbFileSD);

      // API should have failed with insufficient buffer.
      if (Not fAPISuccess) AND (GetLastError() <> ERROR_INSUFFICIENT_BUFFER) then
         raise Exception.Create('GetFileSecurity Error=' + IntToStr(GetLastError()));

      pFileSD := myheapalloc(cbFileSD);
      if pFileSD = nil then
         raise Exception.Create('myheapalloc Error=' + IntToStr(GetLastError()));

      fAPISuccess := GetFileSecurity(lpszFileName,
            secInfo, pFileSD, cbFileSD, cbFileSD);
      if Not fAPISuccess then
         raise Exception.Create('GetFileSecurity Error=' + IntToStr(GetLastError()));

      //
      // STEP 3: Initialize new SD.
      //
      if Not InitializeSecurityDescriptor(@newSD,
            SECURITY_DESCRIPTOR_REVISION) then
         raise Exception.Create('InitializeSecurityDescriptor Error=' + IntToStr(GetLastError()));

      //
      // STEP 4: Get DACL from the old SD.
      //
      if Not GetSecurityDescriptorDacl(pFileSD, fDaclPresent, ptrACL,
            fDaclDefaulted) then
         raise Exception.Create('GetSecurityDescriptorDacl Error=' + IntToStr(GetLastError()));

      //
      // STEP 5: Get size information for DACL.
      //
      AclInfo.AceCount := 0; // Assume NULL DACL.
      AclInfo.AclBytesFree := 0;
      AclInfo.AclBytesInUse := sizeof(ACL);

      if ptrACL = nil then
         fDaclPresent := FALSE;

      // If not NULL DACL, gather size information from DACL.
      if Not fDaclPresent then
         if Not GetAclInformation(ptrACL^, @AclInfo,
               sizeof(ACL_SIZE_INFORMATION), AclSizeInformation) then
            raise Exception.Create('GetAclInformation ' + IntToStr(GetLastError()));

      //
      // STEP 6: Compute size needed for the new ACL.
      //
      cbNewACL := AclInfo.AclBytesInUse + sizeof(ACCESS_ALLOWED_ACE)
                + GetLengthSid(pUserSID) - sizeof(DWORD);

      //
      // STEP 7: Allocate memory for new ACL.
      //
      pNewACL := PACL(myheapalloc(cbNewACL));
      if pNewACL = nil then
         raise Exception.Create('myheapalloc ' + IntToStr(GetLastError()));

      //
      // STEP 8: Initialize the new ACL.
      //
      if Not InitializeAcl(pNewACL^, cbNewACL, ACL_REVISION2) then
         raise Exception.Create('InitializeAcl ' + IntToStr(GetLastError()));

      //
      // STEP 9 If DACL is present, copy all the ACEs from the old DACL
      // to the new DACL.
      //
      // The following code assumes that the old DACL is
      // already in Windows 2000 preferred order. To conform
      // to the new Windows 2000 preferred order, first we will
      // copy all non-inherited ACEs from the old DACL to the
      // new DACL, irrespective of the ACE type.
      //

      newAceIndex := 0;

      if (fDaclPresent) AND (AclInfo.AceCount > 0) then
        begin
         for CurrentAceIndex := 0 to AclInfo.AceCount - 1 do
           begin
            //
            // STEP 10: Get an ACE.
            //
            if Not GetAce(ptrACL^, CurrentAceIndex, pTempAce) then
               raise Exception.Create('GetAce ' + IntToStr(GetLastError()));

            //
            // STEP 11: Check if it is a non-inherited ACE.
            // If it is an inherited ACE, break from the loop so
            // that the new access allowed non-inherited ACE can
            // be added in the correct position, immediately after
            // all non-inherited ACEs.
            //
            if PACCESS_ALLOWED_ACE(pTempAce)^.Header.AceFlags AND INHERITED_ACE > 0 then
               break;

            //
            // STEP 12: Skip adding the ACE, if the SID matches
            // with the account specified, as we are going to
            // add an access allowed ACE with a different access
            // mask.
            //
            if EqualSid(pUserSID, @(PACCESS_ALLOWED_ACE(pTempAce)^.SidStart)) then
               continue;

            //
            // STEP 13: Add the ACE to the new ACL.
            //
            if Not AddAce(pNewACL^, ACL_REVISION, MAXDWORD, pTempAce,
                  PACE_HEADER(pTempAce)^.AceSize) then
               raise Exception.Create('AddAce ' + IntToStr(GetLastError()));

            Inc(newAceIndex);
           end;
        end;

      //
      // STEP 14: Add the access-allowed ACE to the new DACL.
      // The new ACE added here will be in the correct position,
      // immediately after all existing non-inherited ACEs.
      //
      AceFlags := $1   (* OBJECT_INHERIT_ACE *)
               OR $2   (* CONTAINER_INHERIT_ACE *)
               OR $10  (* INHERITED_ACE*);

      if Not AddAccessAllowedAceEx(pNewACL^, ACL_REVISION2, AceFlags, dwAccessMask,
               pUserSID) then
         raise Exception.Create('AddAccessAllowedAce ' + IntToStr(GetLastError()));
      //
      // STEP 15: To conform to the new Windows 2000 preferred order,
      // we will now copy the rest of inherited ACEs from the
      // old DACL to the new DACL.
      //
      if (fDaclPresent) AND (AclInfo.AceCount > 0) then
        begin
         while CurrentAceIndex < AclInfo.AceCount do
           begin
            //
            // STEP 16: Get an ACE.
            //
            if Not GetAce(ptrACL^, CurrentAceIndex, pTempAce) then
               raise Exception.Create('GetAce ' + IntToStr(GetLastError()));

            //
            // STEP 17: Add the ACE to the new ACL.
            //
            if Not AddAce(pNewACL^, ACL_REVISION, MAXDWORD, pTempAce,
                  PACE_HEADER(pTempAce)^.AceSize) then
               raise Exception.Create('AddAce ' + IntToStr(GetLastError()));
           end;

           Inc(CurrentAceIndex);
        end;

      //
      // STEP 18: Set the new DACL to the new SD.
      //
      if Not SetSecurityDescriptorDacl(@newSD, TRUE, pNewACL, FALSE) then
         raise Exception.Create('SetSecurityDescriptorDacl ' + IntToStr(GetLastError()));

      //
      // STEP 19: Copy the old security descriptor control flags
      // regarding DACL automatic inheritance for Windows 2000 or
      // later where SetSecurityDescriptorControl() API is available
      // in advapi32.dll.
      //
      _SetSecurityDescriptorControl := SetSecurityDescriptorControlFnPtr(
                                          GetProcAddress(GetModuleHandle('advapi32.dll'),
                                                         'SetSecurityDescriptorControl'));
      if @_SetSecurityDescriptorControl <> nil then
        begin
         controlBitsOfInterest := 0;
         controlBitsToSet := 0;
         oldControlBits := 0;
         dwRevision := 0;

         if Not GetSecurityDescriptorControl(pFileSD, oldControlBits,
                  dwRevision) then
            raise Exception.Create('GetSecurityDescriptorControl ' + IntToStr(GetLastError()));

         if (oldControlBits AND SE_DACL_AUTO_INHERITED) <> 0 then
           begin
            controlBitsOfInterest := SE_DACL_AUTO_INHERIT_REQ OR SE_DACL_AUTO_INHERITED;
            controlBitsToSet := controlBitsOfInterest;
           end
         else if (oldControlBits AND SE_DACL_PROTECTED) <> 0 then
           begin
            controlBitsOfInterest := SE_DACL_PROTECTED;
            controlBitsToSet := controlBitsOfInterest;
           end;

         if controlBitsOfInterest <> 0 then
            if Not _SetSecurityDescriptorControl(@newSD, controlBitsOfInterest, controlBitsToSet) then
               raise Exception.Create('SetSecurityDescriptorControl ' + IntToStr(GetLastError()));
        end;

      //
      // STEP 20: Set the new SD to the File.
      //
      // msp 07.09.2004: Set to all objects including subdirectories
      // if Not SetFileSecurity(lpszFileName, secInfo, @newSD) then
      if Not SetFileSecurityRecursive(lpszFileName, secInfo, @newSD) then
         raise Exception.Create('SetFileSecurity ' + IntToStr(GetLastError()));

   except
      on E: Exception do
       begin
         MessageDlg(E.Message, mtError, [mbAbort], -1);
         // WriteLog(ltError, Format('AddAccessRights: Beim Ändern der Rechte auf dem Verzeichnis ''%s'' für ''%s'' ist ein Fehler aufgetreten. %s', [lpszFileName, lpszAccountName, E.Message]), []);
         Exit;
       end;
   end;

   //
   // STEP 21: Free allocated memory
   //
   if pUserSID <> nil then
      myheapfree(pUserSID);

   if szDomain <> nil then
      myheapfree(szDomain);

   if pFileSD <> nil then
      myheapfree(pFileSD);

   if pNewACL <> nil then
      myheapfree(pNewACL);

   fResult := TRUE;
end;

function CheckAccessToFile(DesiredAccess: DWORD; const FileName: WideString): Boolean;
const
  GenericFileMapping : TGenericMapping = (
    GenericRead: FILE_GENERIC_READ;
    GenericWrite: FILE_GENERIC_WRITE;
    GenericExecute: FILE_GENERIC_EXECUTE;
    GenericAll: FILE_ALL_ACCESS
    );
var
  LastError              : DWORD;
  LengthNeeded           : DWORD;
  SecurityDescriptor     : PSecurityDescriptor;
  ClientToken            : THandle;
  AccessMask             : DWORD;
  PrivilegeSet           : TPrivilegeSet;
  PrivilegeSetLength     : DWORD;
  GrantedAccess          : DWORD;
  AccessStatus           : BOOL;
begin
  Result := False;
  LastError := GetLastError;
  if not GetFileSecurityW(PWideChar(FileName), OWNER_SECURITY_INFORMATION or
    GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION, nil, 0,
    LengthNeeded) and (GetLastError <> ERROR_INSUFFICIENT_BUFFER) then
    Exit;
  SetLastError(LastError);
  Inc(LengthNeeded, $1000);
  SecurityDescriptor := PSecurityDescriptor(LocalAlloc(LPTR, LengthNeeded));
  if not Assigned(SecurityDescriptor) then
    Exit;
  try
    if not GetFileSecurityW(PWideChar(FileName), OWNER_SECURITY_INFORMATION or
      GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION,
      SecurityDescriptor, LengthNeeded, LengthNeeded) then
      Exit;
    if not ImpersonateSelf(SecurityImpersonation) then
      Exit;
    try
      if not OpenThreadToken(GetCurrentThread, TOKEN_QUERY or
        TOKEN_IMPERSONATE or TOKEN_DUPLICATE, False, ClientToken) then
        Exit;
      try
        AccessMask := DesiredAccess;
        MapGenericMask(AccessMask, GenericFileMapping);
        PrivilegeSetLength := SizeOf(TPrivilegeSet);
        if AccessCheck(SecurityDescriptor, ClientToken, AccessMask,
          GenericFileMapping, PrivilegeSet, PrivilegeSetLength, GrantedAccess,
          AccessStatus) then
          Result := AccessStatus;
      finally
        CloseHandle(ClientToken);
      end;
    finally
      RevertToSelf;
    end;
  finally
    LocalFree(HLOCAL(SecurityDescriptor));
  end;
end;

function GetFileLastAccessTime(sFileName: string): TDateTime;
var
  ffd : TWin32FindData;
  dft : DWord;
  lft : TFileTime;
  h   : THandle;
begin
  // get file information
  h := Windows.FindFirstFile(PChar(sFileName), ffd);
  if INVALID_HANDLE_VALUE <> h then
  begin
    // we're looking for just one file, so close our "find"
    Windows.FindClose(h);

    // convert the FILETIME to local FILETIME
    FileTimeToLocalFileTime(ffd.ftLastAccessTime, lft);

    // convert FILETIME to DOS time
    FileTimeToDosDateTime(lft, LongRec(dft).Hi, LongRec(dft).Lo);

    // finally, convert DOS time to TDateTime for use in Delphi's
    // native date/time functions
    Result := FileDateToDateTime(dft);
  end;
end;

function MrsGetFileType(const strFilename: string): string;
var
  FileInfo: TSHFileInfo;
begin
  FillChar(FileInfo, SizeOf(FileInfo), #0);
  SHGetFileInfo(PChar(strFilename), 0, FileInfo, SizeOf(FileInfo), SHGFI_TYPENAME);
  Result := FileInfo.szTypeName;
end;

function GetFileOwner(FileName: string;
  var Domain, Username: string): Boolean;
var
  SecDescr: PSecurityDescriptor;
  SizeNeeded, SizeNeeded2: DWORD;
  OwnerSID: PSID;
  OwnerDefault: BOOL;
  OwnerName, DomainName: PChar;
  OwnerType: SID_NAME_USE;
begin
  GetFileOwner := False;
  GetMem(SecDescr, 1024);
  GetMem(OwnerSID, SizeOf(PSID));
  GetMem(OwnerName, 1024);
  GetMem(DomainName, 1024);
  try
    if not GetFileSecurity(PChar(FileName),
      OWNER_SECURITY_INFORMATION,
      SecDescr, 1024, SizeNeeded) then
      Exit;
    if not GetSecurityDescriptorOwner(SecDescr,
      OwnerSID, OwnerDefault) then
      Exit;
    SizeNeeded  := 1024;
    SizeNeeded2 := 1024;
    if not LookupAccountSID(nil, OwnerSID, OwnerName,
      SizeNeeded, DomainName, SizeNeeded2, OwnerType) then
      Exit;
    Domain   := DomainName;
    Username := OwnerName;
  finally
    FreeMem(SecDescr);
    FreeMem(OwnerName);
    FreeMem(DomainName);
  end;
  GetFileOwner := True;
end;

function SHMultiFileProperties(pDataObj: IDataObject; Flag: DWORD): HRESULT;
  stdcall; external 'shell32.dll';
{$R-}

function GetFileListDataObject(Files: TStrings): IDataObject;
type
  PArrayOfPItemIDList = ^TArrayOfPItemIDList;
  TArrayOfPItemIDList = array[0..0] of PItemIDList;
var
  Malloc: IMalloc;
  Root: IShellFolder;
  p: PArrayOfPItemIDList;
  chEaten, dwAttributes: ULONG;
  i, FileCount: Integer;
begin
  Result := nil;
  FileCount := Files.Count;
  if FileCount = 0 then Exit;

  OleCheck(SHGetMalloc(Malloc));
  OleCheck(SHGetDesktopFolder(Root));
  p := AllocMem(SizeOf(PItemIDList) * FileCount);
  try
    for i := 0 to FileCount - 1 do
      try
        if not (SysUtils.DirectoryExists(Files[i]) or FileExists(Files[i])) then Continue;
        OleCheck(Root.ParseDisplayName(GetActiveWindow,
          nil,
          PWideChar(WideString(Files[i])),
          chEaten,
          p^[i],
          dwAttributes));
      except
      end;
    OleCheck(Root.GetUIObjectOf(GetActiveWindow,
      FileCount,
      p^[0],
      IDataObject,
      nil,
      Pointer(Result)));
  finally
    for i := 0 to FileCount - 1 do
    begin
      if p^[i] <> nil then Malloc.Free(p^[i]);
    end;
    FreeMem(p);
  end;
  {$R+}
end;

procedure ShowFileProperties(Files: TStrings; aWnd: HWND);
type
  PArrayOfPItemIDList = ^TArrayOfPItemIDList;
  TArrayOfPItemIDList = array[0..0] of PItemIDList;
var
  Data: IDataObject;
begin
  if Files.Count = 0 then Exit;
  Data := GetFileListDataObject(Files);
  SHMultiFileProperties(Data, 0);
end;

procedure PropertiesDialog(const aFilename: string);
var
  sei: ShellExecuteInfo;
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(sei);
  sei.lpFile := PChar(aFilename);
  sei.lpVerb := 'properties';
  sei.fMask  := SEE_MASK_INVOKEIDLIST;
  ShellExecuteEx(@sei);
end;

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
  Listbox1.Perform(LB_SetHorizontalExtent, 1000, Longint(0));
  Application.HintPause := 0;
  Application.HintHidePause := 50000;
  StringGrid1.ColWidths[0] := 145;
  StringGrid1.ColWidths[1] := 250;

  StringGrid1.Cells[0, 0] := 'Name';
  StringGrid1.Cells[1, 0] := 'Information';

  StringGrid1.Cells[0, 1] := '       File Types :';
  StringGrid1.Cells[0, 2] := '     Company Name :';
  StringGrid1.Cells[0, 3] := '      Description :';
  StringGrid1.Cells[0, 4] := '          Version :';
  StringGrid1.Cells[0, 5] := '    Internal Name :';
  StringGrid1.Cells[0, 6] := '  Legal Copyright :';
  StringGrid1.Cells[0, 7] := ' Legal Trademarks :';
  StringGrid1.Cells[0, 8] := 'Original Filename :';
  StringGrid1.Cells[0, 9] := '     Product Name :';
  StringGrid1.Cells[0, 10] := '  Product Version :';
  StringGrid1.Cells[0, 11] := '    Special Build :';
  StringGrid1.Cells[0, 12] := '    Private Build :';
  StringGrid1.Cells[0, 13] := '      Debug Build :';
  StringGrid1.Cells[0, 14] := '      Pre Release :';
  StringGrid1.Cells[0, 15] := '    Private Build :';
  StringGrid1.Cells[0, 16] := '    Special Build :';
end;

procedure TForm1.ListBox1Click(Sender: TObject);
const
  Tabulator: array[0..0] of Integer = (70);
  BoolValues: array[Boolean] of string = ('No', 'Yes');

var
  MyS: TWin32FindData;
  FName: string;
  FvI: TFileVersionInfo;
begin
  if ListBox1.ItemIndex = -1 then Exit;
  FName := ListBox1.Items[ListBox1.ItemIndex];
  Label6.Caption := DateTimeToStr(GetFileLastAccessTime(ListBox1.Items[ListBox1.ItemIndex]));
  // check for generic write access
  Label8.Caption := (BoolToStr(CheckAccessToFile(GENERIC_READ,
                ListBox1.Items[ListBox1.ItemIndex]), True) +
                ': ' +
                SysErrorMessage(GetLastError));

  FindFirstFile(PChar(FName), MyS);
    case MyS.dwFileAttributes of
      FILE_ATTRIBUTE_COMPRESSED: Label10.Caption := ('Compressed');
      FILE_ATTRIBUTE_HIDDEN: Label10.Caption := ('Hidden');
      FILE_ATTRIBUTE_NORMAL: Label10.Caption := ('No attributes');
      FILE_ATTRIBUTE_READONLY: Label10.Caption := ('Read only file');
      FILE_ATTRIBUTE_SYSTEM: Label10.Caption := ('System file');
      FILE_ATTRIBUTE_TEMPORARY: Label10.Caption := ('Temporary storage');
      FILE_ATTRIBUTE_ARCHIVE: Label10.Caption := ('Archive file');
    end;

    if StringGrid1.Visible = true then
    begin
      FvI := FileVersionInfo(ListBox1.Items[ListBox1.ItemIndex]);
      with FvI do
      begin
        StringGrid1.Cells[1, 1] := FileType;
        StringGrid1.Cells[1, 2] := CompanyName;
        StringGrid1.Cells[1, 3] := FileDescription;
        StringGrid1.Cells[1, 4] := FileVersion;
        StringGrid1.Cells[1, 5] := InternalName;
        StringGrid1.Cells[1, 6] := LegalCopyRight;
        StringGrid1.Cells[1, 7] := LegalTradeMarks;
        StringGrid1.Cells[1, 8] := OriginalFileName;
        StringGrid1.Cells[1, 9] := ProductName;
        StringGrid1.Cells[1, 10] := ProductVersion;
        StringGrid1.Cells[1, 11] := SpecialBuildStr;
        StringGrid1.Cells[1, 12] := PrivateBuildStr;
        StringGrid1.Cells[1, 13] := FileFunction;
        StringGrid1.Cells[1, 14] := BoolValues[DebugBuild];
        StringGrid1.Cells[1, 15] := BoolValues[PreRelease];
        StringGrid1.Cells[1, 16] := BoolValues[PrivateBuild];
        StringGrid1.Cells[1, 17] := BoolValues[SpecialBuild];
      end;
    end;
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
  if ListBox1.ItemIndex = -1 then Exit;
  PropertiesDialog(ListBox1.Items[ListBox1.ItemIndex]);
end;

procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
 Len: Integer;
 NewText: String;
begin
  NewText:=Listbox1.Items[Index];

  with Listbox1.Canvas do
  begin
    FillRect(Rect);
    TextOut(Rect.Left + 1, Rect.Top, NewText);
    Len:=TextWidth(NewText) + Rect.Left + 10;
    if Len>flbHorzScrollWidth then
    begin
      flbHorzScrollWidth:=Len;
      Listbox1.Perform(LB_SETHORIZONTALEXTENT, flbHorzScrollWidth, 0 );
    end;
  end;
  DrawListBoxExtra(Control, Index, Rect, State);
end;

procedure TForm1.Owner1Click(Sender: TObject);
var
  Domain, Username: string;
begin
  if ListBox1.ItemIndex = -1 then Exit;
  GetFileOwner(ListBox1.Items[ListBox1.ItemIndex], domain, username);
  Beep;
  ShowMessage(username + '@' + domain);
end;

function TForm1.PathRemoveSeparator(const Path: string): string;
var
  L: Integer;
begin
  L := Length(Path);

  if CheckBox1.Checked = true then begin
    if (L <> 0) and (AnsiLastChar(Path) = PathSeparator) then
    begin
      Result := Copy(Path, 1, L - 1); end else begin Result := Path;
    end;
  end;

  if CheckBox1.Checked = false then begin
    if (L <> 0) and (AnsiLastChar(Path) = PathSeparator) then
    begin
      Result := Copy(Path, 0, L - 0); end else begin Result := Path;
    end;
  end;

end;

procedure TForm1.Properties1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex = -1 then Exit;
  PropertiesDialog(ListBox1.Items[ListBox1.ItemIndex]);
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  Label2.Caption := 'Shredder Blocks $';
end;

procedure TForm1.RadioButton2Click(Sender: TObject);
begin
  Label2.Caption := 'Shredder Bits      $';
end;

procedure TForm1.SetArchive1Click(Sender: TObject);
begin
  SetFileAttributes(PWideChar(ListBox1.Items[ListBox1.ItemIndex]),
                              FILE_ATTRIBUTE_ARCHIVE);
end;

procedure TForm1.SetHidden1Click(Sender: TObject);
begin
  SetFileAttributes(PWideChar(ListBox1.Items[ListBox1.ItemIndex]),
                              FILE_ATTRIBUTE_HIDDEN);
end;

procedure TForm1.SetNormal1Click(Sender: TObject);
begin
  SetFileAttributes(PWideChar(ListBox1.Items[ListBox1.ItemIndex]),
                              FILE_ATTRIBUTE_NORMAL);
end;

procedure TForm1.SetOffline1Click(Sender: TObject);
begin
  SetFileAttributes(PWideChar(ListBox1.Items[ListBox1.ItemIndex]),
                              FILE_ATTRIBUTE_OFFLINE);
end;

procedure TForm1.SetReadonly1Click(Sender: TObject);
begin
  SetFileAttributes(PWideChar(ListBox1.Items[ListBox1.ItemIndex]),
                              FILE_ATTRIBUTE_READONLY);
end;

procedure TForm1.SetSystem1Click(Sender: TObject);
begin
  SetFileAttributes(PWideChar(ListBox1.Items[ListBox1.ItemIndex]),
                              FILE_ATTRIBUTE_SYSTEM);
end;

procedure TForm1.SetTemporary1Click(Sender: TObject);
begin
  SetFileAttributes(PWideChar(ListBox1.Items[ListBox1.ItemIndex]),
                              FILE_ATTRIBUTE_TEMPORARY);
end;

procedure TForm1.AllProperties1Click(Sender: TObject);
begin
  ShowFileProperties(ListBox1.Items, 0);
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
var
  i : integer;
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
          if SysUtils.DirectoryExists(Dir) then
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
  DisableAllMenuItems(PopupMenu1);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i, s, f  : Integer;
begin
  s := 0;
  Dir := '';

  if SelectDirectory('Select directory', '', Dir) then begin

    if DirectoryIsEmpty(Dir) then begin
      MessageDlg('This Folder is Empty!',mtInformation, [mbOK], 0);
      Exit;
    end;
    EnableAllMenuItems(PopupMenu1);
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

  if CheckBox3.Checked = true then
  begin
    // Rename this to your language using the system language 'jeder'.
    // in english language is 'anyone' the access rights.
    AddAccessRights(PWideChar(Dir), 'Jeder', $FFFFFFFF);
  end;

  StatusBar1.Panels[1].Text := IntToStr(ListBox1.Items.Count);
  ProgressBar1.Max := ListBox1.Items.Count;
  StatusBar1.Panels[3].Text := IntToStr(s) + ' bytes';
  ListBox1.Perform(WM_VSCROLL, SB_BOTTOM, 0);
  StatusBar1.SetFocus;
end;

procedure TForm1.Button4Click(Sender: TObject);
const
  Tabulator: array[0..0] of Integer = (70);
  BoolValues: array[Boolean] of string = ('No', 'Yes');

var
  MyS: TWin32FindData;
  FName: string;
  FvI: TFileVersionInfo;
begin
  if OpenDialog1.Execute then
  begin
    stop := 'a';
    ProgressBar1.Position := 0;
    ProgressBar1.Max := 100;
    Edit1.Text := OpenDialog1.FileName;
    Label6.Caption := DateTimeToStr(GetFileLastAccessTime(Edit1.Text));
    ListBox1.Clear;
    StatusBar1.Panels[3].Text :=  IntToStr(FileSize(Edit1.Text)) + ' bytes';

    Label6.Caption := DateTimeToStr(GetFileLastAccessTime(OpenDialog1.FileName));
    // check for generic write access
    Label8.Caption := (BoolToStr(CheckAccessToFile(GENERIC_READ,
                OpenDialog1.FileName), True) +
                ': ' +
                SysErrorMessage(GetLastError));

    FindFirstFile(PChar(Edit1.Text), MyS);
    case MyS.dwFileAttributes of
      FILE_ATTRIBUTE_COMPRESSED: Label10.Caption := ('Compressed');
      FILE_ATTRIBUTE_HIDDEN: Label10.Caption := ('Hidden');
      FILE_ATTRIBUTE_NORMAL: Label10.Caption := ('No attributes');
      FILE_ATTRIBUTE_READONLY: Label10.Caption := ('Read only file');
      FILE_ATTRIBUTE_SYSTEM: Label10.Caption := ('System file');
      FILE_ATTRIBUTE_TEMPORARY: Label10.Caption := ('Temporary storage');
      FILE_ATTRIBUTE_ARCHIVE: Label10.Caption := ('Archive file');
    end;

    if StringGrid1.Visible = true then
    begin
      FvI := FileVersionInfo(OpenDialog1.FileName);
      with FvI do
      begin
        StringGrid1.Cells[1, 1] := FileType;
        StringGrid1.Cells[1, 2] := CompanyName;
        StringGrid1.Cells[1, 3] := FileDescription;
        StringGrid1.Cells[1, 4] := FileVersion;
        StringGrid1.Cells[1, 5] := InternalName;
        StringGrid1.Cells[1, 6] := LegalCopyRight;
        StringGrid1.Cells[1, 7] := LegalTradeMarks;
        StringGrid1.Cells[1, 8] := OriginalFileName;
        StringGrid1.Cells[1, 9] := ProductName;
        StringGrid1.Cells[1, 10] := ProductVersion;
        StringGrid1.Cells[1, 11] := SpecialBuildStr;
        StringGrid1.Cells[1, 12] := PrivateBuildStr;
        StringGrid1.Cells[1, 13] := FileFunction;
        StringGrid1.Cells[1, 14] := BoolValues[DebugBuild];
        StringGrid1.Cells[1, 15] := BoolValues[PreRelease];
        StringGrid1.Cells[1, 16] := BoolValues[PrivateBuild];
        StringGrid1.Cells[1, 17] := BoolValues[SpecialBuild];
      end;
    end;
  end;
  StatusBar1.SetFocus;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  ListBox1.Clear;
  Dir := '';
  DisableAllMenuItems(PopupMenu1);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if StringGrid1.Visible = true then
  begin
    StringGrid1.Visible := false;
    Form1.Width := 450;
    Button6.Caption := 'Info >>';
  end else begin
    StringGrid1.Visible := true;
    Form1.Width := 860;
    Button6.Caption := 'Info <<';
  end;
  StatusBar1.SetFocus;
end;

procedure TForm1.TerminateClick(Sender: TObject);
begin
  stop  := 's';
  Button1.Enabled := true;
  Button2.Enabled := true;
end;

procedure TForm1.yp1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex = -1 then Exit;
  Beep;
  ShowMessage('File type is: ' +
    MrsGetFileType(ListBox1.Items[ListBox1.ItemIndex]));
end;

end.
