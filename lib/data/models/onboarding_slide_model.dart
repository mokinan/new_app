class OnboardingSlideModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final int order;

  const OnboardingSlideModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.order,
  });

  factory OnboardingSlideModel.fromJson(Map<String, dynamic> json) => OnboardingSlideModel(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    imageUrl: json['image_url'] as String,
    order: json['order'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'order': order,
  };
}
