import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Define the function signatures
typedef CFURLCreateWithBytesNative = Pointer<Void> Function(
    Pointer<Void> allocator,
    Pointer<Uint8> URLBytes,
    IntPtr length,
    Int32 encoding,
    Pointer<Void> baseURL);

typedef CFURLCreateWithBytesDart = Pointer<Void> Function(
    Pointer<Void> allocator,
    Pointer<Uint8> URLBytes,
    int length,
    int encoding,
    Pointer<Void> baseURL);

typedef CTFontManagerRegisterFontsForURLNative = Int32 Function(
    Pointer<Void> fontURL, Int32 scope, Pointer<Pointer<Void>> error);

typedef CTFontManagerRegisterFontsForURLDart = int Function(
    Pointer<Void> fontURL, int scope, Pointer<Pointer<Void>> error);

typedef CTFontManagerUnregisterFontsForURLNative = Int32 Function(
    Pointer<Void> fontURL, Int32 scope, Pointer<Pointer<Void>> error);

typedef CTFontManagerUnregisterFontsForURLDart = int Function(
    Pointer<Void> fontURL, int scope, Pointer<Pointer<Void>> error);

int registerFont(String fontPath) {
  final coreFoundation = DynamicLibrary.open(
      '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation');
  final coreText = DynamicLibrary.open(
      '/System/Library/Frameworks/CoreText.framework/CoreText');
  final cfUrlCreate = coreFoundation.lookupFunction<CFURLCreateWithBytesNative,
      CFURLCreateWithBytesDart>('CFURLCreateWithBytes');
  final registerFonts = coreText.lookupFunction<
      CTFontManagerRegisterFontsForURLNative,
      CTFontManagerRegisterFontsForURLDart>('CTFontManagerRegisterFontsForURL');
  final urlString = fontPath.toNativeUtf8();
  final cfUrl = cfUrlCreate(
      nullptr, urlString.cast<Uint8>(), fontPath.length, 0x08000100, nullptr);
  final error = calloc<Pointer<Void>>();
  final result = registerFonts(cfUrl, 3, error);
  if (result != 0) {
    print('Font registered successfully: $fontPath');
  } else {
    print('Failed to register font: $fontPath');
  }
  calloc.free(urlString);
  calloc.free(error);
  return result;
}

int unregisterFont(String fontPath) {
  final coreFoundation = DynamicLibrary.open(
      '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation');
  final coreText = DynamicLibrary.open(
      '/System/Library/Frameworks/CoreText.framework/CoreText');
  final cfUrlCreate = coreFoundation.lookupFunction<CFURLCreateWithBytesNative,
      CFURLCreateWithBytesDart>('CFURLCreateWithBytes');
  final unregisterFonts = coreText.lookupFunction<
          CTFontManagerUnregisterFontsForURLNative,
          CTFontManagerUnregisterFontsForURLDart>(
      'CTFontManagerUnregisterFontsForURL');
  final urlString = fontPath.toNativeUtf8();
  final cfUrl = cfUrlCreate(
      nullptr, urlString.cast<Uint8>(), fontPath.length, 0x08000100, nullptr);
  final error = calloc<Pointer<Void>>();
  final result = unregisterFonts(cfUrl, 3, error);
  if (result != 0) {
    print('Font unregistered successfully: $fontPath');
  } else {
    print('Failed to unregister font: $fontPath');
  }
  calloc.free(urlString);
  calloc.free(error);
  return result;
}

typedef AddFontResourceWNative = Int32 Function(Pointer<Utf16> lpszFilename);
typedef AddFontResourceWDart = int Function(Pointer<Utf16> lpszFilename);

typedef RemoveFontResourceWNative = Int32 Function(Pointer<Utf16> lpszFilename);
typedef RemoveFontResourceWDart = int Function(Pointer<Utf16> lpszFilename);

typedef PostMessageNative = Int32 Function(
    IntPtr hWnd, Uint32 msg, IntPtr wParam, IntPtr lParam);
typedef PostMessageDart = int Function(
    int hWnd, int msg, int wParam, int lParam);

void refreshFontWin32() {
  final user32 = DynamicLibrary.open('user32.dll');
  final postMessage =
      user32.lookupFunction<PostMessageNative, PostMessageDart>('PostMessageW');
  const HWND_BROADCAST = 0xffff;
  const WM_FONTCHANGE = 0x001D;
  postMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
}

int registerFontWin32(String fontPath) {
  final gdi32 = DynamicLibrary.open('gdi32.dll');
  final addFontResourceW =
      gdi32.lookupFunction<AddFontResourceWNative, AddFontResourceWDart>(
          'AddFontResourceW');
  final fontPathUtf16 = fontPath.toNativeUtf16();
  final result = addFontResourceW(fontPathUtf16);
  if (result != 0) {
    print('Font registered successfully: $fontPath');
  } else {
    print('Failed to register font: $fontPath');
  }
  calloc.free(fontPathUtf16);
  return result;
}

int unregisterFontWin32(String fontPath) {
  final gdi32 = DynamicLibrary.open('gdi32.dll');
  final removeFontResourceW =
      gdi32.lookupFunction<RemoveFontResourceWNative, RemoveFontResourceWDart>(
          'RemoveFontResourceW');
  final fontPathUtf16 = fontPath.toNativeUtf16();
  final result = removeFontResourceW(fontPathUtf16);
  if (result != 0) {
    print('Font unregistered successfully: $fontPath');
  } else {
    print('Failed to unregister font: $fontPath');
  }
  calloc.free(fontPathUtf16);
  return result;
}
