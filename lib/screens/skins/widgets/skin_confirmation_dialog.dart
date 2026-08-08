import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/data/models/skin/skin_model.dart';

/// Asks the player to confirm spending [Skin.price] coins before it's bought
/// and equipped. Resolves to `true` on confirm, `null`/`false` otherwise.
class SkinConfirmationDialog extends StatelessWidget {
  final Skin skin;
  const SkinConfirmationDialog({super.key, required this.skin});

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      title: context.tr('confirmPurchase'),
      buttons: [
        DialogButton(
          title: context.tr('no'),
          color: context.color.secondary,
          textColor: Colors.white,
          onTap: () => Navigator.pop(context, false),
        ),
        DialogButton(
          title: context.tr('yesBuy'),
          color: context.color.tertiary,
          textColor: Colors.white,
          onTap: () => Navigator.pop(context, true),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomImage(UiUtils.getSkin(skin.skinX), width: 40, height: 40),
                const SizedBox(width: 12),
                CustomImage(UiUtils.getSkin(skin.skinO), width: 40, height: 40),
              ],
            ),
            const SizedBox(height: 12),
            CustomText(
              skin.name,
              fontWeight: FontWeight.w700,
              fontSize: context.font.large,
            ),
            const SizedBox(height: 8),
            CustomText(
              context.tr('areYouSurePurchaseSkin', params: {
                'price': '${skin.price}',
              }),
              textAlign: TextAlign.center,
              color: context.color.onSurface.withAlpha(200),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomImage(AppIcons.coin, width: 18, height: 18),
                const SizedBox(width: 4),
                CustomText(
                  '${skin.price}',
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
