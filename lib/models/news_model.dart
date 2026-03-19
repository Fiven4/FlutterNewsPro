class NewsModel {
  final int id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String author;
  final String authorId;
  final String category;
  final DateTime date;
  final int likes;
  final int comments;
  final List<String> tags;
  final bool isSaved;
  final bool isLiked;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.authorId,
    required this.category,
    required this.date,
    required this.likes,
    required this.comments,
    required this.tags,
    this.isSaved = false,
    this.isLiked = false,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      author: json['author'] ?? '',
      authorId: json['authorId'] ?? '',
      category: json['category'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isSaved: json['isSaved'] ?? false,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
      'authorId': authorId,
      'category': category,
      'date': date.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'tags': tags,
      'isSaved': isSaved,
      'isLiked': isLiked,
    };
  }

  NewsModel copyWith({
    int? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    String? author,
    String? authorId,
    String? category,
    DateTime? date,
    int? likes,
    int? comments,
    List<String>? tags,
    bool? isSaved,
    bool? isLiked,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      category: category ?? this.category,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      isSaved: isSaved ?? this.isSaved,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    if (difference.inDays == 1) return 'Вчера';
    return '${date.day}.${date.month}.${date.year}';
  }
}