/*
 * EnlyzeWinCompatLib - Let Clang-compiled applications run on older Windows versions
 * Copyright (c) 2021 Colin Finck, ENLYZE GmbH <c.finck@enlyze.com>
 * SPDX-License-Identifier: MIT
 */

/* The original MASM assembly: */
/*
.model flat

EXTERN _LibGetFileSizeEx@8 : PROC
EXTERN _LibInitializeCriticalSectionAndSpinCount@8 : PROC
EXTERN _LibSetFilePointerEx@20 : PROC

.data

PUBLIC __imp__GetFileSizeEx@8
__imp__GetFileSizeEx@8 dd _LibGetFileSizeEx@8

PUBLIC __imp__InitializeCriticalSectionAndSpinCount@8
__imp__InitializeCriticalSectionAndSpinCount@8 dd _LibInitializeCriticalSectionAndSpinCount@8

PUBLIC __imp__SetFilePointerEx@20
__imp__SetFilePointerEx@20 dd _LibSetFilePointerEx@20

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

.extern _LibGetFileSizeEx@8
.extern _LibInitializeCriticalSectionAndSpinCount@8
.extern _LibSetFilePointerEx@20

.data

.globl __imp__GetFileSizeEx@8
__imp__GetFileSizeEx@8: .long _LibGetFileSizeEx@8

.globl __imp__InitializeCriticalSectionAndSpinCount@8
__imp__InitializeCriticalSectionAndSpinCount@8: .long _LibInitializeCriticalSectionAndSpinCount@8

.globl __imp__SetFilePointerEx@20
__imp__SetFilePointerEx@20: .long _LibSetFilePointerEx@20
