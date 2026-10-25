import 'package:easy_localization/easy_localization.dart';
import 'package:shamsi_date/shamsi_date.dart';

String formatChatTime(String dateUtcString) {
  if (dateUtcString.isEmpty) return '';

  final date = DateTime.parse(dateUtcString).toLocal();
  final now = DateTime.now();
  final diff = now.difference(date);

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  if (diff.inMinutes < 1) {
    return "just_now".tr();
  }

  if (diff.inMinutes < 60) {
    return "${diff.inMinutes} ${"minutes_ago".tr()}";
  }

  if (diff.inHours < 24) {
    return "${diff.inHours} ${"hours_ago".tr()}";
  }

  if (dateOnly == yesterday) {
    return "yesterday".tr();
  }

  final jDate = Jalali.fromDateTime(date);
  return '${jDate.year}/${jDate.month.toString().padLeft(2, '0')}/${jDate.day.toString().padLeft(2, '0')}';
}

String formatDayHeader(String dateUtcString) {
  final date = DateTime.parse(dateUtcString).toLocal();
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  if (dateOnly == today) return "today".tr();
  if (dateOnly == yesterday) return "yesterday".tr();

  final j = date.toJalali();
  return "${j.formatter.wN} ${j.day} ${j.formatter.mN} ${j.year}";
}
