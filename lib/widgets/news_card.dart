import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/news_model.dart';
import '../screens/news_detail_screen.dart';
import '../controllers/news_controller.dart';
import '../controllers/auth_controller.dart';

class NewsCard extends StatelessWidget {
  final NewsModel news;
  final String heroPrefix;

  const NewsCard({
    super.key,
    required this.news,
    required this.heroPrefix,
  });

  Widget _buildImage() {
    if (news.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: news.imageUrl,
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[50]!,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => Container(
          height: 240,
          color: Colors.grey[100],
          child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(news.imageUrl),
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  ImageProvider _getAvatarProvider() {
    if (news.authorId == authController.currentUser?.id && authController.currentUser?.avatarPath != null) {
      final file = File('${authController.appDocPath}/${authController.currentUser!.avatarPath}');
      if (file.existsSync()) return FileImage(file);
    }
    return CachedNetworkImageProvider(
        'https://ui-avatars.com/api/?name=${news.author.replaceAll(' ', '+')}&background=F1F5F9&color=0F172A&format=png');
  }

  @override
  Widget build(BuildContext context) {
    final String heroTag = '${heroPrefix}_news_image_${news.id}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                reverseTransitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, __, ___) => NewsDetailScreen(newsId: news.id, heroTag: heroTag),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: heroTag,
                      child: _buildImage(),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: Colors.white.withOpacity(0.2),
                            child: Text(
                              news.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Material(
                            color: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              icon: Icon(
                                news.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () => newsController.toggleBookmark(news.id),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: -0.5,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        news.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                          height: 1.6,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey[200]!, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundImage: _getAvatarProvider(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        news.author,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        news.formattedDate,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => newsController.toggleLike(news.id),
                                  child: Icon(
                                    news.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    size: 20,
                                    color: news.isLiked ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${news.likes}',
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}