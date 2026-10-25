part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class GetAdsEvent extends HomeEvent {
  GetAdsEvent();
}

class GetPartnersEvent extends HomeEvent {
  GetPartnersEvent();
}
