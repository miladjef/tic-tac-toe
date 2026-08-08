import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/services/sound_service.dart';
import 'package:tic_tac_toe/core/theme/colors.dart';

class SoundToggleCard extends StatefulWidget {
  const SoundToggleCard({super.key});

  @override
  State<SoundToggleCard> createState() => _SoundToggleCardState();
}

class _SoundToggleCardState extends State<SoundToggleCard> {
  bool _soundOn = SoundService.isEnabled;

  void _set(bool value) {
    if (value == _soundOn) return;
    SoundService.setEnabled(value);
    setState(() => _soundOn = value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: _pill(
              context,
              active: _soundOn,
              icon: Icons.volume_up,
              label: context.tr('soundOn'),
              onTap: () => _set(true),
            ),
          ),
          Expanded(
            child: _pill(
              context,
              active: !_soundOn,
              icon: Icons.volume_off,
              label: context.tr('soundOff'),
              onTap: () => _set(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(
    BuildContext context, {
    required bool active,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final Color background =
        active ? context.color.secondary : context.color.surface;
    final Color foreground = active ? AppColors.white : context.color.secondary;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.color.secondary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            Icon(icon, color: foreground, size: 16),
            Flexible(
              child: CustomText(
                label,
                color: foreground,
                fontSize: context.font.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
