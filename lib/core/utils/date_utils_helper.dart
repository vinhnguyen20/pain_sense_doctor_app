import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatDateDMY(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String formatDateMDY(DateTime? date,
      {String placeholder = 'mm/dd/yyyy'}) {
    if (date == null) return placeholder;
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// `yyyy-MM-dd`
  static String formatDateApi(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String formatDateMonthAbbr(String isoString) {
    try {
      final d = DateTime.parse(isoString);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return isoString;
    }
  }

  /// Relative date: Today / Yesterday / weekday name / "MMM d, yyyy"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return DateFormat('EEEE').format(local);
    return DateFormat('MMM d, yyyy').format(local);
  }


  /// `TimeOfDay` → `"HH:mm"`
  static String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  /// `"HH:mm"` ( `"HH:mm:ss"`) 
  static TimeOfDay parseTimeOfDay(String hhmm,
      {TimeOfDay fallback = const TimeOfDay(hour: 7, minute: 0)}) {
    final parts = hhmm.trim().split(':');
    if (parts.length < 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return fallback;
    return TimeOfDay(hour: hour, minute: minute);
  }



  static DateTime normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static String dateKey(DateTime date) {
    final d = normalizeDate(date);
    return '${d.year}-${d.month}-${d.day}';
  }

  static bool isValidTime(String input) {
    return RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').hasMatch(input.trim());
  }

  static int? toMinutes(String time) {
    final raw = time.trim();
    if (!isValidTime(raw)) return null;
    final parts = raw.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return (hour * 60) + minute;
  }

  static bool isTimeInPeriod(String time, String period) {
    final minutes = toMinutes(time);
    if (minutes == null) return false;
    return switch (period.trim().toLowerCase()) {
      'morning' => minutes >= 0 && minutes < 12 * 60,
      'afternoon' => minutes >= 12 * 60 && minutes < 18 * 60,
      'evening' => minutes >= 18 * 60 && minutes < 24 * 60,
      _ => false,
    };
  }

  static String defaultTimeForPeriod(String period) {
    return switch (period.trim().toLowerCase()) {
      'morning' => '07:00',
      'afternoon' => '14:00',
      'evening' => '19:00',
      _ => '07:00',
    };
  }

  static String periodFromTime(String time) {
    final hour = int.tryParse(time.split(':').first) ?? 7;
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }

  static String normalizePeriod(String period, String time) {
    final normalized = period.trim().toLowerCase();
    if (normalized == 'morning' ||
        normalized == 'afternoon' ||
        normalized == 'evening') {
      return normalized;
    }
    return periodFromTime(time);
  }

  static String extractScheduleTime(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return '07:00';
    final match = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(input);
    if (match == null) return '07:00';
    final hour = int.parse(match.group(1)!).toString().padLeft(2, '0');
    final minute = match.group(2)!;
    return '$hour:$minute';
  }

  static String getRelativeDay(DateTime inputDate) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final comparedDate = DateTime(
      inputDate.year,
      inputDate.month,
      inputDate.day,
    );

    final difference = today.difference(comparedDate).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    if (difference > 1) return "$difference days ago";
    return "Future date";
  }

  static String getShortRelativeTime(DateTime inputDate) {
    final now = DateTime.now();
    final diff = now.difference(inputDate);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds}s ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else if (diff.inDays == 1) {
      return "1d ago";
    } else {
      return "${diff.inDays}d ago";
    }
  }

  static String getWeekdayShort(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  static String formatDayMonth(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}
