import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/extensions/color_extension.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';

class CustomButton extends StatefulWidget {
  final String? title;
  final Widget? customWidget;
  final VoidCallback? onTap;
  final ButtonType type;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final double? radius;
  final Color? color;
  final Color? textColor;
  final bool inProgress;
  const CustomButton(
      {super.key,
      this.padding,
      this.title,
      this.textColor,
      required this.onTap,
      this.type = ButtonType.shadow,
      this.width,
      this.height,
      this.customWidget,
      this.radius,
      this.color,
      this.inProgress = false});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  late bool isPressed = widget.onTap != null ? false : true;

  @override
  void initState() {
    super.initState();
  }

  Widget buildTitle() {
    if (widget.customWidget != null) {
      return widget.customWidget!;
    }

    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.inProgress) ...[
          SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.color.onSurface,
              )),
          SizedBox(
            width: 5,
          ),
        ],
        Flexible(
          child: CustomText(
            widget.title ?? '',
            fontSize: context.font.medium,
            color: widget.textColor ?? AppColors.white,
            fontWeight: FontWeight.w700,
            maxLines: 1,
            ellipsis: true,
          ),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == ButtonType.shadow) {
      return GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            isPressed = true;
            setState(() {});

            Future.delayed(Duration(milliseconds: 150)).then((value) {
              isPressed = false;
              setState(() {});
            });
            widget.onTap?.call();
          }
        },
        child: InnerShadowContainer(
          child: Container(
            padding: widget.padding,
            width: widget.width,
            height: widget.height,
            child: buildTitle(),
          ),
        ),
      );
    }

    if (widget.type == ButtonType.primary) {
      return MaterialButton(
        minWidth: widget.width,
        padding: widget.padding,
        textColor: widget.textColor,
        height: widget.height ?? 40,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.radius ?? 6)),
        color: widget.color ?? context.color.secondary,
        onPressed: widget.onTap,
        child: buildTitle(),
      );
    }

    if (widget.type == ButtonType.gradient) {
      assert(widget.color != null, 'Color must not be null');
      return Transform.translate(
        offset: isPressed ? Offset(1, 2) : Offset(0, 0),
        child: GestureDetector(
          onTapDown: (details) {
            if (widget.onTap != null) {
              isPressed = true;
              setState(() {});
            }
          },
          onTapUp: (f) async {
            if (widget.onTap != null) {
              await Future.delayed(Duration(milliseconds: 150));
              isPressed = false;
              setState(() {});
              widget.onTap?.call();
            }
          },
          onTapCancel: () {
            isPressed = false;
            setState(() {});
          },
          child: Container(
              width: widget.width,
              height: widget.height ?? double.maxFinite,
              decoration: BoxDecoration(
                  boxShadow: [
                    if (!isPressed)
                      BoxShadow(
                        blurRadius: 8,
                        color: context.color.surface,
                        offset: Offset(3, 3),
                      )
                  ],
                  borderRadius: BorderRadius.circular(widget.radius ?? 6),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [
                        0.05,
                        1.0
                      ],
                      colors: [
                        widget.color!.brighten(isPressed ? 0.3 : 0.4),
                        widget.color!.darken(isPressed ? 0.6 : 0.5),
                      ])),
              child: Padding(
                padding: widget.padding ?? EdgeInsets.zero,
                child: buildTitle(),
              )),
        ),
      );
    }

    return Container();
  }
}
