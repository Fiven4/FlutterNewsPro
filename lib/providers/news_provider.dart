import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier();
});

class NewsState {
  final List<NewsModel> news;
  final bool isLoading;
  final bool hasMore;
  final int page;

  NewsState({
    required this.news,
    required this.isLoading,
    required this.hasMore,
    required this.page,
  });

  NewsState copyWith({
    List<NewsModel>? news,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return NewsState(
      news: news ?? this.news,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier() : super(NewsState(news: [], isLoading: false, hasMore: true, page: 1)) {
    loadNews(isRefresh: true);
  }

  Future<void> loadNews({bool isRefresh = false}) async {
    if (state.isLoading || (!state.hasMore && !isRefresh)) return;

    int nextPage = isRefresh ? 1 : state.page;
    state = state.copyWith(isLoading: true);

    try {
      final newNews = await NewsService.fetchNews(page: nextPage);

      if (isRefresh) {
        state = state.copyWith(
          news: newNews,
          isLoading: false,
          hasMore: newNews.isNotEmpty,
          page: 2,
        );
      } else {
        state = state.copyWith(
          news: [...state.news, ...newNews],
          isLoading: false,
          hasMore: newNews.isNotEmpty,
          page: state.page + 1,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleBookmark(int id) {
    final updatedNews = state.news.map((news) {
      if (news.id == id) {
        return news.copyWith(isSaved: !news.isSaved);
      }
      return news;
    }).toList();
    state = state.copyWith(news: updatedNews);
  }
}