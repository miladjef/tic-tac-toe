import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';

class DashedAvatarWidget extends StatelessWidget {
  final String image;
  final double? size;
  const DashedAvatarWidget({super.key, required this.image, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      foregroundDecoration: BoxDecoration(
          border: Border.all(color: AppColors.white, width: 2),
          shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: AppColors.white,
            radius: Radius.circular(800000),
            dashPattern: [3, 3],
          ),
          child: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: CustomImage(
              image,
              width: size ?? 80,
              height: size ?? 80,
            ),
          )),
    );
  }
}
