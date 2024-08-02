import "package:firebase_auth/firebase_auth.dart";
//import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:kidnav/geofecing%20_tools/geofence_analyser.dart";
import "package:kidnav/geofecing%20_tools/algorithm_check.dart";
import "package:kidnav/history_page/history_home_page.dart";
import "package:kidnav/main_status/home_status_page.dart";
import "package:kidnav/main_status/main_location_display.dart";
import "package:kidnav/main_status/main_status.dart";
import "package:kidnav/main_status/status_map.dart";
import "package:kidnav/notification/notif_test.dart";
import "package:kidnav/geofecing%20_tools/geofence_print_status.dart";
import "package:kidnav/geofence_page/geofence_home_page.dart";
import "package:kidnav/history_page/geofence_alert_history.dart";
import "package:kidnav/homepage_components/bottom_nav_bar.dart";
import "package:kidnav/sms/check_sms.dart";
import "package:kidnav/user_profile/user_profile.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  //sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  //navigate bottom bar
  int _selectedIndex = 0;
  void navigateBottomBar(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }

  //pages to display
  final List<Widget> _pages = [
    //status page
    // SimulateStatusPage(),
    HomeStatusPage(),

    //Map Page\
    // CheckSms(),
    StatusMap(),

    //Geofence Page
    GeofenceHomePage(),

    //History Page
    HistoryHomePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffdcdae7),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfile(),
                ),
              );
            },
            icon: const Icon(Icons.account_circle),
          ),
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      // body: Center(
      //   child: Text(
      //     "LOGGED IN AS:" + user.email!,
      //     style: TextStyle(fontSize: 20),
      //   ),
      // ),
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
    );
  }
}
