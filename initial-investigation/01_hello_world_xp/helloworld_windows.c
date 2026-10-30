#include <windows.h>
#include <tchar.h>

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nCmdShow)
{
	MessageBoxW(NULL, L"Hello world, from C", L"Hello world!", MB_OK | MB_ICONINFORMATION);
	return 0;
}
