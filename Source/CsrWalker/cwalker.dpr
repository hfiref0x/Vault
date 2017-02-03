{$E exe}
{$IMAGEBASE $00400000}
{$APPTYPE CONSOLE}
{$R-}
{$Q-}

{$IFDEF minimum}
program cwalker;
{$ENDIF}
unit pwalker;

interface

uses
  Windows, WinNative, RTL, LDasm;

procedure DisplayErrorMessage(Message: PWideChar);

{$R Resources.res}
type
  _PE_HEADER_BLOCK = record
    dwSignature: DWORD;
    FileHeader: IMAGE_FILE_HEADER;
    OptionalHeader: IMAGE_OPTIONAL_HEADER;
    Sections: array[0..0] of IMAGE_SECTION_HEADER;
  end;
  PE_HEADER_BLOCK = _PE_HEADER_BLOCK;
  PPE_HEADER_BLOCK = ^_PE_HEADER_BLOCK;
  PIMAGE_DOS_HEADER = ^IMAGE_DOS_HEADER;

  _DWBUF = array[0..0] of DWORD;
  DWBUF = _DWBUF;
  PDWBUF = ^_DWBUF;

  _WBUF = array[0..0] of WORD;
  WBUF = _WBUF;
  PWBUF = ^_WBUF;

  _CSR_API_CONNECTINFO = record // <size 0x20>  ++
    ObjectDirectory: PVOID;
    SharedSectionBase: PVOID;
    SharedStaticServerData: PVOID;
    DebugFlags: ULONG;
    SizeOfPebData: ULONG;
    SizeOfTebData: ULONG;
    NumberOfServerDllNames: ULONG;
    ServerProcessId: PVOID;
  end;
  CSR_API_CONNECTINFO = _CSR_API_CONNECTINFO;
  PCSR_API_CONNECTINFO = ^_CSR_API_CONNECTINFO;

  _CSR_API_MSG = packed record // <size 0xe0>  ++
    h: _PORT_MESSAGE;
    ConnectionRequest: PCSR_API_CONNECTINFO;
    //CaptureBuffer: PVOID;    fuck that MS author!
    ApiNumber: ULONG;
    ReturnValue: ULONG;
    Reserved: ULONG;
    u: array[0..$B7] of BYTE;
  end;
  CSR_API_MSG = _CSR_API_MSG;
  PCSR_API_MSG = ^_CSR_API_MSG;

  _CSR_NT_SESSION = packed record // <size 0x18> ++
    SessionLink: LIST_ENTRY;
    SessionId: ULONG;
    ReferenceCount: ULONG;
    RootDirectory: ANSI_STRING;
  end;
  CSR_NT_SESSION = _CSR_NT_SESSION;
  PCSR_NT_SESSION = ^_CSR_NT_SESSION;

  _CSR_PROCESS = packed record //size 0x06c   ++
    ClientId: CLIENT_ID;
    ListLink: LIST_ENTRY;
    ThreadList: LIST_ENTRY;
    NtSession: PCSR_NT_SESSION;
    ExpectedVersion: ULONG;
    ClientPort: PVOID;
    ClientViewBase: PCHAR;
    ClientViewBounds: PCHAR;
    ProcessHandle: PVOID;
    SequenceNumber: ULONG;
    Flags: ULONG;
    DebugFlags: ULONG;
    ReferenceCount: ULONG;
    ProcessGroupId: ULONG;
    ProcessGroupSequence: ULONG;
    fVDM: ULONG;
    ThreadCount: ULONG;
    LastMessageSequence: ULONG;
    NumOutstandingMessages: ULONG;
    ShutdownLevel: ULONG;
    ShutdownFlags: ULONG;
    Luid: _LUID;
    ServerDllPerProcessData: array[0..0] of PVOID;
  end;
  CSR_PROCESS = _CSR_PROCESS;
  PCSR_PROCESS = ^_CSR_PROCESS;

  PCSR_THREAD = ^_CSR_THREAD;
  _CSR_WAIT_BLOCK = record // <size 0xf8> ++
    Length: ULONG;
    Link: LIST_ENTRY;
    WaitParameter: PVOID;
    WaitingThread: PCSR_THREAD;
    WaitRoutine: PVOID;
    WaitReplyMessage: CSR_API_MSG;
  end;
  CSR_WAIT_BLOCK = _CSR_WAIT_BLOCK;
  PCSR_WAIT_BLOCK = ^_CSR_WAIT_BLOCK;

  _CSR_THREAD = packed record // <size 0x38>  ++
    CreateTime: LARGE_INTEGER;
    Links: LIST_ENTRY;
    HashLinks: LIST_ENTRY;
    ClientId: CLIENT_ID;
    Process: PCSR_PROCESS;
    WaitBlock: PCSR_WAIT_BLOCK;
    ThreadHandle: THANDLE;
    Flags: ULONG;
    ReferenceCount: ULONG;
    ImpersonateCount: ULONG;
  end;
  CSR_THREAD = _CSR_THREAD;

implementation

var
  attr: OBJECT_ATTRIBUTES;
  cid: CLIENT_ID;
  ClientId_Array: array[0..1023] of CLIENT_ID;
  ClientId_Count: integer = 0;

  ServersTable: array[0..63] of ULONG;
  ServersTableCount: byte = 0;

  outCon, inCon: THANDLE;
  bytesIO: DWORD;
  dwProcessCount, dwHiddenCount: DWORD;
  hInst: DWORD = 0;
  osver: OSVERSIONINFOW;
  CurrentEPRocess: Pointer = nil;

type
  PEXCEPTION_POINTERS = ^_EXCEPTION_POINTERS;

const
  version: PWideChar = 'Csrss Walker v1.0.0 win32 NTx86 UNICODE (17.07.2008)'#13#10'(C) 2008 by UG North'
  + #13#10#13#10'Console mode processes detector PoC'#13#10'For 32bit Windows XP / 2003 / Vista';
  delimiter: PWideChar = #13#10'-------------------------------------------------------'#13#10;
  CLRF: PWideChar = #13#10;
  csrsrv: PWideChar = 'csrsrv.dll';

procedure AddToServersTable(pid: ULONG);
var
  i: integer;
begin
  for i := 0 to ServersTableCount - 1 do
    if (ServersTable[i] = pid) then exit;
  ServersTable[ServersTableCount] := pid;
  inc(ServersTableCount);
end;

function RtlAdjustPrivilege(
  Privilege: ULONG;
  Enable: BOOLEAN;
  Client: BOOLEAN
  ): NTSTATUS; stdcall;
var
  Status: NTSTATUS;
  Token: THANDLE;
  LuidPrivilege: LUID;
  NewPrivileges: TOKEN_PRIVILEGES;
  OldPrivileges: TOKEN_PRIVILEGES;
  Length: ULONG;
begin
  if (Client) then
    Status := ZwOpenThreadToken(NtCurrentThread, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, FALSE, @Token)
  else
    Status := ZwOpenProcessToken(NtCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, @Token);
  if (Status <> STATUS_SUCCESS) then
  begin
    result := Status;
    exit;
  end;
  LuidPrivilege.QuadPart := Privilege;
  NewPrivileges.PrivilegeCount := 1;
  NewPrivileges.Privileges[0].Luid := LuidPrivilege.QuadPart;
  if Enable then
    NewPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED else
    NewPrivileges.Privileges[0].Attributes := 0;
  Status := ZwAdjustPrivilegesToken(Token, FALSE, @NewPrivileges, sizeof(TOKEN_PRIVILEGES), @OldPrivileges, @Length);
  ZwClose(Token);
  if (Status = STATUS_NOT_ALL_ASSIGNED) then Status := STATUS_PRIVILEGE_NOT_HELD;
  result := Status;
end;

function GetUserModuleByName(Name: PWideChar; ProcessHandle: THANDLE; pSize: PDWORD): Pointer; stdcall;
var
  cpeb1: PPEB;
  pbi1: PROCESS_BASIC_INFORMATION;
  ReturnedLength: DWORD;
  ldrdata: PPEB_LDR_DATA;
  ldrentry: LDR_DATA_TABLE_ENTRY;
  tmpbuf: LongBufW;
  EndMod: pointer;
  UserPool: pointer;
  bytesIO: DWORD;
begin
  result := nil;
  ReturnedLength := 0;
  ZwQueryInformationProcess(ProcessHandle, ProcessBasicInformation, @pbi1, sizeof(PROCESS_BASIC_INFORMATION), @ReturnedLength);
  UserPool := nil;
  bytesIO := 16384;
  ZwAllocateVirtualMemory(NtCurrentProcess, @UserPool, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  if (UserPool <> nil) then
  begin
    ZwReadVirtualMemory(ProcessHandle, pbi1.PebBaseAddress, UserPool, sizeof(PEB), @ReturnedLength);
    if (ReturnedLength <> sizeof(PEB)) then
    begin
      bytesIO := 0;
      ZwFreeVirtualMemory(NtCurrentProcess, @UserPool, @bytesIO, MEM_RELEASE);
      exit;
    end;
    cpeb1 := PPEB(UserPool);
    ldrdata := nil;
    bytesIO := sizeof(PEB_LDR_DATA);
    ZwAllocateVirtualMemory(NtCurrentProcess, @ldrdata, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
    if (ldrdata <> nil) then
    begin
      ZwReadVirtualMemory(ProcessHandle, cpeb1^.Ldr, ldrdata, sizeof(PEB_LDR_DATA), @ReturnedLength);
      if (ReturnedLength = sizeof(PEB_LDR_DATA)) then
      begin
        ZwReadVirtualMemory(ProcessHandle, ldrdata^.InLoadOrderModuleList.Flink, @ldrentry, sizeof(LDR_DATA_TABLE_ENTRY), @ReturnedLength);
        if (ReturnedLength = sizeof(LDR_DATA_TABLE_ENTRY)) then
        begin
          EndMod := ldrentry.DllBase;
          repeat
            if (ldrentry.InLoadOrderModuleList.Flink = nil) then break;
            ZwReadVirtualMemory(ProcessHandle, ldrentry.InLoadOrderModuleList.Flink, @ldrentry, sizeof(LDR_DATA_TABLE_ENTRY), @ReturnedLength);
            if (ReturnedLength <> sizeof(LDR_DATA_TABLE_ENTRY)) then break;
            if (ldrentry.DllBase <> nil) then
            begin
              if (ldrentry.BaseDllName.PStr <> nil) then
              begin
                tmpbuf[0] := #0;
                ZwReadVirtualMemory(ProcessHandle, ldrentry.BaseDllName.PStr, @tmpbuf, MAX_PATH, @ReturnedLength);
                if (strcmpiW(Name, tmpbuf) = 0) then
                begin
                  result := ldrentry.DllBase;
                  pSize^ := ldrentry.SizeOfImage;
                  break;
                end;
              end;
            end;
          until (ldrentry.DllBase = EndMod);
        end;
      end;
      bytesIO := 0;
      ZwFreeVirtualMemory(NtCurrentProcess, @ldrdata, @bytesIO, MEM_RELEASE);
    end;
    bytesIO := 0;
    ZwFreeVirtualMemory(NtCurrentProcess, @UserPool, @bytesIO, MEM_RELEASE);
  end;
end;

function FastGetProcAddress(hModule: HMODULE; lpProcName: PAnsiChar): FARPROC; stdcall;
var
  pe_headers: PPE_HEADER_BLOCK;
  prawexp: ^IMAGE_EXPORT_DIRECTORY;
  pNames, pEntryPoints: PDWBUF;
  pOrdinals: PWBUF;
  i: integer;
begin
  pe_headers := pointer(PChar(hModule) + PIMAGE_DOS_HEADER(hModule)^._lfanew);

  prawexp := pointer(PChar(hModule) +
    pe_headers^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);

  pEntryPoints := pointer(PChar(hModule) + DWORD(prawexp^.AddressOfFunctions));
  pNames := pointer(PChar(hModule) + DWORD(prawexp^.AddressOfNames));
  pOrdinals := pointer(PChar(hModule) + DWORD(prawexp^.AddressOfNameOrdinals));

  for i := 0 to prawexp^.NumberOfNames - 1 do
    if (strcmpA((PChar(hModule) + pNames[i]), lpProcName) = 0) then
    begin
      result := PChar(hModule) + pEntryPoints^[pOrdinals[i]];
      exit;
    end;
  result := nil;
end;

function GetCsrRootProcessAddr(pmod: DWORD): PVOID; stdcall;
var
  p1: PChar;
  Length, l, ProcSize: integer;
begin
  result := nil;
  p1 := FastGetProcAddress(pmod, 'CsrLockProcessByClientId');
  if (p1 <> nil) then
  begin
    ProcSize := SizeOfProc(p1);
    Length := 0;
    repeat
      if ((PBYTE(p1)^ = $83) and (PBYTE(p1 + 2)^ = $08)) then
      begin
        result := pointer(PULONG(p1 - 4)^);
        exit;
      end;
      l := SizeOfCode(p1, nil);
      if (l = 0) then inc(l);
      inc(p1, l);
      inc(Length, l);
    until (Length > ProcSize);
  end;
end;

function CsrThreadHashTable(pmod: DWORD): PVOID; stdcall;
var
  p1: PChar;
  Length, l, ProcSize: integer;
begin
  result := nil;
  p1 := FastGetProcAddress(pmod, 'CsrLockThreadByClientId');
  if (p1 <> nil) then
  begin
    ProcSize := SizeOfProc(p1);
    Length := 0;
    repeat
      //lea
      if ((PBYTE(p1)^ = $8D) and (PBYTE(p1 + 2)^ = $C5)) then
      begin
        result := pointer(PULONG(p1 + 3)^);
        exit;
      end;
      l := SizeOfCode(p1, nil);
      if (l = 0) then inc(l);
      inc(p1, l);
      inc(Length, l);
    until (Length > ProcSize);
  end;
end;

function GetProcessExeNameByProcessId(ProcessId: DWORD; inbuf: PWideChar): boolean; stdcall;
var
  pBuffer: PROCESSENTRY32W;
  SnapShotHandle: THANDLE;
begin
  result := false;
  if (inbuf = nil) then exit;
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat
        if (pBuffer.th32ProcessID = ProcessId) then
        begin
          strcpyW(inbuf, pBuffer.szExeFile);
          result := true;
          break;
        end;
      until (not Process32NextW(SnapShotHandle, @pBuffer));
  CloseHandle(SnapShotHandle);
end;

function IsAdded(ProcessId: ULONG): boolean;
var
  i: integer;
begin
  for i := 0 to ClientId_Count - 1 do
    if (ClientId_Array[i].UniqueProcess = ProcessId) then
    begin
      result := TRUE;
      exit;
    end;
  result := false;
end;

procedure AddItem(pClientId: PCLIENT_ID);
begin
  if (not IsAdded(pClientId^.UniqueProcess)) then
  begin
    ClientId_Array[ClientId_Count].UniqueProcess := pClientId^.UniqueProcess;
    ClientId_Array[ClientId_Count].UniqueThread := pClientId^.UniqueThread;
    inc(ClientId_Count);
  end;
end;

procedure ParseCSRSS(CsrssId: ULONG);
var
  f: THANDLE;
  bytesIO: DWORD;
  buf: PChar;
  addr: dword;
  ListHead, NextEntry: PLIST_ENTRY;
  CsrRootProcess: CSR_PROCESS;
begin
  InitializeObjectAttributes(@attr, nil, 0, 0, nil, nil);
  cid.UniqueProcess := CsrssId;
  cid.UniqueThread := 0;
  f := 0;
  if (ZwOpenProcess(@f, PROCESS_ALL_ACCESS, @attr, @cid) = STATUS_SUCCESS) then
  begin
    bytesIO := 0;
    addr := DWORD(GetUserModuleByName(csrsrv, f, @bytesIO)); //address of the loaded library
    if (addr <> 0) then
    begin
      buf := nil;
      ZwAllocateVirtualMemory(NtCurrentProcess, @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
      if (ZwReadVirtualMemory(f, pointer(addr), buf, bytesIO, @bytesIO) = STATUS_SUCCESS) then
      begin
        addr := (DWORD(GetCsrRootProcessAddr(dword(buf))));
        if (addr <> 0) then
        begin
          bytesIO := sizeof(DWORD);
          if (ZwReadVirtualMemory(f, pointer(addr), @addr, bytesIO, @bytesIO) = STATUS_SUCCESS) then
          begin
            bytesIO := sizeof(CSR_PROCESS);
            memzero(@CsrRootProcess, bytesIO);
            if (ZwReadVirtualMemory(f, pointer(addr), @CsrRootProcess, bytesIO, @bytesIO) = STATUS_SUCCESS) then
            begin
              ListHead := CsrRootProcess.ListLink.Blink;
              NextEntry := CsrRootProcess.ListLink.Flink;
              repeat
                bytesIO := sizeof(DWORD);
                addr := 0;
                ZwReadVirtualMemory(f, NextEntry, @addr, bytesIO, @bytesIO);
                addr := addr - sizeof(CLIENT_ID);
                bytesIO := sizeof(CSR_PROCESS);
                memzero(@CsrRootProcess, sizeof(CSR_PROCESS));
                ZwReadVirtualMemory(f, pointer(addr), @CsrRootProcess, bytesIO, @bytesIO);
                NextEntry := CsrRootProcess.ListLink.Flink;
                AddItem(@CsrRootProcess.ClientId);
              until (NextEntry = ListHead);
            end;
          end;
        end;
      end;
      bytesIO := 0;
      ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
    end;
    ZwClose(f);
  end;
end;

procedure ParseCSRSSHashTable(CsrssPid: ULONG);
var
  f: THANDLE;
  bytesIO: DWORD;
  buf: PChar;
  i, addr, retaddr: dword;
  ListHead, t1: LIST_ENTRY;
  NextEntry: PLIST_ENTRY;
  CsrThread: CSR_THREAD;
begin
  InitializeObjectAttributes(@attr, nil, 0, 0, nil, nil);
  cid.UniqueProcess := CsrssPid;
  cid.UniqueThread := 0;
  f := 0;
  if (ZwOpenProcess(@f, PROCESS_ALL_ACCESS, @attr, @cid) = STATUS_SUCCESS) then
  begin
    bytesIO := 0;
    addr := DWORD(GetUserModuleByName(csrsrv, f, @bytesIO)); //address of the loaded library
    if (addr <> 0) then
    begin
      buf := nil;
      ZwAllocateVirtualMemory(NtCurrentProcess, @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
      if (ZwReadVirtualMemory(f, pointer(addr), buf, bytesIO, @bytesIO) = STATUS_SUCCESS) then
      begin
        retaddr := DWORD(CsrThreadHashTable(DWORD(buf)));
        if (retaddr <> 0) then
        begin

          for i := 0 to 255 do
          begin
            addr := retaddr;
            memzero(@ListHead, sizeof(LIST_ENTRY));
            if (ZwReadVirtualMemory(f, pointer(addr), @ListHead, sizeof(LIST_ENTRY), @bytesIO) = STATUS_SUCCESS) then
            begin
              if ListHead.Blink <> ListHead.Flink then
              begin
                NextEntry := ListHead.Flink;
                repeat
                  bytesIO := sizeof(DWORD);
                  addr := 0;
                  ZwReadVirtualMemory(f, NextEntry, @addr, bytesIO, @bytesIO);
                  addr := addr - 16;

                  bytesIO := sizeof(CsrThread);
                  memzero(@CsrThread, bytesIO);
                  ZwReadVirtualMemory(f, pointer(addr), @CsrThread, bytesIO, @bytesIO);

                  bytesIO := sizeof(LIST_ENTRY);
                  t1.Flink := nil;
                  t1.Blink := nil;
                  ZwReadVirtualMemory(f, NextEntry, @t1, bytesIO, @bytesIO);
                  NextEntry := t1.Flink;
                  AddItem(@CsrThread.ClientId);
                until (NextEntry = ListHead.Blink);
              end;
            end;
            retaddr := retaddr + sizeof(LIST_ENTRY);
          end;
        end;
      end;
      bytesIO := 0;
      ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
    end;
    ZwClose(f);
  end;
end;

procedure ListItems();
var
  i, j: integer;
  inbuf: LBuf;
begin
  strcpyW(inbuf, '# ');
  for j := strlenW(inbuf) to 5 do inbuf[j] := ' ';
  inbuf[6] := #0;
  strcatW(inbuf, 'PID ');
  for j := strlenW(inbuf) to 15 do inbuf[j] := ' ';
  inbuf[16] := #0;
  strcatW(inbuf, 'szFileName'#13#10#13#10);
  WriteConsoleW(outCon, @inbuf, strlenW(inbuf), bytesIO, nil);


  for i := 0 to ClientId_Count - 1 do
  begin
    SetConsoleTextAttribute(outCon, FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    uitoW(i, inbuf);
    strcatW(inbuf, ') ');
    for j := strlenW(inbuf) to 5 do inbuf[j] := ' ';
    inbuf[6] := #0;

    uitoW(ClientId_Array[i].UniqueProcess, strendW(inbuf));
    for j := strlenW(inbuf) to 15 do inbuf[j] := ' ';
    inbuf[16] := #0;

    if not GetProcessExeNameByProcessId(ClientId_Array[i].UniqueProcess, strendW(inbuf)) then
    begin
      SetConsoleTextAttribute(outCon, FOREGROUND_RED or FOREGROUND_INTENSITY);
      strcatW(inbuf, '?? <Rootkit>');
      inc(dwHiddenCount);
    end;
    strcatW(inbuf, CLRF);
    WriteConsoleW(outCon, @inbuf, strlenW(inbuf), bytesIO, nil);
    inc(dwProcessCount);
  end;
end;

procedure ListProcesses();
var
  buf2: LBuf;
  i: integer;
begin
  ClientId_Count := 0;
  memzero(@ClientId_Array, sizeof(ClientId_Array));
  dwProcessCount := 0;
  dwHiddenCount := 0;
  for i := 0 to ServersTableCount - 1 do
  begin
    ParseCSRSS(ServersTable[i]);
    ParseCSRSSHashTable(ServersTable[i]);
  end;
  ListItems();
  strcpyW(buf2, #13#10'Processes/Hidden: ');
  uitoW(dwProcessCount, strendW(buf2));
  strcatW(buf2, ' / ');
  uitoW(dwHiddenCount, strendW(buf2));
  SetConsoleTextAttribute(outCon, FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
  WriteConsoleW(outCon, @buf2, strlenW(buf2), bytesIO, nil);
end;

function OnException(ExceptionInfo: PEXCEPTION_POINTERS): LONGINT; stdcall;
var
  textbuf: array[0..1023] of WCHAR;
begin
  strcpyW(textbuf, 'Sorry, but unhandled exception has occured'#13#10'Program will be terminated'#13#10);
  with ExceptionInfo^.ExceptionRecord^ do
  begin
    strcatW(textbuf, 'Exception code : 0x');
    uitohexW(ExceptionCode, strendW(textbuf));
    strcatW(textbuf, #13#10'Instruction address : 0x');
    uitohexW(DWORD(ExceptionAddress), strendW(textbuf));
    if ExceptionCode = EXCEPTION_ACCESS_VIOLATION then
    begin
      case ExceptionInformation[0] of
        0: strcatW(textbuf, #13#10'Attempt to read at address  : 0x');
        1: strcatW(textbuf, #13#10'Attempt to write at address : 0x');
      end;
      uitohexW(ExceptionInformation[1], strendW(textbuf));
    end;
  end;
  SetConsoleMode(inCon, 0);
  DisplayErrorMessage(textbuf);
  ReadConsoleW(inCon, @textbuf, MAX_PATH, bytesIO, nil);
  ZwTerminateProcess(NtCurrentProcess, $DEAD);
  result := 0;
end;

procedure DisplayErrorMessage(Message: PWideChar);
var
  buf: LBuf;
begin
  SetConsoleTextAttribute(outCon, FOREGROUND_RED or FOREGROUND_INTENSITY);
  strcpyW(buf, CLRF);
  strcatW(buf, Message);
  strcatW(buf, CLRF);
  WriteConsoleW(outCon, @buf, strlenW(buf), bytesIO, nil);
end;

procedure Initialize();
var
  textbuf: LBuf;
  pBuffer: PROCESSENTRY32W;
  SnapShotHandle: THANDLE;
begin
  memzero(@textbuf, sizeof(textbuf));
  hInst := $00400000;
  osver.dwOSVersionInfoSize := sizeof(osver);
  Windows.GetVersionExW(osver);
  if (RtlAdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE) <> STATUS_SUCCESS) then
  begin
    DisplayErrorMessage('Failed to enable debug privilege, not critical issue');
    ReadConsoleW(inCon, @textbuf, MAX_PATH, bytesIO, nil);
  end;

  strcpyW(textbuf, 'Locating csrss processes in the system...'#13#10#13#10);
  WriteConsoleW(outCon, @textbuf, strlenW(textbuf), bytesIO, nil);
  AddToServersTable(CsrGetProcessId());
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat
        if (strcmpiW(pBuffer.szExeFile, 'csrss.exe') = 0) then
        begin
          AddToServersTable(pBuffer.th32ProcessID);
          strcpyW(textbuf, 'csrss.exe is found, pid: ');
          uitoW(pBuffer.th32ProcessID, strendW(textbuf));
          strcatW(textbuf, CLRF);
          SetConsoleTextAttribute(outCon, FOREGROUND_BLUE or FOREGROUND_INTENSITY);
          WriteConsoleW(outCon, @textbuf, strlenW(textbuf), bytesIO, nil);
        end;
      until (not Process32NextW(SnapShotHandle, @pBuffer));
  CloseHandle(SnapShotHandle);
  strcpyW(textbuf, CLRF);
  WriteConsoleW(outCon, @textbuf, strlenW(textbuf), bytesIO, nil);

  ListProcesses();
end;

procedure main();
var
  bytesIO: DWORD;
  tmp: LBuf;
  inp1: INPUT_RECORD;
  p1: CONSOLE_SCREEN_BUFFER_INFO;
begin
  SetConsoleTitleW('Csrss Walker v1.0.0 win32 NTx86 UNICODE (17.07.2008)');

  memzero(@inp1, sizeof(inp1));
  SetUnhandledExceptionFilter(@OnException);
  outCon := GetStdHandle(STD_OUTPUT_HANDLE);
  inCon := GetStdHandle(STD_INPUT_HANDLE);
  memzero(@p1, sizeof(p1));
  GetConsoleScreenBufferInfo(outCon, p1);
  SetConsoleMode(outCon, ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT);

  SetConsoleTextAttribute(outCon, FOREGROUND_BLUE or FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_INTENSITY);
  WriteConsoleW(outCon, delimiter, strlenW(delimiter), bytesIO, nil);
  WriteConsoleW(outCon, version, strlenW(version), bytesIO, nil);
  WriteConsoleW(outCon, delimiter, strlenW(delimiter), bytesIO, nil);
  Initialize();

  SetConsoleTextAttribute(outCon, p1.wAttributes);

  SetConsoleMode(inCon, 0);
  ReadConsoleInputW(inCon, inp1, 1, bytesIO);
  ReadConsoleW(inCon, @tmp, MAX_PATH, bytesIO, nil);
end;

begin
  main();
end.

