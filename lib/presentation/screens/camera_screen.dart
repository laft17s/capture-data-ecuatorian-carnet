import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:capture_data_ecuatorian_carnet/core/logger.dart';
import 'package:capture_data_ecuatorian_carnet/data/services/ocr_service.dart';
import 'package:capture_data_ecuatorian_carnet/presentation/screens/result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;
      setState(() {});
    } catch (e) {
      MyLogger.e('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captura de Cédula')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final size = MediaQuery.of(context).size;
                var scale = size.aspectRatio * _controller.value.aspectRatio;

                if (scale < 1) scale = 1 / scale;

                return Transform.scale(
                  scale: scale,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            final ocrService = OCRService();
            final result =
                await ocrService.extractTextAndImageFromImage(File(image.path));

            final extractedData = result['text'] as Map<String, String>;
            final imageWidget = Image.file(File(image.path));

            // Navegar a la pantalla de resultados
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(
                  imageWidget: imageWidget,
                  ocrText: extractedData.toString(),
                ),
              ),
            );
          } catch (e) {
            MyLogger.e('Error al capturar la imagen: $e');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
