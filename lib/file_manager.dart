import 'dart:io';
import 'package:path/path.dart' as path;

// Function to list all files in a given directory and return their names
List<String> listFilesInDirectory(String directoryPath) {
  try {
    // Create a Directory object from the provided directory path
    final Directory directory = Directory(directoryPath);
    
    // List all entities (files and directories) in the directory
    final List<FileSystemEntity> files = directory.listSync();
    
    // Filter out files and map them to their base names
    final List<String> fileList = files
        .where((FileSystemEntity file) => file is File)
        .map((FileSystemEntity file) => path.basename(file.path))
        .toList();
    
    return fileList;
  } catch (e) {
    // Handle errors and print a message
    print('Error reading directory: $e');
    return [];
  }
}

// Function to list all files in a given directory and return their full paths
List<String> listPathOfFilesInDirectory(String directoryPath) {
  try {
    // Create a Directory object from the provided directory path
    final Directory directory = Directory(directoryPath);
    
    // List all entities (files and directories) in the directory
    final List<FileSystemEntity> files = directory.listSync();
    
    // Filter out files and map them to their full paths
    final List<String> fileList = files
        .where((FileSystemEntity file) => file is File)
        .map((FileSystemEntity file) => file.path)
        .toList();
    
    return fileList;
  } catch (e) {
    // Handle errors and print a message
    print('Error reading directory: $e');
    return [];
  }
}

// Function to list all subdirectories in a given directory and return their names
List<String> listDirectoriesInDirectory(String directoryPath) {
  try {
    // Create a Directory object from the provided directory path
    final Directory directory = Directory(directoryPath);
    
    // List all entities (files and directories) in the directory
    final List<FileSystemEntity> entities = directory.listSync();
    
    // Filter out directories and map them to their base names
    final List<String> directories = entities
        .where((FileSystemEntity entity) => entity is Directory)
        .map((FileSystemEntity dir) => path.basename(dir.path))
        .toList();
    
    return directories;
  } catch (e) {
    // Handle errors and print a message
    print('Error reading directory: $e');
    return [];
  }
}

// Function to list all subdirectories in a given directory and return their full paths
List<String> listPathOfDirectoriesInDirectory(String directoryPath) {
  try {
    // Create a Directory object from the provided directory path
    final Directory directory = Directory(directoryPath);
    
    // List all entities (files and directories) in the directory
    final List<FileSystemEntity> entities = directory.listSync();
    
    // Filter out directories and map them to their full paths
    final List<String> directories = entities
        .where((FileSystemEntity entity) => entity is Directory)
        .map((FileSystemEntity dir) => dir.path)
        .toList();
    
    return directories;
  } catch (e) {
    // Handle errors and print a message
    print('Error reading directory: $e');
    return [];
  }
}
