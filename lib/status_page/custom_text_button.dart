import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0xff3c2c74),
                    Color.fromARGB(255, 36, 24, 75),
                    Color.fromARGB(255, 11, 28, 102),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(text),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(25),
              textStyle: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold,
                // Clear text color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
