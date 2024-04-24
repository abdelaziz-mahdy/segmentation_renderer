# segmentation_renderer

The `segmentation_renderer` package provides a set of Flutter widgets and custom painters designed to visualize segmentation data. It is especially useful for applications dealing with image processing, where segmentations delineate different regions or contours of interest. This package allows the rendering of contours directly on images or separately as geometric shapes based on the segmentation data.

## Features

- **Custom Painters for Contours**: Draw detailed contours on any image based on segmentation data.
- **Shape Renderers**: Optionally, draw shapes such as rectangles, circles, or ellipses around the contours.
- **Flexible Rendering Options**: Choose to render just the contours, bounding shapes, or both, depending on the visualization needs.
- **Smooth Path Rendering**: Enhance the visual quality of contours with optional path smoothing.

## Widgets in the Package

- **`ImageWithContours`**: A widget that combines an image with overlays of contours or bounding shapes based on provided segmentation data. Note: this widget also auto scales the points based on the image render size.
- **`ContoursPainter`**: A custom painter that draws contours either smoothly or as sharp lines directly on a canvas.
- **`ShapeAroundContoursPainter`**: A custom painter that draws specified shapes around the contours.

## Usage

### Setup

Add the `segmentation_renderer` package to your Flutter project by including it in your `pubspec.yaml` file:

```yaml
dependencies:
  segmentation_renderer: ^1.0.0
```

### Basic Example

Here's how you can use the `ImageWithContours` widget in your Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:segmentation_renderer/segmentation_renderer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ImageWithContours(
            image: Image.asset('path/to/your/image.png'),
            contours: [
              Contour(points: [Point(x: 10, y: 10), Point(x: 50, y: 50)]),
              // More contours
            ],
            renderType: RenderType.both,
          ),
        ),
      ),
    );
  }
}
```

### Customization

Customize the appearance of the contours and the bounding shapes:

```dart
ImageWithContours(
  image: Image.asset('path/to/image.png'),
  contours: yourContoursData,
  renderType: RenderType.both,
  // Additional configurations
)
```

### Contours Data

Prepare your contours data, which can be dynamically loaded or statically defined:

```dart
List<Contour> yourContoursData = [
  Contour(points: [Point(x: 10, y: 10), Point(x: 20, y: 20), ...]),
  // Additional contours
];
```

## Contributions

Contributions are welcome! If you have ideas on how to improve this package or add new features, please feel free to contribute to the development.

## License

This package is available under the `MIT License`. See the LICENSE file for more details.
