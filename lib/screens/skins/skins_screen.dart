import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/core/services/firebase_service.dart';
import 'package:tic_tac_toe/core/services/interstitial_ad_service.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';
import 'package:tic_tac_toe/data/models/skin/skin_model.dart';
import 'package:tic_tac_toe/screens/skins/widgets/skin_tile.dart';
import 'package:tic_tac_toe/constants/settings.dart';

class SkinsScreen extends StatefulWidget {
  const SkinsScreen({super.key});
  static Route route(RouteSettings settings) {
    return GradientRouter(builder: (context) => const SkinsScreen());
  }

  @override
  State<SkinsScreen> createState() => _SkinsScreenState();
}

class _SkinsScreenState extends State<SkinsScreen> {
  @override
  void initState() {
    super.initState();
    InterstitialAdService.loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title:
            Text(context.tr('skins'), style: TextStyle(color: AppColors.white)),
        backgroundColor: context.color.surface,
      ),
      body: StreamBuilder<List<Skin>>(
        stream: DatabaseService.instance.streamAvailableSkins(),
        builder: (context, availableSnapshot) {
          if (availableSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator(color: context.color.secondary));
          }
          final availableSkins = availableSnapshot.data ?? AppSettings.skins;

          return StreamBuilder(
            stream: DatabaseService.instance.userSkins.onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: context.color.secondary,
                ));
              }
              if (snapshot.connectionState == ConnectionState.active) {
                return ListView.separated(
                  itemCount: availableSkins.length,
                  padding: EdgeInsets.all(16),
                  separatorBuilder: (context, index) => SizedBox(
                    height: 16,
                  ),
                  itemBuilder: (context, index) {
                    final currentSkin = availableSkins[index];
                    List<DataSnapshot> userSkins =
                        snapshot.data?.snapshot.children
                                .where(
                                  (element) =>
                                      (element.value as dynamic)['id'] ==
                                      currentSkin.id,
                                )
                                .toList() ??
                            [];
                    bool isPurchased = userSkins.isNotEmpty;
                    bool isActive = userSkins
                        .where(
                          (element) =>
                              (element.value as dynamic)['selectedStatus'] ==
                              'active',
                        )
                        .isNotEmpty;

                    return SkinTile(
                      skin: currentSkin,
                      isPurchased: isPurchased,
                      isActive: isActive,
                    );
                  },
                );
              }
              return Container();
            },
          );
        },
      ),
    );
  }
}
