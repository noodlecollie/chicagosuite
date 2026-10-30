/*
 * EnlyzeWinCompatLib - Let Clang-compiled applications run on older Windows versions
 * Copyright (c) 2021 Colin Finck, ENLYZE GmbH <c.finck@enlyze.com>
 * SPDX-License-Identifier: MIT
 */

/* The original MASM assembly: */
/*
.model flat

EXTERN _LibGetModuleHandleExW@12 : PROC
EXTERN _LibHeapQueryInformation@20 : PROC
EXTERN _LibInitializeSListHead@4 : PROC
EXTERN _LibInterlockedFlushSList@4 : PROC
EXTERN _LibInterlockedPushEntrySList@8 : PROC

.data

PUBLIC __imp__GetModuleHandleExW@12
__imp__GetModuleHandleExW@12 dd _LibGetModuleHandleExW@12

PUBLIC __imp__HeapQueryInformation@20
__imp__HeapQueryInformation@20 dd _LibHeapQueryInformation@20

PUBLIC __imp__InitializeSListHead@4
__imp__InitializeSListHead@4 dd _LibInitializeSListHead@4

PUBLIC __imp__InterlockedFlushSList@4
__imp__InterlockedFlushSList@4 dd _LibInterlockedFlushSList@4

PUBLIC __imp__InterlockedPushEntrySList@8
__imp__InterlockedPushEntrySList@8 dd _LibInterlockedPushEntrySList@8

END
*/

/*
Relevant rules that I just learned in order to port this:
	- ".model flat" is not needed
	- "EXTERN" becomes ".extern"
	- ": PROC" is omitted
	- ".data" is identical
	- "PUBLIC" becomes ".globl"
	- Labels must be followed by a colon
	- "dd" (double word) corresponds to ".long"
	- "END" is not needed
*/

/* GAS equivalent: */

.extern _LibGetModuleHandleExW@12
.extern _LibHeapQueryInformation@20
.extern _LibInitializeSListHead@4
.extern _LibInterlockedFlushSList@4
.extern _LibInterlockedPushEntrySList@8

.data

.globl __imp__GetModuleHandleExW@12
__imp__GetModuleHandleExW@12: .long _LibGetModuleHandleExW@12

.globl __imp__HeapQueryInformation@20
__imp__HeapQueryInformation@20: .long _LibHeapQueryInformation@20

.globl __imp__InitializeSListHead@4
__imp__InitializeSListHead@4: .long _LibInitializeSListHead@4

.globl __imp__InterlockedFlushSList@4
__imp__InterlockedFlushSList@4: .long _LibInterlockedFlushSList@4

.globl __imp__InterlockedPushEntrySList@8
__imp__InterlockedPushEntrySList@8: .long _LibInterlockedPushEntrySList@8
