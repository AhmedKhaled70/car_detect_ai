import 'dart:io';

import 'package:car_damage_detection/models/new_car_analyziz_response/new_car_analyziz_response.dart';
import 'package:car_damage_detection/repos/app_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'new_car_analyziz_state.dart';

class NewCarAnalyzizCubit extends Cubit<NewCarAnalyzizState> {
  NewCarAnalyzizCubit({required this.appRepo})
      : super(NewCarAnalyzizInitial());

  final AppRepo appRepo;

  Future<void> analyzeNewCar({
    required File image,
    required String carPlate,
    required String carModel,
    required String carYear,
    required String carColor,
    required String carBrand,
  }) async {
    emit(NewCarAnalyzizLoading());
    final result = await appRepo.newCarAnalyziz(
      image: image,
      carPalte: carPlate,
      carModel: carModel,
      carYear: carYear,
      carColor: carColor,
      carBrand: carBrand,
    );
    result.fold(
      (l) => emit(NewCarAnalyzizError(message: l.message)),
      (r) => emit(NewCarAnalyzizLoaded(response: r)),
    );
  }
}
