import 'dart:io';

import 'package:car_damage_detection/errors/failure.dart';
import 'package:car_damage_detection/models/car_response.dart';
import 'package:car_damage_detection/models/history_analyziz_response/history_analyziz_response.dart';
import 'package:car_damage_detection/models/new_car_analyziz_response/new_car_analyziz_response.dart';
import 'package:car_damage_detection/models/repaire_centers_response.dart';
import 'package:car_damage_detection/services/api_service.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class AppRepo {
  Future<Either<Failure, NewCarAnalyzizResponse>> newCarAnalyziz({
    required File image,
    required String carPalte,
    required String carModel,
    required String carYear,
    required String carColor,
    required String carBrand,
  });

  Future<Either<Failure, List<HistoryAnalyzizResponse>>> historyAnalyziz();

  Future<Either<Failure, List<RepaireCentersResponse>>> repairCenters();

  Future<Either<Failure, List<CarResponse>>> savedCars();

  Future<Either<Failure, NewCarAnalyzizResponse>> analyzizSpecificCar({
    required String carId,
    required File image,
  });
}

class AppRepoImpl implements AppRepo {
  final ApiService apiService;

  AppRepoImpl({required this.apiService});
  @override
  Future<Either<Failure, NewCarAnalyzizResponse>> analyzizSpecificCar({
    required String carId,
    required File image,
  }) async {
    try {
      var data = await apiService.post(
        endPoint: '/Analysis/analyze',
        data: FormData.fromMap({
          "Image": await MultipartFile.fromFile(image.path),
          "CarId": carId,
        }),
      );
      return Right(NewCarAnalyzizResponse.fromJson(data['data']));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<HistoryAnalyzizResponse>>>
  historyAnalyziz() async {
    try {
      final result = await apiService.get(endPoint: '/Analysis/GetAll');
      return Right(
        (result as List)
            .map((e) => HistoryAnalyzizResponse.fromJson(e))
            .toList(),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, NewCarAnalyzizResponse>> newCarAnalyziz({
    required File image,
    required String carPalte,
    required String carModel,
    required String carYear,
    required String carColor,
    required String carBrand,
  }) async {
    try {
      var data = await apiService.post(
        endPoint: '/Analysis/analyzenewcar',
        data: FormData.fromMap({
          "Image": await MultipartFile.fromFile(image.path),
          "CarDto.PlateNumber": carPalte,
          "CarDto.Brand": carBrand,
          "CarDto.Model": carModel,
          "CarDto.Year": carYear,
          "CarDto.Color": carColor,
        }),
      );

      return Right(NewCarAnalyzizResponse.fromJson(data['data']));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<RepaireCentersResponse>>> repairCenters() async {
    try {
      final result = await apiService.get(endPoint: '/RepairCenters');
      return Right(
        (result as List)
            .map((e) => RepaireCentersResponse.fromJson(e))
            .toList(),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<CarResponse>>> savedCars() async {
    try {
      final result = await apiService.get(endPoint: '/Cars/getAll');
      return Right(
        (result as List).map((e) => CarResponse.fromJson(e)).toList(),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }
}
