import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class NewRequestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequestPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _address = TextEditingController();
  String _category = 'General';
  String _priority = 'normal';
  List<XFile> _images = [];
  bool _loading = false;

  Future<void> _pickImages() async {
    final ImagePicker p = ImagePicker();
    final imgs = await p.pickMultiImage();
    if (imgs != null) setState(()=> _images = imgs);
  }

  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) return [];
    List<String> urls = [];
    for (var img in _images) {
      final id = Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child('requests/$id.jpg');
      await ref.putFile(File(img.path));
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submit() async {
    setState(()=> _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final urls = await _uploadImages();
      await FirebaseFirestore.instance.collection('requests').add({
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'category': _category,
        'location': {'address': _address.text.trim(), 'ward_id': ''},
        'submitterId': uid,
        'assignedToRole': 'ward_member',
        'status': 'submitted',
        'priority': _priority,
        'mediaUrls': urls,
        'escalationHistory': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).pop(); // back to home
    } catch (e) {
      print('submit err $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit request')));
    } finally {
      setState(()=> _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Request'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView(
          children: [
            TextField(controller: _title, decoration: InputDecoration(labelText: 'Title')),
            SizedBox(height: 8),
            TextField(controller: _desc, decoration: InputDecoration(labelText: 'Description'), maxLines: 5),
            SizedBox(height: 8),
            TextField(controller: _address, decoration: InputDecoration(labelText: 'Address (optional)')),
            SizedBox(height: 12),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _category,
                items: ['General','Water','Road','Sanitation'].map((e)=> DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(()=> _category = v!),
                decoration: InputDecoration(labelText: 'Category'),
              )),
              SizedBox(width: 8),
              Expanded(child: DropdownButtonFormField<String>(
                value: _priority,
                items: ['low','normal','high'].map((e)=> DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(()=> _priority = v!),
                decoration: InputDecoration(labelText: 'Priority'),
              )),
            ]),
            SizedBox(height: 12),
            ElevatedButton.icon(onPressed: _pickImages, icon: Icon(Icons.photo), label: Text('Pick Images')),
            if (_images.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text('${_images.length} images selected'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? SizedBox(height:16, width:16, child:CircularProgressIndicator(strokeWidth:2)) : Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
