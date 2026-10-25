import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

Map<String, String> formatReminderDateTime(String dateUtcString) {
  if (dateUtcString.isEmpty) return {'date': '', 'time': ''};

  final date = DateTime.parse(dateUtcString).toLocal();
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  final time = DateFormat('HH:mm').format(date);
  String dateString;

  if (dateOnly == today) {
    dateString = 'today'.tr();
  } else if (dateOnly == tomorrow) {
    dateString = 'tomorrow'.tr();
  } else {
    final jDate = Jalali.fromDateTime(date);
    dateString =
        '${jDate.year}/${jDate.month.toString().padLeft(2, '0')}/${jDate.day.toString().padLeft(2, '0')}';
  }

  return {'date': dateString, 'time': time};
}
