class ABadge {
  final int id;
  final String name;
  final String description;
  final String image;
  final bool isUnlocked;
  final int progress;
  final int targetProgress;

  ABadge({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.isUnlocked,
    required this.progress,
    required this.targetProgress,
  });

  factory ABadge.fromJson(Map<String, dynamic> json) {
    return ABadge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      isUnlocked: json['isUnlocked'] ?? false,
      progress: json['progress'] ?? 0,
      targetProgress: json['targetProgress'] ?? 100,
    );
  }

  double get progressPercentage => progress / targetProgress;
}