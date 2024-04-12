import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green, // Set the app's primary theme color
      ),
      debugShowCheckedModeBanner: false,
      home: SimpleClinometer(),
    );
  }
}

class SimpleClinometer extends StatefulWidget {
  const SimpleClinometer({super.key});

  @override
  State<SimpleClinometer> createState() => _SimpleClinometerState();
}

class _SimpleClinometerState extends State<SimpleClinometer> {
  // List to store accelerometer data
  List<AccelerometerEvent> _accelerometerValues = [];
  List<double> angle = [0.0, 0.0, 0.0];
  List<double> angleHold = [999, 999, 999];
  // StreamSubscription for accelerometer events
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();

    // Subscribe to accelerometer events
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        // Update the _accelerometerValues list with the latest event
        _accelerometerValues = [event];
        var angCorrection = [
          -atan(_accelerometerValues[0].y / _accelerometerValues[0].z) *
              (180.0 / pi),
          -atan(_accelerometerValues[0].x / _accelerometerValues[0].z) *
              (180.0 / pi),
          atan(_accelerometerValues[0].y / _accelerometerValues[0].x) *
                  (180.0 / pi) +
              0.0 //correction for mobile
        ];
        const beta = 0.0001;
        angle = [
          beta * angle[0] + (1 - beta) * angCorrection[0],
          beta * angle[1] + (1 - beta) * angCorrection[1],
          beta * angle[2] + (1 - beta) * angCorrection[2]
        ];
      });
    });
  }

  @override
  void dispose() {
    // Cancel the accelerometer event subscription to prevent memory leaks
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Clinometer'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (angleHold[0] == 999.0) {
                angleHold = angle;
                print(angleHold);
              } else {
                angleHold = [999.0, 999.0, 999.0];
                print(angleHold);
              }
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Angle data:',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              if (angleHold[0] != 999.0 && _accelerometerValues.isNotEmpty)
                Text(
                  'X: ${angleHold[0].toStringAsFixed(2)}, '
                  'Y: ${angleHold[1].toStringAsFixed(2)}, '
                  'Z: ${angleHold[2].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                )
              else
                SizedBox(height: 23),
              if (angleHold[0] != 999.0 && _accelerometerValues.isNotEmpty)
                Text(
                  'X: ${(angle[0] - angleHold[0]).toStringAsFixed(2)}, '
                  'Y: ${(angle[1] - angleHold[1]).toStringAsFixed(2)}, '
                  'Z: ${(angle[2] - angleHold[2]).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
              if (angleHold[0] == 999.0 && _accelerometerValues.isNotEmpty)
                Text(
                  'X: ${angle[0].toStringAsFixed(2)}, '
                  'Y: ${angle[1].toStringAsFixed(2)}, '
                  'Z: ${angle[2].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
              if (_accelerometerValues.isEmpty)
                Text('No data available', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
