import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/news_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/news_model.dart';

class CreateNewsScreen extends StatefulWidget {
  const CreateNewsScreen({super.key});

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = 'Технологии';
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _publish() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля и выберите фото')),
      );
      return;
    }

    final newNews = NewsModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleController.text,
      description: _descController.text,
      content: _contentController.text,
      imageUrl: _imageFile!.path,
      author: authController.currentUser?.name ?? 'Пользователь',
      authorId: authController.currentUser?.id ?? '1',
      category: _category,
      date: DateTime.now(),
      likes: 0,
      comments: 0,
      tags: [],
    );

    newsController.addNews(newNews);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Создать новость'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _publish,
            child: const Text('Опубликовать', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('Добавить обложку', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  ],
                )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ['Технологии', 'Спорт', 'Экономика', 'Культура', 'Наука'].map((c) {
                return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)));
              }).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            _buildTextField(_titleController, 'Заголовок', maxLines: 2),
            const SizedBox(height: 16),
            _buildTextField(_descController, 'Краткое описание', maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField(_contentController, 'Полный текст новости', maxLines: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}