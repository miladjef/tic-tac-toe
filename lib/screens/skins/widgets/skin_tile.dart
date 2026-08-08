import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/common/widgets/marquee.dart';
import 'package:tic_tac_toe/data/models/skin/skin_model.dart';
import 'package:tic_tac_toe/screens/skins/widgets/skin_claim_button.dart';

class SkinTile extends StatelessWidget {
  final Skin skin;
  final bool isPurchased;
  final bool isActive;
  const SkinTile(
      {super.key,
      required this.skin,
      required this.isPurchased,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        spacing: 11,
        children: [
          Expanded(
            flex: 5,
            child: InnerShadowContainer(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
                child: Row(
                  children: [
                    CustomImage(
                      UiUtils.getSkin(skin.skinX),
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 8),
                    CustomImage(
                      UiUtils.getSkin(skin.skinO),
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: MarqueeWidget(
                        child: CustomText(
                          skin.name,
                          fontSize: context.font.large,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: SkinClaimButton(
                skin: skin,
                isPurchased: isPurchased,
                isActive: isActive,
              ))
        ],
      ),
    );
  }
}
