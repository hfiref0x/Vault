{$E dll}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$IFDEF minimum}
program unprevx;
{$ENDIF}
unit unprevx;
interface

uses
  Windows, WinNative, RTL;

const
  String1: PWideChar = '\BaseNamedObjects\AllowMePlease';


implementation

var
  buf: LBuf;
  EventHandle: THANDLE;
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;

procedure main();
begin
  OutputDebugStringW('Test');
  EventHandle := 0;

  RtlInitUnicodeString(@str1, String1);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);

  if (ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr) = STATUS_SUCCESS) then
  begin
    ZwClose(EventHandle);
  end else
  begin  //if no event specified then kill that shit
    GetModuleHandleW(@buf);
    ExtractFileNameW(buf, buf);
    if (strcmpiW(buf, 'prevx.exe') = 0) then ExitProcess(0);
  end;
end;

asm
  call main
  xor eax, eax
  inc eax
  retn $000c
end.

