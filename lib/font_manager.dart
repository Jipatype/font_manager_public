import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Define the function signatures for interacting with native libraries

// Signature for the CFURLCreateWithBytes function in CoreFoundation (native)
typedef CFURLCreateWithBytesNative = Pointer<Void> Function(
    Pointer<Void> allocator,
    Pointer<Uint8> URLBytes,
    IntPtr length,
    Int32 encoding,
    Pointer<Void> baseURL);

// Signature for the CFURLCreateWithBytes function in Dart
typedef CFURLCreateWithBytesDart = Pointer<Void> Function(
    Pointer<Void> allocator,
    Pointer<Uint8> URLBytes,
    int length,
    int encoding,
    Pointer<Void> baseURL);

// Signature for the CTFontManagerRegisterFontsForURL function in CoreText (native)
typedef CTFontManagerRegisterFontsForURLNative = Int32 Function(
    Pointer<Void> fontURL, Int32 scope, Pointer<Pointer<Void>> error);

// Signature for the CTFontManagerRegisterFontsForURL function in Dart
typedef CTFontManagerRegisterFontsForURLDart = int Function(
    Pointer<Void> fontURL, int scope, Pointer<Pointer<Void>> error);

// Signature for the CTFontManagerUnregisterFontsForURL function in CoreText (native)
typedef CTFontManagerUnregisterFontsForURLNative = Int32 Function(
    Pointer<Void> fontURL, Int32 scope, Pointer<Pointer<Void>> error);

// Signature for the CTFontManagerUnregisterFontsForURL function in Dart
typedef CTFontManagerUnregisterFontsForURLDart = int Function(
    Pointer<Void> fontURL, int scope, Pointer<Pointer<Void>> error);

// Function to register a font on macOS using the CoreFoundation and CoreText frameworks
int registerFont(String fontPath) {
  // Load the CoreFoundation and CoreText dynamic libraries
  final coreFoundation = DynamicLibrary.open(
      '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation');
  final coreText = DynamicLibrary.open(
      '/System/Library/Frameworks/CoreText.framework/CoreText');

  // Lookup the CFURLCreateWithBytes function
  final cfUrlCreate = coreFoundation.lookupFunction<CFURLCreateWithBytesNative,
      CFURLCreateWithBytesDart>('CFURLCreateWithBytes');

  // Lookup the CTFontManagerRegisterFontsForURL function
  final registerFonts = coreText.lookupFunction<
      CTFontManagerRegisterFontsForURLNative,
      CTFontManagerRegisterFontsForURLDart>('CTFontManagerRegisterFontsForURL');

  // Convert the font path to a native UTF-8 string
  final urlString = fontPath.toNativeUtf8();

  // Create a CFURL object using the font path
  final cfUrl = cfUrlCreate(
      nullptr, urlString.cast<Uint8>(), fontPath.length, 0x08000100, nullptr);

  // Allocate memory for error pointer
  final error = calloc<Pointer<Void>>();

  // Register the font using the CFURL object
  final result = registerFonts(cfUrl, 3, error);

  // Check the result and print the appropriate message
  if (result != 0) {
    print('Font registered successfully: $fontPath');
  } else {
    print('Failed to register font: $fontPath');
  }

  // Free allocated memory
  calloc.free(urlString);
  calloc.free(error);

  return result;
}

// Function to unregister a font on macOS using the CoreFoundation and CoreText frameworks
int unregisterFont(String fontPath) {
  // Load the CoreFoundation and CoreText dynamic libraries
  final coreFoundation = DynamicLibrary.open(
      '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation');
  final coreText = DynamicLibrary.open(
      '/System/Library/Frameworks/CoreText.framework/CoreText');

  // Lookup the CFURLCreateWithBytes function
  final cfUrlCreate = coreFoundation.lookupFunction<CFURLCreateWithBytesNative,
      CFURLCreateWithBytesDart>('CFURLCreateWithBytes');

  // Lookup the CTFontManagerUnregisterFontsForURL function
  final unregisterFonts = coreText.lookupFunction<
          CTFontManagerUnregisterFontsForURLNative,
          CTFontManagerUnregisterFontsForURLDart>(
      'CTFontManagerUnregisterFontsForURL');

  // Convert the font path to a native UTF-8 string
  final urlString = fontPath.toNativeUtf8();

  // Create a CFURL object using the font path
  final cfUrl = cfUrlCreate(
      nullptr, urlString.cast<Uint8>(), fontPath.length, 0x08000100, nullptr);

  // Allocate memory for error pointer
  final error = calloc<Pointer<Void>>();

  // Unregister the font using the CFURL object
  final result = unregisterFonts(cfUrl, 3, error);

  // Check the result and print the appropriate message
  if (result != 0) {
    print('Font unregistered successfully: $fontPath');
  } else {
    print('Failed to unregister font: $fontPath');
  }

  // Free allocated memory
  calloc.free(urlString);
  calloc.free(error);

  return result;
}

// Define function signatures for Windows API functions

// Signature for AddFontResourceW function (native)
typedef AddFontResourceWNative = Int32 Function(Pointer<Utf16> lpszFilename);
// Signature for AddFontResourceW function (Dart)
typedef AddFontResourceWDart = int Function(Pointer<Utf16> lpszFilename);

// Signature for RemoveFontResourceW function (native)
typedef RemoveFontResourceWNative = Int32 Function(Pointer<Utf16> lpszFilename);
// Signature for RemoveFontResourceW function (Dart)
typedef RemoveFontResourceWDart = int Function(Pointer<Utf16> lpszFilename);

// Signature for PostMessage function (native)
typedef PostMessageNative = Int32 Function(
    IntPtr hWnd, Uint32 msg, IntPtr wParam, IntPtr lParam);
// Signature for PostMessage function (Dart)
typedef PostMessageDart = int Function(
    int hWnd, int msg, int wParam, int lParam);

// Function to refresh the font cache in Windows
void refreshFontWin32() {
  // Load the user32 dynamic library
  final user32 = DynamicLibrary.open('user32.dll');

  // Lookup the PostMessageW function
  final postMessage =
      user32.lookupFunction<PostMessageNative, PostMessageDart>('PostMessageW');

  // Constants for broadcasting a font change message
  const HWND_BROADCAST = 0xffff;
  const WM_FONTCHANGE = 0x001D;

  // Broadcast a message to refresh the font cache
  postMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
}

// Function to register a font on Windows
int registerFontWin32(String fontPath) {
  // Load the gdi32 dynamic library
  final gdi32 = DynamicLibrary.open('gdi32.dll');

  // Lookup the AddFontResourceW function
  final addFontResourceW =
      gdi32.lookupFunction<AddFontResourceWNative, AddFontResourceWDart>(
          'AddFontResourceW');

  // Convert the font path to a native UTF-16 string
  final fontPathUtf16 = fontPath.toNativeUtf16();

  // Register the font using the font path
  final result = addFontResourceW(fontPathUtf16);

  // Check the result and print the appropriate message
  if (result != 0) {
    print('Font registered successfully: $fontPath');
  } else {
    print('Failed to register font: $fontPath');
  }

  // Free allocated memory
  calloc.free(fontPathUtf16);

  return result;
}

// Function to unregister a font on Windows
int unregisterFontWin32(String fontPath) {
  // Load the gdi32 dynamic library
  final gdi32 = DynamicLibrary.open('gdi32.dll');

  // Lookup the RemoveFontResourceW function
  final removeFontResourceW =
      gdi32.lookupFunction<RemoveFontResourceWNative, RemoveFontResourceWDart>(
          'RemoveFontResourceW');

  // Convert the font path to a native UTF-16 string
  final fontPathUtf16 = fontPath.toNativeUtf16();

  // Unregister the font using the font path
  final result = removeFontResourceW(fontPathUtf16);

  // Check the result and print the appropriate message
  if (result != 0) {
    print('Font unregistered successfully: $fontPath');
  } else {
    print('Failed to unregister font: $fontPath');
  }

  // Free allocated memory
  calloc.free(fontPathUtf16);

  return result;
}
