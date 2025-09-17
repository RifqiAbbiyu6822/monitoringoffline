class PerbaikanModel {
  final int? id;
  final String namaProyek;
  final String? deskripsi;
  final int status; // 0=0%, 1=50%, 2=100%
  final String createdDate;
  final String updatedDate;

  PerbaikanModel({
    this.id,
    required this.namaProyek,
    this.deskripsi,
    this.status = 0,
    required this.createdDate,
    required this.updatedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_proyek': namaProyek,
      'deskripsi': deskripsi,
      'status': status,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }

  factory PerbaikanModel.fromMap(Map<String, dynamic> map) {
    return PerbaikanModel(
      id: map['id'],
      namaProyek: map['nama_proyek'] ?? '',
      deskripsi: map['deskripsi'],
      status: map['status'] ?? 0,
      createdDate: map['created_date'] ?? '',
      updatedDate: map['updated_date'] ?? '',
    );
  }

  PerbaikanModel copyWith({
    int? id,
    String? namaProyek,
    String? deskripsi,
    int? status,
    String? createdDate,
    String? updatedDate,
  }) {
    return PerbaikanModel(
      id: id ?? this.id,
      namaProyek: namaProyek ?? this.namaProyek,
      deskripsi: deskripsi ?? this.deskripsi,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  String get statusText {
    switch (status) {
      case 0:
        return '0%';
      case 1:
        return '50%';
      case 2:
        return '100%';
      default:
        return '0%';
    }
  }

  int get progressPercentage {
    switch (status) {
      case 0:
        return 0;
      case 1:
        return 50;
      case 2:
        return 100;
      default:
        return 0;
    }
  }

  bool get isCompleted => status == 2;
  
  DateTime get createdDateTime => DateTime.parse(createdDate);
  DateTime get updatedDateTime => DateTime.parse(updatedDate);
}
