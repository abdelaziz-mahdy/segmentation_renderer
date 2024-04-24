import 'package:flutter/material.dart';

import 'contours_reader.dart';

/// Custom painter for drawing contours on a canvas.
class ContoursPainter extends CustomPainter {
  /// The list of contours to be painted.
  final List<Contour> contours;

  /// The width of the original image, used for scaling.
  final double? imageWidth;

  /// The height of the original image, used for scaling.
  final double? imageHeight;

  /// The width of the real rendered image, used for scaling.
  final double? renderWidth;

  /// The height of the real rendered image, used for scaling.
  final double? renderHeight;

  /// The color used to paint the contours.
  final Color color;

  /// The width of the strokes used to draw the contours.
  final double strokeWidth;

  /// Whether to fill the area enclosed by the contours.
  final bool fillArea;

  /// Whether to smooth the paths when drawing the contours.
  final bool smoothPath;

  /// Constructs a ContoursPainter instance.
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

  /// Scales the x-coordinate of a point based on image and render dimensions.
  double scaledXPoint(double x) {
    return (imageWidth != null && renderWidth != null)
        ? (x / imageWidth!) * renderWidth!
        : x;
  }

  /// Scales the y-coordinate of a point based on image and render dimensions.
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
