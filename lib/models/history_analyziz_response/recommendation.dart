class Recommendation {
  String? centerId;
  String? name;
  String? address;
  String? phone;
  String? location;

  Recommendation({
    this.centerId,
    this.name,
    this.address,
    this.phone,
    this.location,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      centerId: json['centerId'] as String?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'centerId': centerId,
    'name': name,
    'address': address,
    'phone': phone,
    'location': location,
  };
}
