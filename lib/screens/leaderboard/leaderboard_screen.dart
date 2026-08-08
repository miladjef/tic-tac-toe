import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/core/services/firebase_service.dart';
import 'package:tic_tac_toe/core/services/interstitial_ad_service.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/models/leaderboard_model.dart';
import 'package:tic_tac_toe/data/repositories/leaderboard_repository.dart';
import 'package:tic_tac_toe/screens/settings/widgets/profile_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  static Route route(RouteSettings settings) => GradientRouter(
        builder: (context) => const LeaderboardScreen(),
      );

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  /// All leaderboard/rank logic lives in the repository; the screen only
  /// renders whatever ranked page it fetches.
  final LeaderboardRepository _repository = LeaderboardRepository();

  /// Used only to highlight the signed-in player's own row.
  final String? _currentUserId = DatabaseService.instance.userId;

  final List<LeaderboardModel> _players = [];
  final ScrollController _scrollController = ScrollController();
  LeaderboardCursor? _nextCursor;
  bool _loading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    InterstitialAdService.loadAd();
    _loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_nextCursor == null || _loadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadNextPage();
    }
  }

  Future<void> _loadFirstPage() async {
    final page = await _repository.fetchLeaderboardPage();
    if (!mounted) return;
    setState(() {
      _players
        ..clear()
        ..addAll(page.players);
      _nextCursor = page.nextCursor;
      _loading = false;
    });
  }

  Future<void> _loadNextPage() async {
    if (_nextCursor == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    final page = await _repository.fetchLeaderboardPage(
      cursor: _nextCursor,
      startRank: _players.length + 1,
    );
    if (!mounted) return;
    setState(() {
      _players.addAll(page.players);
      _nextCursor = page.nextCursor;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: CustomText(context.tr('leaderboard'),
            fontSize: context.font.large,
            fontWeight: FontWeight.w700,
            color: AppColors.white),
        backgroundColor: context.color.surfaceContainer,
        surfaceTintColor: context.color.surfaceContainer,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            children: [
              const ProfileCard(showCoin: false),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: CircularProgressIndicator(
                    color: context.color.secondary,
                  ),
                )
              else if (_players.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: CustomText(
                    context.tr('noPlayersYet'),
                    color: context.color.onSurface,
                  ),
                )
              else ...[
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _players.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _buildPlayerCard(context, _players[index]),
                ),
                if (_loadingMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(
                      color: context.color.secondary,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, LeaderboardModel player) {
    final rank = player.rank ?? 0;
    final isCurrentUser =
        _currentUserId != null && player.userId == _currentUserId;
    return InnerShadowContainer(
      backgroundColor:
          isCurrentUser ? context.color.tertiary.withAlpha(60) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            SizedBox(
                width: 32, child: Center(child: _buildRank(context, rank))),
            _buildAvatar(context, player),
            Expanded(
              child: CustomText(
                player.name,
                color: context.color.onSurface,
                fontWeight: FontWeight.w600,
                ellipsis: true,
                maxLines: 2,
              ),
            ),
            CustomText(
              '${player.score}',
              fontSize: context.font.large,
              fontWeight: FontWeight.w700,
              color: context.color.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRank(BuildContext context, int rank) {
    if (rank >= 1 && rank <= 3) {
      final rankIcons = [AppIcons.rank1, AppIcons.rank2, AppIcons.rank3];
      return CustomImage(
        rankIcons[rank - 1],
        width: 26,
        height: 36,
        fit: BoxFit.contain,
      );
    }
    return CustomText(
      '$rank',
      fontSize: context.font.large,
      fontWeight: FontWeight.w700,
      color: context.color.onSurface,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAvatar(BuildContext context, LeaderboardModel player) {
    final pic = player.profilePic;
    if (pic != null && pic.isNotEmpty) {
      return Container(
        width: 44,
        height: 44,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: CustomImage(pic, fit: BoxFit.cover),
      );
    }
    // No avatar asset — fall back to an initial on a tinted circle.
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.color.tertiary.withAlpha(100),
      ),
      child: CustomText(
        player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
        fontSize: context.font.large,
        fontWeight: FontWeight.w700,
        color: context.color.onSurface,
      ),
    );
  }
}
