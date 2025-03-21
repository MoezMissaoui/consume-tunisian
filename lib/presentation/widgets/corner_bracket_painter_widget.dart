import 'package:flutter/material.dart';

class CornerBracketPainterWidget extends CustomPainter {
  final Color color;

  CornerBracketPainterWidget({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    const double bracketLength = 20;
    const double cornerRadius = 0;

    // Top-left corner
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(cornerRadius, cornerRadius),
        radius: cornerRadius,
      ),
      3.14,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(Offset(cornerRadius, 0), Offset(bracketLength, 0), paint);
    canvas.drawLine(Offset(0, cornerRadius), Offset(0, bracketLength), paint);

    // Top-right corner
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width - cornerRadius, cornerRadius),
        radius: cornerRadius,
      ),
      -1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(size.width - cornerRadius, 0),
      Offset(size.width - bracketLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, cornerRadius),
      Offset(size.width, bracketLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(cornerRadius, size.height - cornerRadius),
        radius: cornerRadius,
      ),
      1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(cornerRadius, size.height),
      Offset(bracketLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height - cornerRadius),
      Offset(0, size.height - bracketLength),
      paint,
    );

    // Bottom-right corner
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width - cornerRadius, size.height - cornerRadius),
        radius: cornerRadius,
      ),
      0,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(size.width - cornerRadius, size.height),
      Offset(size.width - bracketLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerRadius),
      Offset(size.width, size.height - bracketLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
