## llvm-mingw

[llvm-mingw](https://github.com/mstorsjo/llvm-mingw) (msvcrt variant) should work at least as far back as Windows XP.

A working compiler invocation looks something like:

```
clang++ \
  -target i686-pc-windows-gnu \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  <files> \
  -o <output> \
  -Wl,--subsystem,windows:5.1 \
  -stdlib=libc++ \
  -static
```

The [target option](https://clang.llvm.org/docs/CrossCompilation.html#general-cross-compilation-options-in-clang) here means:

* `i686`: 32-bit x86 processor
* `pc`: Vendor (ie. Microsoft PC)
* `windows`: Windows platform
* `gnu`: GNU environment

The [_WIN32_WINNT and WINVER definitions](https://learn.microsoft.com/en-gb/windows/win32/winprog/using-the-windows-headers) define which version of Windows you are targeting and excludes newer, incompatible APIs from the Windows headers. `NTDDI_VERSION` is also available, and is used from Vista onwards (see good old [Raymond Chen](https://devblogs.microsoft.com/oldnewthing/20070411-00/?p=27283/) for more information); although we're not so concerned with that, compilers like llvm-mingw contain comprehensive Windows headers for all versions of Windows, and so this definition should also be set to be consistent with the others.

A value of `0x0501` (or of `0x05010000` for `NTDDI_VERSION`) indicates Windows XP (with no service packs).

The [subsystem option](https://learn.microsoft.com/en-us/cpp/build/reference/subsystem-specify-subsystem?view=msvc-170) should specify `windows` for a UI application, or `console` for a console application. The version specified can be:

* `5.1` for Windows XP 32-bit
* `5.2` for Windows XP 64-bit or Windows Server 2003
* `4.0` for Windows 95 and Windows NT 4.0

`libc`/`libc++` must be linked statically, as runtime DLLs for MinGW will not be present by default on the system.

Note that these compilation settings depend on the `msvcrt.dll` present on the system. The oldest compatible `msvcrt.dll` is the standardised one present in Windows 95 OSR2/Windows NT 4.0.

Note also that the effective minimum Windows subsystem for bare-bones C with pure Windows API calls is `4.0`, whereas the effective minimum Windows subsystem for C++ is `5.0`. This is due to things like thread-local storage, atomics, mutexes, and structured exceptions, none of which were present and/or stable on Windows 9x.

## llvm-mingw "Hello World" Experiments

Based on this info alone, my first steps of investigation were to compile an idiomatic "Hello World" program in both C and C++, and see where it was able to run.

### C

```c
#include <stdio.h>

int main(int argc, char** argv)
{
	(void)argc;
	(void)argv;

	printf("Hello world!\n");
	return 0;
}
```

The code above compiles and runs correctly on Windows XP with:

```
clang \
  -target i686-pc-windows-gnu \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  -DWIN32_LEAN_AND_MEAN \
  testapp.c \
  -o tst_c.exe \
  -Wl,--subsystem,console:5.1 \
  -static
```

### C++

```cpp
#include <iostream>

int main(int, char**)
{
	std::cout << "Hello world!" << std::endl;
	return 0;
}
```

The code above compiles correctly with:

```
clang++ \
  -target i686-pc-windows-gnu \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  -D__MSVCRT_VERSION__=0x0700 \
  -DWIN32_LEAN_AND_MEAN \
  -fno-exceptions \
  testapp.cpp \
  -o tst_cpp.exe \
  -Wl,--subsystem,console:5.1 \
  -stdlib=libc++ \
  -static
```

However, it does not run correctly on Windows XP. It gives the error:

```
The procedure entry point _iswalpha_l could not be located in the dynamic link library msvcrt.dll.
```

This appears to be because the C++ code is locale-aware. `iswalpha_l` is part of `MSVCRT80.dll` (MSVC 2005), but that's not what we're relying on in this case. The issue is that LLVM's libc++ depends on the system-level `msvcrt.dll`, and assumes that `iswalpha_l` and other such functions are available.

As a consequence, we can't simply target Windows XP with C++ code from llvm-mingw. However, we can use [llvm-mingw-xp](https://github.com/mon/llvm-mingw-xp), which provides a libc++ that is patched for XP compatibility. With this version of the compiler, the above invocation does build a program that runs correctly.

## An Alternative Approach: libnt5/EnlyzeWinCompatLib

Based on Colin Finck's two blog posts on the topics of how to compile modern C/C++ for [Windows 200](https://colinfinck.de/posts/modern-visual-studio-meets-ancient-windows) and [Windows NT 4.0](https://colinfinck.de/posts/targeting-25-years-of-windows-with-visual-studio-2019/) respectively, there is a different approach we could use both to reach back as far as Windows NT 4.0, and to use the latest version of llvm-mingw. I've been trying to get around the different components involved in these two posts, but I think it boils down to this:

* [EnlyzeWinCompatLib](https://github.com/enlyze/EnlyzeWinCompatLib), a compatibility library created by Colin Finck himself, that provides all the functions missing in older versions of `msvcrt.dll`.
* libc++ from LLVM, used because it goes along with Clang, and avoids some legacy bugs in the Microsoft CRT.
* winpthreads, used to supplement libc++ because the concurrency code otherwise only supports Windows 7.

Additionally, the [libnt5](https://github.com/Alex313031/libnt5) fork of EnlyzeWinCompatLib appears to add in some extra calls missing from the original, so it may be worth integrating these as well.

I _think_ that the custom libc++/winpthreads projects used in EnlyzeWinCompatLib are because Colin wanted to be able to build everything directly in Visual Studio. I have no such limitation (CMake is more portable anyway), so I hope we can just pull in the LLVM source tree, set it up to cross-compile as per what llvm-mingw does, and configure it to use winpthreads.
