{

stub header file

}
unit Stub;

interface

uses Windows, WinNative, RTL;

type
  TMessageBoxW = function(hWnd: HWND; lpText, lpCaption: PWideChar; uType: UINT): Integer; stdcall;

function InitLoader(phUser32: PDWORD): BOOL;
procedure UnInitLoader();

const
  User32DllPath: PWideChar = '\system32\user32.dll';

var
  huser32: THANDLE;
  MsgBoxW: TMessageBoxW;

implementation

function InitLoader(phUser32: PDWORD): BOOL;
var
  buf: LBuf;
begin
  result := false;
  strcpyW(buf, KI_SHARED_USER_DATA.NtSystemRoot);
  strcatW(buf, User32DllPath);
  huser32 := NativeLoadLibrary(buf);
  if (huser32 <> 0) then
  begin
    MsgBoxW := NativeGetProcAddress(huser32, 'MessageBoxW');
    result := (@MsgBoxW <> nil);
    if (phUser32 <> nil) then phUser32^ := hUser32;
  end;
end;

procedure UnInitLoader();
begin
  if (huser32 <> 0) then LdrUnloadDll(huser32);
end;

end.

