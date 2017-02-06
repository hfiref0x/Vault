{
  Delphi Ring0 Library.
  Исполнение кода в нулевом кольце,
  работа с процессами и памятью ядра.
  Coded By Ms-Rem ( Ms-Rem@yandex.ru ) ICQ 286370715
}

unit Ring0;

interface

uses
  Windows, WinNative, RTL, Loader;

const
  CALL_GATE = 0;

var
  KernelBase: dword; // адрес ядра в памяти
  KernelSize: DWORD;
  hPhysMem: dword; // хэндл секции \Device\PhysicalMemory
  pntkernel: PVOID;

procedure GetOriginalSystemState();
function OpenPhysicalMemory(mAccess: dword): THandle;
function QuasiMmGetPhysicalAddress(VirtualAddress: dword;
  var Offset: dword): dword;
procedure CallRing0(const Ring0Proc: pointer; Param: pointer);
function GetPhysicalAddress(VirtualAddress: dword): LARGE_INTEGER; stdcall;
procedure Ring0CopyMemory(Source, Destination: pointer; Size: dword);
function InitialzeRing0Library(): boolean;
procedure FreeRing0Library();

implementation

type
  PFarCall = ^TFarCall;
  TFarCall = packed record
    Offset: DWORD;
    Selector: Word;
  end;

  TGDTInfo = packed record
    Limit: Word;
    Base: DWORD;
  end;

  PGateDescriptor = ^TGateDescriptor;
  TGateDescriptor = packed record
    OffsetLo: Word; // нижние 2 байта адреса
    Selector: Word; // кодовый селектор (определяет привилегии)
    Attributes: Word; // атрибуты шлюза
    OffsetHi: Word; // верхние 2 байта адреса
  end;

  TRUSTEE_A = packed record
    pMultipleTrustee: pointer;
    MultipleTrusteeOperation: dword;
    TrusteeForm: dword;
    TrusteeType: dword;
    ptstrName: PAnsiChar;
  end;

  PEXPLICIT_ACCESS = ^EXPLICIT_ACCESS;
  EXPLICIT_ACCESS = packed record
    grfAccessPermissions: DWORD;
    grfAccessMode: dword;
    grfInheritance: DWORD;
    Trustee: TRUSTEE_A;
  end;

function GetSecurityInfo(handle: THandle; ObjectType: dword;
  SecurityInfo: SECURITY_INFORMATION;
  ppsidOwner, ppsidGroup: ppointer;
  ppDacl, ppSacl: pointer;
  var ppSecurityDescriptor: PSECURITY_DESCRIPTOR): DWORD;
  stdcall; external 'advapi32.dll';

function SetEntriesInAclA(cCountOfExplicitEntries: ULONG;
  pListOfExplicitEntries: PEXPLICIT_ACCESS;
  OldAcl: PACL; var NewAcl: PACL): DWORD;
  stdcall; external 'advapi32.dll';

function SetSecurityInfo(handle: THandle; ObjectType: dword;
  SecurityInfo: SECURITY_INFORMATION;
  ppsidOwner, ppsidGroup: ppointer;
  ppDacl, ppSacl: PACL): DWORD;
  stdcall; external 'advapi32.dll';

const
  MemDeviceName: PWideChar = '\Device\PhysicalMemory';
  SE_KERNEL_OBJECT = 6;
  GRANT_ACCESS = 1;
  NO_MULTIPLE_TRUSTEE = 0;
  TRUSTEE_IS_NAME = 1;
  TRUSTEE_IS_USER = 1;
  NO_INHERITANCE = 0;

var
  FarCall: TFarCall;
  CurrentGate: PGateDescriptor;
  OldGate: TGateDescriptor;
  ptrGDT: Pointer;
  Ring0ProcAdr: pointer; // текущий указатель на код подлежащий вызову через шлюз.
  AdrMmGetPhys: dword; // GetPhysicalAddress
  AdrMmIsValid: dword; // MmIsAddressValid

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

procedure Ring0CallProc;
asm
 cli
 pushad
 pushfd
 mov di, $30
 mov fs, di
 call Ring0ProcAdr
 mov di, $3B
 mov fs, di
 popfd
 popad
 sti
 retf
end;

function OpenPhysicalMemory(mAccess: dword): THandle;
var
  PhysMemString: UNICODE_STRING;
  Attr: OBJECT_ATTRIBUTES;
  OldAcl, NewAcl: PACL;
  SD: PSECURITY_DESCRIPTOR;
  Access: EXPLICIT_ACCESS;
  mHandle: dword;
begin
  Result := 0;
  mHandle := 0;
  RtlInitUnicodeString(@PhysMemString, MemDeviceName);

  InitializeObjectAttributes(@Attr, @PhysMemString, OBJ_CASE_INSENSITIVE or
    OBJ_KERNEL_HANDLE, 0, nil);

  if ZwOpenSection(@mHandle, READ_CONTROL or
    WRITE_DAC, @Attr) <> STATUS_SUCCESS then Exit;

  if GetSecurityInfo(mHandle, SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION,
    nil, nil, @OldAcl, nil, SD) <> ERROR_SUCCESS then Exit;
  with Access do
  begin
    grfAccessPermissions := mAccess;
    grfAccessMode := GRANT_ACCESS;
    grfInheritance := NO_INHERITANCE;
    Trustee.pMultipleTrustee := nil;
    Trustee.MultipleTrusteeOperation := NO_MULTIPLE_TRUSTEE;
    Trustee.TrusteeForm := TRUSTEE_IS_NAME;
    Trustee.TrusteeType := TRUSTEE_IS_USER;
    Trustee.ptstrName := 'CURRENT_USER';
  end;

  SetEntriesInAclA(1, @Access, OldAcl, NewAcl);

  SetSecurityInfo(mHandle, SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION,
    nil, nil, NewAcl, nil);

  ZwOpenSection(@Result, mAccess, @Attr);

  SetSecurityInfo(mHandle, SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION,
    nil, nil, OldAcl, nil);

  ZwClose(mHandle);
  LocalFree(DWORD(NewAcl));
  LocalFree(DWORD(SD));
end;

function QuasiMmGetPhysicalAddress(VirtualAddress: dword;
  var Offset: dword): dword;
begin
  Offset := VirtualAddress and $FFF;
  if (VirtualAddress > $80000000) and (VirtualAddress < $A0000000) then
    Result := VirtualAddress and $1FFFF000
  else Result := VirtualAddress and $FFF000;
end;

function InstallCallgate(hPhysMem: dword): boolean;
var
  gdt: TGDTInfo;
  offset, base_address: DWORD;
begin
  Result := false;
  if (hPhysMem = 0) then Exit;
  asm
    sgdt [gdt]
  end;
  base_address := QuasiMmGetPhysicalAddress(gdt.Base, offset);
  ptrGDT := MapViewOfFile(hPhysMem, FILE_MAP_READ or FILE_MAP_WRITE,
    0, base_address, gdt.limit + offset);
  if ptrGDT = nil then Exit;
  CurrentGate := PGateDescriptor(DWORD(ptrGDT) + offset);
  repeat
    CurrentGate := PGateDescriptor(DWORD(CurrentGate) + SizeOf(TGateDescriptor));
    if (CurrentGate.Attributes and $FF00) = 0 then
    begin
      OldGate := CurrentGate^;
      CurrentGate.Selector := $08; // ring0 code selector
      CurrentGate.OffsetLo := DWORD(@Ring0CallProc);
      CurrentGate.OffsetHi := DWORD(@Ring0CallProc) shr 16;
      CurrentGate.Attributes := $EC00;
      FarCall.Offset := 0;
      FarCall.Selector := DWORD(CurrentGate) - DWORD(ptrGDT) - offset;
      Break;
    end;
  until DWORD(CurrentGate) >= DWORD(ptrGDT) + gdt.limit + offset;
  FlushViewOfFile(CurrentGate, SizeOf(TGateDescriptor));
  Result := true;
end;

procedure UninstallCallgate();
begin
  CurrentGate^ := OldGate;
  UnmapViewOfFile(ptrGDT);
end;

procedure CallRing0(const Ring0Proc: pointer; Param: pointer);
begin
  asm
    mov eax, Ring0Proc
    mov Ring0ProcAdr, eax
    mov eax, Param
    db $0ff, $01d      // call far [FarCall]
    dd offset FarCall; //
  end;
end;


function GetPhysicalAddress(VirtualAddress: dword): LARGE_INTEGER; stdcall;
var
  Data: packed record
    VirtualAddress: dword;
    Result: LARGE_INTEGER;
  end;

  procedure Ring0Call;
  asm
    mov ebx, [eax]
    push ebx
    mov esi, eax
    call AdrMmGetPhys
    mov  [esi + $04], eax
    mov  [esi + $08], edx
    ret
  end;

begin
  Data.VirtualAddress := VirtualAddress;
  CallRing0(@Ring0Call, @Data);
  Result.QuadPart := Data.Result.QuadPart;
end;

procedure Ring0CopyMemory(Source, Destination: pointer; Size: dword);
var
  Data: packed record
    Src: pointer;
    Dst: pointer;
    Size: dword;
  end;

  procedure Ring0Call;
  asm
  //проверка адресов
    mov ebx, eax
    mov eax, [ebx]
    push eax
    call AdrMmIsValid
    test eax, eax
    jz @Exit
    mov eax, [ebx]
    add eax, [ebx + $08]
    push eax
    call AdrMmIsValid
    test eax, eax
    jz @Exit
    mov eax, [ebx + $04]
    push eax
    call AdrMmIsValid
    test eax, eax
    jz @Exit
    mov eax, [ebx + $04]
    add eax, [ebx + $08]
    push eax
    call AdrMmIsValid
    test eax, eax
    jz @Exit
  //копирование
    mov esi, [ebx]
    mov edi, [ebx + $04]
    mov ecx, [ebx + $08]
    rep movsb
    @Exit:
    ret
  end;

begin
  Data.Src := Source;
  Data.Dst := Destination;
  Data.Size := Size;
  VirtualLock(Source, Size);
  VirtualLock(Destination, Size);
  CallRing0(@Ring0Call, @Data);
  VirtualUnlock(Source, Size);
  VirtualUnlock(Destination, Size);
end;

function InitializeCallGate(): boolean;
begin
  Result := false;
  hPhysMem := OpenPhysicalMemory(SECTION_MAP_READ or SECTION_MAP_WRITE);
  if (hPhysMem = 0) then Exit;
  Result := InstallCallgate(hPhysMem);
end;

function InitialzeRing0Library(): boolean;
begin
  AdrMmGetPhys := DWORD(FastGetProcAddress(HINST(pntkernel), 'MmGetPhysicalAddress'));
  if (AdrMmGetPhys > 0) then AdrMmGetPhys := (AdrMmGetPhys - DWORD(pntkernel)) + KernelBase;

  AdrMmIsValid := DWORD(FastGetProcAddress(HINST(pntkernel), 'MmIsAddressValid'));
  if (AdrMmIsValid > 0) then AdrMmIsValid := (AdrMmIsValid - DWORD(pntkernel)) + KernelBase;

  Result := InitializeCallGate();
end;

procedure FreeRing0Library();
begin
  UninstallCallgate();
  ZwClose(hPhysMem);
end;

end.

