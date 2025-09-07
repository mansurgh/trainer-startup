import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  // This script generates app icons for different platforms
  print('Generating app icons...');
  
  // Create a simple icon programmatically
  final iconData = _createIconData();
  
  // Save as PNG for different sizes
  await _saveIcon(iconData, 1024, 'icon_1024.png');
  await _saveIcon(iconData, 512, 'icon_512.png');
  await _saveIcon(iconData, 256, 'icon_256.png');
  await _saveIcon(iconData, 128, 'icon_128.png');
  await _saveIcon(iconData, 64, 'icon_64.png');
  await _saveIcon(iconData, 32, 'icon_32.png');
  await _saveIcon(iconData, 16, 'icon_16.png');
  
  print('Icons generated successfully!');
}

Uint8List _createIconData() {
  // Create a simple icon with Flutter's painting system
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Background circle
  final paint = Paint()
    ..color = const Color(0xFF6C5CE7)
    ..style = PaintingStyle.fill;
  
  canvas.drawCircle(const Offset(512, 512), 512, paint);
  
  // Fitness icon
  final iconPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  
  // Draw a simple fitness icon (dumbbell)
  _drawDumbbell(canvas, iconPaint);
  
  final picture = recorder.endRecording();
  final image = picture.toImage(1024, 1024);
  
  return image.toByteData(format: ui.ImageByteFormat.png)?.buffer.asUint8List() ?? Uint8List(0);
}

void _drawDumbbell(Canvas canvas, Paint paint) {
  // Draw a simple dumbbell shape
  final path = Path();
  
  // Left weight
  path.addOval(const Rect.fromLTWH(200, 400, 100, 100));
  
  // Right weight  
  path.addOval(const Rect.fromLTWH(700, 400, 100, 100));
  
  // Bar
  path.addRect(const Rect.fromLTWH(300, 450, 400, 20));
  
  // Left handle
  path.addRect(const Rect.fromLTWH(250, 440, 50, 40));
  
  // Right handle
  path.addRect(const Rect.fromLTWH(700, 440, 50, 40));
  
  canvas.drawPath(path, paint);
}

Future<void> _saveIcon(Uint8List iconData, int size, String filename) async {
  final file = File('assets/icons/$filename');
  await file.create(recursive: true);
  await file.writeAsBytes(iconData);
  print('Saved $filename (${size}x$size)');
}
