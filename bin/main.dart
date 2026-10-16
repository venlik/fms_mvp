// bin/main.dart
//
// Interactive REPL over the finance management system.
//
// Usage:
//   dart run bin/main.dart
//
// Exit with `exit`, `quit`, or Ctrl+D. Type `help` for commands.

import 'dart:io';

import 'package:cli_repl/cli_repl.dart';
import 'package:finance_management_system/backend/services/bootstrap.dart';
import 'package:finance_management_system/frontend/cli/platform/cli_logo_store.dart';
import 'package:finance_management_system/frontend/cli/platform/cli_storage.dart';

import 'repl/commands.dart';

Future<void> main() async {
  // Paths for the dev-mode data store. These live next to the project
  // and are ignored by git.
  const env = {
    'APP_DIR': 'z_store.dbg/.app',
    'DOCS_DIR': 'z_store.dbg/.docs',
    'DOWNLOAD_DIR': 'z_store.dbg/.downloads',
  };

  // Build the storage adapter. If any required directory is missing
  // or invalid, CLIStorage.fromEnvironment throws StateError and we
  // abort before doing anything else.
  final CLIStorage storage;
  try {
    storage = CLIStorage.fromEnvironment(env);
  } on StateError catch (e) {
    stderr.writeln('cannot start: $e');
    exitCode = 1;
    return;
  }

  // Build the full service graph. Same bootStrapServices used by the
  // Flutter app — the CLI and the GUI share every code path below this
  // line.
  final services = await bootStrapServices(storage, const CLILogoStore());

  // Greeting. Printed once, before the first prompt.
  stdout
    ..writeln('finance management — interactive')
    ..writeln('type "help" for commands, "exit" to quit.')
    ..writeln();

  // `Repl.run()` yields complete lines as the user types them, and
  // handles all the terminal editing itself: arrow keys for history,
  // Home/End, Ctrl+A/E/U/K/Y, and so on. The default validator treats
  // every newline as a complete statement, which is what we want —
  // every command is one line.
  //
  // prompt: the string shown before the cursor.
  // maxHistory: in-memory history buffer size. 200 entries is plenty
  //   for a session and disappears when the process exits.
  final repl = Repl(prompt: '> ', maxHistory: 200);

  // `run()` returns a synchronous Iterable<String>. Each iteration
  // blocks until the user presses Enter. When stdin closes (Ctrl+D on
  // an empty line), the iterable completes and the loop exits.
  for (final line in repl.run()) {
    final trimmed = line.trim();

    // Skip blank lines without dispatching.
    if (trimmed.isEmpty) continue;

    // Two ways to leave. Ctrl+D is handled by the Repl itself.
    if (trimmed == 'exit' || trimmed == 'quit') break;

    // Dispatch to the command table. Any exception from a command
    // prints a short marker and returns to the prompt — the session
    // keeps running.
    try {
      await dispatch(trimmed, services);
    } catch (e) {
      stdout.writeln('! $e');
    }
  }

  stdout.writeln('bye.');
}