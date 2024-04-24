import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'contours_painter.dart';
import 'contours_reader.dart';
import 'shape_around_contours_painter.dart';

enum RenderType { contours, boundingBox, both }

class ImageWithContours extends StatefulWidget {
  final Image image;
  final List<Contour> contours;
  final RenderType renderType;
  final BoxFit imageFit;
  final bool smoothPath;
  final Color contourColor;
  final double contourStrokeWidth;
  final bool fillContours;
  final ShapeType shapeType;
  final Color shapeColor;
  final double shapeStrokeWidth;
  final double allAroundPadding;

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
