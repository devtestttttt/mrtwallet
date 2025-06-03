// ignore_for_file: avoid_print

class Logg {
  static bool get isDebug => true;

  static void log(Object? text) {
    print('\x1B[33m$text\x1B[0m');
  }

  static void error(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  static void webview(String text) {
    print(text);
  }

  static T def<T>(T Function() n, String text) {
    final stopWatch = Stopwatch()..start();
    final r = n();
    stopWatch.stop();
    print("$text: ${stopWatch.elapsedMilliseconds}");
    return r;
  }
}
