/*
 * EnlyzeWinCompatLib - Let Clang-compiled applications run on older Windows versions
 * Copyright (c) 2021 Colin Finck, ENLYZE GmbH <c.finck@enlyze.com>
 * SPDX-License-Identifier: MIT
*/

/* The original MASM assembly: */
/*
.model flat

EXTERN _LibDecodePointer@4 : PROC
EXTERN _LibEncodePointer@4 : PROC

.data

PUBLIC __imp__DecodePointer@4
__imp__DecodePointer@4 dd _LibDecodePointer@4

PUBLIC __imp__EncodePointer@4
__imp__EncodePointer@4 dd _LibEncodePointer@4

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

.extern _LibDecodePointer@4
.extern _LibEncodePointer@4

.data

.globl __imp__DecodePointer@4
__imp__DecodePointer@4: .long _LibDecodePointer@4

.globl __imp__EncodePointer@4
__imp__EncodePointer@4: .long _LibEncodePointer@4
