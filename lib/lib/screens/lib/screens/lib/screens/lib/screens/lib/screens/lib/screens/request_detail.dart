import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetailPage> {
  Map<String, dynamic>? requestData;
  String requestId = '';
  bool loading = true;

  Future<void> load() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    requestId = args != null && args['requestId'] != null ? args['requestId'] as String : '';
    if (requestId.isEmpty) return;

    final doc = await FirebaseFirestore.instance.collection('requests').doc(requestId).get();
    setState(() {
      requestData = doc.data();
      loading = false;
    });
  }

  Future<void> updateStatus(String status) async {
    if (requestId.isEmpty) return;

    await FirebaseFirestore.instance.collection('requests').doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await load();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (requestData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Request Details')),
        body: Center(child: Text('No data found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(requestData!['title'] ?? 'Request'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView(
          children: [
            Text('Status: ${requestData!['status']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(requestData!['description'] ?? ''),
            SizedBox(height: 16),
            Text('Address: ${requestData!['location']?['address'] ?? ''}'),
            SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => updateStatus('acknowledged'),
                  child: Text('Acknowledge'),
                ),
                ElevatedButton(
                  onPressed: () => updateStatus('in_progress'),
                  child: Text('In Progress'),
                ),
                ElevatedButton(
                  onPressed: () => updateStatus('resolved'),
                  child: Text('Resolve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
