import 'dart:io';

import 'package:car_damage_detection/models/new_car_analyziz_response/new_car_analyziz_response.dart';
import 'package:car_damage_detection/repos/app_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'analyziz_specific_car_state.dart';

class AnalyzizSpecificCarCubit extends Cubit<AnalyzizSpecificCarState> {
  AnalyzizSpecificCarCubit({required this.appRepo})
      : super(AnalyzizSpecificCarInitial());

  final AppRepo appRepo;

  Future<void> analyzeSpecificCar({
    required String carId,
    required File image,
  }) async {
    emit(AnalyzizSpecificCarLoading());
    final result = await appRepo.analyzizSpecificCar(
      carId: carId,
      image: image,
    );
    result.fold(
      (l) => emit(AnalyzizSpecificCarError(message: l.message)),
      (r) => emit(AnalyzizSpecificCarLoaded(response: r)),
    );
  }
}
