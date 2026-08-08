import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/sliver_heighted_deliget.dart';
import 'package:tic_tac_toe/common/widgets/borderd_container.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';

extension _DifficultyLabel on Difficulty {
  /// Translation key for this level's label (see `assets/languages/*.json`).
  String get labelKey => switch (this) {
        Difficulty.easy => 'easy',
        Difficulty.medium => 'medium',
        Difficulty.hard => 'hard',
      };
}

class DifficultySelectionDialog extends StatefulWidget {
  const DifficultySelectionDialog({super.key});

  @override
  State<DifficultySelectionDialog> createState() =>
      _DifficultySelectionDialogState();
}

class _DifficultySelectionDialogState extends State<DifficultySelectionDialog> {
  Difficulty selectedDifficulty = Difficulty.medium;

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      title: context.tr('selectDifficulty'),
      buttons: [
        DialogButton(
          title: context.tr('next'),
          icon: AppIcons.next,
          onTap: () {
            Navigator.pop(context, selectedDifficulty);
          },
        ),
      ],
      child: GridView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            crossAxisCount: 1,
            height: 42),
        children: List.generate(
          Difficulty.values.length,
          (index) {
            final Difficulty difficulty = Difficulty.values[index];
            final bool isSelected = selectedDifficulty == difficulty;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDifficulty = difficulty;
                });
              },
              child: BorderContainer(
                color: isSelected ? context.color.secondary : null,
                borderColor: isSelected ? context.color.secondary : null,
                child: Text(
                  context.tr(difficulty.labelKey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
