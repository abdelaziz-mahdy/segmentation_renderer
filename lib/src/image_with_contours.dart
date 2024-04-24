import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'contours_painter.dart';
import 'contours_reader.dart';
import 'shape_around_contours_painter.dart';

/// Enum representing different types of rendering for the image with contours.
enum RenderType {
  /// Render only the contours.
  contours,

  /// Render bounding boxes around the contours.
  boundingBox,

  /// Render both contours and bounding boxes.
  both
}

/// Widget for displaying an image with contours.
class ImageWithContours extends StatefulWidget {
  /// The image to be displayed.
  final Image image;

  /// The list of contours to be displayed on the image.
  final List<Contour> contours;

  /// The type of rendering for the image with contours.
  final RenderType renderType;

  /// The fit for the image within its container.
  final BoxFit imageFit;

  /// Whether to smooth the paths of the contours.
  final bool smoothPath;

  /// The color of the contour lines.
  final Color contourColor;

  /// The width of the contour lines.
  final double contourStrokeWidth;

  /// Whether to fill the areas enclosed by the contours.
  final bool fillContours;

  /// The type of shape to be drawn around the contours.
  final ShapeType shapeType;

  /// The color of the shape drawn around the contours.
  final Color shapeColor;

  /// The width of the strokes used to draw the shape around the contours.
  final double shapeStrokeWidth;

  /// The padding around the shapes drawn around the contours.
  final double allAroundPadding;

  /// Constructs an ImageWithContours widget.
  const ImageWithContours({
    super.key,
    required this.image,
    required this.contours,
    this.renderType = RenderType.contours,
    this.imageFit = BoxFit.scaleDown,
    this.smoothPath = true,
    this.contourColor = Colors.red,
    this.contourStrokeWidth = 2,
    this.fillContours = false,
    this.shapeType = ShapeType.rectangle,
    this.shapeColor = Colors.blue,
    this.shapeStrokeWidth = 2,
    this.allAroundPadding = 10,
  });

  @override
  State<ImageWithContours> createState() => _ImageWithContoursState();
}

class _ImageWithContoursState extends State<ImageWithContours>
    with WidgetsBindingObserver {
  final GlobalKey imageKey = GlobalKey();
  Completer<ui.Image> completer = Completer<ui.Image>();
  Size? imageSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        if (!completer.isCompleted) {
          completer.complete(info.image);
        }
      }),
    );
    Future.microtask(() => completer.future.then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) => measureSize());
        }));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) => measureSize());
  }

  void measureSize() {
    if (imageKey.currentContext != null) {
      final RenderBox renderBox =
          imageKey.currentContext!.findRenderObject() as RenderBox;
      final newSize = renderBox.size;
      if (newSize != imageSize) {
        setState(() {
          imageSize = newSize;
        });
      }
    }
    // run after build
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) => measureSize());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: completer.future,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        } else {
          return Stack(
            children: [
              Image(
                image: widget.image.image,
                fit: widget.imageFit,
                key: imageKey,
              ),
              if (widget.renderType == RenderType.boundingBox ||
                  widget.renderType == RenderType.both)
                if (imageSize != null)
                  CustomPaint(
                    painter: ShapeAroundContoursPainter(
                      contours: widget.contours,
                      imageHeight: snapshot.data!.height.toDouble(),
                      imageWidth: snapshot.data!.width.toDouble(),
                      renderHeight: imageSize!.height,
                      renderWidth: imageSize!.width,
                      shapeType: widget.shapeType,
                      color: widget.shapeColor,
                      strokeWidth: widget.shapeStrokeWidth,
                      allAroundPadding: widget.allAroundPadding,
                    ),
                  ),
              if (widget.renderType == RenderType.contours ||
                  widget.renderType == RenderType.both)
                if (imageSize != null)
                  CustomPaint(
                    painter: ContoursPainter(
                      contours: widget.contours,
                      imageHeight: snapshot.data!.height.toDouble(),
                      imageWidth: snapshot.data!.width.toDouble(),
                      renderHeight: imageSize!.height,
                      renderWidth: imageSize!.width,
                      smoothPath: widget.smoothPath,
                      color: widget.contourColor,
                      strokeWidth: widget.contourStrokeWidth,
                      fillArea: widget.fillContours,
                    ),
                  ),
            ],
          );
        }
      },
    );
  }
}
