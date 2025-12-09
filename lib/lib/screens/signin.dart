import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
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
        title: Text('Jana Seva - Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 12),
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _signIn,
              child:
                  _loading ? CircularProgressIndicator() : Text('Sign In'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/signup'),
              child: Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
