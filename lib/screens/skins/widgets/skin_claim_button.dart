import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/extensions/color_extension.dart';
import 'package:tic_tac_toe/common/ui_utils.dart';
import 'package:tic_tac_toe/common/widgets/custom_button.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/services/firebase_service.dart';
import 'package:tic_tac_toe/data/models/skin/skin_model.dart';
import 'package:tic_tac_toe/screens/skins/widgets/skin_confirmation_dialog.dart';

class SkinClaimButton extends StatelessWidget {
  final Skin skin;
  final bool isPurchased;
  final bool isActive;
  const SkinClaimButton(
      {super.key,
      required this.skin,
      required this.isPurchased,
      required this.isActive});

  Color getButtonColor(BuildContext context) {
    if (isActive) {
      return Colors.lightGreenAccent;
    }
    if (isPurchased) {
      return context.color.secondary.brighten(0.2);
    } else {
      return context.color.tertiary.brighten(0.3);
    }
  }

  void _showInsufficientCoins(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('notEnoughCoinsToPlay', params: {
          'amount': '${skin.price}',
        })),
      ),
    );
  }

  Future<void> _claim(BuildContext context) async {
    if (isPurchased) {
      await DatabaseService.instance.activateSkin(skin);
      return;
    }

    if (skin.price > 0) {
      final user = await DatabaseService.instance.getUser();
      if (!context.mounted) return;
      if ((user.coin ?? 0) < skin.price) {
        _showInsufficientCoins(context);
        return;
      }

      final confirmed = await UiUtils.showDialog(context,
          child: SkinConfirmationDialog(skin: skin));
      if (confirmed != true) return;
    }

    final bought = await DatabaseService.instance.purchaseSkin(skin);
    if (!bought && context.mounted) _showInsufficientCoins(context);
  }

  Widget _label(BuildContext context, String text) {
    return Center(
      child: CustomText(
        text,
        color: context.color.surface,
        fontSize: context.font.medium,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFreeAndUnowned = !isPurchased && skin.price == 0;

    return CustomButton(
      onTap: isActive ? null : () => _claim(context),
      customWidget: isActive
          ? _label(context, context.tr('active'))
          : isFreeAndUnowned
              ? _label(context, context.tr('free'))
              : SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!isPurchased) ...{
                            CustomImage(
                              AppIcons.coin,
                              width: 18,
                              height: 18,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                          },
                          AutoSizeText(
                              isPurchased
                                  ? context.tr('purchased')
                                  : '${skin.price}',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: context.font.medium,
                                color: context.color.surface,
                                fontWeight: isPurchased
                                    ? FontWeight.w400
                                    : FontWeight.w700,
                              )),
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        decoration: BoxDecoration(
                            color: context.color.surface,
                            borderRadius: BorderRadius.circular(20)),
                        child: AutoSizeText(
                          isPurchased
                              ? context.tr('useNow')
                              : context.tr('claim'),
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
      color: getButtonColor(context),
      type: ButtonType.gradient,
    );
  }
}
