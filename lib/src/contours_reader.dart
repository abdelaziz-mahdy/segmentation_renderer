import 'package:flutter/services.dart';

/// Represents a point in 2D space with x and y coordinates.
class Point {
  double x;
  double y;

  /// Constructs a Point instance with the given x and y coordinates.
  Point({required this.x, required this.y});
}

/// Represents a contour, which is a sequence of points forming a path.
class Contour {
  List<Point> points;

  /// Constructs a Contour instance with the provided list of points.
  Contour({required this.points});
}

/// Utility class for reading contours from asset files.
class ContoursReader {
  /// Loads lines from an asset file located at the given [path].
  static Future<List<String>> loadLinesFromAsset(String path) async {
    return (await rootBundle.loadString(path)).split("\n");
  }

  /// Reads contours from an asset file located at the given [path].
  static Future<List<Contour>> readContoursFromAssetFile(String path) async {
    return readContours(await loadLinesFromAsset(path));
  }

  /// Parses lines representing contours and returns a list of Contour objects.
  /// if a contour line is invalid, it will be ignored and starts a new contour will be created.
  /// If there are no contours, an empty list will be returned.
  static List<Contour> readContours(List<String> lines) {
    List<Contour> contours = [];
    Contour contour = Contour(points: []);

    for (int i = 0; i < lines.length; i++) {
      List<String> line = lines[i].split(",");
      if (line.length != 2) {
        print("Invalid contour line: ${lines[i]} at line ${i + 1}");
        if (contour.points.isNotEmpty) {
          contours.add(contour);
        }
        contour = Contour(points: []);
        continue;
      }
      double x = double.parse(line[0]);
      double y = double.parse(line[1]);
      contour.points.add(Point(x: x, y: y));
    }
    contours.add(contour);
    return contours;
  }
}
