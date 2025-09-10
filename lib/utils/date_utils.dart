import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _displayFormat = DateFormat('dd MMMM yyyy');
  static final DateFormat _shortFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _fileNameFormat = DateFormat('yyyyMMdd');
  static final DateFormat _databaseFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Format tanggal untuk ditampilkan di UI
  static String formatDisplayDate(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Format tanggal pendek untuk ditampilkan di UI
  static String formatShortDate(DateTime date) {
    return _shortFormat.format(date);
  }

  /// Format tanggal untuk nama file
  static String formatFileNameDate(DateTime date) {
    return _fileNameFormat.format(date);
  }

  /// Format tanggal untuk database
  static String formatDatabaseDate(DateTime date) {
    return _databaseFormat.format(date);
  }

  /// Parse tanggal dari string
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Dapatkan awal hari dari tanggal
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Dapatkan akhir hari dari tanggal
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Cek apakah tanggal adalah hari ini
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Cek apakah tanggal adalah kemarin
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  /// Dapatkan relatif waktu (hari ini, kemarin, atau format tanggal)
  static String getRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Hari ini';
    } else if (isYesterday(date)) {
      return 'Kemarin';
    } else {
      return formatDisplayDate(date);
    }
  }

  /// Dapatkan range tanggal untuk query database
  static Map<String, DateTime> getDateRange(DateTime date) {
    return {
      'start': getStartOfDay(date),
      'end': getEndOfDay(date),
    };
  }

  /// Format tanggal dengan waktu
  static String formatDateTime(DateTime dateTime) {
    return '${formatDisplayDate(dateTime)} ${DateFormat('HH:mm').format(dateTime)}';
  }

  /// Dapatkan daftar tanggal dalam range
  static List<DateTime> getDateRangeList(DateTime startDate, DateTime endDate) {
    final List<DateTime> dates = [];
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return dates;
  }

  /// Cek apakah tanggal valid
  static bool isValidDate(DateTime date) {
    try {
      return date.year > 1900 && date.year < 2100;
    } catch (e) {
      return false;
    }
  }
}
