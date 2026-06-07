import 'package:car_damage_detection/models/history_analyziz_response/history_analyziz_response.dart';
import 'package:car_damage_detection/repos/app_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'history_analyziz_state.dart';

class HistoryAnalyzizCubit extends Cubit<HistoryAnalyzizState> {
  HistoryAnalyzizCubit({required this.appRepo})
      : super(HistoryAnalyzizInitial());

  final AppRepo appRepo;

  Future<void> getHistoryAnalyziz() async {
    emit(HistoryAnalyzizLoading());
    final result = await appRepo.historyAnalyziz();
    result.fold(
      (l) => emit(HistoryAnalyzizError(message: l.message)),
      (r) => emit(HistoryAnalyzizLoaded(analyses: r)),
    );
  }
}
