import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50); // Turunkan garis awal sedikit

    // === GEL. 1 (Kiri - Lebih dalam dan dekat kiri) ===
    var controlPoint1 = Offset(size.width * 0.2, size.height);
    var endPoint1 = Offset(size.width * 0.4, size.height - 30);

    // === GEL. 2 (Kanan - Lebih tinggi naik ke kanan) ===
    var controlPoint2 = Offset(size.width * 0.75, size.height - 90);
    var endPoint2 = Offset(size.width, size.height - 60);

    path.quadraticBezierTo(
      controlPoint1.dx, controlPoint1.dy,
      endPoint1.dx, endPoint1.dy,
    );
    path.quadraticBezierTo(
      controlPoint2.dx, controlPoint2.dy,
      endPoint2.dx, endPoint2.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

