import "package:flutter/material.dart";
import "package:google_nav_bar/google_nav_bar.dart";

class BottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;

  BottomNavBar({
    super.key,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffdcdae7),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GNav(
          onTabChange: (value) => onTabChange!(value),
          backgroundColor: Color(0xffdcdae7),
          activeColor: Color(0xff3c2c74),
          color: Color(0xff5c5494),
          tabActiveBorder: Border.all(color: Colors.black),
          gap: 2,
          iconSize: 28,
          textSize: 48,
          tabs: const [
            //status
            GButton(icon: Icons.home, text: "Status"),

            // Map
            GButton(icon: Icons.map, text: "Map"),

            //Geofence
            GButton(
              icon: Icons.edit_location_alt,
              text: "Geofence",
            ),

            //History
            GButton(
              icon: Icons.history,
              text: "History",
            )
          ],
        ),
      ),
    );
  }
}
