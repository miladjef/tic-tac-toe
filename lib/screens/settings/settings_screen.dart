import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/extensions/color_extension.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/constants/app_links.dart';
import 'package:tic_tac_toe/constants/legal_content.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';
import 'package:tic_tac_toe/data/models/menu_option.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tic_tac_toe/screens/settings/widgets/change_language_dialog.dart';
import 'package:tic_tac_toe/screens/settings/widgets/delete_account_confirm_dialog.dart';
import 'package:tic_tac_toe/screens/settings/widgets/logout_confirm_dialog.dart';
import 'package:tic_tac_toe/screens/settings/widgets/profile_card.dart';
import 'package:tic_tac_toe/screens/settings/widgets/sound_toggle_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static Route route(RouteSettings settings) => GradientRouter(
        builder: (context) => const SettingsScreen(),
      );
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  List<MenuCardModel> settings(BuildContext context, {bool isGuest = false}) =>
      [
        MenuCardModel(
          title: context.tr('history'),
          icon: AppIcons.history,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.historyScreen);
          },
        ),
        if (isGuest)
          MenuCardModel(
            title: context.tr('signInNow'),
            icon: AppIcons.guestLogin,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.authOptionsScreen,
                  arguments: true);
            },
          ),
        if (!isGuest)
          MenuCardModel(
            title: context.tr('shop'),
            icon: AppIcons.shop,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.shopScreen);
            },
          ),
        if (!isGuest)
          MenuCardModel(
            title: context.tr('skin'),
            icon: AppIcons.skin,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.skinsScreen);
            },
          ),
        MenuCardModel(
          title: context.tr('changeLanguage'),
          icon: AppIcons.language,
          onTap: () {
            ChangeLanguageDialog.show(context);
          },
        ),
        MenuCardModel(
          title: context.tr('playMoreGames'),
          icon: AppIcons.moreGame,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.moreGamesScreen);
          },
        ),
        MenuCardModel(
          title: context.tr('contactUs'),
          icon: AppIcons.contactUs,
          onTap: () => _openLegalInfo(context, LegalContent.contactUs),
        ),
        MenuCardModel(
          title: context.tr('aboutUs'),
          icon: AppIcons.aboutUs,
          onTap: () => _openLegalInfo(context, LegalContent.aboutUs),
        ),
        MenuCardModel(
          title: context.tr('termsAndConditions'),
          icon: AppIcons.termsAndConditions,
          onTap: () => _openLegalInfo(context, LegalContent.termsAndConditions),
        ),
        MenuCardModel(
          title: context.tr('privacyPolicy'),
          icon: AppIcons.privacyPolicy,
          onTap: () => _openLegalInfo(context, LegalContent.privacyPolicy),
        ),
        MenuCardModel(
          title: context.tr('howToPlay'),
          icon: AppIcons.howToPlay,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.howToPlayScreen);
          },
        ),
        MenuCardModel(
          title: context.tr('shareApp'),
          icon: AppIcons.shareApp,
          onTap: () => _shareApp(context),
        ),
        MenuCardModel(
          title: context.tr('rateUs'),
          icon: AppIcons.rateUs,
          onTap: () => _rateUs(context),
        ),
        MenuCardModel(
          title: context.tr('deleteAccount'),
          icon: AppIcons.deleteAccount,
          onTap: () {
            DeleteAccountConfirmDialog.show(context);
          },
        ),
      ];

  void _openLegalInfo(BuildContext context, LegalInfoPage page) {
    Navigator.pushNamed(
      context,
      AppRoutes.legalInfoScreen,
      arguments: page,
    );
  }

  String get _storeUrl =>
      Platform.isIOS ? AppLinks.appStoreUrl : AppLinks.playStoreUrl;

  Future<void> _rateUs(BuildContext context) async {
    await launchUrl(Uri.parse(_storeUrl), mode: LaunchMode.externalApplication);
  }

  Future<void> _shareApp(BuildContext context) async {
    await SharePlus.instance.share(ShareParams(text: _storeUrl));
  }

  @override
  Widget build(BuildContext context) {
    final isGuest =
        context.watch<AuthenticationBloc>().state is AuthenticatedAsGuestState;
    final menuItems = settings(context, isGuest: isGuest);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.color.surfaceContainer,
        surfaceTintColor: context.color.surfaceContainer,
        actions: [
          IconButton(
            onPressed: () => LogoutConfirmDialog.show(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            children: [
              ProfileCard(editable: true),
              InnerShadowContainer(child: SoundToggleCard()),
              InnerShadowContainer(
                  child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        return settingCard(menuItems[index]);
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: context.color.outline,
                          indent: 16,
                        );
                      },
                      itemCount: menuItems.length))
            ],
          ),
        ),
      ),
    );
  }

  Widget settingCard(MenuCardModel menu) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: menu.onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          spacing: 16,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.color.outline.brighten(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomImage(
                menu.icon,
                fit: BoxFit.none,
                width: 24,
                height: 24,
              ),
            ),
            Expanded(
              child: CustomText(
                menu.title,
                color: AppColors.white,
                maxLines: 1,
                ellipsis: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}
