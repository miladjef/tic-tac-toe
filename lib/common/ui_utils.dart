import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UiUtils {
  UiUtils._();
  static SvgPicture getSvg(String path,
      {Color? color,
      BoxFit fit = BoxFit.contain,
      double? width,
      double? height}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return SvgPicture.network(
        path,
        fit: fit,
        width: width,
        height: height,
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );
    }
    return SvgPicture.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget getImage(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      // Network Image
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: width ?? 24.0);
        },
      );
    } else {
      // Local Asset Image
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: width ?? 24.0);
        },
      );
    }
  }

  static bool isDialogActive = false;
  static Future showDialog(BuildContext context,
      {required Widget child,
      int? millisecondTransitionDuration,
      bool? dismissible}) async {
    //we dont active dialog if the dialog is active already

    return await showGeneralDialog(
      context: context,
      barrierDismissible: (dismissible ?? true),
      barrierLabel: 'Dismiss',
      transitionDuration:
          Duration(milliseconds: millisecondTransitionDuration ?? 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return child;
      },
    );
  }

  static String getSkin(String skin) {
    if (skin.startsWith('http://') || skin.startsWith('https://')) {
      return skin;
    }
    return 'assets/svg/skins/$skin.svg';
  }
}
