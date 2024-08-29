import 'dart:io';
import 'package:path/path.dart' as path;

List<String> listFilesInDirectory(String directoryPath) {
  try {
    final Directory directory = Directory(directoryPath);
    final List<FileSystemEntity> files = directory.listSync();
    final List<String> fileList = files
        .where((FileSystemEntity file) => file is File)
        .map((FileSystemEntity file) => path.basename(file.path))
        .toList();
    return fileList;
  } catch (e) {
    print('Error reading directory: $e');
    return [];
  }
}

List<String> listPathOfFilesInDirectory(String directoryPath) {
  try {
    final Directory directory = Directory(directoryPath);
    final List<FileSystemEntity> files = directory.listSync();
    final List<String> fileList = files
        .where((FileSystemEntity file) => file is File)
        .map((FileSystemEntity file) => file.path)
        .toList();
    return fileList;
  } catch (e) {
    print('Error reading directory: $e');
    return [];
  }
}

List<String> listDirectoriesInDirectory(String directoryPath) {
  try {
    final Directory directory = Directory(directoryPath);
    final List<FileSystemEntity> entities = directory.listSync();
    final List<String> directories = entities
        .where((FileSystemEntity entity) => entity is Directory)
        .map((FileSystemEntity dir) => path.basename(dir.path))
        .toList();
    return directories;
  } catch (e) {
    print('Error reading directory: $e');
    return [];
  }
}

List<String> listPathOfDirectoriesInDirectory(String directoryPath) {
  try {
    final Directory directory = Directory(directoryPath);
    final List<FileSystemEntity> entities = directory.listSync();
    final List<String> directories = entities
        .where((FileSystemEntity entity) => entity is Directory)
        .map((FileSystemEntity dir) => dir.path)
        .toList();
    return directories;
  } catch (e) {
    print('Error reading directory: $e');
    return [];
  }
}
