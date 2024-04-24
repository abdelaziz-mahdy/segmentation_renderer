import 'package:flutter/material.dart';

import 'contours_reader.dart';

class ContoursPainter extends CustomPainter {
  final List<Contour> contours;
  final double? imageWidth;
  final double? imageHeight;
  final double? renderWidth;
  final double? renderHeight;
  final bool fillArea;
  final bool smoothPath;
  final Color color;
  final double strokeWidth;

  ContoursPainter({
    required this.contours,
    this.imageWidth,
    this.imageHeight,
    this.renderWidth,
    this.renderHeight,
    this.color = Colors.red,
    this.strokeWidth = 2,
    this.fillArea = false,
    this.smoothPath = true,
  });

  double scaledXPoint(double x) {
    return (imageWidth != null && renderWidth != null)
        ? (x / imageWidth!) * renderWidth!
        : x;
  }

  double scaledYPoint(double y) {
    return (imageHeight != null && renderHeight != null)
        ? (y / imageHeight!) * renderHeight!
        : y;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = fillArea ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (Contour contour in contours) {
      Path path = Path();
      if (contour.points.isNotEmpty) {
        Point firstPoint = contour.points.first;
        path.moveTo(scaledXPoint(firstPoint.x), scaledYPoint(firstPoint.y));

        if (contour.points.length == 1) {
          // If there's only one point, draw a dot
          canvas.drawCircle(
              Offset(scaledXPoint(firstPoint.x), scaledYPoint(firstPoint.y)),
              strokeWidth / 2,
              paint);
        } else {
          for (int i = 1; i < contour.points.length; i++) {
            Point current = contour.points[i];
            Point previous = contour.points[i - 1];
            double ctrl1X = scaledXPoint(previous.x);
            double ctrl1Y = scaledYPoint(previous.y);
            double ctrl2X = scaledXPoint(current.x);
            double ctrl2Y = scaledYPoint(current.y);
            double midX = (ctrl1X + ctrl2X) / 2;
            double midY = (ctrl1Y + ctrl2Y) / 2;

            if (smoothPath) {
              path.cubicTo(ctrl1X, ctrl1Y, ctrl2X, ctrl2Y, midX, midY);
            } else {
              path.lineTo(ctrl2X, ctrl2Y);
            }
          }
        }
        // Close the path to connect the last point to the first
        path.close();
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ContoursPainter oldDelegate) {
    // Only repaint if there is a change in the contours or paint settings
    return oldDelegate.contours != contours ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.fillArea != fillArea ||
        oldDelegate.smoothPath != smoothPath ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight ||
        oldDelegate.renderWidth != renderWidth ||
        oldDelegate.renderHeight != renderHeight;
  }
}
