import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/news_controller.dart';
import '../models/news_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final int newsId;
  final String heroTag;

  const NewsDetailScreen({super.key, required this.newsId, required this.heroTag});

  Widget _buildImage(NewsModel news) {
    if (news.imageUrl.startsWith('http')) {
      return CachedNetworkImage(imageUrl: news.imageUrl, fit: BoxFit.cover);
    } else {
      return Image.file(File(news.imageUrl), fit: BoxFit.cover);
    }
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.black.withOpacity(0.3),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: color ?? Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: newsController,
      builder: (context, child) {
        final news = newsController.news.firstWhere((n) => n.id == newsId, orElse: () => newsController.news.first);

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 450,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassButton(Icons.arrow_back_rounded, () => Navigator.pop(context)),
                    Row(
                      children: [
                        _buildGlassButton(Icons.ios_share_rounded, () => Share.share('${news.title}\n\n${news.description}')),
                        const SizedBox(width: 12),
                        _buildGlassButton(
                          news.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                              () => newsController.toggleBookmark(news.id),
                        ),
                      ],
                    ),
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Hero(
                    tag: heroTag,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(news),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  transform: Matrix4.translationValues(0, -40, 0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                news.category.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              news.formattedDate,
                              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          news.title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            letterSpacing: -1.0,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey[200]!, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundImage: CachedNetworkImageProvider(
                                    'https://ui-avatars.com/api/?name=${news.author.replaceAll(' ', '+')}&background=F8FAFC&color=0F172A&size=150&format=png'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  news.author,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 2),
                                const Text('Автор редакции', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Text(
                          news.content,
                          style: const TextStyle(
                            fontSize: 19,
                            height: 1.8,
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () => newsController.toggleLike(news.id),
                                child: _buildStat(
                                  news.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  '${news.likes}',
                                  color: news.isLiked ? const Color(0xFFEF4444) : null,
                                ),
                              ),
                              Container(height: 40, width: 1, color: const Color(0xFFE2E8F0)),
                              _buildStat(Icons.chat_bubble_outline_rounded, '${news.comments}'),
                              Container(height: 40, width: 1, color: const Color(0xFFE2E8F0)),
                              _buildStat(Icons.visibility_outlined, '${news.likes + 342}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String value, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? const Color(0xFF64748B), size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      ],
    );
  }
}