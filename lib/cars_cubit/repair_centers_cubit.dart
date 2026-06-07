import 'package:car_damage_detection/models/repaire_centers_response.dart';
import 'package:car_damage_detection/repos/app_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'repair_centers_state.dart';

class RepairCentersCubit extends Cubit<RepairCentersState> {
  RepairCentersCubit({required this.appRepo}) : super(RepairCentersInitial());

  final AppRepo appRepo;

  Future<void> getRepairCenters() async {
    emit(RepairCentersLoading());
    final result = await appRepo.repairCenters();
    result.fold(
      (l) => emit(RepairCentersError(message: l.message)),
      (r) => emit(RepairCentersLoaded(centers: r)),
    );
  }
}
