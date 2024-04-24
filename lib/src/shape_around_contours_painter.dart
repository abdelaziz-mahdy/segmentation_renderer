import 'package:flutter/material.dart';

import 'contours_reader.dart';

enum ShapeType { rectangle, circle, ellipse }

class ShapeAroundContoursPainter extends CustomPainter {
  final List<Contour> contours;
  final double? imageWidth;
  final double? imageHeight;
  final double? renderWidth;
  final double? renderHeight;
  final ShapeType shapeType;
  final Color color;
  final double strokeWidth;
  final double allAroundPadding;

  ShapeAroundContoursPainter({
    required this.contours,
    this.imageWidth,
    this.imageHeight,
    this.renderWidth,
    this.renderHeight,
    this.shapeType = ShapeType.rectangle,
    this.color = Colors.blue,
    this.strokeWidth = 2,
    this.allAroundPadding = 10,
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
      ..style = PaintingStyle.stroke; // Change to fill if needed

    for (Contour contour in contours) {
      var boundingBox = _calculateBoundingBox(contour.points);
      switch (shapeType) {
        case ShapeType.rectangle:
          canvas.drawRect(boundingBox, paint);
          break;
        case ShapeType.circle:
          // Assuming boundingBox is square for circle, otherwise, ellipse is drawn
          double radius = boundingBox.width / 2;
          canvas.drawCircle(boundingBox.center, radius, paint);
          break;
        case ShapeType.ellipse:
          canvas.drawOval(boundingBox, paint);
          break;
      }
    }
  }

  Rect _calculateBoundingBox(List<Point> points) {
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    for (Point point in points) {
      double x = scaledXPoint(point.x);
      double y = scaledYPoint(point.y);
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
    return Rect.fromLTRB(
        minX - allAroundPadding / 2,
        minY - allAroundPadding / 2,
        maxX + allAroundPadding / 2,
        maxY + allAroundPadding / 2);
  }

  @override
  bool shouldRepaint(covariant ShapeAroundContoursPainter oldDelegate) {
    return oldDelegate.contours != contours ||
        oldDelegate.shapeType != shapeType ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.allAroundPadding != allAroundPadding ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight ||
        oldDelegate.renderWidth != renderWidth ||
        oldDelegate.renderHeight != renderHeight;
  }
}
