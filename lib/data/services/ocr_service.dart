import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OCRService {
  final textRecognizer = TextRecognizer();

  Future<Map<String, dynamic>> extractTextAndImageFromImage(
      File imageFile) async {
    // Leer los bytes de la imagen
    final imageBytes = await imageFile.readAsBytes();

    // Decodificar la imagen usando el paquete 'image'
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Error al decodificar la imagen');
    }

    // Convertir la imagen a formato adecuado para ML Kit
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // Crear un objeto ui.Image a partir de los bytes de la imagen original
    final imgBytes = img.encodePng(image);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(Uint8List.fromList(imgBytes), (ui.Image img) {
      completer.complete(img);
    });
    final uiImage = await completer.future;

    // Crear un objeto PictureRecorder y un Canvas para dibujar
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromLTWH(
            0, 0, uiImage.width.toDouble(), uiImage.height.toDouble()));

    // Dibujar la imagen original en el Canvas
    canvas.drawImage(uiImage, Offset.zero, Paint());

    // Crear color verde para dibujar en formato ARGB
    final greenPaint = Paint()
      ..color = const ui.Color(0xFF00FF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar los cuadros verdes alrededor del texto detectado
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final rect = element.boundingBox;

          // Dibujar los bordes del rectángulo en el Canvas
          canvas.drawRect(
            Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height),
            greenPaint,
          );
        }
      }
    }

    // Crear la imagen final a partir del PictureRecorder
    final picture = recorder.endRecording();
    final finalImage = await picture.toImage(uiImage.width, uiImage.height);

    // Extraer el texto de los bloques reconocidos
    final StringBuffer textBuffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          textBuffer.writeln(element.text);
        }
      }
    }

    return {
      'image': finalImage,
      'text': textBuffer.toString(),
    };
  }
}
