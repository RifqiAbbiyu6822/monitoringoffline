class PerbaikanFotoModel {
  final int? id;
  final int perbaikanId;
  final String fotoPath;
  final String? deskripsi;
  final int progres; // 0, 50, 100
  final double latitude;
  final double longitude;
  final String timestamp;

  PerbaikanFotoModel({
    this.id,
    required this.perbaikanId,
    required this.fotoPath,
    this.deskripsi,
    required this.progres,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'perbaikan_id': perbaikanId,
      'foto_path': fotoPath,
      'deskripsi': deskripsi,
      'progres': progres,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
  }

  factory PerbaikanFotoModel.fromMap(Map<String, dynamic> map) {
    return PerbaikanFotoModel(
      id: map['id'],
      perbaikanId: map['perbaikan_id'] ?? 0,
      fotoPath: map['foto_path'] ?? '',
      deskripsi: map['deskripsi'],
      progres: map['progres'] ?? 0,
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] ?? '',
    );
  }

  PerbaikanFotoModel copyWith({
    int? id,
    int? perbaikanId,
    String? fotoPath,
    String? deskripsi,
    int? progres,
    double? latitude,
    double? longitude,
    String? timestamp,
  }) {
    return PerbaikanFotoModel(
      id: id ?? this.id,
      perbaikanId: perbaikanId ?? this.perbaikanId,
      fotoPath: fotoPath ?? this.fotoPath,
      deskripsi: deskripsi ?? this.deskripsi,
      progres: progres ?? this.progres,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  String get locationString => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  
  DateTime get dateTime => DateTime.parse(timestamp);
  
  String get progresText => '$progres%';
}
