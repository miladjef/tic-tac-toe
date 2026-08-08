import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/convert_number.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/avatar_card.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';

/// Avatar / coin balance / leaderboard row shared by [HomeScreen] and any
/// other screen (e.g. HowToPlayScreen) that reuses the home app bar.
class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(55);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthenticationBloc>();
    final isGuest = auth.isGuest;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16)
          .copyWith(top: Platform.isIOS ? 30 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settingsScreen);
            },
            child: AvatarCard(
              image: auth.user?.profilePic ?? AppIcons.guest,
              width: 45,
              height: 45,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          if (!isGuest) Expanded(child: _buildCoinsCard(context)),
          Expanded(flex: 1, child: _buildLeaderboardCard(context)),
        ],
      ),
    );
  }

  Widget _buildCoinsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.shopScreen),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        // Don't clip the pill/icon that overflow the stack bounds.
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.center,
        children: [
          // Bound to the slot (start..end) instead of sizing to content, so a
          // long formatted number can't push the pill past the card edge.
          PositionedDirectional(
            start: 7,
            end: 0,
            child: InnerShadowContainer(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(3, 4, 4, 4),
                child: Row(
                  children: [
                    const SizedBox(width: 30),
                    Flexible(
                      child: CustomText(
                        ConvertNumber.formatCompact(
                            context.watch<AuthenticationBloc>().user?.coin ??
                                0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        maxLines: 1,
                        ellipsis: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CustomImage(
                      AppIcons.incrementCoin,
                      width: 18,
                      height: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            child: CustomImage(
              AppIcons.coin,
              width: 37,
              height: 37,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.leaderboardScreen),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.centerEnd,
        children: [
          // Bound to the slot (start..end) and ellipsize the label instead of
          // sizing to content — a long translation must not spill off the card.
          PositionedDirectional(
            start: 0,
            end: 7,
            child: InnerShadowContainer(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(3, 4, 4, 4),
                child: Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CustomText(
                          context.tr('leaderboard'),
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          maxLines: 1,
                          ellipsis: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 0,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: context.color.secondary),
              child: CustomImage(
                AppIcons.leaderBoardIcon,
                fit: BoxFit.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
