{
 BORLAND PASCAL RUNTIME LIBRARY
 (C) 2003, 2006, 2007 HELL, MP_ART
 (C) 2004, 2005, 2006, 2007 UG North, EP_X0FF
 //no third party stuff used
 version 1.80 //increment if changes has global effect
}
unit RTL;
// uses FPU coprocessor, CMOV instruction
interface

uses
  Windows, FPU;

type
  FBuf = array[0..MAX_PATH - 1] of CHAR; //ANSI Data Type
  LongBufA = array[0..519] of CHAR; //long eqv

  LBuf = array[0..MAX_PATH - 1] of WideChar; //UNICODE Data Type
  LongBufW = array[0..1039] of WCHAR;

  GBuf = array[0..65535] of WideChar; //UNC UNICODE Data Type
  UBuf = array[0..131070] of WideChar;

// ANSI and UNICODE strings handling
function strcatA(dest: PAnsiChar; const src: PAnsiChar): PAnsiChar; register;
function strcatW(dest: PWideChar; const src: PWideChar): PWideChar; register;
function strcmpA(const s1: PAnsiChar; const s2: PAnsiChar): integer; register;
function strcmpW(const s1: PWideChar; const s2: PWideChar): integer; register;
function strcmpiA(const s1: PAnsiChar; const s2: PAnsiChar): integer; register;
function strcmpiW(const s1: PWideChar; const s2: PWideChar): integer; register;
function strcmpnA(const s1: PAnsiChar; const s2: PAnsiChar; n: cardinal): integer; register;
function strcmpnW(const s1: PWideChar; const s2: PWideChar; n: cardinal): integer; register;
function strcmpinA(const s1: PAnsiChar; const s2: PAnsiChar; n: cardinal): integer; register;
function strcmpinW(const s1: PWideChar; const s2: PWideChar; n: cardinal): integer; register;
function strcpyA(dest: PAnsiChar; const src: PAnsiChar): PAnsiChar; register;
function strcpyW(dest: PWideChar; const src: PWideChar): PWideChar; register;
function strcpynA(dest: PAnsiChar; const src: PAnsiChar; len: cardinal): PAnsiChar; register;
function strcpynW(dest: PWideChar; const src: PWideChar; len: cardinal): PWideChar; register;
function strendA(const s: PAnsiChar): PAnsiChar; register;
function strendW(const s: PWideChar): PWideChar; register;
function strlenA(const s: PAnsiChar): cardinal; register;
function strlenW(const s: PWideChar): cardinal; register;
function strposA(const s1: PAnsiChar; const s2: PAnsiChar): PAnsiChar; register;
function strscanA(const s: PAnsiChar; c: AnsiChar): PAnsiChar; register;
function strscanW(const s: PWideChar; c: WideChar): PWideChar; register;
function strlowerA(s: PAnsiChar): PAnsiChar; register;
function strupperA(s: PAnsiChar): PAnsiChar; register;
function upcase1251(c: AnsiChar): AnsiChar; register;
function locase1251(c: AnsiChar): AnsiChar; register;
function upcaseA(c: AnsiChar): AnsiChar; register;
function upcaseW(c: WideChar): WideChar; register;
function locaseA(c: AnsiChar): AnsiChar; register;
function locaseW(c: WideChar): WideChar; register;
function isdigitA(c: AnsiChar): ByteBool; register;
function isdigitW(c: WideChar): WordBool; register;
function issignA(c: AnsiChar): ByteBool; register;
function issignW(c: WideChar): WordBool; register;
// Memory functions
function memcmp(const p1, p2: pointer; size: DWORD): integer; register;
procedure memcopy(dest, src: pointer; length: cardinal); register;
procedure memfill(p1: pointer; length: cardinal; fill: BYTE); register;
procedure memzero(p1: pointer; length: cardinal); register;
// Conversion functions (finctions)
function atoi(s: PAnsiChar): integer; stdcall;
function atoi64(s: PAnsiChar): int64; stdcall;
function atoui(s: PAnsiChar): cardinal; stdcall;
function wtoui(s: PWideChar): cardinal; stdcall;
function itoa(x: integer; buf: PAnsiChar): PAnsiChar; stdcall;
function itow(x: integer; buf: PWideChar): PWideChar; stdcall;
function uitobinA(x: cardinal; buf: PAnsiChar): PAnsiChar; stdcall;
function uitobinW(x: cardinal; buf: PWideChar): PWideChar; stdcall;
function uitonbinA(x: cardinal; buf: PAnsiChar; n: cardinal): PAnsiChar; stdcall;
function uitonbinW(x: cardinal; buf: PWideChar; n: cardinal): PWideChar; stdcall;
function i64toa(x: int64; buf: PAnsiChar): PAnsiChar; stdcall;
function i64tow(x: int64; buf: PWideChar): PWideChar; stdcall;
function uitoa(x: cardinal; buf: PAnsiChar): PAnsiChar; stdcall;
function uitoW(x: cardinal; buf: PWideChar): PWideChar; stdcall;
function uitohex(x: cardinal; buf: PAnsiChar): PAnsiChar; stdcall;
function uitohexn(x: cardinal; buf: PAnsiChar; n: integer): PAnsiChar; stdcall;
function uitohexW(x: cardinal; buf: PWideChar): PWideChar; stdcall;
function uitohexnW(x: cardinal; buf: PWideChar; n: integer): PWideChar; stdcall;
function ui64tohex(x: int64; buf: PAnsiChar): PAnsiChar; stdcall;
function ui64tohexn(x: int64; buf: PAnsiChar; n: integer): PAnsiChar; stdcall;
function hexAtoui(const hex: PAnsiChar): Cardinal; stdcall;
function hexWtoui(const hex: PWideChar): Cardinal; stdcall;
function atof(const s: PAnsiChar): extended; stdcall;
function ftoa(x: extended; buf: PAnsiChar): PAnsiChar; stdcall;
function ftoa_fmt(x: extended; decimals: integer; buf: PAnsiChar): PAnsiChar; stdcall;
function LongBufA2FBuf(const src: LongBufA): FBuf; stdcall;
function LongBufW2LBuf(const src: LongBufW): LBuf; stdcall;
// FileName
function ChangeFileExt(const FileName: PAnsiChar; const ext: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
function ChangeFileExtW(const FileName: PWideChar; const ext: PWideChar; buf: PWideChar): PWideChar; stdcall;
function ExtractFileName(const FileName: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
function ExtractFileNameW(const FileName: PWideChar; buf: PWideChar): PWideChar; stdcall;
function ExtractFilePath(const FileName: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
function ExtractFilePathW(const FileName: PWideChar; buf: PWideChar): PWideChar; stdcall;
function ExtractFileExt(const FileName: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
function ExtractFileExtW(const FileName: PWideChar; buf: PWideChar): PWideChar; stdcall;
// Other
procedure _wait(msInterval: cardinal); stdcall;
function _exec(const cmdLine, CurrentDir: PAnsiChar): boolean; stdcall;
function _execW(const cmdLine, CurrentDir: PWideChar): boolean; stdcall;
function _exec_wait(const cmdLine, CurrentDir: PAnsiChar): boolean; stdcall;
function _exec_waitW(const cmdLine, CurrentDir: PWideChar): boolean; stdcall;
function DirectoryExistsA(const DirName: PAnsiChar): boolean; stdcall;
function DirectoryExistsW(const DirName: PWideChar): boolean; stdcall;
function FileExistsA(const FileName: PAnsiChar): boolean; stdcall;
function FileExistsW(const FileName: PWideChar): boolean; stdcall;
function FileExistsExA(const lpFileName: PChar): BOOL; stdcall;
function FileExistsExW(const lpFileName: PWideChar): BOOL; stdcall;
function DisplayLastError(_hwnd: HWND): integer; stdcall;
function DisplayLastErrorA(_hwnd: HWND): integer; stdcall;
function DisplayLastErrorW(_hwnd: HWND): integer; stdcall;
procedure DisplayLastErrorExA(_hwnd: HWND); stdcall;
procedure DisplayLastErrorExW(_hwnd: HWND); stdcall;
function ReturnLastError(): FBuf; stdcall;
function GetCmdLineParam(n: cardinal; buf: PAnsiChar): cardinal; stdcall;
function GetCmdLineParamW(n: cardinal; buf: PWideChar): cardinal; stdcall;
function GetCmdLineParamsCount(): cardinal; stdcall;
function GetCmdLineParamsVar(const lpParams: PAnsiChar; const lpVar: PAnsiChar; const chDelimiter: Char; const chAssign: Char; buf: PAnsiChar): PAnsiChar; stdcall;
function GetNativeCmdLine(buf: PAnsiChar): PAnsiChar; stdcall;
function GetNativeCmdLineA(buf: PAnsiChar): PAnsiChar; stdcall;
function GetNativeCmdLineW(buf: PWideChar): PWideChar; stdcall;
function CreateNativeCmdLineA(cmdline: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
function IsPowerOf2(x: cardinal): boolean; register;
function RtlTimeToSecondsSince1970(const p1: PSYSTEMTIME): DWORD; stdcall;
function RtlSecondsSince1970ToTime(dwSeconds: DWORD; p1: PSYSTEMTIME): boolean; stdcall;
function EnableSystemPrivilege(PrivName: PChar; Enable: BOOL): boolean; stdcall;
function EnableSystemPrivilegeW(PrivName: PWideChar; Enable: BOOL): boolean; stdcall;
// math i32 i64
function fpu_div64(x, y: pint64): int64; register;
function fpu_mod64(x, y: pint64): int64; register;
function alu_mul64(x, y: pint64): int64; register;
function maxi64(a, b: int64): int64; stdcall;
function maxu(a, b: cardinal): cardinal; register;
function maxi(a, b: integer): integer; register;
function mini64(a, b: int64): int64; stdcall;
function minu(a, b: cardinal): cardinal; register;
function mini(a, b: integer): integer; register;
function align2(x: DWORD): DWORD; register;
function align(x, base: DWORD): DWORD; register;
procedure InitFPU(); stdcall;
function CTL_CODE(DeviceType, _function, Method, Access: cardinal): cardinal;

//RLE Compression
type
  RLEFILEHEADER = record
    sign, usize, crc, flags: DWORD;
  end;
  PRLEFILEHEADER = ^RLEFILEHEADER;

  _BLOCKHEADER = record
    dwSize: DWORD;
    dwCRC: DWORD;
  end;
  BLOCKHEADER = _BLOCKHEADER;
  PBLOCKHEADER = ^_BLOCKHEADER;

procedure Resample2(tempbuf, src: PChar; srcsize: cardinal);
procedure Resample3(tempbuf, src: PChar; srcsize: cardinal);
procedure Resample4(tempbuf, src: PChar; srcsize: cardinal);
function CRCBuffer(buf: PChar; bufsize: cardinal): cardinal;
function DecompressBuffer(dest, src: PChar; srcsize: cardinal): cardinal; stdcall;
function CompressBuffer(dest, src: PChar; srcsize: cardinal): cardinal; stdcall;
function GetUncompressedSize(src: PChar; srcsize: cardinal): cardinal; stdcall;

type
  PFNREADFILEPROC = function(hFile: cardinal; lpBuffer: pointer;
    nNumberOfBytesToRead: DWORD; lpNumberOfBytesRead: PDWORD;
    lpOverlapped: POVERLAPPED): BOOL; stdcall;

  PFNWRITEFILEPROC = function(hFile: cardinal; lpBuffer: pointer;
    nNumberOfBytesToWrite: DWORD; lpNumberOfBytesWritten: PDWORD;
    lpOverlapped: POVERLAPPED): BOOL; stdcall;

const
  pp1: pointer = @Windows.ReadFile;
  pp2: pointer = @Windows.WriteFile;

var
  _ReadFile: PFNREADFILEPROC absolute pp1;
  _WriteFile: PFNWRITEFILEPROC absolute pp2;

const
  _pi: extended = 3.141592653589793238462643383279;
  _pi2: extended = 1.570796326794896619231321691639;
  _e: extended = 2.718281828459045235360287471352;

  DaysOfWeek: array[0..6] of PAnsiChar =
  (
    'Sunday', 'Monday', 'Tuestay', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    );

  Months: array[0..11] of PAnsiChar =
  (
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
    );

implementation
{$R-}
{$Q-}

const
  cwChop: WORD = $0F20;
  cwDef: WORD = $0371;

function fpu_div64(x, y: pint64): int64; register;
asm
  sub esp, $c
  fstcw word ptr [esp + 8]
  fldcw cwChop
  fild qword ptr [eax]
  fild qword ptr [edx]
  fdivp
  fistp qword ptr [esp]
  fldcw word ptr [esp + 8]
  mov eax, [esp]
  mov edx, [esp + 4]
  add esp, $c
end;

function fpu_mod64(x, y: pint64): int64; register;
asm
  sub esp, 8
  fild qword ptr [eax]
  fild qword ptr [edx]
  fdivp
  fstcw word ptr [esp]
  fldcw cwChop
  frndint
  fldcw word ptr [esp]
  fild qword ptr [edx]
  fmulp
  fild qword ptr [eax]
  fxch
  fsubp
  fistp qword ptr [esp]
  mov eax, [esp]
  mov edx, [esp + 4]
  add esp, 8
end;

function alu_mul64(x, y: pint64): int64; register;
asm
  push edi
  push esi
  mov esi, eax
  mov edi, edx
  mov eax, [edi + 4]
  mul dword ptr [esi]
  mov ecx, eax
  mov eax, [esi + 4]
  mul dword ptr [edi]
  add ecx, eax
  mov eax, [esi]
  mul dword ptr [edi]
  add edx, ecx
  pop esi
  pop edi
end;

function upcaseA(c: AnsiChar): AnsiChar; register;
asm
  cmp al, 'a'
  jl @@1
  cmp al, 'z'
  jg @@1
  and al, $df
@@1:
end;

function upcaseW(c: WideChar): WideChar; register;
asm
  cmp ax, WideChar('a')
  jl @@1
  cmp ax, WideChar('z')
  jg @@1
  and ax, $df
@@1:
end;

function locaseA(c: AnsiChar): AnsiChar; register;
asm
  cmp al, 'A'
  jl @@1
  cmp al, 'Z'
  jg @@1
  or al, $20
@@1:
end;

function locaseW(c: WideChar): WideChar; register;
asm
  cmp ax, WideChar('A')
  jl @@1
  cmp ax, WideChar('Z')
  jg @@1
  or ax, $20
@@1:
end;

function locase1251(c: AnsiChar): AnsiChar; register;
begin
  case c of
    'A'..'Z', 'À'..'ß': result := char(BYTE(c) + $20);
    '¨': result := '¸';
  else
    result := c;
  end;
end;

function upcase1251(c: AnsiChar): AnsiChar; register;
begin
  case c of
    'a'..'z', 'à'..'ÿ': result := char(BYTE(c) - $20);
    '¸': result := '¨';
  else
    result := c;
  end;
end;

function strupperA(s: PAnsiChar): PAnsiChar; register;
asm
  push ebx
  push edi
  mov edi, eax
  call strlenA
  test eax, eax
  jz @@1
  mov ecx, eax
@@0:
  mov ebx, ecx
  mov al, [edi + ecx - 1]

  cmp al, 'a'
  jl @@x
  cmp al, 'z'
  jg @@x
  and al, $df
@@x:

  mov ecx, ebx
  mov [edi + ecx - 1], al
  loop @@0
@@1:
  mov eax, edi
  pop edi
  pop ebx
end;

function strlowerA(s: PAnsiChar): PAnsiChar; register;
asm
  push ebx
  push edi
  mov edi, eax
  call strlenA
  test eax, eax
  jz @@1
  mov ecx, eax
@@0:
  mov ebx, ecx
  mov al, [edi + ecx - 1]

  cmp al, 'A'
  jl @@x
  cmp al, 'Z'
  jg @@x
  or al, $20
@@x:

  mov ecx, ebx
  mov [edi + ecx - 1], al
  loop @@0
@@1:
  mov eax, edi
  pop edi
  pop ebx
end;

function strlenA(const s: PAnsiChar): cardinal; register;
asm
  mov edx, edi
  mov edi, eax
  or ecx, -1
  xor eax, eax
  repne scasb
  dec eax
  dec eax
  sub eax, ecx
  mov edi, edx
end;

function strlenW(const s: PWideChar): cardinal; register;
asm
  mov edx, edi
  mov edi, s
  or ecx, -1
  xor eax, eax
  repne scasw
  dec eax
  dec eax
  sub eax, ecx
  mov edi, edx
end;

function strendA(const s: PAnsiChar): PAnsiChar; register;
asm
  mov edx, edi
  mov edi, s
  or ecx, -1
  xor eax, eax
  repnz scasb
  lea eax, edi - 1
  mov edi, edx
end;

function strendW(const s: PWideChar): PWideChar; register;
asm
  mov edx, edi
  mov edi, s
  or ecx, -1
  xor eax, eax
  repnz scasw
  lea eax, edi - 2
  mov edi, edx
end;

function strcpyA(dest: PAnsiChar; const src: PAnsiChar): PAnsiChar; register;
asm
  push edi
  push esi
  mov esi, eax
  mov edi, edx
  or ecx, -1
  xor eax, eax
  repnz scasb
  not ecx
  mov edi, esi
  mov esi, edx
  mov eax, edi
  mov edx, ecx
  shr ecx, 2
  repnz movsd
  mov ecx, edx
  and ecx, 3
  repnz movsb
  pop esi
  pop edi
end;

function strcpyW(dest: PWideChar; const src: PWideChar): PWideChar; register;
asm
  push edi
  push esi
  mov esi, eax
  mov edi, edx
  or ecx, -1
  xor eax, eax
  repnz scasw
  not ecx
  add ecx, ecx
  mov edi, esi
  mov esi, edx
  mov eax, edi
  mov edx, ecx
  shr ecx, 2
  repnz movsd
  mov ecx, edx
  and ecx, 3
  repnz movsb
  pop esi
  pop edi
end;

function strcatA(dest: PAnsiChar; const src: PAnsiChar): PAnsiChar; register;
begin
  strcpyA(strendA(dest), src);
  result := dest;
end;

function strcatW(dest: PWideChar; const src: PWideChar): PWideChar; register;
begin
  strcpyW(strendW(dest), src);
  result := dest;
end;

function strcpynA(dest: PAnsiChar; const src: PAnsiChar; len: cardinal): PAnsiChar; register;
asm
  push edi
  push esi
  mov edi, eax
  mov esi, edx
  mov edx, ecx
  shr ecx, 2
  repnz movsd
  mov ecx, edx
  and ecx, 3
  repnz movsb
  mov byte ptr [edi], 0
  pop esi
  pop edi
end;

function strcpynW(dest: PWideChar; const src: PWideChar; len: cardinal): PWideChar; register;
asm
  push edi
  push esi
  mov edi, eax
  mov esi, edx
  mov edx, ecx
  shr ecx, 1
  repnz movsd
  mov ecx, edx
  and ecx, 1
  repnz movsw
  mov word ptr [edi], 0
  pop esi
  pop edi
end;

function strscanA(const s: PAnsiChar; c: AnsiChar): PAnsiChar; register;
asm
  push edi
  push eax
  mov edi, eax
  or ecx, -1
  xor eax, eax
  repnz scasb
  not ecx
  pop edi
  mov eax, edx
  repnz scasb
  mov eax, 0
  jnz @@1
  mov eax, edi
  dec eax
@@1:
  pop edi
end;

function strscanW(const s: PWideChar; c: WideChar): PWideChar; register;
asm
  push edi
  push eax
  mov edi, eax
  or ecx, -1
  xor eax, eax
  repnz scasw
  not ecx
  pop edi
  mov eax, edx
  repnz scasw
  mov eax, 0
  jnz @@1
  lea eax, [edi-2]
@@1:
  pop edi
end;

function strcmpA(const s1: PAnsiChar; const s2: PAnsiChar): integer; register;
asm
  push edi
  push esi
  mov edi, edx
  mov esi, eax
  or ecx, -1
  xor eax, eax
  repne scasb
  not ecx
  mov edi, edx
  repe cmpsb
  xor edx, edx
  mov al, [esi - 1]
  mov dl, [edi - 1]
  sub eax, edx
  pop esi
  pop edi
end;

function strcmpW(const s1: PWideChar; const s2: PWideChar): integer; register;
asm
  push edi
  push esi
  mov edi, edx
  mov esi, eax
  or ecx, -1
  xor eax, eax
  repne scasw
  not ecx
  mov edi, edx
  repe cmpsw
  xor edx, edx
  mov ax, [esi - 2]
  mov dx, [edi - 2]
  sub eax, edx
  pop esi
  pop edi
end;

function strcmpiA(const s1: PAnsiChar; const s2: PAnsiChar): integer; register;
var
  k: cardinal;
  c1, c2: BYTE;
begin
  result := 0;
  k := 0;
  repeat
    c1 := BYTE(upcase(s1[k]));
    c2 := BYTE(upcase(s2[k]));
    if c1 > c2 then result := 1
    else if c1 < c2 then result := -1;
    if (c1 and c2 = 0) then exit;
    k := k + 1;
  until result <> 0;
end;

function strcmpiW(const s1: PWideChar; const s2: PWideChar): integer; register;
var
  k: cardinal;
  c1, c2: WORD;
begin
  result := 0;
  k := 0;
  repeat
    c1 := WORD(upcaseW(s1[k]));
    c2 := WORD(upcaseW(s2[k]));
    if c1 > c2 then result := 1
    else if c1 < c2 then result := -1;
    if (c1 and c2 = 0) then exit;
    k := k + 1;
  until result <> 0;
end;

function strcmpinA(const s1: PAnsiChar; const s2: PAnsiChar; n: cardinal): integer; register;
var
  k: cardinal;
  c1, c2: BYTE;
begin
  result := 0;
  if n = 0 then exit;
  k := 0;
  repeat
    c1 := BYTE(upcase(s1[k]));
    c2 := BYTE(upcase(s2[k]));
    if c1 > c2 then result := 1
    else if c1 < c2 then result := -1;
    if (c1 and c2 = 0) then exit;
    k := k + 1;
  until (result <> 0) or (k >= n);
end;

function strcmpinW(const s1: PWideChar; const s2: PWideChar; n: cardinal): integer; register;
var
  k: cardinal;
  c1, c2: WORD;
begin
  result := 0;
  if n = 0 then exit;
  k := 0;
  repeat
    c1 := WORD(upcaseW(s1[k]));
    c2 := WORD(upcaseW(s2[k]));
    if c1 > c2 then result := 1
    else if c1 < c2 then result := -1;
    if (c1 and c2 = 0) then exit;
    k := k + 1;
  until (result <> 0) or (k >= n);
end;

function strcmpnA(const s1: PAnsiChar; const s2: PAnsiChar; n: cardinal): integer; register;
var
  k: cardinal;
  c1, c2: BYTE;
begin
  result := 0;
  if n = 0 then exit;
  k := 0;
  repeat
    c1 := BYTE(s1[k]);
    c2 := BYTE(s2[k]);
    if c1 > c2 then result := 1
    else if c1 < c2 then result := -1;
    if (c1 and c2 = 0) then exit;
    k := k + 1;
  until (result <> 0) or (k >= n);
end;

function strcmpnW(const s1: PWideChar; const s2: PWideChar; n: cardinal): integer; register;
var
  k: cardinal;
  c1, c2: WORD;
begin
  result := 0;
  if n = 0 then exit;
  k := 0;
  repeat
    c1 := WORD(s1[k]);
    c2 := WORD(s2[k]);
    if c1 > c2 then result := 1
    else if c1 < c2 then result := -1;
    if (c1 and c2 = 0) then exit;
    k := k + 1;
  until (result <> 0) or (k >= n);
end;

function strposA(const s1: PAnsiChar; const s2: PAnsiChar): PAnsiChar; register;
var
  l0, l1, l2: cardinal;
  k: integer;
  p1: PAnsiChar;
begin
  result := nil;
  l1 := strlenA(s1);
  l2 := strlenA(s2);
  if (l2 > l1) or (l2 = 0) or (l1 = 0) then exit;
  l0 := l1 - l2;
  p1 := s1;
  repeat
    p1 := strscanA(p1, s2[0]);
    if p1 = nil then exit;
    k := strcmpnA(p1, s2, l2);
    if k <> 0 then p1 := p1 + 1;
  until (k = 0) or (p1 > s1 + l0);
  if k = 0 then result := p1;
end;

procedure memzero(p1: pointer; length: cardinal); register;
asm
  push edi
  mov edi, eax
  mov ecx, edx
  shr ecx, 2
  xor eax, eax
  repnz stosd
  mov ecx, edx
  and ecx, 3
  repnz stosb
  pop edi
end;

procedure memfill(p1: pointer; length: cardinal; fill: BYTE); register;
asm
  push edi
  mov edi, eax
  mov eax, ecx
  mov ecx, edx
  rep stosb
  pop edi
end;

procedure memcopy(dest, src: pointer; length: cardinal); register;
asm
  push edi
  push esi
  mov edi, eax
  mov esi, edx
  mov eax, ecx
  shr ecx, 2
  rep movsd
  mov ecx, eax
  and ecx, 3
  rep movsb
  pop esi
  pop edi
end;

function memcmp(const p1, p2: pointer; size: DWORD): integer; register;
asm
  push edi
  push esi
  mov edi, eax
  mov esi, edx
  xor eax, eax
  repe cmpsb
  jg @@1
  setl al
  pop esi
  pop edi
  retn
@@1:
  dec eax
  pop esi
  pop edi
end;

function IsPowerOf2(x: cardinal): boolean; register;
var
  c: cardinal;
begin
  result := true;
  for c := 0 to 31 do
    if x = (1 shl c) then
    begin
      result := true;
      exit;
    end;
end;

const
  hexdigits: PAnsiChar = '0123456789ABCDEF';
  hexdigitsW: PWideChar = '0123456789ABCDEF';

function uitohex(x: cardinal; buf: PAnsiChar): PAnsiChar; stdcall;
var
  c: integer;
begin
  result := buf;
  buf[8] := #0;
  for c := 0 to 7 do
    buf[c] := hexdigits[(x shr ((7 - c) * 4)) and $0F];
end;

function uitohexn(x: cardinal; buf: PAnsiChar; n: integer): PAnsiChar; stdcall;
var
  c: integer;
begin
  result := buf;
  buf[n + 1] := #0;
  for c := 0 to n do
    buf[c] := hexdigits[(x shr ((n - c) * 4)) and $0F];
end;

function uitohexW(x: cardinal; buf: PWideChar): PWideChar; stdcall;
var
  c: integer;
begin
  result := buf;
  buf[8] := #0;
  for c := 0 to 7 do
    buf[c] := hexdigitsW[(x shr ((7 - c) * 4)) and $0F];
end;

function uitohexnW(x: cardinal; buf: PWideChar; n: integer): PWideChar; stdcall;
var
  c: integer;
begin
  result := buf;
  buf[n + 1] := #0;
  for c := 0 to n do
    buf[c] := hexdigitsW[(x shr ((n - c) * 4)) and $0F];
end;

function ui64tohex(x: int64; buf: PAnsiChar): PAnsiChar; stdcall;
var
  c: integer;
begin
  result := buf;
  buf[16] := #0;
  for c := 0 to 15 do
    buf[c] := hexdigits[(x shr ((15 - c) * 4)) and $0F];
end;

function ui64tohexn(x: int64; buf: PAnsiChar; n: integer): PAnsiChar; stdcall;
var
  c: integer;
begin
  result := buf;
  buf[n + 1] := #0;
  for c := 0 to n do
    buf[c] := hexdigits[(x shr ((n - c) * 4)) and $0F];
end;

function hexWtoui(const hex: PWideChar): Cardinal; stdcall;
var
  j, len: integer;
  k: cardinal;
  c: byte;
begin
  result := 0;
  len := strlenW(hex) - 1;
  k := 16;
  for j := 0 to len do
  begin
    c := BYTE(upcasew(hex[j]));
    if (c >= $30) and (c <= $39) then k := c - $30;
    if (c >= $41) and (c <= $46) then k := (c - $37);
    if (k > 15) then
    begin
      result := 0;
      exit;
    end;
    result := result + k shl ((len - j) * 4);
  end;
end;

function hexAtoui(const hex: PAnsiChar): Cardinal; stdcall;
var
  j, len: integer;
  k: cardinal;
  c: byte;
begin
  result := 0;
  len := strlenA(hex) - 1;
  k := 16;
  for j := 0 to len do
  begin
    c := BYTE(upcasea(hex[j]));
    if (c >= $30) and (c <= $39) then k := c - $30;
    if (c >= $41) and (c <= $46) then k := (c - $37);
    if (k > 15) then
    begin
      result := 0;
      exit;
    end;
    result := result + k shl ((len - j) * 4);
  end;
end;

function itoa(x: integer; buf: PAnsiChar): PAnsiChar; stdcall;
asm
  push edi
  sub esp, 16
  mov edi, esp
  mov eax, x
  test eax, eax
  jns @@0
  neg eax
@@0:
  xor ecx, ecx
  mov cl, 10
@@1:
  cdq
  div ecx
  or dl, '0'
  mov byte ptr [edi], dl
  inc edi
  test eax, eax
  jnz @@1
  mov edx, buf
  mov eax, x
  test eax, eax
  jns @@2
  mov byte ptr [edi], '-'
  inc edi
@@2:
  dec edi
  mov cl, byte ptr [edi]
  mov byte ptr [edx], cl
  inc edx
  cmp esp, edi
  jnz @@2
  mov byte ptr [edx], 0
  add esp, 16
  pop edi
  mov eax, buf
end;

function itow(x: integer; buf: PWideChar): PWideChar; stdcall;
asm
  push edi
  sub esp, 32
  mov edi, esp
  mov eax, x
  test eax, eax
  jns @@0
  neg eax
@@0:
  xor ecx, ecx
  mov cl, 10
@@1:
  cdq
  div ecx
  or dl, '0'
  mov word ptr [edi], dx
  inc edi
  inc edi
  test eax, eax
  jnz @@1
  mov edx, buf
  mov eax, x
  test eax, eax
  jns @@2
  mov word ptr [edi], WideChar('-')
  inc edi
  inc edi
@@2:
  dec edi
  dec edi
  mov cx, word ptr [edi]
  mov word ptr [edx], cx
  inc edx
  inc edx
  cmp esp, edi
  jnz @@2
  mov word ptr [edx], 0
  add esp, 32
  pop edi
  mov eax, buf
end;

function i64toa(x: int64; buf: PAnsiChar): PAnsiChar; stdcall;
var
  c, p, k: integer;
  mx: int64;
  started: boolean;
begin
  if x = 0 then
  begin
    buf^ := '0';
    (buf + 1)^ := #0;
    result := buf;
    exit;
  end;
  started := false;
  mx := 1000000000000000000;
  if x < 0 then
  begin
    p := 1;
    buf^ := '-';
    x := -x;
  end
  else
    p := 0;
  for c := 0 to 18 do
  begin
    k := (x div mx) mod 10;
    mx := mx div 10;
    if k <> 0 then started := true;
    if started then
    begin
      buf[p] := char(k + ord('0'));
      inc(p);
    end;
  end;
  buf[p] := #0;
  result := buf;
end;

function i64tow(x: int64; buf: PWideChar): PWideChar; stdcall;
var
  c, p, k: integer;
  mx: int64;
  started: boolean;
begin
  if x = 0 then
  begin
    buf^ := '0';
    (buf + 1)^ := #0;
    result := buf;
    exit;
  end;
  started := false;
  mx := 1000000000000000000;
  if x < 0 then
  begin
    p := 1;
    buf^ := '-';
    x := -x;
  end
  else
    p := 0;
  for c := 0 to 18 do
  begin
    k := (x div mx) mod 10;
    mx := mx div 10;
    if k <> 0 then started := true;
    if started then
    begin
      buf[p] := WideChar(k + $30);
      inc(p);
    end;
  end;
  buf[p] := #0;
  result := buf;
end;


function uitoa(x: cardinal; buf: PAnsiChar): PAnsiChar; stdcall;
asm
  push edi
  sub esp, 16
  mov edi, esp
  mov eax, x
  xor ecx, ecx
  mov cl, 10
@@1:
  xor edx, edx
  div ecx
  or dl, '0'
  mov byte ptr [edi], dl
  inc edi
  test eax, eax
  jnz @@1
  mov edx, buf
@@2:
  dec edi
  mov cl, byte ptr [edi]
  mov byte ptr [edx], cl
  inc edx
  cmp esp, edi
  jnz @@2
  mov byte ptr [edx], 0
  add esp, 16
  pop edi
  mov eax, buf
end;

function uitow(x: cardinal; buf: PWideChar): PWideChar; stdcall;
asm
  push edi
  sub esp, 32
  mov edi, esp
  mov eax, x
  xor ecx, ecx
  mov cl, 10
@@1:
  xor edx, edx
  div ecx
  or dl, '0'
  mov word ptr [edi], dx
  inc edi
  inc edi
  test eax, eax
  jnz @@1
  mov edx, buf
@@2:
  dec edi
  dec edi
  mov cx, word ptr [edi]
  mov word ptr [edx], cx
  inc edx
  inc edx
  cmp esp, edi
  jnz @@2
  mov word ptr [edx], 0
  add esp, 32
  pop edi
  mov eax, buf
end;

function uitobinA(x: cardinal; buf: PAnsiChar): PAnsiChar; stdcall;
var
  j, i, k: cardinal;
begin
  buf[0] := #0;
  k := 0;
  for i := 31 downto 0 do
  begin
    j := (x shr i) and 1;
    if (j > 0) then buf[k] := '1' else buf[k] := '0';
    inc(k);
  end;
  buf[k] := #0;
  result := buf;
end;

function uitobinW(x: cardinal; buf: PWideChar): PWideChar; stdcall;
var
  j, i, k: cardinal;
begin
  buf[0] := #0;
  k := 0;
  for i := 31 downto 0 do
  begin
    j := (x shr i) and 1;
    if (j > 0) then buf[k] := '1' else buf[k] := '0';
    inc(k);
  end;
  buf[k] := #0;
  result := buf;
end;

function uitonbinA(x: cardinal; buf: PAnsiChar; n: cardinal): PAnsiChar; stdcall;
var
  j, i, k: cardinal;
begin
  buf[0] := #0;
  k := 0;
  for i := n - 1 downto 0 do
  begin
    j := (x shr i) and 1;
    if j > 0 then buf[k] := '1' else buf[k] := '0';
    inc(k);
  end;
  buf[k] := #0;
  result := buf;
end;

function uitonbinW(x: cardinal; buf: PWideChar; n: cardinal): PWideChar; stdcall;
var
  j, i, k: cardinal;
begin
  buf[0] := #0;
  k := 0;
  for i := n - 1 downto 0 do
  begin
    j := (x shr i) and 1;
    if j > 0 then buf[k] := '1' else buf[k] := '0';
    inc(k);
  end;
  buf[k] := #0;
  result := buf;
end;

const
  spd = 86400;
  mdays: array[0..11] of integer =
  (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

function RtlTimeToSecondsSince1970(const p1: PSYSTEMTIME): DWORD; stdcall;
var
  days, c, s: integer;
begin
  days := p1^.wDay + ((p1^.wYear - 1972) div 4);
  s := (days + (p1^.wYear - 1970) * 365) * spd;
  for c := 1 to p1^.wMonth - 1 do
    s := s + mdays[c - 1] * spd;
  result := s + p1^.wHour * 3600 + p1^.wMinute * 60 + p1^.wSecond;
end;

function RtlSecondsSince1970ToTime(dwSeconds: DWORD; p1: PSYSTEMTIME): boolean; stdcall;
var
  days, c: integer;
begin
  p1^.wMilliseconds := 0;
  p1^.wSecond := dwSeconds mod 60;
  p1^.wMinute := (dwSeconds div 60) mod 60;
  p1^.wHour := (dwSeconds div 3600) mod 24;

  days := dwSeconds div spd;
  p1^.wDayOfWeek := (days + 4) mod 7;
  p1^.wDay := 1;
  p1^.wMonth := 1;
  p1^.wYear := 1970;
  c := 0;
  while (c < days) do
  begin
    inc(c);
    inc(p1^.wDay);
    if p1^.wDay > mdays[p1^.wMonth - 1] then
      if not ((p1^.wYear mod 4 = 0) and (p1^.wMonth = 2) and (p1^.wDay = 29)) then
      begin
        inc(p1^.wMonth);
        p1^.wDay := 1;
      end;
    if p1^.wMonth > 12 then
    begin
      inc(p1^.wYear);
      p1^.wMonth := 1;
    end;
  end;
  result := true;
end;

function GetCmdLineParam(n: cardinal; buf: PAnsiChar): cardinal; stdcall;
var
  c: cardinal;
  p0, p1: PAnsiChar;
begin
  buf^ := #0;
  p0 := GetCommandLineA();
  p1 := p0;

  for c := 0 to n do
  begin
    while p1^ = ' ' do inc(p1);
    p0 := p1;
    if (p1^ = '"') then
    begin
      inc(p0);
      inc(p1);
      while (p1^ <> '"') and (p1^ <> #0) do inc(p1);
    end
    else
      while (p1^ <> ' ') and (p1^ <> '"') and (p1^ <> #0) do inc(p1);

    if (p1^ = #0) and (c < n) then
    begin
      result := 0;
      exit;
    end;
    if (p1^ = '"') and (c < n) then inc(p1);
  end;

  result := p1 - p0;
  strcpynA(buf, p0, result);
end;

function GetCmdLineParamW(n: cardinal; buf: PWideChar): cardinal; stdcall;
var
  c: cardinal;
  p0, p1: PWideChar;
begin
  buf^ := #0;
  p0 := GetCommandLineW();
  p1 := p0;

  for c := 0 to n do
  begin
    while p1^ = ' ' do inc(p1);
    p0 := p1;
    if (p1^ = '"') then
    begin
      inc(p0);
      inc(p1);
      while (p1^ <> '"') and (p1^ <> #0) do inc(p1);
    end
    else
      while (p1^ <> ' ') and (p1^ <> '"') and (p1^ <> #0) do inc(p1);

    if (p1^ = #0) and (c < n) then
    begin
      result := 0;
      exit;
    end;
    if (p1^ = '"') and (c < n) then inc(p1);
  end;

  result := p1 - p0;
  strcpynW(buf, p0, result);
end;

function GetCmdLineParamsCount(): cardinal; stdcall;
var
  k, c: cardinal;
  p1: FBuf;
begin
  k := 1;
  while true do
  begin
    c := GetCmdLineParam(k, p1);
    if (c = 0) then break else inc(k);
  end;
  result := k - 2;
end;

function GetCmdLineParamsVar(
  const lpParams: PAnsiChar; //line with params, e.g. test=true|load=false
  const lpVar: PAnsiChar; //variable, e.g. "test"
  const chDelimiter: Char; //params delimiter, e.g. "|"
  const chAssign: Char; //assign char, e.g. "="
  buf: PAnsiChar
  ): PAnsiChar; stdcall;

var
  n, u, k, l, i, j: integer;
  p0, p1: PAnsiChar;
  tmpbuf: array[0..MAX_PATH - 1] of CHAR;
begin
  result := nil;
  u := strlenA(lpParams);
  if (u = 0) then exit;

  GetCmdLineParam(0, buf);
  k := strlenA(buf);
  if (k = 0) then exit;

  n := u - k;
  if (n <= 2) then exit;
  strcpynA(buf, @lpParams[k + 1], n);
  if (buf[0] = #0) then exit;
  p0 := buf;
  p1 := p0;
  i := 0;
  n := 0;
  j := 0;
  repeat
    if (p0^ = chDelimiter) then
    begin
      inc(i);
      strcpynA(p1, @buf[n], i - n - 1);
      l := 0;
      while (p1[l] <> chAssign) do inc(l);
      if (l > 0) then
      begin
        strcpynA(tmpbuf, buf, l);
        if (strcmpiA(tmpbuf, lpVar) = 0) then
        begin
          strcpyA(buf, @buf[l + 1]);
          j := 1;
        end;
        if (j > 0) then
        begin
          result := buf;
          exit;
        end;
      end;
      n := i;
      inc(p0);
    end else
    begin
      inc(i);
      inc(p0);
      if (p0^ = #0) then //drop last parameter
      begin
        strcpynA(p1, @buf[n], i - n);
        l := 0;
        while (p1[l] <> chAssign) do inc(l);
        if (l > 0) then
        begin
          strcpynA(tmpbuf, buf, l);
          if (strcmpiA(tmpbuf, lpVar) = 0) then
          begin
            strcpyA(buf, @buf[l + 1]);
            j := 1;
          end;
          if (j > 0) then
          begin
            result := buf;
            exit;
          end;
        end;
      end;
    end;
  until (p0^ = #0);
end;

//stub function (need to recompile some shit w/o gemoroy)

function GetNativeCmdLine(buf: PAnsiChar): PAnsiChar; stdcall;
begin
  result := GetNativeCmdLineA(buf);
end;

function GetNativeCmdLineA(buf: PAnsiChar): PAnsiChar; stdcall;
var
  i, n: integer;
  p0: PAnsiChar;
begin
  p0 := GetCommandLineA();
  n := 0;
  for i := 0 to (strlenA(p0) - 1) do
    if (p0[i] <> '"') then
    begin
      buf[n] := p0[i];
      inc(n);
    end;
  result := buf;
end;

function GetNativeCmdLineW(buf: PWideChar): PWideChar; stdcall;
var
  i, n: integer;
  p0: PWideChar;
begin
  p0 := GetCommandLineW();
  n := 0;
  for i := 0 to (strlenW(p0) - 1) do
    if (p0[i] <> '"') then
    begin
      buf[n] := p0[i];
      inc(n);
    end;
  result := buf;
end;

function CreateNativeCmdLineA(cmdline: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
var
  i, n: integer;
begin
  n := 0;
  for i := 0 to (strlenA(cmdline) - 1) do
    if (cmdline[i] <> '"') then
    begin
      buf[n] := cmdline[i];
      inc(n);
    end;
  result := buf;
end;

function isdigitA(c: AnsiChar): ByteBool; register;
asm
  cmp al, '0'
  jl @@1
  cmp al, '9'
  jg @@1
  retn
@@1:
  xor eax, eax
end;

function issignA(c: AnsiChar): ByteBool; register;
asm
  cmp al, '+'
  je @@1
  cmp al, '-'
  jne @@2
@@1:
  retn
@@2:
  xor eax, eax
end;

function isdigitW(c: WideChar): WordBool; register;
asm
  cmp ax, WideChar('0')
  jl @@1
  cmp ax, WideChar('9')
  jg @@1
  retn
@@1:
  xor eax, eax
end;

function issignW(c: WideChar): WordBool; register;
asm
  cmp ax, WideChar('+')
  je @@1
  cmp ax, WideChar('-')
  jne @@2
@@1:
  retn
@@2:
  xor eax, eax
end;

function atoui(s: PAnsiChar): cardinal; stdcall;
var
  c, k, t, l: cardinal;
  d: AnsiChar;
begin
  result := 0;
  if s = nil then exit;
  l := strlenA(s);
  if l = 0 then exit;

  t := 0;
  k := 1;

  for c := l - 1 downto 0 do
  begin
    d := PAnsiChar(s + c)^;
    if not isdigitA(d) then exit;
    t := t + cardinal(BYTE(d) - $30) * k;
    if c > 0 then k := k * 10;
  end;
  result := t;
end;

function wtoui(s: PWideChar): cardinal; stdcall;
var
  c, k, t, l: cardinal;
  d: WideChar;
begin
  result := 0;
  if s = nil then exit;
  l := strlenW(s);
  if l = 0 then exit;

  t := 0;
  k := 1;

  for c := l - 1 downto 0 do
  begin
    d := PWideChar(s + c)^;
    if not isdigitW(d) then exit;
    t := t + cardinal(BYTE(d) - $30) * k;
    if c > 0 then k := k * 10;
  end;
  result := t;
end;

function atoi(s: PAnsiChar): integer; stdcall;
var
  c, k, t, l: integer;
  d: AnsiChar;
begin
  result := 0;
  if s = nil then exit;
  l := strlenA(s);
  if l = 0 then exit;

  t := 0;
  k := 1;
  case s^ of
    '+':
      begin
        s := s + 1;
        l := l - 1;
      end;
    '-':
      begin
        k := -1;
        s := s + 1;
        l := l - 1;
      end;
  end;

  for c := l - 1 downto 0 do
  begin
    d := PAnsiChar(s + c)^;
    if not isdigitA(d) then exit;
    t := t + (BYTE(d) - $30) * k;
    if c > 0 then k := k * 10;
  end;
  result := t;
end;

function atoi64(s: PAnsiChar): int64; stdcall;
const
  mx: int64 = 10;
var
  c, l: integer;
  t, k, t1: int64;
  d: AnsiChar;
begin
  result := 0;
  if s = nil then exit;
  l := strlenA(s);
  if l = 0 then exit;

  t := 0;
  k := 1;
  case s^ of
    '+':
      begin
        s := s + 1;
        l := l - 1;
      end;
    '-':
      begin
        k := -1;
        s := s + 1;
        l := l - 1;
      end;
  end;

  for c := l - 1 downto 0 do
  begin
    d := PAnsiChar(s + c)^;
    if not isdigitA(d) then exit;
    t1 := BYTE(d) - $30;
    t := t + alu_mul64(@k, @t1); ;
    if c > 0 then k := alu_mul64(@k, @mx);
  end;
  result := t;
end;

function ftoa(x: extended; buf: PAnsiChar): PAnsiChar; stdcall;
const
  mx: int64 = 10;
var
  c, t, p: integer;
  k: int64;

  procedure _step();
  begin
    k := trunc(x);
    k := fpu_mod64(@k, @mx);
    buf[p] := char($30 + k);
    x := x * 10;
    inc(p);
  end;

begin
  c := 0;
  p := 0;
  if x = 0 then
  begin
    buf[0] := '0';
    buf[1] := #0;
    result := buf;
    exit;
  end;
  if x < 0 then
  begin
    buf[0] := '-';
    inc(p);
    x := abs(x);
  end;
  while x < 1 do
  begin
    x := x * 10;
    dec(c);
  end;
  while x >= 10 do
  begin
    x := x / 10;
    inc(c);
  end;
  asm
    fnclex
  end;
  _step();
  buf[p] := '.';
  inc(p);

  for t := 0 to 14 do
    _step();

  if c <> 0 then
  begin
    buf[p] := 'E';
    itoa(c, @buf[p + 1]);
  end;
  result := buf;
end;

function ftoa_fmt(x: extended; decimals: integer; buf: PAnsiChar): PAnsiChar; stdcall;
const
  mx: int64 = 10;
var
  c, t, p, g: integer;
  dot, f: boolean;
  k: int64;
  x2: extended;

  procedure _step();
  begin
    k := trunc(x);
    k := fpu_mod64(@k, @mx);
    buf[p] := char($30 + k);
    x := x * 10;
    inc(p);
  end;

begin
  if decimals < 1 then decimals := 1;
  c := 0;
  p := 0;
  if x = 0 then
  begin
    buf[0] := '0';
    buf[1] := #0;
    result := buf;
    exit;
  end;
  x2 := x;
  if x < 0 then
  begin
    buf[0] := '-';
    inc(p);
    x := abs(x);
  end;
  while x < 1 do
  begin
    x := x * 10;
    dec(c);
  end;
  while x >= 10 do
  begin
    x := x / 10;
    inc(c);
  end;
  asm
    fnclex
  end;
  if c > 17 then
  begin
    result := ftoa(x2, buf);
    exit;
  end;

  dot := false;
  f := true;
  if c < 0 then
  begin
    buf[p] := '0';
    buf[p + 1] := '.';
    dot := true;
    p := p + 2;
    g := p;
    for t := 0 to abs(c) - 2 do
    begin
      buf[t + g] := '0';
      inc(p);
      dec(decimals);
      if decimals <= 0 then
      begin
        f := false;
        break;
      end;
    end;
  end;

  if f then
    for t := 0 to 17 do
    begin
      _step();
      if dot then dec(decimals);
      if decimals <= 0 then break;
      if (t = c) and (t < 16) then
      begin
        buf[p] := '.';
        dot := true;
        inc(p);
      end;
    end;
  buf[p] := #0;
  result := buf;
end;

function atof(const s: PAnsiChar): extended; stdcall;
const
  mx: int64 = 10;
var
  buf: array[0..31] of AnsiChar;
  p0: PAnsiChar;
  t: cardinal;
  c, u: int64;
begin
  p0 := strscanA(s, '.');
  if p0 = nil then p0 := strendA(s);
  strcpynA(buf, s, p0 - s);
  u := atoi64(buf);
  strcpyA(buf, p0 + 1);
  c := 1;
  if u < 0 then c := -1;
  for t := 1 to strlenA(buf) do
    c := alu_mul64(@c, @mx);
  result := u + atoi64(buf) / c;
  if (s[0] = '-') and (result > 0) then result := -result;
end;

function LongBufA2FBuf(const src: LongBufA): FBuf; stdcall;
begin
  strcpynA(Result, src, MAX_PATH - 1);
end;

function LongBufW2LBuf(const src: LongBufW): LBuf; stdcall;
begin
  strcpynW(Result, src, MAX_PATH - 1);
end;

procedure _wait(msInterval: cardinal); stdcall;
const
  mm: int64 = 1000;
var
  ct, mx, t0, t: int64;
begin
  QueryPerformanceFrequency(mx);
  QueryPerformanceCounter(t0);
  t := t0;
  ct := msInterval;
  ct := alu_mul64(@ct, @mx);
  ct := fpu_div64(@ct, @mm);
  while (t - t0) < ct do
    QueryPerformanceCounter(t);
end;

function ChangeFileExt(const FileName: PAnsiChar; const ext: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
var
  l, c: integer;
begin
  result := nil;
  l := strlenA(FileName);
  if l = 0 then exit;
  case FileName[l - 1] of
    '\', ':': exit;
  end;
  strcpyA(buf, FileName);
  result := buf;
  for c := l - 1 downto 0 do
    case buf[c] of
      '.':
        begin
          strcpyA(@buf[c + 1], ext);
          exit;
        end;
      '\', ':': break;
    end;
  buf[l] := '.';
  buf[l + 1] := #0;
  strcatA(buf, ext);
end;

function ChangeFileExtW(const FileName: PWideChar; const ext: PWideChar; buf: PWideChar): PWideChar; stdcall;
var
  l, c: integer;
begin
  result := nil;
  l := strlenW(FileName);
  if l = 0 then exit;
  case FileName[l - 1] of
    '\', ':': exit;
  end;
  strcpyW(buf, FileName);
  result := buf;
  for c := l - 1 downto 0 do
    case buf[c] of
      '.':
        begin
          strcpyW(@buf[c + 1], ext);
          exit;
        end;
      '\', ':': break;
    end;
  buf[l] := '.';
  buf[l + 1] := #0;
  strcatW(buf, ext);
end;

function ExtractFileName(const FileName: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
var
  l, c: integer;
begin
  result := nil;
  l := strlenA(FileName);
  if l = 0 then exit;
  case FileName[l - 1] of
    '\', ':': exit;
  end;
  for c := l - 1 downto 0 do
    case FileName[c] of
      '\', ':':
        begin
          result := strcpyA(buf, @FileName[c + 1]);
          exit;
        end;
    end;
  result := strcpyA(buf, FileName);
end;

function ExtractFileNameW(const FileName: PWideChar; buf: PWideChar): PWideChar; stdcall;
var
  l, c: integer;
begin
  result := nil;
  l := strlenW(FileName);
  if l = 0 then exit;
  case FileName[l - 1] of
    '\', ':': exit;
  end;
  for c := l - 1 downto 0 do
    case FileName[c] of
      '\', ':':
        begin
          result := strcpyW(buf, @FileName[c + 1]);
          exit;
        end;
    end;
  result := strcpyW(buf, FileName);
end;

function ExtractFilePath(const FileName: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
var
  l, c: integer;
begin
  result := nil;
  l := strlenA(FileName);
  if l = 0 then exit;
  for c := l - 1 downto 0 do
    case FileName[c] of
      '\', ':':
        begin
          result := strcpynA(buf, FileName, c + 1);
          exit;
        end;
    end;
end;

function ExtractFilePathW(const FileName: PWideChar; buf: PWideChar): PWideChar; stdcall;
var
  l, c: integer;
begin
  result := nil;
  l := strlenW(FileName);
  if l = 0 then exit;
  for c := l - 1 downto 0 do
    case FileName[c] of
      '\', ':':
        begin
          result := strcpynW(buf, FileName, c + 1);
          exit;
        end;
    end;
end;

function ExtractFileExt(const FileName: PAnsiChar; buf: PAnsiChar): PAnsiChar; stdcall;
var
  l, c: integer;
begin
  result := nil;
  l := strlenA(FileName);
  if l = 0 then exit;
  case FileName[l - 1] of
    '\', ':': exit;
  end;
  for c := l - 1 downto 0 do
    case FileName[c] of
      '.':
        begin
          strcpyA(buf, @FileName[c + 1]);
          result := buf;
          exit;
        end;
      '\', ':': break;
    end;
end;

function ExtractFileExtW(const FileName: PWideChar; buf: PWideChar): PWideChar; stdcall;
var
  l, c: integer;
begin
  result := nil;
  l := strlenW(FileName);
  if l = 0 then exit;
  case FileName[l - 1] of
    '\', ':': exit;
  end;
  for c := l - 1 downto 0 do
    case FileName[c] of
      '.':
        begin
          strcpyW(buf, @FileName[c + 1]);
          result := buf;
          exit;
        end;
      '\', ':': break;
    end;
end;

function FileExistsA(const FileName: PAnsiChar): boolean; stdcall;
var
  code: cardinal;
begin
  code := GetFileAttributesA(FileName);
  result := (code <> $FFFFFFFF) and (not (FILE_ATTRIBUTE_DIRECTORY and code <> 0));
end;

function FileExistsW(const FileName: PWideChar): boolean; stdcall;
var
  code: cardinal;
begin
  code := GetFileAttributesW(FileName);
  result := (code <> $FFFFFFFF) and (not (FILE_ATTRIBUTE_DIRECTORY and code <> 0));
end;

function FileExistsExA(const lpFileName: PChar): BOOL; stdcall;
var
  fdh: THANDLE;
  fd1: WIN32_FIND_DATAA;
  namebuf: array[0..MAX_PATH - 1] of CHAR;
begin
  ExtractFileName(lpFileName, namebuf);
  fdh := FindFirstFileA(lpFileName, fd1);

  result := false;
  if (fdh <> INVALID_HANDLE_VALUE) then
    if (strcmpiA(fd1.cFileName, namebuf) = 0) then
      result := true;
  FindClose(fdh);
end;

function FileExistsExW(const lpFileName: PWideChar): BOOL; stdcall;
var
  fdh: THANDLE;
  fd1: WIN32_FIND_DATAW;
  namebuf: array[0..MAX_PATH - 1] of WideChar;
begin
  ExtractFileNameW(lpFileName, namebuf);
  fdh := FindFirstFileW(lpFileName, fd1);

  result := false;
  if (fdh <> INVALID_HANDLE_VALUE) then
    if (strcmpiW(fd1.cFileName, namebuf) = 0) then
      result := true;
  FindClose(fdh);
end;

function DirectoryExistsA(const DirName: PAnsiChar): boolean; stdcall;
var
  code: cardinal;
begin
  code := GetFileAttributesA(DirName);
  result := (code <> $FFFFFFFF) and (FILE_ATTRIBUTE_DIRECTORY and code <> 0);
end;

function DirectoryExistsW(const DirName: PWideChar): boolean; stdcall;
var
  code: cardinal;
begin
  code := GetFileAttributesW(DirName);
  result := (code <> $FFFFFFFF) and (FILE_ATTRIBUTE_DIRECTORY and code <> 0);
end;

function DisplayLastError(_hwnd: HWND): integer; stdcall;
begin
  result := DisplayLastErrorA(_hwnd);
end;

function DisplayLastErrorA(_hwnd: HWND): integer; stdcall;
var
  err: cardinal;
  mbuf: array[0..1023] of AnsiChar;
begin
  err := GetLastError();
  mbuf[0] := #0;
  FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, nil, err, 0, mbuf, 1024, nil);
  if err = 0 then
    result := MessageBoxA(_hwnd, mbuf, 'No error', MB_ICONASTERISK)
  else
    result := MessageBoxA(_hwnd, mbuf, nil, MB_ICONERROR or MB_ABORTRETRYIGNORE);
end;

function DisplayLastErrorW(_hwnd: HWND): integer; stdcall;
var
  err: cardinal;
  mbuf: array[0..1023] of WideChar;
begin
  err := GetLastError();
  mbuf[0] := #0;
  FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, nil, err, 0, mbuf, 1024, nil);
  if err = 0 then
    result := MessageBoxW(_hwnd, mbuf, 'No error', MB_ICONASTERISK)
  else
    result := MessageBoxW(_hwnd, mbuf, nil, MB_ICONERROR or MB_ABORTRETRYIGNORE);
end;

function ReturnLastError(): FBuf; stdcall;
var
  err: cardinal;
  mbuf: array[0..1023] of AnsiChar;
begin
  err := GetLastError();
  mbuf[0] := #0;
  FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, nil, err, 0, mbuf, 1024, nil);
  if err = 0 then
    strcpyA(result, 'No error')
  else
    strcpynA(result, mbuf, MAX_PATH - 1);
end;


function maxu(a, b: cardinal): cardinal; register;
asm
  cmp eax, edx
  db $0f, $42, $c2 // cmovb eax, edx
end;

function maxi(a, b: integer): integer; register;
asm
  cmp edx, eax
  db $0f, $4f, $c2 // cmovg eax, edx
end;

function maxi64(a, b: int64): int64; stdcall;
asm
  mov eax, [ebp + $08]
  mov edx, [ebp + $0c]
  cmp edx, [ebp + $14]
  db $0f, $4c, $55, $14 // cmovl edx, [ebp + $14]
  db $0f, $4c, $45, $10 // cmovl eax, [ebp + $10]
  jne @@1
  mov ecx, [ebp + $10]
  cmp eax, ecx
  db $0f, $42, $c1 // cmovb eax, ecx
  @@1:
end;

function minu(a, b: cardinal): cardinal; register;
asm
  cmp edx, eax
  db $0f, $42, $c2 // cmovb eax, edx
end;

function mini(a, b: integer): integer; register;
asm
  cmp eax, edx
  db $0f, $4f, $c2 // cmovg eax, edx
end;

function mini64(a, b: int64): int64; stdcall;
asm
  mov eax, [ebp + $08]
  mov edx, [ebp + $0c]
  cmp [ebp + $14], edx
  db $0f, $4c, $55, $14 // cmovl edx, [ebp + $14]
  db $0f, $4c, $45, $10 // cmovl eax, [ebp + $10]
  jne @@1
  mov ecx, [ebp + $10]
  cmp ecx, eax
  db $0f, $42, $c1 // cmovb eax, ecx
  @@1:
end;

function align(x, base: DWORD): DWORD; register;
asm
  push ebx
  mov ecx, eax
  mov ebx, edx
  xor edx, edx
  div ebx
  or edx, edx
  jz @@1
  sub ecx, edx
  add ecx, ebx
@@1:
  mov eax, ecx
  pop ebx
end;

function align2(x: DWORD): DWORD; register;
asm
  xor edx, edx
  bt eax, edx
  adc eax, edx
end;

function _exec(const cmdLine, CurrentDir: PAnsiChar): boolean; stdcall;
var
  sti1: STARTUPINFO;
  pi1: PROCESS_INFORMATION;
begin
  GetStartupInfo(sti1);
  result := CreateProcessA(nil, cmdLine, nil, nil, false,
    CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS, nil, CurrentDir, sti1, pi1);
  CloseHandle(pi1.hProcess);
  CloseHandle(pi1.hThread);
end;

function _exec_wait(const cmdLine, CurrentDir: PAnsiChar): boolean; stdcall;
var
  sti1: STARTUPINFO;
  pi1: PROCESS_INFORMATION;
begin
  GetStartupInfo(sti1);
  result := CreateProcessA(nil, cmdLine, nil, nil, false,
    CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS, nil, CurrentDir, sti1, pi1);
  WaitForSingleObject(pi1.hProcess, INFINITE);
  CloseHandle(pi1.hProcess);
  CloseHandle(pi1.hThread);
end;

function _exec_waitW(const cmdLine, CurrentDir: PWideChar): boolean; stdcall;
var
  sti1: STARTUPINFOW;
  pi1: PROCESS_INFORMATION;
begin
  GetStartupInfoW(sti1);
  result := CreateProcessW(nil, cmdLine, nil, nil, false,
    CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS, nil, CurrentDir, sti1, pi1);
  WaitForSingleObject(pi1.hProcess, INFINITE);
  CloseHandle(pi1.hProcess);
  CloseHandle(pi1.hThread);
end;

function _execW(const cmdLine, CurrentDir: PWideChar): boolean; stdcall;
var
  sti1: STARTUPINFOW;
  pi1: PROCESS_INFORMATION;
begin
  GetStartupInfoW(sti1);
  result := CreateProcessW(nil, cmdLine, nil, nil, false,
    CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS, nil, CurrentDir, sti1, pi1);
  CloseHandle(pi1.hProcess);
  CloseHandle(pi1.hThread);
end;

procedure InitFPU(); stdcall;
asm
  fninit
  fldcw cwDef
end;

//RLE Compression routine

function GetUncompressedSize(src: PChar; srcsize: cardinal): cardinal; stdcall;
var
  c, p, l: cardinal;
begin
  p := 0;
  c := 0;
  while (c < srcsize) do
  begin
    if src[c] = #0 then
    begin
      l := BYTE(src[c + 1]);
      c := c + l;
    end
    else
      l := BYTE(src[c]);
    c := c + 2;
    p := p + l;
  end;
  result := p;
end;

function CompressBuffer(dest, src: PChar; srcsize: cardinal): cardinal; stdcall;
var
  c, p, k, l: cardinal;
begin
  result := 0;
  case srcsize of
    0: exit;
    1:
      begin
        result := 2;
        dest[0] := #1;
        dest[1] := src[0];
        exit;
      end;
  end;

  c := 0;
  p := 0;
  k := 1;
  l := 0;

  while (c < srcsize - 1) do
  begin
    if (src[c] = src[c + 1]) and (k < 255) then
      k := k + 1
    else
      if (k = 1) and (l < 255) then
      begin
        l := l + 1;
        dest[p] := #0;
        dest[p + 1] := char(l);
        dest[p + 1 + l] := src[c];
      end
      else
      begin
        if l > 0 then
        begin
          p := p + 2 + l;
          l := 0;
        end;
        dest[p] := char(k);
        dest[p + 1] := src[c];
        p := p + 2;
        k := 1;
      end;
    c := c + 1;
  end;

  if l > 0 then
  begin
    dest[p] := #0;
    dest[p + 1] := char(l);
    dest[p + 2 + l] := src[c];
    p := p + 2 + l;
  end;
  dest[p] := char(k);
  dest[p + 1] := src[c];
  p := p + 2;
  result := p;
end;

function DecompressBuffer(dest, src: PChar; srcsize: cardinal): cardinal; stdcall;
var
  c, p, l: cardinal;
begin
  p := 0;
  c := 0;
  while (c < srcsize) do
  begin
    if src[c] = #0 then
    begin
      l := BYTE(src[c + 1]);
      memcopy(@dest[p], @src[c + 2], l);
      c := c + l;
    end
    else
    begin
      l := BYTE(src[c]);
      memfill(@dest[p], l, BYTE(src[c + 1]));
    end;
    c := c + 2;
    p := p + l;
  end;
  result := p;
end;

procedure Resample2(tempbuf, src: PChar; srcsize: cardinal);
var
  gofs, c: cardinal;
begin
  if srcsize < 2 then exit;
  gofs := srcsize div 2;
  memcopy(tempbuf, src, srcsize);
  for c := 0 to (srcsize div 2) - 1 do
  begin
    src[c * 2] := tempbuf[c];
    src[c * 2 + 1] := tempbuf[c + gofs];
  end;
end;

procedure Resample4(tempbuf, src: PChar; srcsize: cardinal);
var
  gofs, bofs, aofs, c: cardinal;
begin
  if srcsize < 4 then exit;
  gofs := srcsize div 4;
  bofs := gofs * 2;
  aofs := gofs * 3;
  memcopy(tempbuf, src, srcsize);
  for c := 0 to (srcsize div 4) - 1 do
  begin
    src[c * 4] := tempbuf[c];
    src[c * 4 + 1] := tempbuf[c + gofs];
    src[c * 4 + 2] := tempbuf[c + bofs];
    src[c * 4 + 3] := tempbuf[c + aofs];
  end;
end;

procedure Resample3(tempbuf, src: PChar; srcsize: cardinal);
var
  gofs, bofs, c: cardinal;
begin
  if srcsize < 3 then exit;
  gofs := srcsize div 3;
  bofs := gofs * 2;
  memcopy(tempbuf, src, srcsize);
  for c := 0 to (srcsize div 3) - 1 do
  begin
    src[c * 3] := tempbuf[c];
    src[c * 3 + 1] := tempbuf[c + gofs];
    src[c * 3 + 2] := tempbuf[c + bofs];
  end;
end;

function CRCBuffer(buf: PChar; bufsize: cardinal): cardinal;
asm
  push esi
  xor esi, esi
  mov ecx, edx
@@1:
  movzx edx, byte ptr [eax]
  add esi, edx
  rol esi, 1
  inc eax
  loop @@1
  mov eax, esi
  pop esi
end;

function EnableSystemPrivilege(PrivName: PChar; Enable: BOOL): boolean; stdcall;
var
  tmp: _TOKEN_PRIVILEGES;
  token1, prevlen: Cardinal;
begin
  OpenProcessToken(GetCurrentProcess(), TOKEN_ALL_ACCESS, token1);
  LookupPrivilegeValue(nil, PrivName, tmp.Privileges[0].Luid);
  tmp.PrivilegeCount := 1;
  if Enable then tmp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED else
    tmp.Privileges[0].Attributes := 0;
  result := AdjustTokenPrivileges(token1, false, tmp, 0, nil, prevlen);
end;

function EnableSystemPrivilegeW(PrivName: PWideChar; Enable: BOOL): boolean; stdcall;
var
  tmp: _TOKEN_PRIVILEGES;
  token1, prevlen: Cardinal;
begin
  OpenProcessToken(GetCurrentProcess(), TOKEN_ALL_ACCESS, token1);
  LookupPrivilegeValueW(nil, PrivName, tmp.Privileges[0].Luid);
  tmp.PrivilegeCount := 1;
  if Enable then tmp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED else
    tmp.Privileges[0].Attributes := 0;
  result := AdjustTokenPrivileges(token1, false, tmp, 0, nil, prevlen);
end;

function MAKELANGID(p, s: word): Integer;
begin
  result := (s shl 10) or p;
end;

const
  NTMsgLib = 'netmsg.dll';

procedure DisplayLastErrorExA(_hwnd: HWND); stdcall;
begin
  DisplayLastErrorExW(_hwnd);
end;

procedure DisplayLastErrorExW(_hwnd: HWND); stdcall;
var
  hErrLib: THANDLE;
  msg: PWideChar;
  buf: LBuf;
  code, flags: Integer;
begin
  code := GetLastError();
  hErrLib := LoadLibraryExW(NTMsgLib, 0, LOAD_LIBRARY_AS_DATAFILE);
  flags := FORMAT_MESSAGE_ALLOCATE_BUFFER or
    FORMAT_MESSAGE_IGNORE_INSERTS or
    FORMAT_MESSAGE_FROM_SYSTEM;

  if (hErrLib <> 0) then
    flags := flags or FORMAT_MESSAGE_FROM_HMODULE;

  if FormatMessageW(flags,
    pointer(hErrLib),
    code,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    PWideChar(@msg),
    0,
    nil) <> 0 then
  begin
    strcpyW(buf, 'Last NT raised error: ');
    itow(code, strendW(buf));
    MessageBoxW(_hwnd, msg, buf, MB_ICONERROR);
  end else MessageBoxW(_hwnd, 'no error', 'RTL', MB_ICONASTERISK);
  if (msg <> nil) then LocalFree(HLOCAL(msg));
  if (hErrLib <> 0) then FreeLibrary(hErrLib)
end;

function CTL_CODE(DeviceType, _function, Method, Access: cardinal): cardinal;
begin
  result := (DeviceType shl 16) or (Access shl 14) or (_function shl 2) or Method;
end;

end.

