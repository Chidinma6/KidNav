import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class GeofenceAlertHistoryPage extends StatefulWidget {
  const GeofenceAlertHistoryPage({Key? key}) : super(key: key);

  @override
  State<GeofenceAlertHistoryPage> createState() =>
      _GeofenceAlertHistoryPageState();
}

class _GeofenceAlertHistoryPageState extends State<GeofenceAlertHistoryPage> {
  final activeUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference historyCollection = usersCollection
        .doc(activeUser.email!)
        .collection('Geofence Alert History');

    return Scaffold(
      appBar: AppBar(
        title: Text('Geofence Alert History'),
        backgroundColor: Color(0xffdcdae7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historyCollection
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final historyDocs = snapshot.data?.docs ?? [];

          if (historyDocs.isEmpty) {
            return Center(
              child: Text(
                'No Geofence Alert History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.separated(
            itemCount: historyDocs.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final historyData =
                  historyDocs[index].data() as Map<String, dynamic>;
              final historyMessage = historyData['message'];
              final historyTimestamp = historyData['timestamp'] as Timestamp?;

              return ListTile(
                title: Text(
                  historyMessage,
                ),
                subtitle: Text(
                  _formatTimestamp(historyTimestamp),
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
