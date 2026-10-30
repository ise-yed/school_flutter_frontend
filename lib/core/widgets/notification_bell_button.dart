import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/api_provider.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';
import 'package:school_flutter_frontend/features/profile/screens/notification_screen.dart';

/// شمارنده سراسری اعلان‌های خوانده‌نشده برای نمایش بج روی آیکون زنگوله
final ValueNotifier<int> unreadNotificationsCount = ValueNotifier<int>(0);

Future<void> refreshUnreadNotificationsCount() async {
  if (!isLogin.value || currentUserModel.schoolId == null) {
    unreadNotificationsCount.value = 0;
    return;
  }
  try {
    final res = await apiProvider.get(
      'notifications/inbox/',
      queryParameters: {'is_read': false, 'page': 1},
    );
    if (res.data is Map) {
      final count = (res.data['count'] as num?)?.toInt() ?? 0;
      unreadNotificationsCount.value = count;
    }
  } catch (_) {}
}

class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({super.key});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  @override
  void initState() {
    super.initState();
    refreshUnreadNotificationsCount();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserModel.schoolId == null) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<int>(
      valueListenable: unreadNotificationsCount,
      builder: (context, unreadCount, _) {
        return IconButton(
          tooltip: 'اعلان‌ها',
          onPressed: () async {
            await goScreen(
              context: context,
              screen: const NotificationScreen(),
            );
            refreshUnreadNotificationsCount();
          },
          icon: badges.Badge(
            showBadge: unreadCount > 0,
            position: badges.BadgePosition.topStart(top: -6, start: -6),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: AppColors.error,
              padding: EdgeInsets.all(5),
            ),
            badgeContent: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary500,
            ),
          ),
        );
      },
    );
  }
}
