import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/custom_button.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/screens/home/widgets/home_card_shape.dart';

class HomeCard extends StatefulWidget {
  final bool reverse;
  final String? title;
  final String subTitle;
  final String image;
  final VoidCallback? onTap;

  const HomeCard(
      {super.key,
      required this.reverse,
      required this.image,
      this.title,
      required this.subTitle,
      this.onTap});

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  @override
  Widget build(BuildContext context) {
    
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final visualFlip = isRtl ? !widget.reverse : widget.reverse;
    return Transform.flip(
      flipX: visualFlip,
      child: Container(
        width: context.screenWidth,
        decoration: ShapeDecoration(
          shape: HomeCardShapeBorder(borderColor: context.color.outline),
          shadows: [
            BoxShadow(
              color: Color(0xffFFFFFF).withValues(alpha: 0.07),
            ),
            BoxShadow(
              color: context.color.surface.withValues(alpha: 0.2),
              offset: Offset(visualFlip ? -5 : 5, 5),
              spreadRadius: 0,
              blurRadius: 0,
            ),
            BoxShadow(
                color: context.color.surface.withValues(alpha: 0.23),
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(visualFlip ? -3 : 3, 3)),
          ],
        ),
        child: Transform.flip(
          flipX: visualFlip,
          child: Row(
            children: [
              if (widget.reverse) buildContent(),
              CustomImage(
                widget.image,
                fit: BoxFit.contain,
              ),
              if (!widget.reverse) buildContent()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 64, 24, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          crossAxisAlignment: widget.reverse
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            CustomText(
              (widget.title ?? '').toUpperCase(),
              fontSize: context.font.xL,
              fontWeight: FontWeight.w700,
              maxLines: 2,
              ellipsis: true,
              color: AppColors.white,
              textAlign: widget.reverse ? TextAlign.start : TextAlign.end,
            ),
            CustomText(
              widget.subTitle,
              maxLines: 2,
              ellipsis: true,
              textAlign: widget.reverse ? TextAlign.start : TextAlign.end,
            ),
            CustomButton(
              onTap: () {
                widget.onTap?.call();
              },
              height: 32,
              title: context.tr('playNow'),
              type: ButtonType.primary,
            )
          ],
        ),
      ),
    );
  }
}
