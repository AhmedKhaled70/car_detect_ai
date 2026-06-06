import 'finding.dart';
import 'recommendation.dart';

class HistoryAnalyzizResponse {
  String? analysisId;
  String? userId;
  DateTime? createdAtUtc;
  num? totalEstimatedCost;
  Finding? finding;
  List<Recommendation>? recommendations;

  HistoryAnalyzizResponse({
    this.analysisId,
    this.userId,
    this.createdAtUtc,
    this.totalEstimatedCost,
    this.finding,
    this.recommendations,
  });

  factory HistoryAnalyzizResponse.fromJson(Map<String, dynamic> json) {
    return HistoryAnalyzizResponse(
      analysisId: json['analysisId'] as String?,
      userId: json['userId'] as String?,
      createdAtUtc: json['createdAtUtc'] == null
          ? null
          : DateTime.parse(json['createdAtUtc'] as String),
      totalEstimatedCost: json['totalEstimatedCost'] as num?,
      finding: json['finding'] == null
          ? null
          : Finding.fromJson(json['finding'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'analysisId': analysisId,
    'userId': userId,
    'createdAtUtc': createdAtUtc?.toIso8601String(),
    'totalEstimatedCost': totalEstimatedCost,
    'finding': finding?.toJson(),
    'recommendations': recommendations?.map((e) => e.toJson()).toList(),
  };
}
