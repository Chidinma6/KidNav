// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kidnav/geofence_page/create_geofence.dart';
import 'package:kidnav/geofence_page/geofence_list_page.dart';
import 'package:kidnav/geofence_page/view_geofence.dart';
import 'package:kidnav/history_page/geofence_alert_history.dart';
import 'package:kidnav/history_page/location_history.dart';

class HistoryHomePage extends StatelessWidget {
  const HistoryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'History:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 59, 48, 99),
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Check Location and Geofence Alert History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 74, 64, 109),
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LocationHistory(),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffdcdae7),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text(
                'Location History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => GeofenceAlertHistoryPage(),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffdcdae7),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text(
                'Geofence Alert History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
