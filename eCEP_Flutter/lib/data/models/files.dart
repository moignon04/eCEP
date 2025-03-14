class File {
  final String id;
  final String name;
  final String url;
  final String type;
  final String extension;
  final String mimeType;
  final int size;

  File({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.extension,
    required this.mimeType,
    required this.size,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      type: json['type'],
      extension: json['extension'],
      mimeType: json['mime_type'],
      size: json['size'],
    );
  }
}