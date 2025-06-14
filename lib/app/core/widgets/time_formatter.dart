class TimeFormatter {
  static String format(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }
}
