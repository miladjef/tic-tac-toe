import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/sliver_heighted_deliget.dart';
import 'package:tic_tac_toe/common/widgets/coin_cointainer.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/constants/settings.dart';

class EntryFeeSelectionDialog extends StatefulWidget {
  const EntryFeeSelectionDialog({super.key});

  @override
  State<EntryFeeSelectionDialog> createState() =>
      _EntryFeeSelectionDialogState();
}

class _EntryFeeSelectionDialogState extends State<EntryFeeSelectionDialog> {
  int selectedEntryFee = AppSettings.multiplayerFees.first;

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      title: context.tr('playWithRandomMatch'),
      buttons: [
        DialogButton(
          title: context.tr('next'),
          icon: AppIcons.next,
          onTap: () {
            Navigator.pop(context, selectedEntryFee);
          },
        ),
      ],
      child: GridView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            crossAxisCount: 2,
            height: 42),
        children: List.generate(
          AppSettings.multiplayerFees.length,
          (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedEntryFee = AppSettings.multiplayerFees[index];
                });
              },
              child: CoinContainer(
                selected:
                    selectedEntryFee == AppSettings.multiplayerFees[index],
                coins: AppSettings.multiplayerFees[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
