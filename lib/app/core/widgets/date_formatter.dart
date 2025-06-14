class DateFormatter {
  static String format(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return timestamp;
    }
  }
}
