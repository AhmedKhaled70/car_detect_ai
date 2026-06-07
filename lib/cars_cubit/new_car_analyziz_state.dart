part of 'new_car_analyziz_cubit.dart';

sealed class NewCarAnalyzizState {}

final class NewCarAnalyzizInitial extends NewCarAnalyzizState {}

final class NewCarAnalyzizLoading extends NewCarAnalyzizState {}

final class NewCarAnalyzizLoaded extends NewCarAnalyzizState {
  final NewCarAnalyzizResponse response;
  NewCarAnalyzizLoaded({required this.response});
}

final class NewCarAnalyzizError extends NewCarAnalyzizState {
  final String message;
  NewCarAnalyzizError({required this.message});
}
