import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';

/// Standard bottom sheet chrome (rounded top corners, drag handle,
/// optional title) shared by every bottom-sheet-presented screen.
Future<T?> showCustomBottomSheet<T>(
  BuildContext context, {
  String? title,
  required Widget child,
  Color? backgroundColor,
  bool enableDrag = true,
  bool isDismissible = true,
  bool useSafeArea = true,
  bool showDragHandle = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: useSafeArea,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    barrierColor: Colors.black54,
    backgroundColor: backgroundColor ?? context.color.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              color: context.color.outline,
              strokeWidth: 1,
              dashPattern: const [4, 4],
              padding: EdgeInsets.zero,
              radius: const Radius.circular(24),
            ),
            // customPath: (size) => Path()
            //   ..addRRect(
            //     RRect.fromRectAndCorners(
            //       Rect.fromLTWH(0, 0, size.width, size.height),
            //       topLeft: const Radius.circular(20),
            //       topRight: const Radius.circular(20),
            //     ),
            //   ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDragHandle) const CustomBottomSheetDragHandle(),
                if (title != null) ...[
                  const SizedBox(height: 8),
                  CustomText(
                    title,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 8),
                ],
                Flexible(child: child),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class CustomBottomSheetDragHandle extends StatelessWidget {
  const CustomBottomSheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.color.onSurface.withAlpha(50),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
