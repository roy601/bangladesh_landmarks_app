class Landmark {
  final int? id;
  final String title;
  final double lat;
  final double lon;
  final String? image;

  Landmark({
    this.id,
    required this.title,
    required this.lat,
    required this.lon,
    this.image,
  });

  // Convert JSON to Landmark object
  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      title: json['title'] ?? '',
      lat: _parseDouble(json['lat']),
      lon: _parseDouble(json['lon']),
      image: json['image'],
    );
  }

  // Convert Landmark object to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      if (image != null) 'image': image,
    };
  }

  // Helper method to parse double values
  static double _parseDouble(dynamic value) {
    if (value == null || value == '') return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Convert to Map for local database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      'image': image,
    };
  }

  // Create from Map (for local database)
  factory Landmark.fromMap(Map<String, dynamic> map) {
    return Landmark(
      id: map['id'],
      title: map['title'] ?? '',
      lat: map['lat'] ?? 0.0,
      lon: map['lon'] ?? 0.0,
      image: map['image'],
    );
  }

  // Create a copy with modified fields
  Landmark copyWith({
    int? id,
    String? title,
    double? lat,
    double? lon,
    String? image,
  }) {
    return Landmark(
      id: id ?? this.id,
      title: title ?? this.title,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      image: image ?? this.image,
    );
  }

  // Get full image URL
  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;
    if (image!.startsWith('http')) return image;
    return 'https://labs.anontech.info/cse489/t3/$image';
  }

  @override
  String toString() {
    return 'Landmark{id: $id, title: $title, lat: $lat, lon: $lon, image: $image}';
  }
}
