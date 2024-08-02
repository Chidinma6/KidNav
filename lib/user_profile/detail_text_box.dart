import 'package:flutter/material.dart';

class DetailTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final Function(String) onPressed;

  DetailTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 73, 66, 117),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 10),
                child: Text(
                  sectionName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ),
            ],
          ),

          // Text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: text
                  .split('\n')
                  .map((line) {
                    // Extract field name
                    String fieldName = line.split(':').first.trim();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 201, 196, 226),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  line,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 3, 3, 3),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Color.fromARGB(255, 3, 3, 3),
                                  ),
                                  onPressed: () => onPressed(fieldName),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  })
                  .expand((element) => [element, const SizedBox(height: 2)])
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
