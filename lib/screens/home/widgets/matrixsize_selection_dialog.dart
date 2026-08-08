import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/sliver_heighted_deliget.dart';
import 'package:tic_tac_toe/common/widgets/borderd_container.dart';
import 'package:tic_tac_toe/common/widgets/custom_dialog_box.dart';
import 'package:tic_tac_toe/data/models/game/matrix_size_model.dart';
import 'package:tic_tac_toe/constants/settings.dart';

class MatrixSizeSelectionDialog extends StatefulWidget {
  const MatrixSizeSelectionDialog({super.key});

  @override
  State<MatrixSizeSelectionDialog> createState() =>
      _MatrixSizeSelectionDialogState();
}

class _MatrixSizeSelectionDialogState extends State<MatrixSizeSelectionDialog> {
  MatrixSize? selectedMatrixSize = AppSettings.matrixSizes.first;

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      title: context.tr('chooseYourGameMode'),
      buttons: [
        DialogButton(
          title: context.tr('start'),
          onTap: () {
            Navigator.pop(context, selectedMatrixSize);
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
          AppSettings.matrixSizes.length,
          (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMatrixSize = AppSettings.matrixSizes[index];
                });
              },
              child: BorderContainer(
                color: selectedMatrixSize == AppSettings.matrixSizes[index]
                    ? context.color.secondary
                    : null,
                borderColor:
                    selectedMatrixSize == AppSettings.matrixSizes[index]
                        ? context.color.secondary
                        : null,
                child: Text(
                  AppSettings.matrixSizes[index].title.toString(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
