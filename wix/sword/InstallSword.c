// Visual effect adding InstallShield-style background gradient and text to an MSI installer.

#define WIN32_LEAN_AND_MEAN
#include <tchar.h>
#include <stdint.h>
#include <windows.h>
#include <shellapi.h>

COLORREF rgbText = 0xffffff;
LPTSTR pchFontName = _T("Times New Roman");
INT iFontSizePt = 24;
LPTSTR pchText = _T("InstallSword Wizard");
BOOL hasBackdrop = TRUE;

void DrawGradient(HWND hWnd, HDC hdc)
{
    RECT rc;
    GetClientRect(hWnd, &rc);

    int i, nBars = (rc.bottom / 8) + 1;
    nBars = min(nBars, 60);

    COLORREF rgbMax = 0xff0000;
    COLORREF prgbBars[60];
    prgbBars[0] = 0;
    prgbBars[nBars-1] = rgbMax;
    for (i = 1; nBars - 1 > i; i += 1)
        prgbBars[i] = RGB(
            GetRValue(rgbMax) * i / (nBars - 2),
            GetGValue(rgbMax) * i / (nBars - 2),
            GetBValue(rgbMax) * i / (nBars - 2)
        );

    SelectObject(hdc, GetStockObject(NULL_PEN));
    int32_t nBarHeight = rc.bottom / nBars;
    for (i = 1; nBars > i; i += 1) {
        HBRUSH hbr = CreateSolidBrush(prgbBars[nBars - i]);
        HGDIOBJ h = SelectObject(hdc, hbr);
        Rectangle(hdc, 0, (i - 1) * nBarHeight, rc.right + 1, nBarHeight * i + 1);
        SelectObject(hdc, h);
        DeleteObject(hbr);
    }
    SelectObject(hdc, GetStockObject(BLACK_BRUSH));
    Rectangle(hdc, 0, (i - 1) * nBarHeight, rc.right + 1, rc.bottom + 1);
}

void DrawTitleText(HWND hWnd, HDC hdc)
{
    static HFONT hFont;
    if (hFont == NULL) {
        LOGFONT lf;
        lf.lfQuality = DRAFT_QUALITY;
        lf.lfOutPrecision = OUT_TT_ONLY_PRECIS;
        lf.lfPitchAndFamily = VARIABLE_PITCH|FF_SWISS;
        lf.lfHeight = (GetDeviceCaps(hdc, LOGPIXELSY) * iFontSizePt) / -72;
        lf.lfClipPrecision = CLIP_DEFAULT_PRECIS;
        lf.lfCharSet = ANSI_CHARSET;
        lf.lfWidth = 0;
        lf.lfWeight = 700;
        if (!hasBackdrop)
            lf.lfWeight = 400;
        lf.lfItalic = 1;
        lf.lfUnderline = 0;
        lf.lfEscapement = 0;
        lf.lfOrientation = 0;
        lf.lfStrikeOut = 0;
        _tcsncpy(lf.lfFaceName, pchFontName, sizeof(lf.lfFaceName) / sizeof(TCHAR));
        hFont = CreateFontIndirect(&lf);
    }

    SelectObject(hdc, hFont);

    POINT ptStart = {5, 5};
    LogicalToPhysicalPoint(hWnd, &ptStart);

    RECT rcText;
    GetClientRect(hWnd, &rcText);
    rcText.left = ptStart.x;
    rcText.top = ptStart.y;
    DrawText(hdc, pchText, -1, &rcText, DT_CALCRECT);

    SetBkMode(hdc, 1);
    if (hasBackdrop)
    {
        SetTextColor(hdc, 0x0000000);
        SetBkColor(hdc, 0);
        RECT rcBackdrop = rcText;
        POINT ptOffset = {4, 4};
        LogicalToPhysicalPoint(hWnd, &ptOffset);
        OffsetRect(&rcBackdrop, ptOffset.x, ptOffset.y);
        DrawText(hdc, pchText, -1, &rcBackdrop,
            DT_EXPANDTABS | DT_NOCLIP | DT_NOPREFIX | DT_WORDBREAK);
    }

    SetTextColor(hdc, rgbText);
    SetBkColor(hdc, 0);
    DrawText(hdc, pchText, -1, &rcText,
        DT_EXPANDTABS | DT_NOCLIP | DT_NOPREFIX | DT_WORDBREAK);
}

LPTSTR pchMatchTitle = _T("");
HWND hBackgroundWnd = NULL;
HWND hChildren[256];
int nChildren = 0;

LRESULT CALLBACK MainWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message) {
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hWnd, &ps);
            DrawGradient(hWnd, hdc);
            DrawTitleText(hWnd, hdc);
            EndPaint(hWnd, &ps);
            return 0;
        }

        case WM_CLOSE:
            DestroyWindow(hWnd);
            return 0;

        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;

        case WM_TIMER:
            if (nChildren == 0)
                PostQuitMessage(0);
            return 0;

        default:
            return DefWindowProc(hWnd, message, wParam, lParam);
    }
}

BOOL CALLBACK CheckAndReparentWindow(HWND hWnd, LPARAM lParam)
{
    TCHAR chValue[256];
    if (!GetClassName(hWnd, chValue, sizeof(chValue) / sizeof(TCHAR)))
        return TRUE;
    if (_tcscmp(chValue, _T("MsiDialogCloseClass")))
        return TRUE;
    if (!GetWindowText(hWnd, chValue, sizeof(chValue) / sizeof(TCHAR)))
        return TRUE;
    if (!_tcsstr(chValue, pchMatchTitle))
        return TRUE;

    SetParent(hWnd, hBackgroundWnd);
    for (int i = 0; i < sizeof(hChildren) / sizeof(HWND); i++) {
        if (hChildren[i] == NULL) {
            hChildren[i] = hWnd;
            nChildren++;
            break;
        }
    }
    return TRUE;
}

void CALLBACK WinEventProc(HWINEVENTHOOK hook, DWORD event, HWND hWnd, LONG idObject, LONG idChild,
                           DWORD dwEventThread, DWORD dwmsEventTime)
{
    if (event == EVENT_OBJECT_CREATE) {
        CheckAndReparentWindow(hWnd, 0);
    }
    if (event == EVENT_OBJECT_DESTROY) {
        for (int i = 0; i < sizeof(hChildren) / sizeof(HWND); i++) {
            if (hChildren[i] == hWnd) {
                hChildren[i] = NULL;
                nChildren--;
                break;
            }
        }
        if (nChildren == 0) {
            SetTimer(hBackgroundWnd, 1, 100, NULL);
        }
    }
}

int WINAPI _tWinMain(
  HINSTANCE hInstance,
  HINSTANCE hPrevInstance,
  LPTSTR    lpCmdLine,
  int       nShowCmd
)
{
    SetProcessDPIAware();

#ifdef _UNICODE
    int argc;
    LPWSTR *argv = CommandLineToArgvW(lpCmdLine, &argc);
#endif

    if (argc == 2) {
        pchMatchTitle = argv[0];
        pchText = argv[1];
    }

    WNDCLASS wc = {0};
    wc.hInstance = hInstance;
    wc.lpszClassName = _T("InstallSword_Main");
    wc.lpfnWndProc = MainWndProc;
    wc.hbrBackground = (HBRUSH)(COLOR_3DFACE + 1);
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    if (!RegisterClass(&wc))
        return FALSE;

    hBackgroundWnd = CreateWindowEx(WS_EX_NOACTIVATE|WS_EX_TOPMOST, wc.lpszClassName, 0,
        WS_POPUP|WS_CLIPCHILDREN|WS_CLIPSIBLINGS|WS_GROUP,
        0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN),
        NULL, NULL, NULL, 0);
    if (!hBackgroundWnd)
        return FALSE;

    ShowWindow(hBackgroundWnd, SW_SHOW);
    EnumDesktopWindows(NULL, CheckAndReparentWindow, 0);
    SetWinEventHook(EVENT_OBJECT_CREATE, EVENT_OBJECT_DESTROY,
        NULL, WinEventProc, 0, 0, WINEVENT_OUTOFCONTEXT|WINEVENT_SKIPOWNPROCESS);
    if (nChildren == 0)
        return 0;

    MSG msg;
    while (GetMessage(&msg, 0, 0, 0))
        DispatchMessage(&msg);
    return 0;
}
