import 'package:flutter/material.dart';
import '../controllers/news_controller.dart';
import '../widgets/news_card.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохраненное'),
      ),
      body: AnimatedBuilder(
        animation: newsController,
        builder: (context, child) {
          final savedNews = newsController.savedNews;

          if (savedNews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Здесь пока пусто',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сохраняйте новости, чтобы прочитать позже',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: savedNews.length,
            itemBuilder: (context, index) {
              return NewsCard(
                news: savedNews[index],
                heroPrefix: 'bookmarks',
              );
            },
          );
        },
      ),
    );
  }
}