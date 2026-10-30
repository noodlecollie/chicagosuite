// Adapted from https://github.com/Alex313031/libnt5/tree/msvc-v141-xp/tests

#ifndef TEST_H
#define TEST_H

#ifndef WIN32_LEAN_AND_MEAN
 #define WIN32_LEAN_AND_MEAN
#endif

#ifndef _UNICODE
 #define _UNICODE
#endif

#ifdef _UNICODE
 #ifndef UNICODE
  #define UNICODE
 #endif
#endif

#include "targetver.h"

#include <windows.h>
#include <commctrl.h>
#include <tchar.h>

extern HINSTANCE g_hInstance;

// Dummy file output for conhost
static FILE* fDummyFile;

void OpenMessageBox(LPCWSTR MsgTitle, LPCWSTR MsgContent);

#endif // TEST_H
