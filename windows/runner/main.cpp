
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM for plugins and Windows APIs.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);

  // Use a default size for the Pace window.
  constexpr int window_width = 1280;
  constexpr int window_height = 720;

  // Get the primary monitor's usable area, excluding the taskbar.
  RECT work_area{};
  if (!SystemParametersInfoW(SPI_GETWORKAREA, 0, &work_area, 0)) {
    work_area = {0, 0, 1280, 720};
  }

  // Calculate an initial position within the usable area.
  int x = work_area.left +
          ((work_area.right - work_area.left) - window_width) / 2;
  int y = work_area.top +
          ((work_area.bottom - work_area.top) - window_height) / 2;

  // Keep the window's initial position inside the work area.
  if (x < work_area.left) {
    x = work_area.left;
  }
  if (y < work_area.top) {
    y = work_area.top;
  }

  Win32Window::Point origin(x, y);
  Win32Window::Size size(window_width, window_height);

  if (!window.Create(L"Pace", origin, size)) {
    ::CoUninitialize();
    return EXIT_FAILURE;
  }

  window.SetQuitOnClose(true);

  // Standard Windows message loop.
  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
