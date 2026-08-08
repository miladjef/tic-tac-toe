import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/custom_button.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';

class DialogButton {
  final String title;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool inProgress;
  final String? icon;
  const DialogButton(
      {required this.title,
      this.color,
      this.onTap,
      this.textColor,
      this.inProgress = false,
      this.icon});
}

class CustomDialogBox extends StatelessWidget {
  final String title;
  final bool hideCloseButton;
  final Widget child;
  final List<DialogButton>? buttons;
  const CustomDialogBox(
      {super.key,
      required this.title,
      this.hideCloseButton = false,
      required this.child,
      this.buttons});

  @override
  Widget build(BuildContext context) {
    return CustomDialogBoxBuilder(
      builder: (context) {
        return Material(
          child: Column(
            children: [
              if (!hideCloseButton) buildCloseIcon(context),
              if (hideCloseButton)
                SizedBox(
                  height: 10,
                ),
              buildHeader(context),
              child,
              buildButtonRow(context)
            ],
          ),
        );
      },
    );
  }

  Widget buildButtonRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        spacing: 10,
        children: [
          for (DialogButton button in buttons ?? []) ...[
            Expanded(
              child: CustomButton(
                onTap: button.onTap,
                title: button.title,
                textColor: button.textColor,
                customWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (button.icon != null) ...[
                      CustomImage(
                        button.icon!,
                        width: 14,
                        height: 14,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                    Flexible(
                      child: CustomText(
                        button.title,
                        color: button.textColor,
                        fontSize: context.font.medium,
                        maxLines: 1,
                        ellipsis: true,
                      ),
                    )
                  ],
                ),
                type: ButtonType.primary,
                color: button.color,
                inProgress: button.inProgress,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomText(
          title,
          fontWeight: FontWeight.w700,
          fontSize: context.font.large,
          color: AppColors.white,
        ),
        Divider(
          endIndent: 14,
          indent: 14,
          thickness: 0.5,
          color: context.color.outline,
        ),
      ],
    );
  }

  Widget buildCloseIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, null);
      },
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Container(
          margin: EdgeInsetsDirectional.only(top: 10, end: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.color.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Icon(
              color: context.color.onSurface.withAlpha(150),
              Icons.close_rounded,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDialogBoxBuilder extends StatelessWidget {
  final double? height;
  final double? width;
  final double? dottedLineDistance;
  final double? distanceRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? shadowBlurRadius;
  final Offset? shadowOffset;
  final Function()? onDismiss;
  final WidgetBuilder builder;

  const CustomDialogBoxBuilder({
    super.key,
    this.height,
    this.width,
    required this.builder,
    this.dottedLineDistance,
    this.distanceRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.shadowBlurRadius,
    this.shadowOffset,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final kInnerDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius ?? 10),
      boxShadow: [
        BoxShadow(
          color: Color.fromARGB(173, 242, 242, 242),
          blurRadius: 0,
          spreadRadius: -10,
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.surface,
          spreadRadius: -8,
          blurRadius: shadowBlurRadius ?? 8.0,
          offset: shadowOffset ?? Offset(0, 0),
        ),
      ],
    );

    return GestureDetector(
      onTap: onDismiss,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: FittedBox(
          fit: BoxFit.none,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              width: width ?? context.screenWidth,
              height: height,
              decoration: kInnerDecoration,
              child: FittedBox(
                fit: BoxFit.none,
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    color: borderColor ?? Theme.of(context).colorScheme.outline,
                    strokeWidth: 1,
                    stackFit: StackFit.loose,
                    borderPadding: EdgeInsets.all(distanceRadius ?? 20),
                    dashPattern: [4, 4],
                    radius: Radius.circular(borderRadius ?? 10),
                  ),
                  child: SizedBox(
                    width: width ?? context.screenWidth,
                    height: height,
                    child: Padding(
                      padding: EdgeInsets.all(distanceRadius ?? 20),
                      child: builder(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
