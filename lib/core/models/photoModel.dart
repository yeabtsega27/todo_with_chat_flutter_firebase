class Photo {
  String photoURL;
  DateTime uploadTime;
  String path;

  Photo({
    required this.photoURL,
    required this.uploadTime,
    required this.path,
  });

  // Convert Photo to JSON
  Map<String, dynamic> toJson() {
    return {
      'photoURL': photoURL,
      'uploadTime': uploadTime.toString(),
      'path': path,
    };
  }

  // Create Photo from JSON
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoURL: json['photoURL'],
      uploadTime: DateTime.parse(json['uploadTime']),
      path: json['path'] ?? "",
    );
  }
}
