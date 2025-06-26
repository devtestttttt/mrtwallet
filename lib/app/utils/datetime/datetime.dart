class DateTimeUtils {
  static DateTime fromSecondsSinceEpoch(int s) {
    return DateTime.fromMillisecondsSinceEpoch(s * 1000);
  }

  static int secondsSinceEpoch(DateTime s) {
    return s.millisecondsSinceEpoch ~/ 1000;
  }

  static DateTime? detectEpochUnit(int epoch, {int? minYear, int? maxYear}) {
    final dtSeconds =
        DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: true);
    final dtMillis = DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true);
    final dtMicros = DateTime.fromMicrosecondsSinceEpoch(epoch, isUtc: true);
    final now = DateTime.now().year;
    final min = minYear ?? now - 1;
    final max = maxYear ?? now + 1;
    bool inRange(DateTime dt) => dt.year >= min && dt.year <= max;
    if (inRange(dtMicros)) return dtMicros.toLocal();
    if (inRange(dtMillis)) return dtMillis.toLocal();
    if (inRange(dtSeconds)) return dtSeconds.toLocal();
    return null;
  }
}
