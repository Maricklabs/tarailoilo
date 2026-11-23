// Small date/time formatters shared by the screens (no extra package).

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// "January 4, 2027"
String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// "January 4 - 7, 2027", "January 30 - February 2, 2027", or one date.
String formatDateRange(DateTime start, DateTime end) {
  final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
  if (sameDay) return formatDate(start);
  if (start.year != end.year) return '${formatDate(start)} - ${formatDate(end)}';
  if (start.month == end.month) {
    return '${_months[start.month - 1]} ${start.day} - ${end.day}, ${start.year}';
  }
  return '${_months[start.month - 1]} ${start.day} - ${_months[end.month - 1]} ${end.day}, ${start.year}';
}

/// "9:00 AM"
String formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// "2:00 PM - 7:00 PM"
String formatTimeRange(DateTime start, DateTime end) => '${formatTime(start)} - ${formatTime(end)}';

/// "850 m" or "10 km" for distances.
String formatDistance(double meters) =>
    meters < 1000 ? '${meters.round()} m' : '${(meters / 1000).toStringAsFixed(meters < 10000 ? 1 : 0)} km';
