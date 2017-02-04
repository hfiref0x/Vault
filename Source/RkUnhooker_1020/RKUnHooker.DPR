{$E EXE}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$IFDEF minimum}
program RKUnHooker;
{$ENDIF}
unit RKUnHooker;
interface
implementation

uses
  Windows, Messages, WinBase, RTL, WinNative, commctrl, commdlg, ListView32, ObjList2;

{$R Resources.res}

const
  SERVICE_ERROR_NORMAL = $00000001;
  SERVICE_DEMAND_START = $00000003;
  SERVICE_KERNEL_DRIVER = $00000001;
  ColumnsCount = 4;
  AppName: PWideChar = 'RootKit UnHooker v1.02 win32 NTx86 UNICODE';
  DriverLink: PWideChar = '\\.\rkhdrv10';
  ServiceDisplayName: PWideChar = 'RootKit Unhook Driver';
  ServiceFileName: PWideChar = 'rkhdrv10.sys';
  RegPath: PWideChar = '\Registry\Machine\System\CurrentControlSet\Services\rkhdrv10';
  ServiceKeyName: PWideChar = 'SYSTEM\CurrentControlSet\Services\rkhdrv10';
  ServiceEnumName: PWideChar = 'SYSTEM\CurrentControlSet\Services\rkhdrv10\Enum';
  AboutStr: PWideChar = 'build 23 from 06.06.2006, UG North';
  UnknownModule: PAnsiChar = 'Unknown module filename';
  SENTEROK: PWideChar = 'SYSENTER state - OK, ';
  SENTERBAD: PWideChar = 'SYSENTER !HOOKED! ';

  IOPORT_READ_KERNEL_SDT = $00220004;
  IOPORT_WRITE_KERNEL_SDT = $00220008;
  IOPORT_GET_KERNEL_SDT_INFO = $0022000C;
  IOPORT_GET_KERNEL_MODULES_INFO = $00220010;
  IOPORT_GET_KERNEL_SYSENTER_INFO = $00220014;

type
  _SystemModules = record
    Count: ULONG;
    sysmodules: array[0..0] of SYSTEM_MODULE_INFORMATION;
  end;
  SytemModules = _SystemModules;
  PSystemModules = ^_SystemModules;

  _SERVICE_DESCRIPTOR_ENTRY = record
    ServiceTableBase: ^PVOID;
    ServiceCounterTableBase: ^PVOID; //Used only in checked build
    NumberOfServices: DWORD;
    ParamTableBase: PBYTE;
  end;
  SERVICE_DESCRIPTOR_ENTRY = _SERVICE_DESCRIPTOR_ENTRY;
  PSERVICE_DESCRIPTOR_ENTRY = ^_SERVICE_DESCRIPTOR_ENTRY;

  _KSERVICE_PTR = record
    dwServiceNumber: DWORD;
    dwServiceEntryPoint: pointer;
  end;
  KSERVICE_PTR = _KSERVICE_PTR;
  PKSERVICE_PTR = ^_KSERVICE_PTR;

  _DWBUF = array[0..0] of DWORD;
  DWBUF = _DWBUF;
  PDWBUF = ^_DWBUF;

  _WBUF = array[0..0] of WORD;
  WBUF = _WBUF;
  PWBUF = ^_WBUF;

  _SECTIONBUF = array[0..0] of IMAGE_SECTION_HEADER;
  SECTIONBUF = _SECTIONBUF;
  PSECTIONBUF = ^_SECTIONBUF;

  infobuffer = record
    modulescount: ULONG;
    moduleinfo: SYSTEM_MODULE_INFORMATION;
  end;

var
  CurrentDirectory: LBuf;
  MainWindow, AboutWindow, StatusBar: HWND;
  LData1: PListViewData = nil;
  LVTexts: TSTRList;
  quit: Boolean = false;
  hInst: Cardinal;
  kmodule: infobuffer;
  f: THANDLE;
  bytesIO: DWORD;
  listexp: array[0..383, 0..255] of AnsiChar;
  CurrentTable, OrigTable: PDWBUF;
  Modules: PSystemModules;
  sdt1: SERVICE_DESCRIPTOR_ENTRY;
  hMenu1: HMENU;
  osver: OSVERSIONINFOW;
  SelectedColumn: integer = 0;
  windir, winsysdir: FBuf;
  SysEnterHooked: boolean = false;

function ExtractDriver(): boolean;
var
  hRes: HRSRC;
  hResData: HGLOBAL;
  p1: pointer;
  size: cardinal;
  f: THANDLE;
  buf: LongBufW;
  bytesIO: DWORD;
begin
  result := false;
  hRes := FindResourceW(hinst, 'rkhdrv10', 'BINRES');
  if (hRes = 0) then exit;
  size := SizeOfResource(hinst, hRes);
  if (size = 0) then exit;
  hResData := LoadResource(hinst, hRes);
  if (hResData = 0) then exit;
  p1 := LockResource(hResData);
  if (p1 = nil) then exit;
  strcpyW(buf, CurrentDirectory);
  strcatW(buf, ServiceFileName);
  f := CreateFileW(buf, GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_FLAG_SEQUENTIAL_SCAN or FILE_ATTRIBUTE_HIDDEN, 0);
  _WriteFile(f, p1, size, @bytesIO, nil);
  CloseHandle(f);
  result := (bytesIO = size);
end;

function DeleteDriver(): boolean;
var
  buf: LongBufW;
begin
  strcpyW(buf, CurrentDirectory);
  strcatW(buf, ServiceFileName);
  result := DeleteFileW(buf);
end;

function LoadServiceDriver(): BOOL; stdcall;
var
  disp: DWORD;
  skey: HKEY;
  sa1: SECURITY_ATTRIBUTES;
  textbuf, pf: PWideChar;
  p1: PWideChar;
  s1: UNICODE_STRING;
  pathlen: DWORD;
  buf: LBuf;
begin
  result := false;
  if (not ExtractDriver()) then
  begin
    MessageBoxW(MainWindow, 'Error extracting driver', nil, MB_ICONERROR);
    exit;
  end;
  RtlInitUnicodeString(@s1, RegPath);
  pathlen := GetFullPathNameW(ServiceFileName, 0, nil, pf);
  if (pathlen = 0) then exit;
  textbuf := pointer(LocalAlloc(LPTR, ((pathlen + 4) * sizeof(WideChar))));
  pf := nil;
  strcpyW(textbuf, '\??\');
  GetFullPathNameW(ServiceFileName, pathlen, strendW(textbuf), p1);
  sa1.nLength := sizeof(SECURITY_ATTRIBUTES);
  sa1.lpSecurityDescriptor := nil;
  sa1.bInheritHandle := false;
  if RegCreateKeyExW(HKEY_LOCAL_MACHINE, ServiceKeyName, 0, nil,
    REG_OPTION_VOLATILE, KEY_ALL_ACCESS,
    @sa1, skey, @disp) <> ERROR_SUCCESS then
  begin
    MessageBoxW(MainWindow, 'Error creating registry key', nil, MB_ICONERROR);
    DeleteDriver();
    exit;
  end;
  RegSetValueExW(skey, 'DisplayName', 0, REG_SZ, ServiceDisplayName,
    (strlenW(ServiceDisplayName) + 1) * sizeof(WideChar));
  RegSetValueExW(skey, 'ImagePath', 0, REG_EXPAND_SZ, textbuf,
    (strlenW(textbuf) + 1) * sizeof(WideChar));
  disp := SERVICE_ERROR_NORMAL;
  RegSetValueExW(skey, 'ErrorControl', 0, REG_DWORD, @disp, sizeof(DWORD));
  disp := SERVICE_DEMAND_START;
  RegSetValueExW(skey, 'Start', 0, REG_DWORD, @disp, sizeof(DWORD));
  disp := SERVICE_KERNEL_DRIVER;
  RegSetValueExW(skey, 'Type', 0, REG_DWORD, @disp, sizeof(DWORD));
  RegCloseKey(skey);
  LocalFree(HLOCAL(textbuf));
  disp := NtLoadDriver(@s1);
  if (disp <> 0) and (disp <> $C000010E) then
  begin
    RegDeleteKeyW(HKEY_LOCAL_MACHINE, ServiceEnumName);
    RegDeleteKeyW(HKEY_LOCAL_MACHINE, ServiceKeyName);
    strcpyW(buf, 'Error loading driver, NTSTATUS code: ');
    uitohexW(disp, strendW(buf));
    DeleteDriver();
    MessageBoxW(MainWindow, buf, nil, MB_ICONERROR);
    exit;
  end;
  result := true;
end;

function UnloadServiceDriver(): BOOL; stdcall;
var
  s1: UNICODE_STRING;
begin
  RtlInitUnicodeString(@s1, RegPath);
  result := (NtUnloadDriver(@s1) = 0);
  if result then
  begin
    RegDeleteKeyW(HKEY_LOCAL_MACHINE, ServiceEnumName);
    RegDeleteKeyW(HKEY_LOCAL_MACHINE, ServiceKeyName);
    DeleteDriver();
  end else MessageBoxW(MainWindow, 'Error unloading driver', nil, MB_ICONERROR);
end;

procedure DumpOrigSDT();
var
  f: THANDLE;
  bytesIO, sz: DWORD;
  kernelpath: array[0..MAX_PATH - 1] of WideChar;
  t: integer;

  pdosh: ^IMAGE_DOS_HEADER;
  pfileh: ^IMAGE_FILE_HEADER;
  popth: ^IMAGE_OPTIONAL_HEADER;
  psections: PSECTIONBUF;
  buf, ptable: PChar;

  function GetFileOffset(_ptr: DWORD): DWORD;
  var
    c, sva: DWORD;
  begin
    for c := 0 to pfileh^.NumberOfSections - 1 do
    begin
      sva := psections^[c].VirtualAddress;
      if (sva <= _ptr) and (sva + psections^[c].SizeOfRawData > _ptr) then
      begin
        result := psections^[c].PointerToRawData + (_ptr - sva);
        exit;
      end;
    end;
    result := 0;
  end;

begin
  GetSystemDirectoryW(kernelpath, MAX_PATH);
  if kernelpath[strlenW(kernelpath) - 1] <> WideChar('\') then
    strcatW(kernelpath, '\');
  MultiByteToWideChar(CP_ACP, 0, @kmodule.moduleinfo.ImageName[kmodule.moduleinfo.ModuleNameOffset],
    -1, strendW(kernelpath), MAX_PATH);

  f := CreateFileW(kernelpath, GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if f <> INVALID_HANDLE_VALUE then
  begin
    sz := GetFileSize(f, nil);
    buf := VirtualAlloc(nil, sz, MEM_COMMIT, PAGE_READWRITE);
    _ReadFile(f, buf, sz, @bytesIO, nil);
    CloseHandle(f);

    pdosh := pointer(buf);
    pfileh := pointer(buf + 4 + DWORD(pdosh^._lfanew));
    popth := pointer(buf + 4 + DWORD(pdosh^._lfanew) + IMAGE_SIZEOF_FILE_HEADER);
    psections := pointer(DWORD(popth) + IMAGE_SIZEOF_NT_OPTIONAL_HEADER);

    ptable := pointer(buf + GetFileOffset(DWORD(sdt1.ServiceTableBase) - DWORD(kmodule.moduleinfo.Base)));
    memcopy(OrigTable, ptable, sdt1.NumberOfServices * sizeof(PVOID));

    for t := 0 to sdt1.NumberOfServices - 1 do
      dec(OrigTable^[t], popth^.ImageBase);

    VirtualFree(buf, 0, MEM_RELEASE);
  end else MessageBoxW(MainWindow, 'Error open Windows Core', nil, MB_ICONERROR);
end;

function DecodeModuleName(inbuf: PChar): FBuf; stdcall;
var
  tmpbuf: FBuf;
begin
  strcpynA(result, inbuf, 4);
  if (strcmpia(result, '\??\') = 0) then
  begin
    strcpyA(result, @inbuf[4]);
    exit;
  end;
  strcpynA(result, inbuf, 12);
  if (strcmpiA(result, '\SystemRoot\') = 0) then
  begin
    strcpyA(result, windir);
    strcatA(result, '\');
    strcatA(result, @inbuf[12]);
    Exit;
  end;
  strcpynA(result, inbuf, 9);
  if (strcmpiA(result, 'System32\') = 0) then
  begin
    strcpyA(result, winsysdir);
    strcatA(result, '\');
    strcatA(result, @inbuf[9]);
    Exit;
  end;
  strcpynA(result, inbuf, 7);
  if (strcmpiA(result, 'System\') = 0) then
  begin
    strcpyA(result, winsysdir);
    strcatA(result, '\');
    strcatA(result, @inbuf[7]);
    Exit;
  end;
  strcpyA(tmpbuf, @windir[2]);
  strcpynA(result, inbuf, strlenA(tmpbuf));
  if (strcmpiA(result, tmpbuf) = 0) then
  begin
    strcpyA(result, windir);
    strcatA(result, @inbuf[strlenA(tmpbuf)]);
    Exit;
  end;
  strcpyA(result, inbuf);
end;

procedure DumpExports(const lpModuleName: PWideChar);
var
  f: THANDLE;
  bytesIO, sz, expva: DWORD;
  buf, p0: PChar;
  pNames, pEntryPoints: PDWBUF;
  pOrdinals: PWBUF;
  prawexp: ^IMAGE_EXPORT_DIRECTORY;
  ntdllpath: array[0..MAX_PATH - 1] of WideChar;

  pdosh: ^IMAGE_DOS_HEADER;
  pfileh: ^IMAGE_FILE_HEADER;
  popth: ^IMAGE_OPTIONAL_HEADER;
  psections: PSECTIONBUF;

  c, k: integer;

  function GetFileOffset(_ptr: DWORD): DWORD;
  var
    c, sva: DWORD;
  begin
    for c := 0 to pfileh^.NumberOfSections - 1 do
    begin
      sva := psections^[c].VirtualAddress;
      if (sva <= _ptr) and (sva + psections^[c].SizeOfRawData > _ptr) then
      begin
        result := psections^[c].PointerToRawData + (_ptr - sva);
        exit;
      end;
    end;
    result := 0;
  end;

begin
  GetSystemDirectoryW(ntdllpath, MAX_PATH);
  if ntdllpath[strlenW(ntdllpath) - 1] <> WideChar('\') then
    strcatW(ntdllpath, '\');
  strcatW(ntdllpath, lpModuleName);

  f := CreateFileW(ntdllpath, GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if (f <> INVALID_HANDLE_VALUE) then
  begin
    sz := GetFileSize(f, nil);
    buf := VirtualAlloc(nil, sz, MEM_COMMIT, PAGE_READWRITE);
    _ReadFile(f, buf, sz, @bytesIO, nil);
    CloseHandle(f);

    //  ntdll loaded in buf
    pdosh := pointer(buf);
    pfileh := pointer(buf + 4 + DWORD(pdosh^._lfanew));
    popth := pointer(buf + 4 + DWORD(pdosh^._lfanew) + IMAGE_SIZEOF_FILE_HEADER);
    psections := pointer(DWORD(popth) + IMAGE_SIZEOF_NT_OPTIONAL_HEADER);

    expva := popth^.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress;

    prawexp := pointer(buf + GetFileOffset(expva));
    pointer(pEntryPoints) := buf + GetFileOffset(DWORD(prawexp^.AddressOfFunctions));
    pointer(pNames) := buf + GetFileOffset(DWORD(prawexp^.AddressOfNames));
    pointer(pOrdinals) := buf + GetFileOffset(DWORD(prawexp^.AddressOfNameOrdinals));

    k := 0;
    for c := 0 to prawexp^.NumberOfNames - 1 do
    begin
      p0 := buf + GetFileOffset(pNames^[c]);
      if (strcmpnA(p0, 'Nt', 2) = 0) then
      begin
        sz := pEntryPoints^[pOrdinals[c]];
        sz := DWORD(buf + GetFileOffset(sz) + 1);
        sz := PDWORD(sz)^;
        if (DWORD(sz) >= sdt1.NumberOfServices) then continue;
        strcpyA(@listexp[sz], p0);
        inc(k);
        if (DWORD(k) >= sdt1.NumberOfServices) then break;
      end;
    end;
    VirtualFree(buf, 0, MEM_RELEASE);
  end else MessageBoxW(MainWindow, 'Error reading ntdll.dll', nil, MB_ICONERROR);
end;

const
  ntdll: PWideChar = 'ntdll.dll';
  YesId: PChar = 'Yes';
  NoId: PChar = '-';

procedure FillList();
var
  t, c, u: DWORD;
  buf2, buf: FBuf;
  buf3: LBuf;
begin
  ZwQuerySystemInformation(SystemModuleInformation, @kmodule, sizeof(kmodule), @bytesIO);
  LoadServiceDriver();
  f := CreateFileW(DriverLink, GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  if (f <> INVALID_HANDLE_VALUE) then
  begin
    DeviceIoControl(f, IOPORT_GET_KERNEL_SDT_INFO, nil, 0, @sdt1, sizeof(SERVICE_DESCRIPTOR_ENTRY), bytesIO, nil);
    CurrentTable := VirtualAlloc(nil, sdt1.NumberOfServices * sizeof(PVOID), MEM_COMMIT, PAGE_READWRITE);

    OrigTable := VirtualAlloc(nil, sdt1.NumberOfServices * sizeof(PVOID), MEM_COMMIT, PAGE_READWRITE);

    DumpOrigSDT();
    DeviceIoControl(f, IOPORT_READ_KERNEL_SDT, nil, 0, CurrentTable, sdt1.NumberOfServices * sizeof(PVOID), bytesIO, nil);
    DumpExports(ntdll);

    LView_ClearAll(LData1);
    STRListClear(@LVTexts);
    c := 0;
    t := 0;
    DeviceIoControl(f, IOPORT_GET_KERNEL_MODULES_INFO, nil, 0, @c, sizeof(DWORD), bytesIO, nil);
    if (c <> 0) then
    begin
      Modules := VirtualAlloc(nil, c + sizeof(SytemModules), MEM_COMMIT, PAGE_READWRITE);
      DeviceIoControl(f, IOPORT_GET_KERNEL_MODULES_INFO, nil, 0, Modules, c + sizeof(SytemModules), bytesIO, nil);
      for c := 0 to sdt1.NumberOfServices - 1 do
      begin
        strcpyA(buf2, UnknownModule);
        for u := 0 to Modules^.Count - 1 do
        begin
          if (DWORD(CurrentTable^[c]) >= DWORD(Modules^.sysmodules[u].Base)) and
            (DWORD(CurrentTable^[c]) <= (DWORD(Modules^.sysmodules[u].Base) + Modules^.sysmodules[u].Size)) then
          begin
            buf2 := DecodeModuleName(Modules^.sysmodules[u].ImageName);
          end;
        end;
        STRListClear(@LVTexts);
        STRListAdd(@LVTexts, uitoA(c, buf));
        STRListAdd(@LVTexts, @listexp[c]);
        if ((CurrentTable^[c] - DWORD(kmodule.moduleinfo.Base)) <> OrigTable^[c]) then
        begin
          STRListAdd(@LVTexts, YesId);
          inc(t);
        end else STRListAdd(@LVTexts, NoId);
        strcpyA(buf, '0x');
        uitohex((CurrentTable^[c]), strendA(buf));
        STRListAdd(@LVTexts, buf);
        STRListAdd(@LVTexts, buf2);
        LView_AddItem(LData1, LView_ItemCount(LData1), ColumnsCount, LVTexts);
      end;
    end;
    c := 0;
    DeviceIoControl(f, IOPORT_GET_KERNEL_SYSENTER_INFO, nil, 0, @c, sizeof(DWORD), bytesIO, nil);
    SysEnterHooked := not ((c >= DWORD(kmodule.moduleinfo.Base)) and (c <= (DWORD(kmodule.moduleinfo.Base) + kmodule.moduleinfo.Size)));
    if not SysEnterHooked then strcpyW(buf3, SENTEROK) else strcpyW(buf3, SENTERBAD);
    strcatW(buf3, 'Services/Hooked: ');
    uitoW(sdt1.NumberOfServices, strendW(buf3));
    strcatW(buf3, '/');
    uitoW(t, strendW(buf3));
    SetWindowTextW(StatusBar, buf3);
    VirtualFree(Modules, 0, MEM_RELEASE);
    CloseHandle(f);
  end else MessageBoxW(MainWindow, 'Error initialize driver', nil, MB_ICONERROR);
  UnloadServiceDriver();
  VirtualFree(CurrentTable, 0, MEM_RELEASE);
  VirtualFree(OrigTable, 0, MEM_RELEASE);
end;

function UnHook(ServiceNumber: cardinal; uhall: boolean): boolean;
var
  f: THANDLE;
  bytesIO, c: DWORD;
  sp1: KSERVICE_PTR;
begin
  result := false;
  ZwQuerySystemInformation(SystemModuleInformation, @kmodule, sizeof(kmodule), @bytesIO);

  LoadServiceDriver();
  f := CreateFileW(DriverLink, GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  if f <> INVALID_HANDLE_VALUE then
  begin
    DeviceIoControl(f, IOPORT_GET_KERNEL_SDT_INFO, nil, 0, @sdt1, sizeof(SERVICE_DESCRIPTOR_ENTRY), bytesIO, nil);
    CurrentTable := VirtualAlloc(nil, sdt1.NumberOfServices * sizeof(PVOID), MEM_COMMIT, PAGE_READWRITE);
    OrigTable := VirtualAlloc(nil, sdt1.NumberOfServices * sizeof(PVOID), MEM_COMMIT, PAGE_READWRITE);

    DumpOrigSDT();

    DeviceIoControl(f, IOPORT_READ_KERNEL_SDT, nil, 0, CurrentTable, sdt1.NumberOfServices * sizeof(PVOID), bytesIO, nil);

    DumpExports(ntdll);

    for c := 0 to sdt1.NumberOfServices - 1 do
      dec(CurrentTable^[c], DWORD(kmodule.moduleinfo.Base));

    if (uhall) then
    begin
      for c := 0 to sdt1.NumberOfServices - 1 do
        if (CurrentTable^[c] <> OrigTable^[c]) then
        begin
          sp1.dwServiceNumber := c;
          sp1.dwServiceEntryPoint := pointer(OrigTable^[c] + DWORD(kmodule.moduleinfo.Base));
          result := DeviceIoControl(f, IOPORT_WRITE_KERNEL_SDT, @sp1, sizeof(KSERVICE_PTR), nil, 0, bytesIO, nil);
        end;
    end
    else
    begin
      for c := 0 to sdt1.NumberOfServices - 1 do
        if (CurrentTable^[c] <> OrigTable^[c]) and (c = ServiceNumber) then
        begin
          sp1.dwServiceNumber := c;
          sp1.dwServiceEntryPoint := pointer(OrigTable^[c] + DWORD(kmodule.moduleinfo.Base));
          result := DeviceIoControl(f, IOPORT_WRITE_KERNEL_SDT, @sp1, sizeof(KSERVICE_PTR), nil, 0, bytesIO, nil);
        end;
    end;
    CloseHandle(f);
  end;
  UnloadServiceDriver();
  VirtualFree(CurrentTable, 0, MEM_RELEASE);
  VirtualFree(OrigTable, 0, MEM_RELEASE);
end;

function SortNumbers(n1, n2: cardinal; nSortData: dword): dword; stdcall;
var
  c1, c2: cardinal;
begin
  result := MaxDword;
  if (nSortData = 0) then
  begin
    c1 := atoui(STRListGetEntry(@ps1(n1)^.text, nSortData));
    c2 := atoui(STRListGetEntry(@ps1(n2)^.text, nSortData));
    if (c1 < c2) then
      Result := MaxDword
    else if (c1 > c2) then
      Result := 1
    else
      Result := 0;
    exit;
  end;
  if (nSortData = 1) or (nSortData = 3) or (nSortData = 4) then result := strcmpiA(STRListGetEntry(@ps1(n1)^.text, nSortData), STRListGetEntry(@ps1(n2)^.text, nSortData));
  if (nSortData = 2) then result := strcmpiA(STRListGetEntry(@ps1(n2)^.text, nSortData), STRListGetEntry(@ps1(n1)^.text, nSortData));
end;

var
  SelectedService: integer = -1;

function AboutDialogProc(hwndDlg: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
begin
  result := false;
  case uMsg of
    WM_INITDIALOG:
      begin
        SetWindowTextW(GetDlgItem(hwndDlg, 1008), AboutStr);
        exit;
      end;
    WM_COMMAND:
      case LoWord(WParam) of
        IDOK:
          begin
            EndDialog(hwndDlg, S_OK);
            exit;
          end;
      end;
    WM_CLOSE:
      begin
        EndDialog(hwndDlg, S_OK);
        exit;
      end;
  end;
end;

procedure SaveListToFile(pwFileName: PWideChar);
const
  ReportHead: PChar = '<!--Machine generated file, DO NOT EDIT--!>'#13#10'<HTML><HEAD><TITLE>RootKit UnHooker Listing</TITLE></HEAD>' +
  '<BODY alink = "red" vlink = "snow" bgcolor = "black"><STYLE type="text/css">TD {font-family: Tahoma; font-size: 10pt}</STYLE>';
  TableHead: PChar = '<TABLE Border = "2" cellpadding = "5" cellspacing = "0" Width = "550" align = "center">' +
  '<TR align = "center"><TD width = "50" height = "20"><FONT Color = "springgreen">Id</FONT></TD>' +
    '<TD Width = "150"><FONT Color = "springgreen">Service Name</FONT></TD>' +
    '<TD Width = "100"><FONT Color = "springgreen">Hooked</FONT></TD>' +
    '<TD Width = "100"><FONT Color = "springgreen">Address</FONT></TD>' +
    '<TD width = "150"><FONT Color = "springgreen">Module</FONT></TD></TR>';
  ColHead: PChar = '<FONT Color = "springgreen">';
  ColEnd: PChar = '</FONT></TD>';
  ReportEnd: PChar = '</TABLE><BR><BR></BODY></HTML>';
  RedAlert: PChar = '<FONT Color="red">';
  RedAlertClose: PChar = '</FONT>';
var
  f: THANDLE;
  bytesIO: DWORD;
  buf: FBuf;
  tmpbuf: array[0..8191] of CHAR;
  i: integer;
  hf: boolean;
begin
  f := CreateFileW(pwFileName, GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if (f = INVALID_HANDLE_VALUE) then exit;
  strcpyA(tmpbuf, ReportHead);
  strcatA(tmpbuf, '<Font Color = "springgreen" Face = "Tahoma" Size = "2">SYSENTER instruction hook detected - ');
  if SysEnterHooked then
  begin
    strcatA(tmpbuf, '<FONT Color="red">');
    strcatA(tmpbuf, YesId);
    strcatA(tmpbuf, '</FONT>');
  end else strcatA(tmpbuf, 'No');
  strcatA(tmpbuf, '</FONT><BR><BR>');
  strcatA(tmpbuf, TableHead);
  _WriteFile(f, @tmpbuf, strlenA(tmpbuf), @bytesIO, nil);
  FlushFileBuffers(f);
  for i := 0 to LView_ItemCount(Ldata1) - 1 do
  begin
    strcpyA(tmpbuf, '<TR>');

    buf[0] := #0;
    buf := LView_GetItemText(LData1, i, 2);
    hf := (strcmpiA(buf, YesID) = 0);

    strcatA(tmpbuf, '<TD align = "center" height = "30">');
    strcatA(tmpbuf, ColHead);
    buf[0] := #0;
    buf := LView_GetItemText(LData1, i, 0);
    if hf then strcatA(tmpbuf, RedAlert);
    strcatA(tmpbuf, buf);
    if hf then strcatA(tmpbuf, RedAlertClose);
    strcatA(tmpbuf, ColEnd);

    strcatA(tmpbuf, '<TD align = "left" height = "30">');
    strcatA(tmpbuf, ColHead);
    buf[0] := #0;
    buf := LView_GetItemText(LData1, i, 1);
    if hf then strcatA(tmpbuf, RedAlert);
    strcatA(tmpbuf, buf);
    if hf then strcatA(tmpbuf, RedAlertClose);
    strcatA(tmpbuf, ColEnd);

    strcatA(tmpbuf, '<TD align = "center" height = "30">');
    strcatA(tmpbuf, ColHead);
    if hf then
    begin
      strcpyA(buf, RedAlert);
      strcatA(buf, YesId);
      strcatA(buf, RedAlertClose);
    end else strcpyA(buf, NoId);
    strcatA(tmpbuf, buf);
    strcatA(tmpbuf, ColEnd);

    strcatA(tmpbuf, '<TD align = "center" height = "30">');
    strcatA(tmpbuf, ColHead);
    buf[0] := #0;
    buf := LView_GetItemText(LData1, i, 3);
    if hf then strcatA(tmpbuf, RedAlert);
    strcatA(tmpbuf, buf);
    if hf then strcatA(tmpbuf, RedAlertClose);
    strcatA(tmpbuf, ColEnd);

    strcatA(tmpbuf, '<TD align = "left" height = "30">');
    strcatA(tmpbuf, ColHead);
    buf[0] := #0;
    buf := LView_GetItemText(LData1, i, 4);
    if hf then strcatA(tmpbuf, RedAlert);
    strcatA(tmpbuf, buf);
    if hf then strcatA(tmpbuf, RedAlertClose);
    strcatA(tmpbuf, ColEnd);
    strcatA(tmpbuf, '</TR>');
    _WriteFile(f, @tmpbuf, strlenA(tmpbuf), @bytesIO, nil);
  end;
  _WriteFile(f, ReportEnd, strlenA(ReportEnd), @bytesIO, nil);
  CloseHandle(f);
end;

function SaveDialog(lpFilter: PWideChar; var _lpstrFile: LBuf): BOOL; stdcall;
var
  tag1: OPENFILENAMEW;
begin
  memzero(@tag1, sizeof(tag1));
  strcpyW(_lpstrFile, 'Report.htm');
  with tag1 do
  begin
    lStructSize := SizeOf(OPENFILENAMEW);
    hWndOwner := MainWindow;
    lpstrFilter := lpFilter;
    lpstrFile := _lpstrFile;
    nMaxFile := MAX_PATH;
    lpstrInitialDir := nil;
    Flags := OFN_EXPLORER or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT;
  end;
  result := GetSaveFileNameW(tag1);
end;

procedure OnResize();
var
  r1: TRECT;
begin
  GetClientRect(MainWindow, r1);
  if LData1 = nil then exit;
  SetWindowPos(LData1^.wnd, 0, 0, 0, r1.Right, r1.Bottom - 72, SWP_NOMOVE or SWP_NOZORDER);
  SetWindowPos(GetDlgItem(MainWindow, 4), 0, 269, r1.Bottom - 56, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
  SetWindowPos(GetDlgItem(MainWindow, 5), 0, 140, r1.Bottom - 56, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
  SetWindowPos(GetDlgItem(MainWindow, 3), 0, 398, r1.Bottom - 56, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
  SetWindowPos(GetDlgItem(MainWindow, 2), 0, 482, r1.Bottom - 56, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
  SendMessageW(GetDlgItem(MainWindow, 1011), WM_SIZE, 0, 0);
  RedrawWindow(StatusBar, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_ERASENOW);
end;

function MainDialogProc(hwndDlg: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
var
  buf: FBuf;
  buf1: LBuf;
begin
  result := false;
  case uMsg of
    WM_SIZE: OnResize();
    WM_INITDIALOG:
      begin
        SetClassLongW(hwndDlg, GCL_HICON, LoadIconW(hInst, pointer(120)));
        hMenu1 := LoadMenuW(Hinst, pointer(190));
        SetMenu(hwndDlg, hMenu1);
        StatusBar := GetDlgItem(hwndDlg, 1011);
        LData1 := LView_InitListView(true, hwndDlg,
          LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES or
          LVS_EX_INFOTIP,
          1010, ColumnsCount, LVTexts);
        LView_AddColumn(Ldata1, LVCFMT_LEFT, 40, PChar('Id'));
        LView_AddColumn(Ldata1, LVCFMT_LEFT, 240, PChar('Service Name'));
        LView_AddColumn(Ldata1, LVCFMT_CENTER, 50, PChar('Hooked'));
        LView_AddColumn(Ldata1, LVCFMT_CENTER, 80, PChar('Address'));
        LView_AddColumn(Ldata1, LVCFMT_LEFT, 265, PChar('Module'));
        SetWindowTextW(hwndDlg, AppName);
        FillList();
        SendMessageW(StatusBar, WM_SIZE, 0, 0);
        exit;
      end;
    WM_CLOSE:
      begin
        quit := true;
        exit;
      end;
    WM_NOTIFY:
      begin
        if (LPNMHDR(lParam)^.hwndFrom = LData1.wnd) then
        begin
          if (LPNMHDR(lParam)^.code = LVN_ITEMCHANGED) then
          begin
            buf[0] := #0;
            buf := LView_GetItemText(LData1, PNMListView(lParam)^.iItem, 0);
            SelectedService := atoui(buf);
          end;
          if (LPNMHDR(lParam)^.code) = LVN_COLUMNCLICK then
          begin
            SelectedColumn := PNMListView(lParam)^.iSubItem;
            SendMessageW(LData1.wnd, LVM_SORTITEMS, SelectedColumn, Longint(@SortNumbers));
            exit;
          end;
        end;
        exit;
      end;
    WM_COMMAND:
      case LoWord(WParam) of
        IDCANCEL:
          begin
            quit := true;
            exit;
          end;
        3: //Refresh List
          begin
            LView_ClearAll(LData1);
            FillList();
            if (SelectedColumn < 0) then SelectedColumn := 0;
            SendMessageW(LData1.wnd, LVM_SORTITEMS, SelectedColumn, Longint(@SortNumbers));
            exit;
          end;
        4: //UnHook Selected
          begin
            if (SelectedService < 0) then exit;
            if UnHook(SelectedService, false) then
            begin
              LView_ClearAll(LData1);
              FillList();
              SendMessageW(LData1.wnd, LVM_SORTITEMS, 2, Longint(@SortNumbers));
            end;
            exit;
          end;
        5: //UnHook All
          begin
            if UnHook(0, true) then
            begin
              LView_ClearAll(LData1);
              FillList();
              SendMessageW(LData1.wnd, LVM_SORTITEMS, 2, Longint(@SortNumbers));
            end;
            exit;
          end;
        6: //About Box
          begin
            AboutWindow := DialogBoxW(hinst, pointer(102), MainWindow, @AboutDialogProc);
            exit;
          end;
        7:
          begin
            memzero(@buf, MAX_PATH);
            if SaveDialog('All files'#0'*.*'#0#0, buf1) then
            begin
              SaveListToFile(buf1);
              SetCurrentDirectoryW(CurrentDirectory);
            end;
            exit;
          end;
      end;
  end;
end;

procedure GUImain();
var
  msg1: MSG;
begin
  InitCommonControls();
  hinst := GetModuleHandleW(nil);
  MainWindow := CreateDialogParamW(0, pointer(101), 0, @MainDialogProc, 0);
  while GetMessageW(msg1, 0, 0, 0) do
  begin
    TranslateMessage(msg1);
    DispatchMessageW(msg1);
    if quit then
    begin
      LView_Uninit(LData1, true);
      HeapFree(GetProcessHeap(), HEAP_NO_SERIALIZE, LData1);
      STRListDestroy(@LVTexts);
      DestroyMenu(hMenu1);
      DestroyWindow(MainWindow);
      break;
    end;
  end;
end;

var
  tmp: LBuf;

begin
  osver.dwOSVersionInfoSize := sizeof(osver);
  Windows.GetVersionExW(osver);
  if (osver.dwMajorVersion < 5) then
  begin
    MessageBoxW(0, 'Not supported Windows NT version, click OK to exit', nil, MB_OK or MB_ICONERROR);
    ExitProcess(0);
  end;
  if not RTL.EnableSystemPrivilegeW('SeLoadDriverPrivilege', true) then
  begin
    MessageBoxW(0, 'Error, load driver privilege not adjusted', nil, MB_ICONWARNING);
    ExitProcess(0);
  end;
  tmp[0] := WCHAR(0);
  GetWindowsDirectoryW(tmp, MAX_PATH);
  WideCharToMultiByte(CP_ACP, 0, @tmp, -1, windir, strlenW(tmp), nil, nil);
  tmp[0] := WCHAR(0);
  GetSystemDirectoryW(tmp, MAX_PATH);
  WideCharToMultiByte(CP_ACP, 0, @tmp, -1, winsysdir, strlenW(tmp), nil, nil);

  GetCurrentDirectoryW(MAX_PATH, CurrentDirectory);
  strcatW(CurrentDirectory, '\');
  GUImain();
  ExitProcess(0);
end.

