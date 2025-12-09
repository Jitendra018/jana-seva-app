import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _wardCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<void> _signUp() async {
    setState(() => _loading = true);
    try {
      var cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': '',
        'role': 'citizen',
        'ward_id': _wardCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pushReplacementNamed('/roleRedirect');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jana Seva - Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _wardCtrl,
              decoration: InputDecoration(labelText: 'Ward (optional)'),
            ),
            SizedBox(height: 12),
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _signUp,
              child:
                  _loading ? CircularProgressIndicator() : Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
