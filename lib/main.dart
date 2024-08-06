import 'package:capture_data_ecuatorian_carnet/presentation/screens/camera_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: Scaffold(
        body: Center(
          child: CameraScreen(),
        ),
      ),
    );
  }
}
