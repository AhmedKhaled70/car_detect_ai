import 'package:car_damage_detection/models/car_response.dart';
import 'package:car_damage_detection/repos/app_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'history_cars_state.dart';

class HistoryCarsCubit extends Cubit<HistoryCarsState> {
  HistoryCarsCubit({required this.appRepo}) : super(HistoryCarsInitial());

  final AppRepo appRepo;

  Future<void> getHistory() async {
    emit(HistoryCarsLoading());
    final result = await appRepo.savedCars();
    result.fold(
      (l) => emit(HistoryCarsError(message: l.message)),
      (r) => emit(HistoryCarsLoaded(cars: r)),
    );
  }
}
