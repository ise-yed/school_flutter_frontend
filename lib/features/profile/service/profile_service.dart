import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_setting.dart';
import '../../../core/utils/api_provider.dart';
import '../../../core/utils/app_error.dart';
import '../../auth/models/user_model.dart';
import '../model/notification_model.dart';

class ProfileService {
  Future<UserModel> getCurrentUser() async {
    return currentUserModel;
  }

  Future<UserModel> editProfile({required UserModel user}) async {
    return currentUserModel;
  }

  Future<String> uploadFile(
    XFile file, {
    void Function(int sent, int total)? onProgress,
  }) async {
    return file.name;
  }

  /// ثبت توکن FCM در بک‌اند مدرسه (فقط برای کاربرانی که متعلق به یک مدرسه هستند)
  Future<void> updateFirebaseToken({
    required String firebaseToken,
    required String deviceType,
  }) async {
    if (!isLogin.value || currentUserModel.schoolId == null) return;
    try {
      await apiProvider.post(
        'notifications/devices/register/',
        data: {'registration_id': firebaseToken, 'device_type': deviceType},
      );
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error as AppException;
      throw AppException(AppErrorCode.unknown, serverMessage: e.message);
    }
  }

  /// دریافت لیست اعلان‌های درون‌برنامه‌ای کاربر از /api/v1/notifications/inbox/
  Future<NotificationModel> getNotificationData({
    int? page,
    int? limit,
    bool? isRead,
  }) async {
    try {
      final Map<String, dynamic> query = {};
      if (page != null) query['page'] = page;
      if (isRead != null) query['is_read'] = isRead;

      final response = await apiProvider.get(
        'notifications/inbox/',
        queryParameters: query,
      );

      return NotificationModel.fromJson(
        response.data,
        currentPage: page ?? 1,
        limit: limit ?? 25,
      );
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error as AppException;
      throw AppException(AppErrorCode.unknown, serverMessage: e.message);
    }
  }

  Future<void> seenNotification() async {
    await markAllNotificationsAsRead();
  }

  /// علامت‌گذاری یک اعلان به عنوان خوانده‌شده
  Future<NotificationDoc> markNotificationAsRead(String id) async {
    try {
      final response = await apiProvider.post(
        'notifications/inbox/$id/mark-read/',
      );
      if (response.data is Map<String, dynamic>) {
        return NotificationDoc.fromJson(response.data as Map<String, dynamic>);
      }
      throw AppException(AppErrorCode.unknown);
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error as AppException;
      throw AppException(AppErrorCode.unknown, serverMessage: e.message);
    }
  }

  /// علامت‌گذاری همه اعلان‌های کاربر به عنوان خوانده‌شده
  Future<int> markAllNotificationsAsRead() async {
    try {
      final response = await apiProvider.post(
        'notifications/inbox/mark-all-read/',
      );
      if (response.data is Map) {
        return (response.data['marked_as_read'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error as AppException;
      throw AppException(AppErrorCode.unknown, serverMessage: e.message);
    }
  }
}
