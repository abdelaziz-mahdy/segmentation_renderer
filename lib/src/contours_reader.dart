import 'package:flutter/services.dart';

class Point {
  double x;
  double y;

  Point({required this.x, required this.y});
}

class Contour {
  List<Point> points;

  Contour({required this.points});
}

class ContoursReader {
  static Future<List<String>> loadLinesFromAsset(String path) async {
    return (await rootBundle.loadString(path)).split("\n");
  }

  static Future<List<Contour>> readContoursFromAssetFile(String path) async {
    return readContours(await loadLinesFromAsset(path));
  }

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
