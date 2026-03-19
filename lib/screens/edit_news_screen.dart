import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/news_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/news_model.dart';

class EditNewsScreen extends StatefulWidget {
  final NewsModel news;

  const EditNewsScreen({super.key, required this.news});

  @override
  State<EditNewsScreen> createState() => _EditNewsScreenState();
}

class _EditNewsScreenState extends State<EditNewsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _contentController;
  late String _category;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news.title);
    _descController = TextEditingController(text: widget.news.description);
    _contentController = TextEditingController(text: widget.news.content);
    _category = widget.news.category;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните обязательные поля')),
      );
      return;
    }

    String finalImageUrl = widget.news.imageUrl;

    if (_imageFile != null) {
      final fileName = 'news_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await _imageFile!.copy('${authController.appDocPath}/$fileName');
      finalImageUrl = savedImage.path;
    }

    final updatedNews = widget.news.copyWith(
      title: _titleController.text,
      description: _descController.text,
      content: _contentController.text,
      imageUrl: finalImageUrl,
      category: _category,
    );

    newsController.updateNews(updatedNews);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Редактировать новость'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
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
                      : (!widget.news.imageUrl.startsWith('http')
                      ? DecorationImage(image: FileImage(File(widget.news.imageUrl)), fit: BoxFit.cover)
                      : DecorationImage(image: NetworkImage(widget.news.imageUrl), fit: BoxFit.cover)),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),
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