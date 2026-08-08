import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/convert_number.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';

class CoinContainer extends StatelessWidget {
  final int coins;
  final bool selected;
  const CoinContainer({super.key, required this.coins, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        border: selected
            ? null
            : Border.all(color: context.color.onSurface.withAlpha(200)),
        color: selected ? context.color.secondary : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(
            AppIcons.coin,
            width: 18,
            height: 18,
          ),
          SizedBox(
            width: 6,
          ),
          CustomText(
            ConvertNumber.formatCompact(coins),
            fontSize: context.font.large,
            color: context.color.onSurface.withAlpha(255),
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
