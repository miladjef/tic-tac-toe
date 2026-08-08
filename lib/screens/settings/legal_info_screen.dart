import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/constants/legal_content.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';

class LegalInfoScreen extends StatelessWidget {
  final LegalInfoPage page;

  const LegalInfoScreen({super.key, required this.page});

  static Route route(RouteSettings settings) {
    final arguments = settings.arguments;
    final page =
        arguments is LegalInfoPage ? arguments : LegalContent.contactUs;

    return GradientRouter(
      builder: (context) => LegalInfoScreen(page: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: CustomText(
          context.tr(page.titleKey),
          fontSize: context.font.large,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        backgroundColor: context.color.surfaceContainer,
        surfaceTintColor: context.color.surfaceContainer,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.paddingOf(context).bottom,
        ),
        child: InnerShadowContainer(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 18,
              children: [
                CustomText(
                  context.tr(page.titleKey),
                  fontSize: context.font.xL,
                  fontWeight: FontWeight.w700,
                  color: context.color.onSurface,
                ),
                CustomText(
                  page.body.trim(),
                  fontSize: context.font.normal,
                  color: context.color.onSurface.withAlpha(210),
                ),
                if (page.contactItems.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  ...page.contactItems
                      .map((item) => _contactTile(context, item)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactTile(BuildContext context, LegalContactItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.color.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.color.outline),
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(_iconFor(item.type), color: context.color.primary),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                CustomText(
                  item.label,
                  fontSize: context.font.small,
                  color: context.color.onSurface.withAlpha(170),
                ),
                CustomText(
                  item.value,
                  fontSize: context.font.normal,
                  fontWeight: FontWeight.w700,
                  color: context.color.onSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(LegalContactType type) {
    switch (type) {
      case LegalContactType.email:
        return Icons.mail_outline;
      case LegalContactType.phone:
        return Icons.call_outlined;
      case LegalContactType.responseTime:
        return Icons.schedule_outlined;
    }
  }
}
