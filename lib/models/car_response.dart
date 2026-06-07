class CarResponse {
  String? carId;
  String? plateNumber;
  String? brand;
  String? model;
  int? year;
  String? color;

  CarResponse({
    this.carId,
    this.plateNumber,
    this.brand,
    this.model,
    this.year,
    this.color,
  });

  factory CarResponse.fromJson(Map<String, dynamic> json) => CarResponse(
    carId: json['carId'] as String?,
    plateNumber: json['plateNumber'] as String?,
    brand: json['brand'] as String?,
    model: json['model'] as String?,
    year: json['year'] as int?,
    color: json['color'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'carId': carId,
    'plateNumber': plateNumber,
    'brand': brand,
    'model': model,
    'year': year,
    'color': color,
  };
}
