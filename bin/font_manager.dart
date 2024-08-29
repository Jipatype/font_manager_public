import 'package:font_manager/font_manager.dart';
import 'package:font_manager/file_manager.dart';
import 'dart:convert';
import 'dart:io';
void main(List<String> args) async {
  if (args.length < 2) {
    final Uri scriptUri = Platform.script;
    final String scriptPath = scriptUri.toFilePath();
    final String scriptName = scriptPath.split(Platform.pathSeparator).last;
    print('Please provide follow this pattern : $scriptName <command> <fontPath>');
    return;
  }
  if (args[0] == '--register') {
    if (Platform.isMacOS) {
      registerFont(args[1]);
    }
    if (Platform.isWindows) {
      final int result = registerFontWin32(args[1]);
      if (result != 0) {
        refreshFontWin32();
      }
    }
    return;
  }
  if (args[0] == '--unregister') {
    if (Platform.isMacOS) {
      unregisterFont(args[1]);
    }
    if (Platform.isWindows) {
      final int result = unregisterFontWin32(args[1]);
      if (result != 0) {
        refreshFontWin32();
      }
    }
    return;
  }
  if (args[0] == '--unregister-all') {
    final List<String> fontPaths = listPathOfFilesInDirectory(args[1]);
    final List<Future<int>> task = [];
    for (final String fontPath in fontPaths) {
      if (Platform.isMacOS) {
        task.add(Future(() => unregisterFont(fontPath)));
      }
      if (Platform.isWindows) {
        task.add(Future(() => unregisterFontWin32(fontPath)));
      }
    }
    final result = await Future.wait(task);
    if (Platform.isWindows && task.isNotEmpty) {
      if (result.any((value) => value != 0)) {
        refreshFontWin32();
      }
    }
    return;
  }
  if(args[0] == '--register-json' || args[0] == '--unregister-json') {
    final File file = File(args[1]);
    final String contents = await file.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(contents);
    final List<dynamic> fontPaths = jsonData['fontPaths'];
    final List<Future<int>> task = [];
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
    final List<int> result = await Future.wait(task);
    jsonData.addAll({ 'result' : result });
    await file.writeAsString(jsonEncode(jsonData));
    if (Platform.isWindows && task.isNotEmpty) {
      if (result.any((value) => value != 0)) {
        refreshFontWin32();
      }
    }
    return;
  }
}