import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';


class AddRecScreen extends StatefulWidget {
  const AddRecScreen({super.key});

  @override
  State<AddRecScreen> createState() => _AddRecScreenState();
}

class _AddRecScreenState extends State<AddRecScreen> {
  final _formKey = GlobalKey<FormState>();
  final _client = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _reviewController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedCategory;
  int _rating = 5;
  bool _crewDiscount = false;

  final List<String> _categories = [
    'Food',
    'Nightlife',
    'Shopping',
    'Entertainment',
    'Experiences',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    final insertRes = await _client.from('recommendations').insert({
  'user_id': userId,
  'business_name': _nameController.text.trim(),
  'city': _cityController.text.trim(),
  'review': _reviewController.text.trim(),
  'category': _selectedCategory,
  'tags': _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
  'rating': _rating,
  'crew_discount': _crewDiscount,
}).select();

if (insertRes.error != null || insertRes.data == null) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${insertRes.error?.message}')));
  return;
}

final recId = insertRes.data[0]['id'] as String;

final photoUrl = await _uploadImage(recId);
if (photoUrl != null) {
  await _client.from('photos').insert({
    'recommendation_id': recId,
    'uploaded_by': userId,
    'url': photoUrl,
  });
}


    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.error!.message}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recommendation submitted!')));
      Navigator.pop(context);
    }

    File? _selectedImage;
final picker = ImagePicker();

Future<void> _pickImage() async {
  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
  if (picked != null) {
    setState(() => _selectedImage = File(picked.path));
  }
}

Future<String?> _uploadImage(String recId) async {
  if (_selectedImage == null) return null;

  final fileExt = path.extension(_selectedImage!.path);
  final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
  final filePath = 'recommendations/$recId/$fileName';
  final bytes = await _selectedImage!.readAsBytes();
  final contentType = lookupMimeType(fileName);

  final res = await Supabase.instance.client.storage
      .from('photos')
      .uploadBinary(filePath, bytes, fileOptions: FileOptions(contentType: contentType));

  if (res.error != null) {
    print('Upload failed: ${res.error!.message}');
    return null;
  }

  return Supabase.instance.client.storage.from('photos').getPublicUrl(filePath);
}

  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _reviewController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a Recommendation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Business Name'),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? 'Choose a category' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Enter a city' : null,
              ),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
              ),
              TextFormField(
                controller: _reviewController,
                decoration: const InputDecoration(labelText: 'Review (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Rating:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _rating,
                    items: List.generate(5, (i) => i + 1)
                        .map((val) => DropdownMenuItem(value: val, child: Text('$val ★')))
                        .toList(),
                    onChanged: (val) => setState(() => _rating = val ?? 5),
                  ),
                ],
              ),
              CheckboxListTile(
                value: _crewDiscount,
                onChanged: (val) => setState(() => _crewDiscount = val ?? false),
                title: const Text('Crew Discount Available'),
              ),
              const SizedBox(height: 16),
                _outlinedImagePicker(),

              ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
Widget _outlinedImagePicker() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Add a Photo (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            image: _selectedImage != null
                ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                : null,
          ),
          child: _selectedImage == null
              ? const Center(child: Icon(Icons.add_a_photo, size: 32, color: Colors.grey))
              : null,
        ),
      ),
    ],
  );
}
