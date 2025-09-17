class TemuanModel {
  final int? id;
  final String deskripsi;
  final String fotoPath;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String createdDate;

  TemuanModel({
    this.id,
    required this.deskripsi,
    required this.fotoPath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deskripsi': deskripsi,
      'foto_path': fotoPath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'created_date': createdDate,
    };
  }

  factory TemuanModel.fromMap(Map<String, dynamic> map) {
    return TemuanModel(
      id: map['id'],
      deskripsi: map['deskripsi'] ?? '',
      fotoPath: map['foto_path'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] ?? '',
      createdDate: map['created_date'] ?? '',
    );
  }

  TemuanModel copyWith({
    int? id,
    String? deskripsi,
    String? fotoPath,
    double? latitude,
    double? longitude,
    String? timestamp,
    String? createdDate,
  }) {
    return TemuanModel(
      id: id ?? this.id,
      deskripsi: deskripsi ?? this.deskripsi,
      fotoPath: fotoPath ?? this.fotoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  String get locationString => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  
  DateTime get dateTime => DateTime.parse(timestamp);
}
