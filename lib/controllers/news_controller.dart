import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsController extends ChangeNotifier {
  List<NewsModel> news = [];
  List<NewsModel> savedNewsList = [];
  List<NewsModel> createdNewsList = [];
  List<NewsModel> likedNewsList = [];

  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  String _currentUserId = '';

  void setUser(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _init();
    }
  }

  void clearUser() {
    _currentUserId = '';
    news.clear();
    savedNewsList.clear();
    likedNewsList.clear();
    page = 1;
    hasMore = true;
    notifyListeners();
  }

  Future<void> _init() async {
    page = 1;
    hasMore = true;
    news.clear();
    await _loadLocalData();
    loadNews(isRefresh: true);
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedStr = prefs.getStringList('saved_news_$_currentUserId') ?? [];
    savedNewsList = savedStr.map((e) => NewsModel.fromJson(jsonDecode(e))).toList();

    final createdStr = prefs.getStringList('created_news') ?? [];
    createdNewsList = createdStr.map((e) => NewsModel.fromJson(jsonDecode(e))).toList();

    final likedStr = prefs.getStringList('liked_news_$_currentUserId') ?? [];
    likedNewsList = likedStr.map((e) => NewsModel.fromJson(jsonDecode(e))).toList();

    notifyListeners();
  }

  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedStr = savedNewsList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('saved_news_$_currentUserId', savedStr);

    final createdStr = createdNewsList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('created_news', createdStr);

    final likedStr = likedNewsList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('liked_news_$_currentUserId', likedStr);
  }

  List<NewsModel> get savedNews => savedNewsList;

  List<NewsModel> getUserNews(String userId) {
    return createdNewsList.where((n) => n.authorId == userId).toList();
  }

  List<NewsModel> get likedNews => likedNewsList;

  int get totalLikesReceived {
    int total = 0;
    for (var n in getUserNews(_currentUserId)) {
      total += n.likes;
    }
    return total;
  }

  Future<void> loadNews({bool isRefresh = false}) async {
    if (isLoading || (!hasMore && !isRefresh)) return;

    int nextPage = isRefresh ? 1 : page;
    isLoading = true;
    notifyListeners();

    try {
      final newNews = await NewsService.fetchNews(page: nextPage);

      final syncedNews = newNews.map((n) {
        final isSaved = savedNewsList.any((saved) => saved.id == n.id);
        final isLiked = likedNewsList.any((liked) => liked.id == n.id);
        return n.copyWith(
          isSaved: isSaved,
          isLiked: isLiked,
          likes: isLiked ? n.likes + 1 : n.likes,
        );
      }).toList();

      if (isRefresh) {
        final syncedCreated = createdNewsList.map((n) {
          final isSaved = savedNewsList.any((saved) => saved.id == n.id);
          final isLiked = likedNewsList.any((liked) => liked.id == n.id);
          return n.copyWith(isSaved: isSaved, isLiked: isLiked);
        }).toList();

        news = [...syncedCreated, ...syncedNews];
        hasMore = newNews.isNotEmpty;
        page = 2;
      } else {
        news.addAll(syncedNews);
        hasMore = newNews.isNotEmpty;
        page++;
      }
    } catch (e) {
      hasMore = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleBookmark(int id) {
    final index = news.indexWhere((n) => n.id == id);
    if (index != -1) {
      final current = news[index];
      final isNowSaved = !current.isSaved;

      news[index] = current.copyWith(isSaved: isNowSaved);

      if (isNowSaved) {
        savedNewsList.add(news[index]);
      } else {
        savedNewsList.removeWhere((n) => n.id == id);
      }
    } else {
      savedNewsList.removeWhere((n) => n.id == id);
    }

    _saveLocalData();
    notifyListeners();
  }

  void toggleLike(int id) {
    final index = news.indexWhere((n) => n.id == id);
    if (index != -1) {
      final current = news[index];
      final isNowLiked = !current.isLiked;

      news[index] = current.copyWith(
        isLiked: isNowLiked,
        likes: isNowLiked ? current.likes + 1 : current.likes - 1,
      );

      if (isNowLiked) {
        likedNewsList.add(news[index]);
      } else {
        likedNewsList.removeWhere((n) => n.id == id);
      }

      final createdIndex = createdNewsList.indexWhere((n) => n.id == id);
      if (createdIndex != -1) {
        createdNewsList[createdIndex] = createdNewsList[createdIndex].copyWith(
          likes: news[index].likes,
        );
      }
    } else {
      likedNewsList.removeWhere((n) => n.id == id);
    }

    _saveLocalData();
    notifyListeners();
  }

  void addNews(NewsModel newNews) {
    createdNewsList.insert(0, newNews);
    news.insert(0, newNews);
    _saveLocalData();
    notifyListeners();
  }
}

final newsController = NewsController();