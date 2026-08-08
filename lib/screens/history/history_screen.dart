import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/extensions/color_extension.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/common/widgets/inner_shadow.dart';
import 'package:tic_tac_toe/core/services/firebase_service.dart';
import 'package:tic_tac_toe/core/services/interstitial_ad_service.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/models/history_model.dart';
import 'package:tic_tac_toe/data/models/user/user_model.dart';
import 'package:tic_tac_toe/screens/settings/widgets/profile_card.dart';

/// Day-range options for the "Select days" filter.
enum HistoryDayFilter {
  all('all', null),
  week('last7Days', 7),
  month('last30Days', 30);

  final String labelKey;
  final int? days;
  const HistoryDayFilter(this.labelKey, this.days);

  String label(BuildContext context) => context.tr(labelKey);
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static Route route(RouteSettings settings) => GradientRouter(
        builder: (context) => const HistoryScreen(),
      );

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryDayFilter _selectedFilter = HistoryDayFilter.all;

  final Stream<List<HistoryModel>> _historyStream =
      DatabaseService.instance.streamHistory();

  @override
  void initState() {
    super.initState();
    InterstitialAdService.loadAd();
  }

  List<HistoryModel> _filter(List<HistoryModel> all) {
    final days = _selectedFilter.days;
    if (days == null || all.isEmpty) return all;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return all.where((e) => e.dateTime.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: CustomText(context.tr('history'),
            fontSize: context.font.large,
            fontWeight: FontWeight.w700,
            color: AppColors.white),
        backgroundColor: context.color.surfaceContainer,
        surfaceTintColor: context.color.surfaceContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          children: [
            ProfileCard(bottomBuilder: _buildSummary),
            Expanded(
              child: StreamBuilder<List<HistoryModel>>(
                stream: _historyStream,
                builder: (context, snapshot) {
                  final history =
                      _filter(snapshot.data ?? const <HistoryModel>[]);
                  return _buildHistoryTable(context, history);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, UserModel? user) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ProfileCard.buildInsight(context,
              (title: context.tr('played'), value: user?.matchPlayed ?? 0)),
        ),
        ProfileCard.buildVerticalDivider(context),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 6,
            children: [
              CustomText(context.tr('duration'),
                  fontSize: context.font.small, textAlign: TextAlign.center),
              _buildDayDropdown(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayDropdown(BuildContext context) {
    return PopupMenuButton<HistoryDayFilter>(
      color: context.color.surfaceContainer,
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      initialValue: _selectedFilter,
      onSelected: (filter) => setState(() => _selectedFilter = filter),
      itemBuilder: (context) => HistoryDayFilter.values
          .map((filter) => PopupMenuItem(
                value: filter,
                child: CustomText(filter.label(context),
                    fontSize: context.font.medium,
                    color: context.color.onSurface),
              ))
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: CustomText(_selectedFilter.label(context),
                fontSize: context.font.medium,
                fontWeight: FontWeight.w700,
                color: context.color.onSurface,
                maxLines: 1,
                ellipsis: true),
          ),
          Icon(Icons.keyboard_arrow_down, color: context.color.onSurface),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(BuildContext context, List<HistoryModel> history) {
    return Column(
      spacing: 16,
      children: [
        // Header sits in its own card, detached from the data — matches the UI.
        InnerShadowContainer(child: _buildHeaderRow(context)),
        // Data card fills the remaining height; the list scrolls within it.
        Expanded(
          child: InnerShadowContainer(
            child: history.isEmpty
                ? Center(
                    child: CustomText(context.tr('noHistoryFound'),
                        fontSize: context.font.normal),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: history.length,
                    separatorBuilder: (context, index) => Divider(
                        color: context.color.outline,
                        indent: 16,
                        endIndent: 16),
                    itemBuilder: (context, index) =>
                        _buildHistoryRow(context, history[index]),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    Widget cell(String title) {
      return Expanded(
        child: CustomText(title,
            fontSize: context.font.normal,
            fontWeight: FontWeight.w700,
            color: context.color.onSurface,
            textAlign: TextAlign.center),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          cell(context.tr('transaction')),
          cell(context.tr('status')),
          cell(context.tr('dateTime')),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(BuildContext context, HistoryModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              '${item.amount}',
              fontSize: context.font.normal,
              fontWeight: FontWeight.w600,
              color: _amountColor(context, item),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: CustomText(item.status.label(context),
                fontSize: context.font.normal, textAlign: TextAlign.center),
          ),
          Expanded(
            child: CustomText(_formatDate(item.dateTime),
                fontSize: context.font.small, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Color _amountColor(BuildContext context, HistoryModel item) {
    return item.amount < 0
        ? context.color.error.brighten(0.1)
        : context.color.onSurface;
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)} ${_months[date.month - 1]} ${date.year}\n'
        '${two(date.hour)}:${two(date.minute)}';
  }
}
