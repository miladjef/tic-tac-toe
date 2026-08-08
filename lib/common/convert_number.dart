enum ClampReached { min, max }

class ConvertNumber {
  static double inRange({
    required double currentValue,
    required double minValue,
    required double maxValue,
    required double newMaxValue,
    required double newMinValue,
  }) {
    return (currentValue - minValue) /
            (maxValue - minValue) *
            (newMaxValue - newMinValue) +
        newMinValue;
  }

  static T clamp<T extends num>(
    T value,
    T min,
    T max,
    Function(ClampReached reached) callBack,
  ) {
    if (value == max) {
      callBack(ClampReached.max);
    } else if (value == min) {
      callBack(ClampReached.min);
    }
    return value.clamp(min, max) as T;
  }

  static bool isInteger(num value) => (value % 1) == 0;

  static String formatCompact(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
    } else {
      return number.toString();
    }
  }
}
