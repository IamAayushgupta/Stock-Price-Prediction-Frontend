class NewsModel {
  final String title;
  final String description;
  final String source;
  final DateTime publishedAt;
  final String? imageUrl;
  final String url;

  NewsModel({
    required this.title,
    required this.description,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
    required this.url,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      source: json['source'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ?? DateTime.now(),
      imageUrl: json['image_url'] as String?,
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'source': source,
      'published_at': publishedAt.toIso8601String(),
      'image_url': imageUrl,
      'url': url,
    };
  }
}
