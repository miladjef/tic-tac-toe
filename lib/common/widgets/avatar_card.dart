import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';

class AvatarCard extends StatelessWidget {
  final String image;
  final double width;
  final double height;
  final BoxFit? fit;
  final bool? disableShadow;
  final BoxShape shape;
  const AvatarCard(
      {super.key,
      required this.image,
      this.width = 45,
      this.height = 45,
      this.fit,
      this.disableShadow,
      this.shape = BoxShape.rectangle});

  @override
  Widget build(BuildContext context) {
    if (disableShadow == true) {
      return Padding(
        padding: EdgeInsets.all(4),
        child: CustomImage(image,
            width: width,
            height: height,
            fit: fit ?? BoxFit.cover,
            radius: shape == BoxShape.circle ? max(width, height) : 6),
      );
    }
    return InnerShadowContainer(
      height: height + 10,
      width: width + 10,
      shape: shape,
      child: Padding(
        padding: EdgeInsets.all(4),
        child: CustomImage(image,
            width: width,
            height: height,
            fit: fit ?? BoxFit.cover,
            radius: shape == BoxShape.circle ? max(width, height) : 6),
      ),
    );
  }
}
