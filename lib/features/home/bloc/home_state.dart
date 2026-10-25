part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

class GetAdsLoadingState extends HomeState {}

class GetAdsSuccessState extends HomeState {
  // final Map<String, ChatRoomDoc> chats;

  // GetAdsSuccessState({this.chats = const {}});
}

class GetAdsFailedState extends HomeState {
  final String message;

  GetAdsFailedState({required this.message});
}

class GetPartnersLoadingState extends HomeState {}

class GetPartnersSuccessState extends HomeState {
  GetPartnersSuccessState();
}

class GetPartnersFailedState extends HomeState {
  final String message;

  GetPartnersFailedState({required this.message});
}
