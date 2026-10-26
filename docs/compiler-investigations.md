[llvm-mingw](https://github.com/mstorsjo/llvm-mingw) (msvcrt variant) should work at least as far back as Windows XP.

The compiler invocation should look something like this:

```
clang++ \
  -target i686-pc-windows-gnu \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
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

The [_WIN32_WINNT and WINVER definitions](https://learn.microsoft.com/en-gb/windows/win32/winprog/using-the-windows-headers) defines which version of Windows you are targeting and excludes newer, incompatible APIs from the Windows headers.

*`NTDDI_VERSION` is also available, but only present from the Vista SDK headers onwards, so should not be used here. See good old [Raymond Chen](https://devblogs.microsoft.com/oldnewthing/20070411-00/?p=27283/) for more information.*

`libc`/`libc++` must be linked statically, as runtime DLLs for MinGW will not be present by default on the system.

Note that these compilation settings depend on the `msvcrt.dll` present on the system. The oldest compatible `msvcrt.dll` is the standardised one present in Windows 95 OSR2/Windows NT 4.0.

Note also that the effective minimum Windows subsystem for bare-bones C with pure Windows API calls is `4.0`, whereas the effective minimum Windows subsystem for C++ is `5.0`. This is due to things like thread-local storage, atomics, mutexes, and structured exceptions, none of which were present and/or stable on Windows 9x.
