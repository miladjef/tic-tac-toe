import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';

class GradientRouter extends PageRoute<void> {
  final bool? barrierDismiss;
  final bool disableMazeBackground;
  GradientRouter(
      {required this.builder,
      this.barrierDismiss,
      super.settings,
      this.disableMazeBackground = false})
      : super(fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;
  @override
  Color get barrierColor => Colors.transparent;
  @override
  bool get barrierDismissible => barrierDismiss ?? super.barrierDismissible;

  @override
  String get barrierLabel => "blurred";

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final Widget result = builder(context);
    final Widget screen = Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: AppColors.screenBackgroundGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Stack(
          children: [
            if (!disableMazeBackground)
              Positioned(
                top: -130,
                left: -120,
                child: Image.asset(AppIcons.mazeIcon),
              ),
            if (!disableMazeBackground)
              Positioned(
                bottom: -140,
                right: -130,
                child: Image.asset(AppIcons.mazeIcon),
              ),
            result,
          ],
        ));

    if (Platform.isIOS) {
      final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;

      return theme.buildTransitions(
        this,
        context,
        animation,
        Animation.fromValueListenable(ValueNotifier(0)),
        screen,
      );
    }
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: screen,
    );
  }
}
