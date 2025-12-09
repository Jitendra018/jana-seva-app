import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfficialDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>?;
    final role = args != null && args['role'] != null ? args['role'] as String : 'ward_member';
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard ($role)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return Center(child: Text('No requests'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, idx) {
              final d = docs[idx];
              return ListTile(
                title: Text(d['title'] ?? ''),
                subtitle: Text('${d['status'] ?? ''} — ${d['location']?['address'] ?? ''}'),
                onTap: () => Navigator.of(context).pushNamed('/requestDetail', arguments: {'requestId': d.id}),
              );
            },
          );
        },
      ),
    );
  }
}
