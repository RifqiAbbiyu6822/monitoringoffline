class Temuan {
  final int? id;
  final DateTime tanggal;
  final String jenisTemuan;
  final String jalur;
  final String lajur;
  final String kilometer;
  final String latitude;
  final String longitude;
  final String deskripsi;
  final String? fotoPath;

  const Temuan({
    this.id,
    required this.tanggal,
    required this.jenisTemuan,
    required this.jalur,
    required this.lajur,
    required this.kilometer,
    required this.latitude,
    required this.longitude,
    required this.deskripsi,
    this.fotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.millisecondsSinceEpoch,
      'jenis_temuan': jenisTemuan,
      'jalur': jalur,
      'lajur': lajur,
      'kilometer': kilometer,
      'latitude': latitude,
      'longitude': longitude,
      'deskripsi': deskripsi,
      'foto_path': fotoPath,
    };
  }

  factory Temuan.fromMap(Map<String, dynamic> map) {
    return Temuan(
      id: map['id'],
      tanggal: DateTime.fromMillisecondsSinceEpoch(map['tanggal']),
      jenisTemuan: map['jenis_temuan'],
      jalur: map['jalur'],
      lajur: map['lajur'],
      kilometer: map['kilometer'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      deskripsi: map['deskripsi'],
      fotoPath: map['foto_path'],
    );
  }

  Temuan copyWith({
    int? id,
    DateTime? tanggal,
    String? jenisTemuan,
    String? jalur,
    String? lajur,
    String? kilometer,
    String? latitude,
    String? longitude,
    String? deskripsi,
    String? fotoPath,
  }) {
    return Temuan(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      jenisTemuan: jenisTemuan ?? this.jenisTemuan,
      jalur: jalur ?? this.jalur,
      lajur: lajur ?? this.lajur,
      kilometer: kilometer ?? this.kilometer,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deskripsi: deskripsi ?? this.deskripsi,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }

  @override
  String toString() {
    return 'Temuan(id: $id, tanggal: $tanggal, jenisTemuan: $jenisTemuan, '
        'jalur: $jalur, lajur: $lajur, kilometer: $kilometer, '
        'latitude: $latitude, longitude: $longitude, deskripsi: $deskripsi, '
        'fotoPath: $fotoPath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Temuan &&
        other.id == id &&
        other.tanggal == tanggal &&
        other.jenisTemuan == jenisTemuan &&
        other.jalur == jalur &&
        other.lajur == lajur &&
        other.kilometer == kilometer &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.deskripsi == deskripsi &&
        other.fotoPath == fotoPath;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      tanggal,
      jenisTemuan,
      jalur,
      lajur,
      kilometer,
      latitude,
      longitude,
      deskripsi,
      fotoPath,
    );
  }
}
