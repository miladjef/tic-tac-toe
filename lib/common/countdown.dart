import 'dart:async';
import 'package:flutter/foundation.dart';

class Countdown {
  final ValueNotifier<int> current;
  Timer? _timer;
  final Duration _interval;
  int? _start;

  void Function()? endCallback;
  void reset() {
    current.value = _start!;
    _timer?.cancel();
  }

  Countdown(int start, {Duration interval = const Duration(seconds: 1)})
      : current = ValueNotifier<int>(start),
        _interval = interval {
    _start = start;

    current.addListener(
      () {
        if (current.value == 0) {
          endCallback?.call();
        }
      },
    );
  }

  void onTimerEnd(void Function() callBack) {
    endCallback = callBack;
  }

  void start() {
    _timer?.cancel();

    _timer = Timer.periodic(_interval, (timer) {
      if (current.value > 0) {
        current.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    current.dispose();
  }
}
