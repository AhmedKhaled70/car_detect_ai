part of 'history_cars_cubit.dart';

sealed class HistoryCarsState {}

final class HistoryCarsInitial extends HistoryCarsState {}

final class HistoryCarsLoading extends HistoryCarsState {}

final class HistoryCarsLoaded extends HistoryCarsState {
  final List<CarResponse> cars;
  HistoryCarsLoaded({required this.cars});
}

final class HistoryCarsError extends HistoryCarsState {
  final String message;
  HistoryCarsError({required this.message});
}
