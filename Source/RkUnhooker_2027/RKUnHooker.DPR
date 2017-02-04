//{$DEFINE minimum}
{$DEFINE debug}
{$E exe}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$IFDEF minimum}
program RKUnHooker;
{$ENDIF}
{$IFNDEF minimum}
unit RKUnHooker;
interface
implementation
{$ENDIF}
uses
  Windows, Messages, WinBase, RTL, WinNative, commctrl, commdlg, ListView32, ObjList2;

{$R Resources.res}
const
  C_PAGES = 3;

type
  tag_dlghdr = record
    hwndTab: HWND; // tab control
    hwndDisplay: HWND; // current child dialog box
    rcDisplay: TRECT; // display rectangle for the tab control
    apRes: array[0..C_PAGES] of PDLGTEMPLATE;
  end;
  DLGHDR = tag_dlghdr;
  PDLGHDR = ^tag_dlghdr;

procedure ListProcesses(); forward;
function IsDebuggerPresent(): BOOL; forward;
procedure GenerateReport(); forward;

function OnSelChanged(hwndDlg: HWND): BOOL; stdcall; forward;

const
  SERVICE_BOOT_START = $00000000;
  SERVICE_ERROR_NORMAL = $00000001;
  SERVICE_DEMAND_START = $00000003;
  SERVICE_KERNEL_DRIVER = $00000001;
  //количество колонок для каждого листвью начиная с первой вкладки

  ColumnsCount = 4;
  ColumnsCount2 = 3;
  ColumnsCount3 = 3;

  AppName: PWideChar = 'RootKit UnHooker v2.0.200 win32 NTx86 UNICODE';
  DriverLink: PWideChar = '\\.\rkhdrv10';
  ServiceDisplayName: PWideChar = 'RootKit Unhooker Driver';
  ServiceFileName: PWideChar = 'rkhdrv10.sys';
  RegPath: PWideChar = '\Registry\Machine\System\CurrentControlSet\Services\rkhdrv10';
  ServiceKeyName: PWideChar = 'SYSTEM\CurrentControlSet\Services\rkhdrv10';
  RKUnHookerKey: PWideChar = 'SOFTWARE\RKU';
  RKUnHookerValue: PWideChar = 'Settings';
  LoadedOrdersGroup: PWideChar = 'SYSTEM\CurrentControlSet\Control\GroupOrderList';
  AboutStr: PWideChar = 'July 08, 2006.';
  UnknownModule: PAnsiChar = 'Unknown module filename';
  SENTEROK: PWideChar = 'SYSENTER state - OK, ';
  SENTERBAD: PWideChar = 'SYSENTER !HOOKED! ';
  IDTOK: PWideChar = 'Int 2E state - OK, ';
  IDTBAD: PWideChar = 'Int 2E !HOOKED! ';
  ServiceGroupName: PWideChar = 'Boot Bus Extender';
//tab sheet init
  Page_1: PChar = 'SSDT Hooks Detector/Restorer';
  Page_2: PChar = 'Hidden Modules Detector'; //"DnG"
  Page_3: PChar = 'Hidden Processes Detector'; //"Stealth mode engine"
  Page_4: PChar = 'Hidden Files Detector'; //"FDetector"
  Page_5: PChar = 'Report';
  ServiceTag = $1000;

type
  _Options = record
    bStealthEngine: boolean;
    dwReserved: DWORD;
  end;
  TOptions = _Options;
  POptions = ^_Options;

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
  MainHdr: PDLGHDR = nil;
  mi1: hMenu;
  ChildDialogProc: array[0..C_PAGES] of pointer;
  dwDlgBase: DWORD;
  cxMargin, cyMargin: integer;

  InfoClass: DWORD = 0;
  CurrentDirectory: LBuf;
  MainWindow, AboutWindow, StatusBar: HWND;

  LData1: PListViewData = nil; //SSDT ListView
  LData2: PListViewData = nil; //Drivers ListView
  LData3: PListViewData = nil; //Processes ListView
  ListBoxWND: HWND = 0;
  r2: TPOINT = (x: 0; y: 0);
  LVTexts: TSTRList;
  Report: TSTRList;
  quit: Boolean = false;
  hInst: Cardinal;
  kmodule: infobuffer;
  UModules: PSystemModules;
  bytesIO: DWORD;
  listexp: array[0..383, 0..255] of AnsiChar;
  CurrentTable, OrigTable: PDWBUF;
  Modules: PSystemModules;
  sdt1: SERVICE_DESCRIPTOR_ENTRY;
  hMenu1: HMENU;
  hMenu2: HMENU;
  osver: OSVERSIONINFOW;
  SelectedColumn: integer = 0;
  SelectedColumnLV2: integer = 0;
  SelectedColumnLV3: integer = 0;
  k: dword = 0;
  windir, winsysdir: FBuf; //переменные под windows & windows\system32
  CallGateHooked: boolean = false; //хук на системный вызов
  DriverHandle: THANDLE = 0; //дескриптор драйвера
  skey: HKEY; //переменная для хранения дескриптора ключа реестра
  DataSize: DWORD = 0; //размер данных для чтения реестра
  DataType: DWORD = 0; //тип данных для чтения из реестра
  Options: TOptions = (bStealthEngine: false; dwReserved: 0); //настройки приложения

  {CTL codes}
  IOPORT_READ_KERNEL_SDT: cardinal;
  IOPORT_WRITE_KERNEL_SDT: cardinal;
  IOPORT_GET_KERNEL_SDT_INFO: cardinal;
  IOPORT_GET_KERNEL_SYSTEM_INFO: cardinal;
  IOPORT_GET_KERNEL_SYSENTER_INFO: cardinal;
  IOPORT_LIST_CID: cardinal;
  IOPORT_KILL_PROCESS: cardinal;

//функция извлечения драйвера из исполняемого файла

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
{$IFNDEF debug}
  asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp
  @@1:
    call @@2
    jmp @@3
  @@2:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    mov [ecx], ecx
    jmp @@1
  @@3:
    mov esp, k
    popad
    popfd
  end;
{$ENDIF}
  hRes := FindResourceW(hinst, 'rkhdrv10', 'BINRES');
  if (hRes = 0) then exit;
  size := SizeOfResource(hinst, hRes);
  if (size = 0) then exit;
  hResData := LoadResource(hinst, hRes);
  if (hResData = 0) then exit;
  p1 := LockResource(hResData);
  if (p1 = nil) then exit;
  memzero(@buf, sizeof(buf));
  GetSystemDirectoryW(buf, MAX_PATH);
  strcatW(buf, '\drivers\');
  strcatW(buf, ServiceFileName);
  bytesIO := 0;
  f := CreateFileW(buf, GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_FLAG_SEQUENTIAL_SCAN, 0);
  _WriteFile(f, p1, size, @bytesIO, nil);
  CloseHandle(f);
  result := (bytesIO = size);
end;

//функция удаления драйвера с диска

function DeleteDriver(): boolean;
var
  buf: LongBufW;
begin
  strcpyW(buf, CurrentDirectory);
  strcatW(buf, ServiceFileName);
  result := DeleteFileW(buf);
end;

//читаем настройки программы из реестра

procedure ReadSettings();
begin
  if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, RKUnHookerKey, 0, nil,
    REG_OPTION_NON_VOLATILE, KEY_READ, nil, skey, @DataSize) <> ERROR_SUCCESS) then exit;
  if (RegQueryValueExW(skey, RKUnHookerValue, nil, @DataType, nil, @DataSize) = ERROR_SUCCESS) then
  begin
    RegQueryValueExW(skey, RKUnHookerValue, nil, @DataType, @Options, @DataSize);
  end;
  RegCloseKey(skey);
  skey := 0;
end;

//записываем настройки в реестр

procedure WriteSettings();
begin
  if RegCreateKeyExW(HKEY_LOCAL_MACHINE, RKUnHookerKey, 0, nil,
    REG_OPTION_NON_VOLATILE, KEY_WRITE, nil, skey, @bytesIO) <> ERROR_SUCCESS then exit;
  RegSetValueExW(skey, RKUnHookerValue, 0, REG_BINARY, @Options, sizeof(TOptions));
  RegCloseKey(skey);
  skey := 0;
end;

//Записываем данные драйвера на загрузку как BOOT_START

function WriteLoadSettings(bBootStart: boolean): boolean; stdcall;
var
  disp: DWORD;
begin
  result := false;
  if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, ServiceKeyName, 0, nil,
    REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, nil, skey, @disp) <> ERROR_SUCCESS) then exit;
  if bBootStart then
  begin
    RegSetValueExW(skey, 'Group', 0, REG_SZ, ServiceGroupName,
      (strlenW(ServiceGroupName) + 1) * sizeof(WideChar));
    disp := ServiceTag;
    RegSetValueExW(skey, 'Tag', 0, REG_DWORD, @disp, sizeof(DWORD));
  end
  else
  begin
    RegDeleteValueW(skey, 'Tag');
    RegDeleteValueW(skey, 'Group');
  end;
  RegSetValueExW(skey, 'DisplayName', 0, REG_SZ, ServiceDisplayName,
    (strlenW(ServiceDisplayName) + 1) * sizeof(WideChar));
  disp := SERVICE_ERROR_NORMAL;
  RegSetValueExW(skey, 'ErrorControl', 0, REG_DWORD, @disp, sizeof(DWORD));
  if bBootStart then disp := SERVICE_BOOT_START else disp := SERVICE_DEMAND_START;
  RegSetValueExW(skey, 'Start', 0, REG_DWORD, @disp, sizeof(DWORD));
  disp := SERVICE_KERNEL_DRIVER;
  RegSetValueExW(skey, 'Type', 0, REG_DWORD, @disp, sizeof(DWORD));
  RegCloseKey(skey);
  skey := 0;
  result := true;
end;

//записываем себя первыми на загрузку, потом вызываем функцию записи данных драйвера

procedure CheckLoadingOrderSet(bEnable: boolean);
var
  buf: array[0..1023] of DWORD;
begin
  if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, LoadedOrdersGroup, 0, nil,
    REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, nil, skey, @DataType) <> ERROR_SUCCESS) then exit;
  DataSize := 0;
  if (RegQueryValueExW(skey, ServiceGroupName, nil, @DataType, nil,
    @DataSize) = ERROR_SUCCESS) then
  begin
    memzero(@buf, sizeof(buf));
    RegQueryValueExW(skey, ServiceGroupName, nil, @DataType, @buf[2], @DataSize);
    if bEnable then
    begin
      if (buf[2] <> ServiceTag) or (buf[3] <> ServiceTag) then
      begin
        buf[0] := ServiceTag;
        buf[1] := ServiceTag;
        RegSetValueExW(skey, ServiceGroupName, 0, REG_BINARY, @buf, DataSize + (2 * sizeof(DWORD)));
      end;
    end else
    begin
      if (buf[2] = ServiceTag) and (buf[3] = ServiceTag) then
        RegSetValueExW(skey, ServiceGroupName, 0, REG_BINARY, @buf[4], DataSize - 2 * sizeof(DWORD));
    end;
    WriteLoadSettings(bEnable);
  end;
  RegCloseKey(skey);
end;

//грузим чертов драйвер

function LoadServiceDriver(bBootEnable: boolean): BOOL; stdcall;
var
  s1: UNICODE_STRING;
  buf: LBuf;
  disp: DWORD;
begin
  result := false;
  if (not ExtractDriver()) then
  begin
    MessageBoxW(MainWindow, 'Error extracting driver', nil, MB_ICONERROR);
    exit;
  end;
  if not WriteLoadSettings(bBootEnable) then
  begin
    MessageBoxW(MainWindow, 'Error creating registry key', nil, MB_ICONERROR);
    DeleteDriver();
    exit;
  end;
  RtlInitUnicodeString(@s1, RegPath);
  disp := ZwLoadDriver(@s1);
  if (disp <> 0) then
  begin
    strcpyW(buf, 'Error loading driver, NTSTATUS code: ');
    uitohexW(disp, strendW(buf));
    MessageBoxW(MainWindow, buf, nil, MB_ICONERROR);
    exit;
  end;
  result := true;
end;

//дампим оригинальную SSDT

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
{$IFNDEF debug}
  asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp
  @@1:
    call @@2
    jmp @@3
  @@2:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    db $0f, $0b
    jmp @@1
  @@3:
    mov esp, k
    popad
    popfd
  end;
{$ENDIF}
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
  bytesIO := 0;
  ZwQuerySystemInformation(SystemModuleInformation, @kmodule, sizeof(kmodule), @bytesIO);

  DeviceIoControl(DriverHandle, IOPORT_GET_KERNEL_SDT_INFO, nil, 0, @sdt1, sizeof(SERVICE_DESCRIPTOR_ENTRY), bytesIO, nil);
  CurrentTable := VirtualAlloc(nil, sdt1.NumberOfServices * sizeof(PVOID), MEM_COMMIT, PAGE_READWRITE);

  OrigTable := VirtualAlloc(nil, sdt1.NumberOfServices * sizeof(PVOID), MEM_COMMIT, PAGE_READWRITE);

  DumpOrigSDT();
  DeviceIoControl(DriverHandle, IOPORT_READ_KERNEL_SDT, nil, 0, CurrentTable, sdt1.NumberOfServices * sizeof(PVOID), bytesIO, nil);
  DumpExports(ntdll);

  LView_ClearAll(LData1);
  STRListClear(@LVTexts);
  c := 0;
  t := 0;
{$IFNDEF debug}
  asm
      pushfd
      pushad
      xor ecx, ecx
      mov k, esp
    @@1:
      call @@2
      jmp @@3
    @@2:
      push dword ptr fs:[ecx]
      mov fs:[ecx], esp
      div ecx
      jmp @@1
    @@3:
      mov esp, k
      popad
      popfd
  end;
{$ENDIF}
  InfoClass := DWORD(SystemModuleInformation);
  DeviceIoControl(DriverHandle, IOPORT_GET_KERNEL_SYSTEM_INFO, @InfoClass, sizeof(DWORD), @c, sizeof(DWORD), bytesIO, nil);
  if (c <> 0) then
  begin
    Modules := VirtualAlloc(nil, c, MEM_COMMIT, PAGE_READWRITE);
    DeviceIoControl(DriverHandle, IOPORT_GET_KERNEL_SYSTEM_INFO, @InfoClass, sizeof(DWORD), Modules, c, bytesIO, nil);

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
  case osver.dwMinorVersion of
    0:
      begin
        if not CallGateHooked then strcpyW(buf3, IDTOK) else strcpyW(buf3, IDTBAD);
      end;
    1, 2:
      begin
        DeviceIoControl(DriverHandle, IOPORT_GET_KERNEL_SYSENTER_INFO, nil, 0, @c, sizeof(DWORD), bytesIO, nil);
        CallGateHooked := not ((c >= DWORD(kmodule.moduleinfo.Base)) and (c <= (DWORD(kmodule.moduleinfo.Base) + kmodule.moduleinfo.Size)));
        if not CallGateHooked then strcpyW(buf3, SENTEROK) else strcpyW(buf3, SENTERBAD);
      end;
  end;
  strcatW(buf3, 'Services/Hooked: ');
  uitoW(sdt1.NumberOfServices, strendW(buf3));
  strcatW(buf3, '/');
  uitoW(t, strendW(buf3));
  SetWindowTextW(StatusBar, buf3);
  VirtualFree(Modules, 0, MEM_RELEASE);
  VirtualFree(CurrentTable, 0, MEM_RELEASE);
  VirtualFree(OrigTable, 0, MEM_RELEASE);
end;

function UnHook(ServiceNumber: cardinal; uhall: boolean): boolean;
var
  bytesIO, c: DWORD;
  sp1: KSERVICE_PTR;
begin
  result := false;
  ZwQuerySystemInformation(SystemModuleInformation, @kmodule, sizeof(kmodule), @bytesIO);

  DeviceIoControl(DriverHandle, IOPORT_GET_KERNEL_SDT_INFO, nil, 0, @sdt1, sizeof(SERVICE_DESCRIPTOR_ENTRY), bytesIO, nil);
  CurrentTable := VirtualAlloc(nil, sdt1.NumberOfServices * sizeof(PVOID), MEM_COMMIT, PAGE_READWRITE);
  OrigTable := VirtualAlloc(nil, sdt1.NumberOfServices * sizeof(PVOID), MEM_COMMIT, PAGE_READWRITE);

  DumpOrigSDT();
  DeviceIoControl(DriverHandle, IOPORT_READ_KERNEL_SDT, nil, 0, CurrentTable, sdt1.NumberOfServices * sizeof(PVOID), bytesIO, nil);
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
        result := DeviceIoControl(DriverHandle, IOPORT_WRITE_KERNEL_SDT, @sp1, sizeof(KSERVICE_PTR), nil, 0, bytesIO, nil);
      end;
  end
  else
  begin
    for c := 0 to sdt1.NumberOfServices - 1 do
      if (CurrentTable^[c] <> OrigTable^[c]) and (c = ServiceNumber) then
      begin
        sp1.dwServiceNumber := c;
        sp1.dwServiceEntryPoint := pointer(OrigTable^[c] + DWORD(kmodule.moduleinfo.Base));
        result := DeviceIoControl(DriverHandle, IOPORT_WRITE_KERNEL_SDT, @sp1, sizeof(KSERVICE_PTR), nil, 0, bytesIO, nil);
      end;
  end;
  VirtualFree(CurrentTable, 0, MEM_RELEASE);
  VirtualFree(OrigTable, 0, MEM_RELEASE);
end;

function SortListView1(n1, n2: cardinal; nSortData: dword): dword; stdcall;
var
  c1, c2: cardinal;
begin
  case nSortData of
    0:
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
    1, 3, 4:
      begin
        result := strcmpiA(STRListGetEntry(@ps1(n1)^.text, nSortData), STRListGetEntry(@ps1(n2)^.text, nSortData));
        exit;
      end;
    2:
      begin
        result := strcmpiA(STRListGetEntry(@ps1(n2)^.text, nSortData), STRListGetEntry(@ps1(n1)^.text, nSortData));
        exit;
      end;
  else result := MaxDword;
  end;
end;

function SortListView2(n1, n2: cardinal; nSortData: dword): dword; stdcall;
begin
  result := strcmpiA(STRListGetEntry(@ps1(n1)^.text, nSortData), STRListGetEntry(@ps1(n2)^.text, nSortData));
end;

function SortListView3(n1, n2: cardinal; nSortData: dword): dword; stdcall;
var
  c1, c2: cardinal;
begin
  case nSortData of
    0:
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
    1..3:
      begin
        result := strcmpiA(STRListGetEntry(@ps1(n1)^.text, nSortData), STRListGetEntry(@ps1(n2)^.text, nSortData));
        exit;
      end;
  else result := MaxDword;
  end;
end;

var
  SelectedService: integer = -1;
  SelectedProcess: Cardinal = MaxDword;

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

procedure GenerateReport();
var
  buf: array[0..1023] of WCHAR;
  buf2: FBuf;
  buf3: array[0..1023] of CHAR;
  i: integer;
  hf: boolean;
begin
  SendMessageW(ListBoxWND, LB_RESETCONTENT, 0, 0);
  STRListClear(@Report);
  buf[0] := #0;
  hf := false;
  if CallGateHooked then
  begin
    hf := true;
    STRListAdd(@Report, 'System Call Instruction Hooked!');
  end;
  SendMessageW(MainHdr^.hwndTab, TCM_SETCURSEL, 0, 0);
  OnSelChanged(MainWindow);
  SendMessageW(LData1.wnd, LVM_SORTITEMS, 2, Longint(@SortListView1));

  //List SSDT
  STRListAdd(@Report, '>SDT State');
  for i := 0 to LView_ItemCount(Ldata1) - 1 do
  begin
    buf2[0] := #0;
    buf2 := LView_GetItemText(LData1, i, 2);
    if (strcmpiA(@buf2, YesID) = 0) then
    begin
      hf := true;
      strcpyA(buf3, 'Hooked service: ');
      buf2 := LView_GetItemText(LData1, i, 1);
      strcatA(buf3, buf2);
      STRListAdd(@Report, @buf3);

      strcpyA(buf3, 'Actual Address: ');
      buf2 := LView_GetItemText(LData1, i, 3);
      strcatA(buf3, buf2);
      STRListAdd(@Report, @buf3);

      strcpyA(buf3, 'Hooked by: ');
      buf2 := LView_GetItemText(LData1, i, 4);
      strcatA(buf3, buf2);
      STRListAdd(@Report, @buf3);
      buf3[0] := #0;
      STRListAdd(@Report, @buf3);
    end;
  end;

  //List Processes
  SendMessageW(MainHdr^.hwndTab, TCM_SETCURSEL, 1, 0);
  OnSelChanged(MainWindow);
  SendMessageW(LData3.wnd, LVM_SORTITEMS, 3, Longint(@SortListView3));

  STRListAdd(@Report, '>Processes');
  for i := 0 to LView_ItemCount(Ldata3) - 1 do
  begin
    buf2[0] := #0;
    buf2 := LView_GetItemText(LData3, i, 3);
    if (strcmpiA(buf2, YesID) = 0) then
    begin
      hf := true;
      strcpyA(buf3, 'Hidden process: ');
      buf2 := LView_GetItemText(LData3, i, 1);
      strcatA(buf3, buf2);
      STRListAdd(@Report, @buf3);

      strcpyA(buf3, 'Process Id: ');
      buf2 := LView_GetItemText(LData3, i, 0);
      strcatA(buf3, buf2);
      STRListAdd(@Report, @buf3);

      strcpyA(buf3, 'EPROCESS Address: ');
      buf2 := LView_GetItemText(LData3, i, 2);
      strcatA(buf3, buf2);
      STRListAdd(@Report, @buf3);
      buf3[0] := #0;
      STRListAdd(@Report, @buf3);
    end;
  end;

  //List Drivers
  SendMessageW(MainHdr^.hwndTab, TCM_SETCURSEL, 2, 0);
  OnSelChanged(MainWindow);
  SendMessageW(LData2.wnd, LVM_SORTITEMS, 3, Longint(@SortListView2));
  STRListAdd(@Report, '>Drivers');
  for i := 0 to LView_ItemCount(Ldata2) - 1 do
  begin
    buf2[0] := #0;
    buf2 := LView_GetItemText(LData2, i, 3);
    if (strcmpiA(buf2, YesID) = 0) then
    begin
      hf := true;
      strcpyA(buf3, 'Hidden driver: ');
      buf2 := LView_GetItemText(LData2, i, 0);
      strcatA(buf3, buf2);
      STRListAdd(@Report, @buf3);

      strcpyA(buf3, 'Loaded from: ');
      buf2 := LView_GetItemText(LData2, i, 1);
      strcatA(buf3, buf2);
      STRListAdd(@Report, @buf3);

      strcpyA(buf3, 'Address: ');
      buf2 := LView_GetItemText(LData2, i, 2);
      strcatA(buf3, buf2);
      STRListAdd(@Report, @buf3);
      buf3[0] := #0;
      STRListAdd(@Report, @buf3);
    end;
  end;

  SendMessageW(MainHdr^.hwndTab, TCM_SETCURSEL, 3, 0);
  OnSelChanged(MainWindow);

  for i := 0 to Integer(Report.FCount) - 1 do
  begin
    MultiByteToWideChar(CP_ACP, 0, STRListGetEntry(@Report, i),
      -1, buf, MAX_PATH);
    SendMessageW(ListBoxWND, LB_ADDSTRING, 0, Integer(@buf));
  end;
  buf[0] := #0;
  if (hf) then
    strcpyW(buf, '!!POSSIBLE ROOTKIT ACTIVITY DETECTED!! =)') else
    strcpyW(buf, 'Nothing detected :(');
  SendMessageW(ListBoxWND, LB_ADDSTRING, 0, Integer(@buf));
  SetWindowTextW(StatusBar, @buf);
end;

procedure SaveListToFile(pwFileName: PWideChar);
var
  f: THANDLE;
  bytesIO: DWORD;
  i: integer;
  buf: array[0..1025] of CHAR;
begin
  f := CreateFileW(pwFileName, GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  for i := 0 to Integer(Report.FCount) - 1 do
  begin
    strcpyA(buf, STRListGetEntry(@Report, i));
    strcatA(buf, #13#10);
    _WriteFile(f, @buf, strlenA(buf), @bytesIO, nil);
  end;
  CloseHandle(f);
end;

function SaveDialog(lpFilter: PWideChar; var _lpstrFile: LBuf): BOOL; stdcall;
var
  tag1: OPENFILENAMEW;
begin
  memzero(@tag1, sizeof(tag1));
  strcpyW(_lpstrFile, 'Report.txt');
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

procedure DnG(); //dig and get
var
  c, t, u, i: dword;
  buf, buf2: FBuf;
  buf3: LBuf;
  found: boolean;
begin
  ZwQuerySystemInformation(SystemModuleInformation, @i, sizeof(DWORD), @bytesIO);
  UModules := VirtualAlloc(nil, bytesIO, MEM_COMMIT, PAGE_READWRITE);
  if (UModules = nil) then
  begin
    MessageBoxW(MainWindow, 'Error allocate memory', nil, MB_ICONERROR);
    exit;
  end;
  ZwQuerySystemInformation(SystemModuleInformation, UModules, bytesIO, @bytesIO);

  LView_ClearAll(LData2);
  c := 0;
  t := 0;
  buf[0] := #0;
  InfoClass := DWORD(SystemModuleInformation);
  DeviceIoControl(DriverHandle, IOPORT_GET_KERNEL_SYSTEM_INFO, @InfoClass, sizeof(InfoClass), @c, sizeof(DWORD), bytesIO, nil);
  if (c <> 0) then
  begin
    Modules := VirtualAlloc(nil, c, MEM_COMMIT, PAGE_READWRITE);
    DeviceIoControl(DriverHandle, IOPORT_GET_KERNEL_SYSTEM_INFO, @InfoClass, sizeof(InfoClass), Modules, c, bytesIO, nil);

    found := false;
    for u := 0 to Modules^.Count - 1 do
    begin
      for i := 0 to UModules^.Count - 1 do
      begin
        if (UModules^.sysmodules[i].Base = Modules^.sysmodules[u].Base) and
          (UModules^.sysmodules[i].Index = Modules^.sysmodules[u].Index) then
        begin
          found := true;
          break;
        end;
        if not found then inc(t);
      end;
      STRListClear(@LVTexts);
      buf2 := DecodeModuleName(Modules^.sysmodules[u].ImageName);

        //display name only
      strcpyA(buf, @Modules^.sysmodules[u].ImageName[Modules^.sysmodules[u].ModuleNameOffset]);
      STRListAdd(@LVTexts, buf);
      STRListAdd(@LVTexts, buf2); //decoded path to driver

        //address
      strcpyA(buf, '0x');
      RTL.uitohex(Cardinal(Modules^.sysmodules[u].Base), strendA(buf));
      STRListAdd(@LVTexts, buf);

        //hidden from user mode API
      if not found then STRListAdd(@LVTexts, '!Hidden module!') else
        STRListAdd(@LVTexts, '-');
      LView_AddItem(LData2, LView_ItemCount(LData2), ColumnsCount2, LVTexts);
    end;
  end;
  strcpyW(buf3, 'Drivers/Hidden: ');
  uitoW(Modules^.Count, strendW(buf3));
  strcatW(buf3, '/');
  uitoW(t, strendW(buf3));
  SetWindowTextW(StatusBar, buf3);
  VirtualFree(Modules, 0, MEM_RELEASE);
  VirtualFree(UModules, 0, MEM_RELEASE);
end;

//all resize must be here

procedure ResizeButtons(r1: PRECT); stdcall;
begin
  SetWindowPos(GetDlgItem(MainWindow, 4), 0, 269, r1^.Bottom + 10, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
  SetWindowPos(GetDlgItem(MainWindow, 5), 0, 140, r1^.Bottom + 10, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
  SetWindowPos(GetDlgItem(MainWindow, 3), 0, 398, r1^.Bottom + 10, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
  SetWindowPos(GetDlgItem(MainWindow, 2), 0, 482, r1^.Bottom + 10, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
end;

procedure ResizeTabWindow(TabWindow: HWND); stdcall;
var
  r1: TRECT;
  iSel: integer;
begin
  GetClientRect(MainHdr^.hwndTab, r1);
  ResizeButtons(@r1);
  SetWindowPos(TabWindow, HWND_TOP, MainHdr^.rcDisplay.left,
    MainHdr^.rcDisplay.top, r1.right - 10, r1.Bottom - 26, 0);
  GetClientRect(MainHdr^.hwndTab, r1);
  iSel := SendMessageW(MainHdr^.hwndTab, TCM_GETCURSEL, 0, 0);
  case iSel of
    0: //SSDT
      begin
        if (LData1 = nil) then exit;
        SetWindowPos(LData1^.wnd, 0, 0, 0, r1.Right - 10, r1.Bottom - 30, SWP_NOMOVE or SWP_NOZORDER);
      end;
    1: //Processes
      begin
        if (LData3 = nil) then exit;
        SetWindowPos(LData3^.wnd, 0, 0, 0, r1.Right - 10, r1.Bottom - 30, SWP_NOMOVE or SWP_NOZORDER);
      end;
    2: //Drivers
      begin
        if (LData2 = nil) then exit;
        SetWindowPos(LData2^.wnd, 0, 0, 0, r1.Right - 10, r1.Bottom - 30, SWP_NOMOVE or SWP_NOZORDER);
      end;
    3: //Report
      begin
        SetWindowPos(ListBoxWnd, 0, 0, 0, r1.Right - 10, r1.Bottom - 30, SWP_NOMOVE or SWP_NOZORDER);
      end;
  end;
end;

//on tab selection change proc

function OnSelChanged(hwndDlg: HWND): BOOL; stdcall;
var
  iSel: integer;
begin
  result := false;
  iSel := SendMessageW(MainHdr^.hwndTab, TCM_GETCURSEL, 0, 0);
  if (iSel = -1) then exit;
  if (MainHdr^.hwndDisplay <> 0) then DestroyWindow(MainHdr^.hwndDisplay);
  MainHdr^.hwndDisplay := CreateDialogIndirectW(hinst, PDLGTEMPLATE(MainHdr^.apRes[iSel])^, hwndDlg, ChildDialogProc[iSel]);
  ResizeTabWindow(MainHdr^.hwndDisplay);
  case iSel of
    0:
      begin
        EnableWindow(GetDlgItem(MainWindow, 4), true); //unhook selected
        EnableWindow(GetDlgItem(MainWindow, 5), true); //unhook all
      end;
    1, 2, 3:
      begin
        EnableWindow(GetDlgItem(MainWindow, 4), false); //unhook selected
        EnableWindow(GetDlgItem(MainWindow, 5), false); //unhook all
      end;
  end;
end;

//lock resource dlg

function DoLockDlgRes(ResName: PWideChar): PDLGTEMPLATE; stdcall;
var
  hrsrc: Cardinal;
  hglb: HGLOBAL;
begin
  hrsrc := FindResourceW(hinst, ResName, pointer(RT_DIALOG));
  hglb := LoadResource(hinst, hrsrc);
  result := pointer(LockResource(hglb));
end;

//инициализация таб контрола

procedure OnTabbedDialogInit(hwndDlg: HWND); stdcall;
var
  tie: TC_ITEM;
  rcTab: TRECT;
begin
  dwDlgBase := GetDialogBaseUnits();
  cxMargin := LoWord(dwDlgBase) div 4;
  cyMargin := HiWord(dwDlgBase) div 8;

  MainHdr^.hwndTab := GetDlgItem(hwndDlg, 1000);
  if (MainHdr^.hwndTab = 0) then exit;
  memzero(@tie, sizeof(tie));
  tie.mask := TCIF_TEXT or TCIF_IMAGE;
  tie.iImage := -1;

  tie.pszText := Page_1;
  tie.cchTextMax := strlenA(Page_1);
  SendMessageW(MainHdr^.hwndTab, TCM_INSERTITEM, 0, LPARAM(@tie));

  tie.pszText := Page_3;
  tie.cchTextMax := strlenA(Page_3);
  SendMessageW(MainHdr^.hwndTab, TCM_INSERTITEM, 2, LPARAM(@tie));

  tie.pszText := Page_2;
  tie.cchTextMax := strlenA(Page_2);
  SendMessageW(MainHdr^.hwndTab, TCM_INSERTITEM, 3, LPARAM(@tie));

  tie.pszText := Page_5;
  tie.cchTextMax := strlenA(Page_5);
  SendMessageW(MainHdr^.hwndTab, TCM_INSERTITEM, 4, LPARAM(@tie));

  MainHdr^.apRes[0] := DoLockDlgRes(pointer(101));
  MainHdr^.apRes[1] := DoLockDlgRes(pointer(105));
  MainHdr^.apRes[2] := DoLockDlgRes(pointer(103));
  MainHdr^.apRes[3] := DoLockDlgRes(pointer(106));

  SetRectEmpty(rcTab);
  GetWindowRect(MainHdr^.hwndTab, rcTab);
  SendMessageW(MainHdr^.hwndTab, TCM_ADJUSTRECT, WPARAM(TRUE), LPARAM(@rcTab));
  OffsetRect(rcTab, cxMargin - rcTab.left, cyMargin - rcTab.top);
  CopyRect(MainHdr^.rcDisplay, rcTab);
  SendMessageW(MainHdr^.hwndTab, TCM_ADJUSTRECT, WPARAM(FALSE), LPARAM(@MainHdr^.rcDisplay));
  SetWindowPos(MainHdr^.hwndTab, 0, rcTab.left, rcTab.top, rcTab.right - rcTab.left, rcTab.bottom - rcTab.top - 20,
    SWP_NOZORDER);
  OnSelChanged(hwndDlg);
end;

//list processes procedure

type
  _EPROCESSINFO_ENTRY = record
    EPROCESSptr: PVOID;
    UniqueProcessId: ULONG;
    ObjectTable: POINTER;
    ImageFileName: array[0..15] of UCHAR;
  end; EPROCESSINFO_ENTRY = _EPROCESSINFO_ENTRY; PEPROCESSINFO_ENTRY = ^_EPROCESSINFO_ENTRY;

type
  _EPROCESSINFO = record
    CountOfEntries: ULONG;
    ProcessList: array[0..0] of EPROCESSINFO_ENTRY;
  end; EPROCESSINFO = _EPROCESSINFO; PEPROCESSINFO = ^_EPROCESSINFO;

type
  TProcessInfo = record
    uProcessId: ULONG;
    EPROCESSptr: PVOID;
    ImageFileName: array[0..15] of CHAR;
    Hidden: boolean;
  end;
  PProcessInfo = ^TProcessInfo;

  TTHLProcessInfo = record
    dwProcessId: ULONG;
    ImageFileName: array[0..15] of CHAR;
  end;

procedure ListProcesses();
var
  dwProcessCount, dwHiddenCount: dword;
  buf3: LBuf;
  buf: FBuf;
  pBuf: pointer;
  c, t, u: integer;
  pBuffer: PROCESSENTRY32W;
  SnapShotHandle: THANDLE;
  inf1: PEPROCESSINFO;

  EPBuf: array[0..127] of TProcessInfo;
 // EPBuf: array[0..127] of pointer;
  THBuf: array[0..127] of TTHLProcessInfo;
  EPCount: integer;
  f2: boolean;

  procedure AddProcessToList(ProcessInfo: PProcessInfo);
  var
    buf: FBuf;
  begin
    STRListClear(@LVTexts);
    //PID
    uitoA(ProcessInfo^.uProcessId, buf);
    STRListAdd(@LVTexts, buf);
    //Name
    STRListAdd(@LVTexts, @ProcessInfo^.ImageFileName);
    //EPROCESS Address
    strcpyA(buf, '0x');
    uitohex(DWORD(ProcessInfo^.EPROCESSptr), strendA(buf));
    STRListAdd(@LVTexts, buf);
    //Hidden
    if ProcessInfo^.Hidden then strcpyA(buf, 'Yes') else strcpyA(buf, '-');
    STRListAdd(@LVTexts, buf);
    LView_AddItem(LData3, LView_ItemCount(LData3), ColumnsCount3, LVTexts);
  end;

begin
  pBuf := VirtualAlloc(nil, 4194304, MEM_COMMIT, PAGE_READWRITE);
  inf1 := pBuf;
  bytesIO := 0;
  DeviceIoControl(DriverHandle, IOPORT_LIST_CID, nil, 0, pBuf, 4194304, bytesIO, nil);
  EPCount := 0;
  memzero(@EPBuf, sizeof(EPBuf));
  for c := 0 to inf1^.CountOfEntries - 1 do
  begin
    f2 := true;
    for t := 0 to EPCount - 1 do
      if inf1^.ProcessList[c].EPROCESSptr = EPBuf[t].EPROCESSptr then
      begin
        f2 := false;
        break;
      end;

    if f2 and (inf1^.ProcessList[c].ObjectTable <> nil) then
    begin
      EPBuf[EPCount].EPROCESSptr := inf1^.ProcessList[c].EPROCESSptr;
      EPBuf[EPCount].uProcessId := inf1^.ProcessList[c].UniqueProcessId;
      memcopy(@EPBuf[EPCount].ImageFileName, @inf1^.ProcessList[c].ImageFileName, sizeof(inf1^.ProcessList[c].ImageFileName));
      inc(EPCount);
    end;
  end;
  VirtualFree(pBuf, 0, MEM_RELEASE);

  //Get ToolHelp Information

  t := 0;
  memzero(@THBuf, sizeof(THBuf));
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat
        THBuf[t].dwProcessId := pBuffer.th32ProcessID;
        memzero(@buf, sizeof(buf));
        WideCharToMultiByte(CP_ACP, 0, @pBuffer.szExeFile, -1, buf, strlenW(@pBuffer.szExeFile), nil, nil);
        strcpynA(THBuf[t].ImageFileName, buf, sizeof(THBuf[t].ImageFileName));
        inc(t);
      until (not Process32NextW(SnapShotHandle, @pBuffer));
  CloseHandle(SnapShotHandle);
  dwProcessCount := 0;
  dwHiddenCount := 0;

  for c := 0 to EPCount - 1 do
  begin
    f2 := true;
    for u := 0 to t - 1 do
      if (EPBuf[c].uProcessId = THBuf[u].dwProcessId) and
        (strcmpinA(EPBuf[c].ImageFileName, THBuf[u].ImageFileName, sizeof(EPBuf[c].ImageFileName)) = 0)
        then
      begin
        EPBuf[c].Hidden := false;
        f2 := false;
        break;
      end;
    if f2 then inc(dwHiddenCount);
    inc(dwProcessCount);
    AddProcessToList(@EPBuf[c]);
  end;

  SendMessageW(LData3.wnd, LVM_SORTITEMS, 0, Longint(@SortListView3));
  strcpyW(buf3, 'Processes/Hidden: ');
  uitoW(dwProcessCount, strendW(buf3));
  strcatW(buf3, '/');
  uitoW(dwHiddenCount, strendW(buf3));
  SetWindowTextW(StatusBar, buf3);
end;

procedure SetMenuState(iSel: integer);
begin
  case iSel of
    0: //SSDT
      begin
        EnableMenuItem(hMenu2, 0, MF_BYCOMMAND or MF_BYPOSITION or MF_ENABLED);
        EnableMenuItem(hMenu2, 1, MF_BYCOMMAND or MF_BYPOSITION or MF_ENABLED);
        EnableMenuItem(hMenu2, 3, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
        EnableMenuItem(hMenu2, 4, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
      end;
    1: //Processes
      begin
        EnableMenuItem(hMenu2, 0, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
        EnableMenuItem(hMenu2, 1, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
        EnableMenuItem(hMenu2, 3, MF_BYCOMMAND or MF_BYPOSITION or MF_ENABLED);
        EnableMenuItem(hMenu2, 4, MF_BYCOMMAND or MF_BYPOSITION or MF_ENABLED);
      end;
    2, 3:  //Drivers, Report
      begin
        EnableMenuItem(hMenu2, 0, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
        EnableMenuItem(hMenu2, 1, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
        EnableMenuItem(hMenu2, 3, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
        EnableMenuItem(hMenu2, 4, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
      end;
  end;
end;

//EPROCESS'es list

function ProcessesDialogProc(hwndDlg: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
var
  buf: FBuf;
begin
  result := false;
  case uMsg of
    WM_INITDIALOG:
      begin
        LData3 := LView_InitListView(true, hwndDlg,
          LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES or
          LVS_EX_INFOTIP,
          1010, ColumnsCount3, LVTexts);
        LView_AddColumn(Ldata3, LVCFMT_LEFT, 50, PChar('PID'));
        LView_AddColumn(Ldata3, LVCFMT_LEFT, 360, PChar('Process Name (could be empty)'));
        LView_AddColumn(Ldata3, LVCFMT_CENTER, 120, PChar('EPROCESS Address'));
        LView_AddColumn(Ldata3, LVCFMT_CENTER, 140, PChar('Hidden from Windows API'));
        hMenu2 := GetSubMenu(hMenu1, 1);

        SetMenuState(1);
        EnableMenuItem(mi1, 0, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);

        ListProcesses();
      end;
    WM_NOTIFY:
      begin
        if (LPNMHDR(lParam)^.hwndFrom = LData3.wnd) then
        begin
          case (LPNMHDR(lParam)^.code) of
            NM_RCLICK:
              begin
                GetCursorPos(r2);
                TrackPopupMenu(hMenu2, TPM_RIGHTBUTTON or TPM_LEFTALIGN, r2.x, r2.y, 0, MainWindow, nil);
              end;
            LVN_COLUMNCLICK:
              begin
                SelectedColumnLV3 := PNMListView(lParam)^.iSubItem;
                SendMessageW(LData3.wnd, LVM_SORTITEMS, SelectedColumnLV3, Longint(@SortListView3));
                exit;
              end;
            LVN_ITEMCHANGED:
              begin
                buf[0] := #0;
                buf := LView_GetItemText(LData3, PNMListView(lParam)^.iItem, 0);
                SelectedProcess := atoui(buf);
              end;
          end;
        end;
        exit;
      end;
    WM_CLOSE:
      begin
        DestroyMenu(hMenu2);
        quit := true;
        exit;
      end;
  end;
end;

//Hidden from user mode API modules tab sheet

function ModulesDialogProc(hwndDlg: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
begin
  result := false;
  case uMsg of
    WM_INITDIALOG:
      begin
        LData2 := LView_InitListView(true, hwndDlg,
          LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES or
          LVS_EX_INFOTIP,
          1010, ColumnsCount2, LVTexts);
        LView_AddColumn(Ldata2, LVCFMT_LEFT, 120, PChar('Module Name'));
        LView_AddColumn(Ldata2, LVCFMT_LEFT, 320, PChar('Loaded from (could be only name)'));
        LView_AddColumn(Ldata2, LVCFMT_CENTER, 80, PChar('Address'));
        LView_AddColumn(Ldata2, LVCFMT_CENTER, 160, PChar('Hidden from User Mode API'));

        EnableMenuItem(mi1, 0, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
        SetMenuState(2);

        DnG();
      end;
    WM_NOTIFY:
      begin
        if (LPNMHDR(lParam)^.hwndFrom = LData2.wnd) then
        begin
          if ((LPNMHDR(lParam)^.code) = LVN_COLUMNCLICK) then
          begin
            SelectedColumnLV2 := PNMListView(lParam)^.iSubItem;
            SendMessageW(LData2.wnd, LVM_SORTITEMS, SelectedColumnLV2, Longint(@SortListView2));
            exit;
          end;
        end;
        exit;
      end;
    WM_CLOSE:
      begin
        quit := true;
        exit;
      end;
  end;
end;

//Report page

function ReportDialogProc(hwndDlg: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
begin
  result := false;
  case uMsg of
    WM_INITDIALOG:
      begin
        EnableMenuItem(mi1, 0, MF_BYCOMMAND or MF_BYPOSITION or MF_ENABLED);
        SetMenuState(3);
        ListBoxWND := GetDlgItem(hwndDlg, 1000);
        SetWindowTextW(StatusBar, 'Press Refresh to generate report');
        exit;
      end;
    WM_CLOSE:
      begin
        quit := true;
        exit;
      end;
  end;
end;

//first page handler (SSDT hooks)

function SSDTDialogProc(hwndDlg: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
var
  buf: FBuf;
begin
  result := false;
  case uMsg of
    WM_INITDIALOG:
      begin
        LData1 := LView_InitListView(true, hwndDlg,
          LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES or
          LVS_EX_INFOTIP,
          1010, ColumnsCount, LVTexts);
        LView_AddColumn(Ldata1, LVCFMT_LEFT, 40, PChar('Id'));
        LView_AddColumn(Ldata1, LVCFMT_LEFT, 240, PChar('Service Name'));
        LView_AddColumn(Ldata1, LVCFMT_CENTER, 50, PChar('Hooked'));
        LView_AddColumn(Ldata1, LVCFMT_CENTER, 80, PChar('Address'));
        LView_AddColumn(Ldata1, LVCFMT_LEFT, 265, PChar('Module'));
        hMenu2 := GetSubMenu(hMenu1, 1);
        FillList();

        EnableMenuItem(mi1, 0, MF_BYCOMMAND or MF_BYPOSITION or MF_GRAYED);
        SetMenuState(0);

        exit;
      end;
    WM_CLOSE:
      begin
        DestroyMenu(hMenu2);
        quit := true;
        exit;
      end;
    WM_NOTIFY:
      begin
        if (LPNMHDR(lParam)^.hwndFrom = LData1.wnd) then
        begin
          case (LPNMHDR(lParam)^.code) of
            LVN_ITEMCHANGED:
              begin
                buf[0] := #0;
                buf := LView_GetItemText(LData1, PNMListView(lParam)^.iItem, 0);
                SelectedService := atoui(buf);
              end;
            LVN_COLUMNCLICK:
              begin
                SelectedColumn := PNMListView(lParam)^.iSubItem;
                SendMessageW(LData1.wnd, LVM_SORTITEMS, SelectedColumn, Longint(@SortListView1));
                exit;
              end;
            NM_RCLICK:
              begin
                GetCursorPos(r2);
                TrackPopupMenu(hMenu2, TPM_RIGHTBUTTON or TPM_LEFTALIGN, r2.x, r2.y, 0, MainWindow, nil);
              end;
          end;
        end;
        exit;
      end;
  end;
end;

//main window dialog procedure (contains tab sheet handler procs)

function MainWindowProc(hwndDlg: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
var
  t1: LPNMHDR;
  iSel: integer;
  r1, r2: TRECT;
  buf: FBuf;
  buf1: LBuf;
  buf2: LongBufW;
  fuFlags: DWORD;
  SInfo: STARTUPINFOW;
  PInfo: PROCESS_INFORMATION;
begin
  result := false;
  case uMsg of
    WM_INITDIALOG:
      begin
        SetWindowTextW(hwndDlg, AppName);
        StatusBar := GetDlgItem(hwndDlg, 1011);
        SetClassLongW(hwndDlg, GCL_HICON, LoadIconW(hInst, pointer(120)));
        //setting menu, resizing status bar
        hMenu1 := LoadMenuW(Hinst, pointer(190));
        mi1 := GetSubMenu(hMenu1, 0);

        ChildDialogProc[0] := @SSDTDialogProc;
        ChildDialogProc[1] := @ProcessesDialogProc;
        ChildDialogProc[2] := @ModulesDialogProc;
        ChildDialogProc[3] := @ReportDialogProc;
        MainHdr := pointer(LocalAlloc(LPTR, sizeof(DLGHDR)));
        OnTabbedDialogInit(hwndDlg);
        SendMessageW(StatusBar, WM_SIZE, 0, 0);
        SetMenu(hwndDlg, hMenu1);
      end;
    WM_SHOWWINDOW:
      begin
        if BOOL(WParam) then
        begin
          if Options.bStealthEngine then fuFlags := (MF_BYCOMMAND or MF_CHECKED) else fuFlags := (MF_BYCOMMAND or MF_UNCHECKED);
          CheckMenuItem(hMenu1, 255, fuFlags);
        end;
      end;
    WM_SIZE:
      begin
        //resizing tab sheet window, status bar control
        SendMessageW(StatusBar, WM_SIZE, 0, 0);
        RedrawWindow(StatusBar, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_ERASENOW);
        GetClientRect(hwndDlg, r1);
        //resize of the tab control
        SetWindowPos(MainHdr^.hwndTab, HWND_TOP, 0, 0, r1.right, r1.Bottom - 70, 0);
        GetWindowRect(MainHdr^.hwndTab, r2);
        SendMessageW(MainHdr^.hwndTab, TCM_ADJUSTRECT, Integer(TRUE), Integer(@r2));
        OffsetRect(r2, cxMargin - r2.left, cyMargin - r2.top);
        ResizeTabWindow(MainHdr^.hwndDisplay);
      end;
    WM_NOTIFY:
      begin
        //changing active tab
        t1 := LPNMHDR(lParam);
        if (t1^.hwndFrom = MainHdr^.hwndTab) then
          case t1^.code of
            TCN_SELCHANGE:
              begin
                OnSelChanged(hwndDlg);
              end;
          end;
      end;
    WM_CLOSE:
      begin
        DestroyWindow(MainHdr^.hwndDisplay);
        EndDialog(hwndDlg, S_OK);
        quit := true;
      end;
    WM_DESTROY:
      begin
      //free allocated buffer
        LocalFree(HLOCAL(MainHdr));
      end;
    WM_COMMAND:
      begin
{$IFNDEF debug}
        if IsDebuggerPresent() then ExitProcess(0);
{$ENDIF}
        case LoWord(WParam) of
          ID_CANCEL:
            begin
              SendMessageW(hwndDlg, WM_CLOSE, 0, 0);
              exit;
            end;
          3: //Refresh Lists
            begin
              iSel := SendMessageW(MainHdr^.hwndTab, TCM_GETCURSEL, 0, 0);
              case iSel of
                -1: exit;
                0: //Refresh SSDT
                  begin
                    LView_ClearAll(LData1);
                    FillList();
                    if (SelectedColumn < 0) then SelectedColumn := 0;
                    SendMessageW(LData1.wnd, LVM_SORTITEMS, SelectedColumn, Longint(@SortListView1));
                  end;
                1: //Refresh Processes
                  begin
                    LView_ClearAll(LData3);
                    ListProcesses();
                    if (SelectedColumnLV3 < 0) then SelectedColumnLV3 := 0;
                    SendMessageW(LData3.wnd, LVM_SORTITEMS, SelectedColumnLV3, Longint(@SortListView3));
                  end;
                2: //Refresh Modules
                  begin
                    LView_ClearAll(LData2);
                    DnG();
                    if (SelectedColumnLV2 < 0) then SelectedColumnLV2 := 0;
                    SendMessageW(LData2.wnd, LVM_SORTITEMS, SelectedColumnLV2, Longint(@SortListView2));
                  end;
                3: //Refresh Report
                  begin
                    GenerateReport();
                  end;
              end;
              exit;
            end;
          4: //UnHook Selected
            begin
              if (SelectedService < 0) then exit;
              if UnHook(SelectedService, false) then
              begin
                LView_ClearAll(LData1);
                FillList();
                SendMessageW(LData1.wnd, LVM_SORTITEMS, 2, Longint(@SortListView1));
              end;
              exit;
            end;
          5: //UnHook All
            begin
              if MessageBoxW(MainWindow, 'Are you sure want to do this?'#13#13 +
                'Using this function can lead to BSOD and PC reboot', 'Warning - "UnHook ALL"', MB_ICONWARNING or MB_YESNO) = IDNO then exit;
              if UnHook(0, true) then
              begin
                LView_ClearAll(LData1);
                FillList();
                SendMessageW(LData1.wnd, LVM_SORTITEMS, 2, Longint(@SortListView1));
              end;
              exit;
            end;
          6: //About Box
            begin
              AboutWindow := DialogBoxW(hinst, pointer(102), MainWindow, @AboutDialogProc);
              exit;
            end;
          7: //generate report ;)
            begin
              memzero(@buf, MAX_PATH);
              if SaveDialog('All files'#0'*.*'#0#0, buf1) then
              begin
                SaveListToFile(buf1);
                SetCurrentDirectoryW(CurrentDirectory);
              end;
              exit;
            end;
          255: //Use Stealth Engine
            begin
              Options.bStealthEngine := not Options.bStealthEngine;
              if Options.bStealthEngine then fuFlags := (MF_BYCOMMAND or MF_CHECKED) else fuFlags := (MF_BYCOMMAND or MF_UNCHECKED);
              CheckMenuItem(hMenu1, 255, fuFlags);
              CheckLoadingOrderSet(Options.bStealthEngine);
            end;
          8: // kill process
            begin
              if (SelectedProcess = MaxDword) or (SelectedProcess = GetCurrentProcessId()) then exit;
              if (MessageBoxW(MainWindow, 'Are you sure want to kill that process?', 'Confirmation', MB_ICONQUESTION or MB_YESNO) = IDNO) then exit;
              if DeviceIoControl(DriverHandle, IOPORT_KILL_PROCESS, @SelectedProcess, sizeof(DWORD), nil, 0, bytesIO, nil) then
              begin
                LView_ClearAll(LData3);
                Sleep(100);
                ListProcesses();
              end;
            end;
          9: //force kill
            begin
              if (SelectedProcess = MaxDword) or (SelectedProcess = GetCurrentProcessId()) then exit;
              if (MessageBoxW(MainWindow, 'Are you sure want to kill that process?'#13#10 +
                'Using this function can lead to BSOD and PC reboot', 'Confirmation', MB_ICONQUESTION or MB_YESNO) = IDNO) then exit;
              {
                 TO-DO: Place code here
              }
              MessageBoxW(MainWindow, 'Not implemented', nil, MB_OK);
            end;
          11: //execute help
            begin
              strcpyW(buf1, CurrentDirectory);
              strcatW(buf1, 'RKUnHooker.chm');
              if not RTL.FileExistsW(buf1) then
              begin
                MessageBoxW(MainWindow, 'Help file not found', nil, MB_ICONINFORMATION);
                exit;
              end;
              ShowWindow(MainWindow, SW_MINIMIZE);
              strcpyW(buf2, 'hh.exe "');
              strcatW(buf2, buf1);
              GetStartupInfoW(SInfo);
              if CreateProcessW(nil, buf2, nil, nil, false, CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS, nil, nil, SInfo, PInfo) then
              begin
                WaitForSingleObjectEx(PInfo.hProcess, INFINITE, False);
                CloseHandle(PInfo.hProcess);
                CloseHandle(PInfo.hThread);
                ShowWindow(MainWindow, SW_RESTORE);
              end;
              exit;
            end;
        end;
      end;
  end;
end;

function IsDebuggerPresent(): BOOL;
var
  pBuf: PROCESS_BASIC_INFORMATION;
begin
  bytesIO := 0;
  ZwQueryInformationProcess(GetCurrentProcess(), ProcessBasicInformation, @pBuf, sizeof(PROCESS_BASIC_INFORMATION), @bytesIO);
  result := BOOL(pBuf.PebBaseAddress^.BeingDebugged);
end;
//this is crap shit
procedure GUImain();
var
  msg1: MSG;
begin
{$IFNDEF debug}
  asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp
  @@1:
    call @@2
    jmp @@3
  @@2:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    int 3
    jmp @@1
  @@3:
    mov esp, k
    popad
    popfd
  end;
{$ENDIF}
  InitCommonControls();
  hinst := GetModuleHandleW(nil);
  MainWindow := CreateDialogParamW(0, pointer(104), 0, @MainWindowProc, 0);
  while GetMessageW(msg1, 0, 0, 0) do
  begin
    TranslateMessage(msg1);
    DispatchMessageW(msg1);
    if quit then
    begin
      LView_Uninit(LData1, true);
      HeapFree(GetProcessHeap(), HEAP_NO_SERIALIZE, LData1);
      LView_Uninit(LData2, true);
      HeapFree(GetProcessHeap(), HEAP_NO_SERIALIZE, LData2);
      LView_Uninit(LData3, true);
      HeapFree(GetProcessHeap(), HEAP_NO_SERIALIZE, LData3);
      STRListDestroy(@LVTexts);
      STRListDestroy(@Report);
      DestroyMenu(mi1);
      DestroyMenu(hMenu1);
      DestroyWindow(MainWindow);
      break;
    end;
  end;
end;

var
  tmp: LBuf;
  hWindow: HWND;
  s1: UNICODE_STRING;
begin
  hWindow := FindWindowW(nil, AppName);
  if (hWindow > 0) then
  begin
    SetForegroundWindow(hWindow);
    ExitProcess(0);
  end;
  osver.dwOSVersionInfoSize := sizeof(osver);
  Windows.GetVersionExW(osver);
  if (osver.dwMajorVersion < 5) or (osver.dwMajorVersion > 5) then
  begin
    MessageBoxW(0, 'Not supported Windows NT version, click OK to exit', nil, MB_OK or MB_ICONERROR);
    ExitProcess(0);
  end;
  if not RTL.EnableSystemPrivilegeW('SeLoadDriverPrivilege', true) then
  begin
    MessageBoxW(0, 'Error, load driver privilege not adjusted', nil, MB_ICONWARNING);
    ExitProcess(0);
  end;
  if not RTL.EnableSystemPrivilegeW('SeDebugPrivilege', true) then
    MessageBoxW(0, 'Failed to enable debug privilege, not critical issue', 'Information', MB_OK);
{$IFNDEF debug}
  asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp

    xor ecx, ecx
  @@7:
    call @@8
    jmp @@9
  @@8:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    mov edx, ecx
    inc edx
    div edx
    jmp @@7
  @@9:

    xor ecx, ecx
  @@10:
    call @@11
    jmp @@12
  @@11:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    db $0f, $0b
    jmp @@10
  @@12:

    xor ecx, ecx
  @@22:
    call @@23
    jmp @@24
  @@23:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    int 3
    jmp @@22
  @@24:
    mov esp, k
    popad
    popfd
  end;
{$ENDIF}
  IOPORT_READ_KERNEL_SDT := CTL_CODE(FILE_DEVICE_UNKNOWN, $0001, METHOD_NEITHER, FILE_ANY_ACCESS);
  IOPORT_WRITE_KERNEL_SDT := CTL_CODE(FILE_DEVICE_UNKNOWN, $0002, METHOD_NEITHER, FILE_ANY_ACCESS);
  IOPORT_GET_KERNEL_SDT_INFO := CTL_CODE(FILE_DEVICE_UNKNOWN, $0003, METHOD_NEITHER, FILE_ANY_ACCESS);
  IOPORT_GET_KERNEL_SYSTEM_INFO := CTL_CODE(FILE_DEVICE_UNKNOWN, $0004, METHOD_NEITHER, FILE_ANY_ACCESS);
  IOPORT_GET_KERNEL_SYSENTER_INFO := CTL_CODE(FILE_DEVICE_UNKNOWN, $0005, METHOD_NEITHER, FILE_ANY_ACCESS);
  IOPORT_LIST_CID := CTL_CODE(FILE_DEVICE_UNKNOWN, $0006, METHOD_NEITHER, FILE_ANY_ACCESS);
  IOPORT_KILL_PROCESS := CTL_CODE(FILE_DEVICE_UNKNOWN, $0007, METHOD_NEITHER, FILE_ANY_ACCESS);

  STRListCreate(@Report);
  tmp[0] := WCHAR(0);
  GetWindowsDirectoryW(tmp, MAX_PATH);
  WideCharToMultiByte(CP_ACP, 0, @tmp, -1, windir, strlenW(tmp), nil, nil);
  tmp[0] := WCHAR(0);
  GetSystemDirectoryW(tmp, MAX_PATH);
  WideCharToMultiByte(CP_ACP, 0, @tmp, -1, winsysdir, strlenW(tmp), nil, nil);
  GetCmdLineParamW(0, CurrentDirectory);
  ExtractFilePathW(CurrentDirectory, CurrentDirectory);
  strcatW(CurrentDirectory, '\');
  ReadSettings();
//{$DEFINE normal}
{$IFNDEF normal}
  RtlInitUnicodeString(@s1, RegPath);
  ZwUnloadDriver(@s1);
{$ENDIF}
{$IFDEF normal}
  DriverHandle := CreateFileW(DriverLink, GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  if (DriverHandle = INVALID_HANDLE_VALUE) then
  begin
{$ENDIF}
    LoadServiceDriver(Options.bStealthEngine);
    DriverHandle := CreateFileW(DriverLink, GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
{$IFDEF normal}
    if (DriverHandle = INVALID_HANDLE_VALUE) then
    begin
      MessageBoxW(0, 'Error loading driver', nil, MB_ICONERROR);
      ExitProcess(0);
    end;
  end;
{$ENDIF}
  CheckLoadingOrderSet(Options.bStealthEngine);

  GUImain();
  CloseHandle(DriverHandle);
  WriteSettings();
  ExitProcess(0);
end.

