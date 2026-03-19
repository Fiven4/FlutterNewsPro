import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/news_controller.dart';
import '../models/news_model.dart';
import '../widgets/news_card.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await newsController.loadNews(isRefresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await newsController.loadNews();
    if (newsController.hasMore) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return AnimatedBuilder(
          animation: newsController,
          builder: (context, child) {
            final notifications = newsController.notifications;
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 24),
                      const Text('Уведомления', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      if (notifications.isEmpty)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_active_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('У вас пока нет новых уведомлений', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: notifications.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: notif.isRead ? Colors.grey[200] : const Color(0xFFE2E8F0),
                                  child: Icon(Icons.notifications, color: notif.isRead ? Colors.grey[500] : const Color(0xFF0F172A)),
                                ),
                                title: Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    notif.message,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      newsController.markNotificationsAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главное'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: NewsSearchDelegate());
            },
          ),
          AnimatedBuilder(
            animation: newsController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: _showNotifications,
                  ),
                  if (newsController.unreadNotificationsCount > 0)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${newsController.unreadNotificationsCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: newsController,
        builder: (context, child) {
          if (newsController.isLoading && newsController.news.isEmpty) {
            return _buildShimmer();
          }

          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: newsController.hasMore,
            header: const WaterDropMaterialHeader(backgroundColor: Colors.white, color: Colors.black87),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: newsController.news.length,
              itemBuilder: (context, index) {
                return NewsCard(
                  news: newsController.news[index],
                  heroPrefix: 'feed',
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            height: 380,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          ),
        );
      },
    );
  }
}

class NewsSearchDelegate extends SearchDelegate<NewsModel?> {
  @override
  String get searchFieldLabel => 'Поиск новостей...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.black87),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black87),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final results = newsController.news.where((n) {
      final q = query.toLowerCase();
      return n.title.toLowerCase().contains(q) || n.description.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text('Ничего не найдено', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return NewsCard(
          news: results[index],
          heroPrefix: 'search_$query',
        );
      },
    );
  }
}