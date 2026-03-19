import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';
import '../models/notification_model.dart';
import '../services/news_service.dart';

class NewsController extends ChangeNotifier {
  List<NewsModel> news = [];
  List<NewsModel> savedNewsList = [];
  List<NewsModel> createdNewsList = [];
  List<NewsModel> likedNewsList = [];
  List<NotificationModel> notifications = [];

  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  String _currentUserId = '';

  void setUser(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _registerUser(userId);
      _init();
    }
  }

  Future<void> _registerUser(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList('global_registered_users') ?? [];
    if (!users.contains(userId)) {
      users.add(userId);
      await prefs.setStringList('global_registered_users', users);
    }
  }

  void clearUser() {
    _currentUserId = '';
    news.clear();
    savedNewsList.clear();
    likedNewsList.clear();
    createdNewsList.clear();
    notifications.clear();
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

  int get unreadNotificationsCount => notifications.where((n) => !n.isRead).length;

  void markNotificationsAsRead() {
    bool changed = false;
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      _saveLocalData();
      notifyListeners();
    }
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final savedStr = prefs.getStringList('saved_news_$_currentUserId') ?? [];
    savedNewsList = savedStr.map((e) => NewsModel.fromJson(jsonDecode(e))).toList();

    final createdStr = prefs.getStringList('global_created_news') ?? [];
    createdNewsList = createdStr.map((e) => NewsModel.fromJson(jsonDecode(e))).toList();

    final likedStr = prefs.getStringList('liked_news_$_currentUserId') ?? [];
    likedNewsList = likedStr.map((e) => NewsModel.fromJson(jsonDecode(e))).toList();

    final notifStr = prefs.getStringList('notifications_$_currentUserId') ?? [];
    notifications = notifStr.map((e) => NotificationModel.fromJson(jsonDecode(e))).toList();

    notifyListeners();
  }

  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedStr = savedNewsList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('saved_news_$_currentUserId', savedStr);

    final createdStr = createdNewsList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('global_created_news', createdStr);

    final likedStr = likedNewsList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('liked_news_$_currentUserId', likedStr);

    final notifStr = notifications.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('notifications_$_currentUserId', notifStr);
  }

  Future<void> _sendNotificationToUser(String targetUserId, String title, String message) async {
    if (targetUserId.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final newNotif = NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_$targetUserId',
        title: title,
        message: message,
        date: DateTime.now(),
      );

      final key = 'notifications_$targetUserId';
      final notifStr = prefs.getStringList(key) ?? [];
      final notifList = notifStr.map((e) => NotificationModel.fromJson(jsonDecode(e))).toList();

      notifList.insert(0, newNotif);
      await prefs.setStringList(key, notifList.map((e) => jsonEncode(e.toJson())).toList());

      if (targetUserId == _currentUserId) {
        notifications = notifList;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Ошибка отправки уведомления: $e");
    }
  }

  List<NewsModel> get savedNews => savedNewsList;
  List<NewsModel> getUserNews(String userId) => createdNewsList.where((n) => n.authorId == userId).toList();
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

  Future<void> toggleBookmark(int id) async {
    final index = news.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final current = news[index];
    final isNowSaved = !current.isSaved;

    news[index] = current.copyWith(isSaved: isNowSaved);

    if (isNowSaved) {
      savedNewsList.add(news[index]);
    } else {
      savedNewsList.removeWhere((n) => n.id == id);
    }

    notifyListeners();

    if (isNowSaved && current.authorId != _currentUserId && current.authorId.isNotEmpty) {
      await _sendNotificationToUser(
        current.authorId,
        'Пост в закладках 📌',
        'Ваша публикация "${current.title}" была добавлена в сохраненное.',
      );
    }

    await _saveLocalData();
  }

  Future<void> toggleLike(int id) async {
    final index = news.indexWhere((n) => n.id == id);
    if (index == -1) return;

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

    notifyListeners();

    if (isNowLiked && current.authorId != _currentUserId && current.authorId.isNotEmpty) {
      await _sendNotificationToUser(
        current.authorId,
        'Новый лайк! ❤️',
        'Пользователям понравилась ваша публикация "${current.title}".',
      );
    }

    await _saveLocalData();
  }

  Future<void> addNews(NewsModel newNews) async {
    createdNewsList.insert(0, newNews);
    news.insert(0, newNews);
    await _saveLocalData();
    notifyListeners();

    await _sendNotificationToUser(
        _currentUserId,
        'Успешная публикация',
        'Ваша новость "${newNews.title}" успешно опубликована.'
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    List<String> registeredUsers = prefs.getStringList('global_registered_users') ?? [];

    for (String targetUserId in registeredUsers) {
      if (targetUserId != _currentUserId) {
        await _sendNotificationToUser(
          targetUserId,
          'Новая публикация',
          'Пользователь ${newNews.author} опубликовал(а) новость "${newNews.title}".',
        );
      }
    }
  }

  void updateNews(NewsModel updatedNews) {
    int idx = news.indexWhere((n) => n.id == updatedNews.id);
    if (idx != -1) news[idx] = updatedNews;

    idx = createdNewsList.indexWhere((n) => n.id == updatedNews.id);
    if (idx != -1) createdNewsList[idx] = updatedNews;

    idx = savedNewsList.indexWhere((n) => n.id == updatedNews.id);
    if (idx != -1) savedNewsList[idx] = updatedNews;

    idx = likedNewsList.indexWhere((n) => n.id == updatedNews.id);
    if (idx != -1) likedNewsList[idx] = updatedNews;

    _saveLocalData();
    notifyListeners();
  }

  void deleteNews(int id) {
    news.removeWhere((n) => n.id == id);
    createdNewsList.removeWhere((n) => n.id == id);
    savedNewsList.removeWhere((n) => n.id == id);
    likedNewsList.removeWhere((n) => n.id == id);
    _saveLocalData();
    notifyListeners();
  }
}

final newsController = NewsController();