import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../controllers/news_controller.dart';
import '../widgets/news_card.dart';
import 'create_news_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _pickAvatar() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      await authController.updateAvatar(pickedFile.path);
    }
  }

  void _editProfile() {
    final nameCtrl = TextEditingController(text: authController.currentUser?.name);
    final bioCtrl = TextEditingController(text: authController.currentUser?.bio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Редактировать профиль', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Имя',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'О себе',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                authController.updateProfile(nameCtrl.text.trim(), bioCtrl.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  ImageProvider _getAvatarProvider() {
    if (authController.currentUser?.avatarPath != null) {
      final file = File('${authController.appDocPath}/${authController.currentUser!.avatarPath}');
      if (file.existsSync()) return FileImage(file);
    }
    return NetworkImage('https://ui-avatars.com/api/?name=${authController.currentUser?.name.replaceAll(' ', '+') ?? 'U'}&background=F8FAFC&color=0F172A&size=200&format=png');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editProfile,
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: authController.logout,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNewsScreen())),
          backgroundColor: const Color(0xFF0F172A),
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('Написать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: AnimatedBuilder(
          animation: Listenable.merge([authController, newsController]),
          builder: (context, child) {
            final user = authController.currentUser;
            final myNews = newsController.getUserNews(user?.id ?? '');
            final savedNews = newsController.savedNews;
            final likedNews = newsController.likedNews;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _getAvatarProvider(),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(user?.name ?? 'Имя пользователя', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text(user?.email ?? 'email@example.com', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                          const SizedBox(height: 12),
                          Text(user?.bio ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Color(0xFF334155))),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatCard('Статьи', myNews.length.toString()),
                              _buildStatCard('Сохранено', savedNews.length.toString()),
                              _buildStatCard('Понравилось', likedNews.length.toString()),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: const Color(0xFF0F172A),
                        unselectedLabelColor: const Color(0xFF64748B),
                        indicatorColor: const Color(0xFF0F172A),
                        tabs: const [
                          Tab(text: 'Мои посты'),
                          Tab(text: 'Сохраненное'),
                          Tab(text: 'Лайки'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _buildNewsList(myNews, 'profile_posted', 'У вас пока нет публикаций'),
                  _buildNewsList(savedNews, 'profile_saved', 'У вас нет сохраненных новостей'),
                  _buildNewsList(likedNews, 'profile_liked', 'Вы еще не оценили ни одной новости'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsList(List newsList, String heroPrefix, String emptyMessage) {
    if (newsList.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Color(0xFF64748B), fontSize: 16)),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        return NewsCard(
          news: newsList[index],
          heroPrefix: heroPrefix,
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}