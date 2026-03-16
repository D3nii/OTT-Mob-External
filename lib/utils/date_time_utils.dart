/// Utility functions for working with DateTime objects
class DateTimeUtils {
  /// Parses a string to a DateTime object, throwing an exception if parsing fails
  static DateTime parseDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) {
      throw Exception('Cannot parse null DateTime string');
    }
    return DateTime.parse(dateTimeStr); // Will throw FormatException if invalid
  }

  /// Parses a string to a DateTime object
  ///
  /// Returns null if the string is null or cannot be parsed
  static DateTime? parseDateTimeNullable(String? dateTimeStr) {
    if (dateTimeStr == null) return null;
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  /// Converts minutes to Duration, throwing if the input is null
  static Duration fromMinutesToDuration(int? minutes) {
    if (minutes == null) {
      throw Exception('Cannot convert null minutes to Duration');
    }
    return Duration(minutes: minutes);
  }

  /// Converts hours to Duration, throwing if the input is null
  static Duration fromHoursToDuration(int? hours) {
    if (hours == null) {
      throw Exception('Cannot convert null hours to Duration');
    }
    return Duration(hours: hours);
  }

  /// Formats a Duration into a human-readable string like "1 hr 30 min" or "45 min"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '$hours hr $minutes min';
      } else {
        return '$hours hr';
      }
    } else {
      return '$minutes min';
    }
  }
}
