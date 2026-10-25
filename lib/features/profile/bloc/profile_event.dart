part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

/// -------------------- Get Current User --------------------
class GetCurrentUserEvent extends ProfileEvent {
  GetCurrentUserEvent();
}

/// -------------------- Edit Profile --------------------
class EditProfileEvent extends ProfileEvent {
  final UserModel user;

  EditProfileEvent({required this.user});
}

/// -------------------- Get Pets --------------------
class GetPetsEvent extends ProfileEvent {
  GetPetsEvent();
}

/// -------------------- Get Breeds --------------------
class GetBreedsEvent extends ProfileEvent {
  final String pet;

  GetBreedsEvent({required this.pet});
}

/// -------------------- Upload File --------------------
class UploadFileEvent extends ProfileEvent {
  final XFile file;
  final int tempId;

  UploadFileEvent({required this.file, required this.tempId});
}

/// -------------------- Get App Const Setting --------------------
// class GetAppConstSettingEvent extends ProfileEvent {}

/// -------------------- ticket --------------------
// !get all tickets
class GetTicketListEvent extends ProfileEvent {}

// !create ticket
class CreateTicketEvent extends ProfileEvent {
  final String subject;
  final String description;
  final String message;

  CreateTicketEvent({
    required this.subject,
    required this.description,
    required this.message,
  });
}

// !close ticket
class CloseTicketEvent extends ProfileEvent {
  final String id;

  CloseTicketEvent({required this.id});
}

// ! ticket single data
class GetTicketSingleDataEvent extends ProfileEvent {
  final String id;

  GetTicketSingleDataEvent({required this.id});
}

// !Replay Ticket
class ReplayTicketDataEvent extends ProfileEvent {
  String? message;
  String? document;
  final String id;

  ReplayTicketDataEvent({this.message, this.document, required this.id});
}

// !Notification data
class NotificationDataEvent extends ProfileEvent {
  final int? page;
  final int? limit;
  final bool callSeen;

  NotificationDataEvent({this.page, this.limit, this.callSeen = false});
}

class MarkNotificationAsReadEvent extends ProfileEvent {
  final String id;

  MarkNotificationAsReadEvent({required this.id});
}

class MarkAllNotificationsAsReadEvent extends ProfileEvent {
  MarkAllNotificationsAsReadEvent();
}

