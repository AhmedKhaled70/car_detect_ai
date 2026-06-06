class RepaireCentersResponse {
  String? centerId;
  String? name;
  String? phone;
  String? address;
  String? location;
  String? supportedBrand;
  bool? isActive;
  dynamic detectionRepairCenters;

  RepaireCentersResponse({
    this.centerId,
    this.name,
    this.phone,
    this.address,
    this.location,
    this.supportedBrand,
    this.isActive,
    this.detectionRepairCenters,
  });

  factory RepaireCentersResponse.fromJson(Map<String, dynamic> json) {
    return RepaireCentersResponse(
      centerId: json['centerId'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      location: json['location'] as String?,
      supportedBrand: json['supportedBrand'] as String?,
      isActive: json['isActive'] as bool?,
      detectionRepairCenters: json['detectionRepairCenters'] as dynamic,
    );
  }

  Map<String, dynamic> toJson() => {
    'centerId': centerId,
    'name': name,
    'phone': phone,
    'address': address,
    'location': location,
    'supportedBrand': supportedBrand,
    'isActive': isActive,
    'detectionRepairCenters': detectionRepairCenters,
  };
}
