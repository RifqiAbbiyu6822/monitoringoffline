enum GridType {
  fullA4,
  twoColumns,
  fourColumns,
}

enum Orientation {
  portrait,
  landscape,
}

class PdfConfig {
  final GridType gridType;
  final Orientation orientation;

  PdfConfig({
    required this.gridType,
    required this.orientation,
  });

  Map<String, dynamic> toMap() {
    return {
      'grid_type': gridType.index,
      'orientation': orientation.index,
    };
  }

  factory PdfConfig.fromMap(Map<String, dynamic> map) {
    return PdfConfig(
      gridType: GridType.values[map['grid_type']],
      orientation: Orientation.values[map['orientation']],
    );
  }

  PdfConfig copyWith({
    GridType? gridType,
    Orientation? orientation,
  }) {
    return PdfConfig(
      gridType: gridType ?? this.gridType,
      orientation: orientation ?? this.orientation,
    );
  }
}
