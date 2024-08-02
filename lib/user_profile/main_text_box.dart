import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  void Function()? onPressed;

  MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 73, 67, 112),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //section Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //section name
              Text(
                sectionName,
                style: const TextStyle(color: Colors.white),
              ),

              //edit button
              IconButton(
                  onPressed: onPressed,
                  icon: const Icon(
                    Icons.edit,
                    color: Color.fromARGB(255, 14, 7, 51),
                  ))
            ],
          ),

          //Text
          Text(text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              )),
        ],
      ),
    );
  }
}
