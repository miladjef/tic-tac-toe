import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/widgets/custom_bottom_sheet.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/localization/app_language.dart';
import 'package:tic_tac_toe/data/bloc/locale/locale_cubit.dart';

class ChangeLanguageDialog {
  ChangeLanguageDialog._();

  static Future<void> show(BuildContext context) {
    return showCustomBottomSheet(
      context,
      title: context.tr('changeLanguage'),
      child: const _LanguageList(),
    );
  }
}

class _LanguageList extends StatelessWidget {
  const _LanguageList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: AppLanguages.supported.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final language = AppLanguages.supported[index];
            final isSelected = language.code == locale.languageCode;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.read<LocaleCubit>().changeLocale(language.code);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  spacing: 14,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? context.color.secondary
                              : context.color.outline,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.color.secondary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: CustomText(
                        language.nativeName,
                        fontSize: context.font.medium,
                        color: isSelected
                            ? context.color.secondary
                            : context.color.onSurface.withAlpha(200),
                        maxLines: 1,
                        ellipsis: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
