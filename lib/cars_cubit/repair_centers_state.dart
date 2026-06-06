part of 'repair_centers_cubit.dart';

sealed class RepairCentersState {}

final class RepairCentersInitial extends RepairCentersState {}

final class RepairCentersLoading extends RepairCentersState {}

final class RepairCentersLoaded extends RepairCentersState {
  final List<RepaireCentersResponse> centers;
  RepairCentersLoaded({required this.centers});
}

final class RepairCentersError extends RepairCentersState {
  final String message;
  RepairCentersError({required this.message});
}
