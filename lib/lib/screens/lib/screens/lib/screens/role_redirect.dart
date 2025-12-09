import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleRedirectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RoleRedirectState();
}

class _RoleRedirectState extends State<RoleRedirectPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/');
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      // create default citizen doc
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'role': 'citizen',
        'ward_id': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).pushReplacementNamed('/citizenHome');
      return;
    }
    final data = doc.data()!;
    final role = data['role'] ?? 'citizen';
    if (role == 'citizen') {
      Navigator.of(context).pushReplacementNamed('/citizenHome');
    } else {
      Navigator.of(context).pushReplacementNamed('/officialDashboard', arguments: {'role': role});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
