part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

/// -------------------- Get Current User --------------------
class GetCurrentUserLoading extends ProfileState {}

class GetCurrentUserSuccess extends ProfileState {
  final UserModel user;

  GetCurrentUserSuccess(this.user);
}

class GetCurrentUserError extends ProfileState {
  final String message;

  GetCurrentUserError(this.message);
}

/// -------------------- Edit Profile --------------------
class EditProfileLoading extends ProfileState {}

class EditProfileSuccess extends ProfileState {
  final UserModel user;

  EditProfileSuccess(this.user);
}

class EditProfileError extends ProfileState {
  final String message;

  EditProfileError(this.message);
}

/// -------------------- Upload File --------------------

class UploadFileLoading extends ProfileState {
  final int tempId;
  final double progress;
  UploadFileLoading(this.tempId, this.progress);
}

class UploadFileSuccess extends ProfileState {
  final int tempId;
  final String fileName;
  UploadFileSuccess({required this.tempId, required this.fileName});
}

class UploadFileError extends ProfileState {
  final int tempId;
  final String message;

  UploadFileError({required this.tempId, required this.message});
}

/// -------------------- App Const Setting --------------------
class AppConstSettingLoading extends ProfileState {}

class AppConstSettingSuccess extends ProfileState {
  final AppConstSettingModel appConstSetting;

  AppConstSettingSuccess(this.appConstSetting);
}

class AppConstSettingError extends ProfileState {
  final String message;

  AppConstSettingError(this.message);
}

// ! notification
class NotificationDataLoadingState extends ProfileState {}

class NotificationDataSuccessState extends ProfileState {
  final NotificationModel? notificationModel;

  NotificationDataSuccessState(this.notificationModel);
}

class NotificationDataFailedState extends ProfileState {
  final String message;

  NotificationDataFailedState(this.message);
}

class MarkNotificationAsReadSuccessState extends ProfileState {
  final NotificationDoc notification;

  MarkNotificationAsReadSuccessState({required this.notification});
}

class MarkAllNotificationsAsReadSuccessState extends ProfileState {
  final int count;

  MarkAllNotificationsAsReadSuccessState({required this.count});
}

class SeenNotificationLoadingState extends ProfileState {}

class SeenNotificationSuccessState extends ProfileState {
  SeenNotificationSuccessState();
}

class SeecNotificationFailedState extends ProfileState {
  final String message;

  SeecNotificationFailedState(this.message);
}

