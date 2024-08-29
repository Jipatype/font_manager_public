import 'package:font_manager/font_manager.dart'; // Custom package for font management
import 'package:font_manager/file_manager.dart'; // Custom package for file management
import 'dart:convert'; // For JSON encoding and decoding
import 'dart:io'; // For interacting with the file system and platform-specific functionalities

void main(List<String> args) async {
  // Check if there are at least two command-line arguments
  if (args.length < 2) {
    final Uri scriptUri = Platform.script;
    final String scriptPath = scriptUri.toFilePath();
    final String scriptName = scriptPath.split(Platform.pathSeparator).last;

    // Print the usage pattern if arguments are insufficient
    print('Please provide follow this pattern : $scriptName <command> <fontPath>');
    return;
  }

  // Check if the '--register' command is given to register a font
  if (args[0] == '--register') {
    // Handle registration for macOS
    if (Platform.isMacOS) {
      registerFont(args[1]);
    }

    // Handle registration for Windows
    if (Platform.isWindows) {
      final int result = registerFontWin32(args[1]);
      
      // Refresh the font cache on Windows if registration was successful
      if (result != 0) {
        refreshFontWin32();
      }
    }
    return;
  }

  // Check if the '--unregister' command is given to unregister a font
  if (args[0] == '--unregister') {
    // Handle unregistration for macOS
    if (Platform.isMacOS) {
      unregisterFont(args[1]);
    }

    // Handle unregistration for Windows
    if (Platform.isWindows) {
      final int result = unregisterFontWin32(args[1]);

      // Refresh the font cache on Windows if unregistration was successful
      if (result != 0) {
        refreshFontWin32();
      }
    }
    return;
  }

  // Check if the '--unregister-all' command is given to unregister all fonts in a directory
  if (args[0] == '--unregister-all') {
    // Get list of all file paths in the specified directory
    final List<String> fontPaths = listPathOfFilesInDirectory(args[1]);
    final List<Future<int>> task = [];

    // Create tasks to unregister each font based on the platform
    for (final String fontPath in fontPaths) {
      if (Platform.isMacOS) {
        task.add(Future(() => unregisterFont(fontPath)));
      }
      if (Platform.isWindows) {
        task.add(Future(() => unregisterFontWin32(fontPath)));
      }
    }

    // Await all tasks and handle results
    final result = await Future.wait(task);

    // Refresh the font cache on Windows if any unregistration was successful
    if (Platform.isWindows && task.isNotEmpty) {
      if (result.any((value) => value != 0)) {
        refreshFontWin32();
      }
    }
    return;
  }

  // Check if the '--register-json' or '--unregister-json' command is given for JSON-based font management
  if (args[0] == '--register-json' || args[0] == '--unregister-json') {
    // Open and read the JSON file specified by the argument
    final File file = File(args[1]);
    final String contents = await file.readAsString();
    
    // Parse JSON contents to get font paths
    final Map<String, dynamic> jsonData = jsonDecode(contents);
    final List<dynamic> fontPaths = jsonData['fontPaths'];
    final List<Future<int>> task = [];

    // Create tasks to register or unregister fonts based on the JSON content
    for (final String fontPath in fontPaths) {
      if (Platform.isMacOS) {
        if (args[0] == '--register-json') {
          task.add(Future(() => registerFont(fontPath)));
        }
        if (args[0] == '--unregister-json') {
          task.add(Future(() => unregisterFont(fontPath)));
        }
      }
      if (Platform.isWindows) {
        if (args[0] == '--register-json') {
          task.add(Future(() => registerFontWin32(fontPath)));
        }
        if (args[0] == '--unregister-json') {
          task.add(Future(() => unregisterFontWin32(fontPath)));
        }
      }
    }

    // Await all tasks and write results back to the JSON file
    final List<int> result = await Future.wait(task);
    jsonData.addAll({'result': result});
    await file.writeAsString(jsonEncode(jsonData));

    // Refresh the font cache on Windows if any task was successful
    if (Platform.isWindows && task.isNotEmpty) {
      if (result.any((value) => value != 0)) {
        refreshFontWin32();
      }
    }
    return;
  }
}
