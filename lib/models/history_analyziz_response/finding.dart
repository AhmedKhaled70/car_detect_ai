class Finding {
  String? locationLabel;
  String? severity;
  num? estimatedCost;
  double? confidence;
  String? imagePath;

  Finding({
    this.locationLabel,
    this.severity,
    this.estimatedCost,
    this.confidence,
    this.imagePath,
  });

  factory Finding.fromJson(Map<String, dynamic> json) => Finding(
    locationLabel: json['locationLabel'] as String?,
    severity: json['severity'] as String?,
    estimatedCost: json['estimatedCost'] as num?,
    confidence: (json['confidence'] as num?)?.toDouble(),
    imagePath: json['imagePath'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'locationLabel': locationLabel,
    'severity': severity,
    'estimatedCost': estimatedCost,
    'confidence': confidence,
    'imagePath': imagePath,
  };
}
