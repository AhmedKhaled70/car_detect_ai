part of 'analyziz_specific_car_cubit.dart';

sealed class AnalyzizSpecificCarState {}

final class AnalyzizSpecificCarInitial extends AnalyzizSpecificCarState {}

final class AnalyzizSpecificCarLoading extends AnalyzizSpecificCarState {}

final class AnalyzizSpecificCarLoaded extends AnalyzizSpecificCarState {
  final NewCarAnalyzizResponse response;
  AnalyzizSpecificCarLoaded({required this.response});
}

final class AnalyzizSpecificCarError extends AnalyzizSpecificCarState {
  final String message;
  AnalyzizSpecificCarError({required this.message});
}
