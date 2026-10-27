## llvm-mingw

[llvm-mingw](https://github.com/mstorsjo/llvm-mingw) (msvcrt variant) should work at least as far back as Windows XP.

The compiler invocation should look something like this:

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

The [subsystem option](https://learn.microsoft.com/en-us/cpp/build/reference/subsystem-specify-subsystem?view=msvc-170) should specify `windows` for a UI application, or `console` for a console application. The version specified can be:

* `5.1` for Windows XP 32-bit
* `5.2` for Windows XP 64-bit or Windows Server 2003
* `4.0` for Windows 95 and Windows NT 4.0

The [_WIN32_WINNT and WINVER definitions](https://learn.microsoft.com/en-gb/windows/win32/winprog/using-the-windows-headers) defines which version of Windows you are targeting and excludes newer, incompatible APIs from the Windows headers. `NTDDI_VERSION` is also available, and is used from Vista onwards (see good old [Raymond Chen](https://devblogs.microsoft.com/oldnewthing/20070411-00/?p=27283/) for more information); although we're not so concerned with that, compilers like llvm-mingw contain comprehensive Windows headers for all versions of Windows, and so this definition should also be set to be consistent with the others.

`libc`/`libc++` must be linked statically, as runtime DLLs for MinGW will not be present by default on the system.

Note that these compilation settings depend on the `msvcrt.dll` present on the system. The oldest compatible `msvcrt.dll` is the standardised one present in Windows 95 OSR2/Windows NT 4.0.

Note also that the effective minimum Windows subsystem for bare-bones C with pure Windows API calls is `4.0`, whereas the effective minimum Windows subsystem for C++ is `5.0`. This is due to things like thread-local storage, atomics, mutexes, and structured exceptions, none of which were present and/or stable on Windows 9x.

## llvm-mingw "Hello World" Experiments

My first steps of investigation were to compile an idiomatic "Hello World" program in both C and C++, and see where it was able to run.

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
