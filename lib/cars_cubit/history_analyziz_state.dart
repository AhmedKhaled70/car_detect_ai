part of 'history_analyziz_cubit.dart';

sealed class HistoryAnalyzizState {}

final class HistoryAnalyzizInitial extends HistoryAnalyzizState {}

final class HistoryAnalyzizLoading extends HistoryAnalyzizState {}

final class HistoryAnalyzizLoaded extends HistoryAnalyzizState {
  final List<HistoryAnalyzizResponse> analyses;
  HistoryAnalyzizLoaded({required this.analyses});
}

final class HistoryAnalyzizError extends HistoryAnalyzizState {
  final String message;
  HistoryAnalyzizError({required this.message});
}
