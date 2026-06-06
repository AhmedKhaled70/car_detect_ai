class Finding {
  String? locationLabel;
  String? severity;
  int? estimatedCost;
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
    estimatedCost: json['estimatedCost'] as int?,
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
