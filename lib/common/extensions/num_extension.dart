extension NumExtension on num {
  String get toStringWithCommas {
    final String number = toString();
    if (number.length >= 4) {
      return number.replaceRange(3, 4, ',');
    }
    return number;
  }

  double minMaxNormalize(double min, double max) {
    if (min == max) return 0.0; // Avoid division by zero
    return (this - min) / (max - min);
  }
}
