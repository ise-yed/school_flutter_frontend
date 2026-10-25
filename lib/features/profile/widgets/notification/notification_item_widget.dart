import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/widgets/format_reminder_date.dart';
import 'package:school_flutter_frontend/features/profile/model/notification_model.dart';

class NotificationsItemWidget extends StatelessWidget {
  final bool isActive;
  final NotificationDoc notificationdata;
  final VoidCallback? onTap;

  const NotificationsItemWidget({
    super.key,
    this.isActive = true,
    required this.notificationdata,
    this.onTap,
  });

  Widget _buildTypeIcon(String type, BuildContext context) {
    Color bgColor;
    String iconPath;

    switch (type) {
      // Appointments - positive / ongoing
      case 'appointment_created':
      case 'appointment_rescheduled':
      case 'appointment_reminder':
      case 'reminder':
        bgColor = const Color(0xFF2563EB); // Royal Blue
        iconPath = 'assets/icons/calendar.svg';
        break;

      case 'appointment_confirmed':
      case 'appointment_completed':
        bgColor = const Color(0xFF059669); // Emerald Green
        iconPath = 'assets/icons/check-circle.svg';
        break;

      // Appointments - negative
      case 'appointment_cancelled':
      case 'appointment_no_show':
        bgColor = const Color(0xFFDC2626); // Crimson Red
        iconPath = 'assets/icons/warning.svg';
        break;

      // Payments
      case 'payment_success':
      case 'refund_success':
        bgColor = const Color(0xFF10B981); // Mint Green
        iconPath = 'assets/icons/cart.svg';
        break;

      case 'payment_failed':
        bgColor = const Color(0xFFE11D48); // Rose Red
        iconPath = 'assets/icons/warning.svg';
        break;

      // Chat
      case 'chat_message_received':
      case 'message':
        bgColor = const Color(0xFF7C3AED); // Violet
        iconPath = 'assets/icons/chat_2.svg';
        break;

      // Security / Account
      case 'password_changed':
      case 'password_reset_requested':
        bgColor = const Color(0xFFD97706); // Amber
        iconPath = 'assets/icons/lock.svg';
        break;

      // Legacy types
      case 'ticket':
        bgColor = AppColors.yellow;
        iconPath = 'assets/icons/description.svg';
        break;

      case 'handover':
        bgColor = Colors.blue;
        iconPath = 'assets/icons/heart_fill.svg';
        break;

      default:
        bgColor = Theme.of(context).colorScheme.primary;
        iconPath = 'assets/icons/notification.svg';
        break;
    }

    return Container(
      height: 48.r,
      width: 48.r,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: 22.r,
          height: 22.r,
          colorFilter: ColorFilter.mode(bgColor, BlendMode.srcIn),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notificationdata.isRead;
    final dateInfo = formatReminderDateTime(
      notificationdata.createdAt.toIso8601String(),
    );
    final dateStr = dateInfo['date'] ?? '';
    final timeStr = dateInfo['time'] ?? '';
    final formattedTime = timeStr.isNotEmpty
        ? '$dateStr  •  $timeStr'
        : dateStr;

    final theme = Theme.of(context);
    final cardBg = isUnread
        ? theme.colorScheme.primary.withValues(alpha: 0.05)
        : theme.colorScheme.shadow;

    final border = isUnread
        ? Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            width: 1,
          )
        : null;

    return Container(
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeIcon(notificationdata.type, context),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notificationdata.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14.5.sp,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            SizedBox(width: 6.w),
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        notificationdata.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12.sp,
                          color: isUnread
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        formattedTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
