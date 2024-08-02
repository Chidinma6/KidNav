import 'package:flutter/material.dart';

class AlgorithmCheck extends StatefulWidget {
  @override
  _AlgorithmCheckState createState() => _AlgorithmCheckState();
}

class _AlgorithmCheckState extends State<AlgorithmCheck> {
  final List<List<double>> polygon = [
    [6.6724843577207045, 3.15400448226083],
    [6.6721098252845765, 3.1549609942955343],
    [6.671698752772539, 3.154878219218609],
    [6.671497783861538, 3.154556316130007],
    [6.671534323669671, 3.1541332434992717],
    [6.672073285522982, 3.1539309044150077],
    [6.672338198758931, 3.1540044822638307],
  ];

  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();
  String resultMessage = '';
  final String geofenceName = 'My Geofence';

  int windingNumber(List<double> point, List<List<double>> polygon) {
    double x = point[0];
    double y = point[1];
    int num = polygon.length;
    int windingNumber = 0;

    for (int i = 0; i < num - 1; i++) {
      double x1 = polygon[i][0];
      double y1 = polygon[i][1];
      double x2 = polygon[i + 1][0];
      double y2 = polygon[i + 1][1];

      if (y1 <= y) {
        if (y2 > y && isLeft(x1, y1, x2, y2, x, y) > 0) {
          windingNumber++;
        }
      } else {
        if (y2 <= y && isLeft(x1, y1, x2, y2, x, y) < 0) {
          windingNumber--;
        }
      }
    }

    return windingNumber;
  }

  double isLeft(
      double x1, double y1, double x2, double y2, double x, double y) {
    return (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1);
  }

  void checkPoint() {
    double? latitude = double.tryParse(latController.text);
    double? longitude = double.tryParse(longController.text);

    if (latitude == null || longitude == null) {
      setState(() {
        resultMessage = 'Invalid coordinates';
      });
      return;
    }

    List<double> point = [latitude, longitude];
    int result = windingNumber(point, polygon);

    setState(() {
      resultMessage = result != 0
          ? 'The point is inside the polygon'
          : 'The point is outside the polygon';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geofence Checker'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: latController,
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: longController,
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: checkPoint,
                child: Text('Check Point'),
              ),
              SizedBox(height: 20),
              Text(
                resultMessage,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Geofence: $geofenceName',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Geofence Points:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: polygon.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          'Point ${index + 1}: [${polygon[index][0]}, ${polygon[index][1]}]'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
