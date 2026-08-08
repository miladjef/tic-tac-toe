import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/enums.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/widgets/custom_button.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/screens/home/widgets/home_top_bar.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static Route route(RouteSettings settings) => GradientRouter(
        builder: (context) => const HowToPlayScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const HomeTopBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 58, 16, 16),
        child: Column(
          children: [
            _buildCard(context),
            Expanded(
              child: Center(
                child: CustomImage(
                  AppIcons.dora4,
                  width: 150,
                  height: 166,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: context.color.outline,
          strokeWidth: 1,
          radius: const Radius.circular(10),
          dashPattern: const [4, 4],
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                context.tr('howToPlay'),
                fontWeight: FontWeight.w700,
                fontSize: context.font.large,
                color: context.color.onSurface.withAlpha(200),
              ),
              Divider(
                endIndent: 14,
                indent: 14,
                thickness: 0.5,
                color: context.color.outline,
              ),
              const SizedBox(height: 8),
              CustomText(
                context.tr('howToPlayDescription'),
                textAlign: TextAlign.center,
                fontSize: context.font.medium,
                color: context.color.onSurface.withAlpha(200),
              ),
              const SizedBox(height: 20),
              CustomButton(
                title: context.tr('ok'),
                type: ButtonType.primary,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
