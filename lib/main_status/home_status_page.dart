import 'package:flutter/material.dart';
import 'package:kidnav/main_status/main_status.dart';
import 'package:kidnav/main_status/main_location_display.dart';

class HomeStatusPage extends StatefulWidget {
  @override
  State<HomeStatusPage> createState() => _HomeStatusPageState();
}

class _HomeStatusPageState extends State<HomeStatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 150),
            MainStatus(),
            SizedBox(height: 200),
            MainLocationDisplay(),
          ],
        ),
      ),
    );
  }
}
