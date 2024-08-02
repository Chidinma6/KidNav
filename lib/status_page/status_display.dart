import 'package:flutter/material.dart';

class StatusDisplay extends StatelessWidget {
  final String text;
  final String place;
  final String statuslat;
  final String statuslng;
  final String timeLocated;
  final void Function()? onPressed;

  StatusDisplay({
    Key? key,
    required this.text,
    required this.place,
    required this.statuslat,
    required this.statuslng,
    required this.timeLocated,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xff3c2c74),
            Color.fromARGB(255, 66, 45, 138),
            Color.fromARGB(255, 11, 28, 102),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 10), // Adjust the height as needed

          const Divider(
            color: Colors.white,
            thickness: 1,
            height: 20,
            indent: 0,
            endIndent: 0,
          ),

          Text(
            place,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 10), // Adjust the height as needed

          const Divider(
            color: Colors.white,
            thickness: 1,
            height: 20,
            indent: 0,
            endIndent: 0,
          ),

          Text(
            statuslat,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 10), // Adjust the height as needed

          const Divider(
            color: Colors.white,
            thickness: 1,
            height: 20,
            indent: 0,
            endIndent: 0,
          ),

          Text(
            statuslng,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 10), // Adjust the height as needed

          const Divider(
            color: Colors.white,
            thickness: 1,
            height: 20,
            indent: 0,
            endIndent: 0,
          ),

          Text(
            timeLocated,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
