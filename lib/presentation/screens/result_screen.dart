import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Widget imageWidget;
  final String ocrText;

  const ResultScreen({
    super.key,
    required this.imageWidget,
    required this.ocrText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: Column(
        children: [
          Expanded(child: imageWidget),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Texto OCR:\n$ocrText',
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
