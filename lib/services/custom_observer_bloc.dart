import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomObserverBloc extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    log("create: ${bloc.toString()}");
    super.onCreate(bloc);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    log("change: ${bloc.toString()} $change");
    super.onChange(bloc, change);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log("close: ${bloc.toString()}");
  }
}
