import 'dart:ui';

extension ColorExt on Color {
  Color brighten(double value) {
    double red = (r + value).clamp(0.0, 1.0);
    double green = (g + value).clamp(0.0, 1.0);
    double blue = (b + value).clamp(0.0, 1.0);

    return Color.fromARGB(
      255,
      (red * 255).toInt(),
      (green * 255).toInt(),
      (blue * 255).toInt(),
    );
  }

  Color darken(double value) {
    double red = (r - value).clamp(0.0, 1.0);
    double green = (g - value).clamp(0.0, 1.0);
    double blue = (b - value).clamp(0.0, 1.0);

    return Color.fromARGB(
      255,
      (red * 255).toInt(),
      (green * 255).toInt(),
      (blue * 255).toInt(),
    );
  }
}
