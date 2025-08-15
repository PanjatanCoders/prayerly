/// Model class representing Qibla compass data
class QiblaData {
  /// Qibla direction in degrees from North (0-360)
  final double direction;
  
  /// Distance to Kaaba in kilometers
  final double distance;
  
  /// Current bearing relative to Qibla direction
  final double bearing;
  
  /// When this data was calculated
  final DateTime calculatedAt;

  const QiblaData({
    required this.direction,
    required this.distance,
    required this.bearing,
    required this.calculatedAt,
  });

  /// Create a copy with updated values
  QiblaData copyWith({
    double? direction,
    double? distance,
    double? bearing,
    DateTime? calculatedAt,
  }) {
    return QiblaData(
      direction: direction ?? this.direction,
      distance: distance ?? this.distance,
      bearing: bearing ?? this.bearing,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  String toString() {
    return 'QiblaData{direction: $direction°, distance: ${distance.toStringAsFixed(1)}km, bearing: $bearing°, calculatedAt: $calculatedAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QiblaData &&
        other.direction == direction &&
        other.distance == distance &&
        other.bearing == bearing &&
        other.calculatedAt == calculatedAt;
  }

  @override
  int get hashCode {
    return direction.hashCode ^
        distance.hashCode ^
        bearing.hashCode ^
        calculatedAt.hashCode;
  }
}