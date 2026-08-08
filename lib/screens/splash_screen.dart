import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/common/app_icons.dart';
import 'package:tic_tac_toe/common/extensions/build_context.dart';
import 'package:tic_tac_toe/common/navigation_routers/gradient_router.dart';
import 'package:tic_tac_toe/common/widgets/custom_image.dart';
import 'package:tic_tac_toe/common/widgets/custom_text.dart';
import 'package:tic_tac_toe/core/routes/routes.dart';
import 'package:tic_tac_toe/data/bloc/authentication/authentication_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static Route route(RouteSettings settings) => GradientRouter(
      builder: (context) => const SplashScreen(), disableMazeBackground: true);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<AuthenticationBloc>().add(CheckAuthenticationEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is UnAuthorizedState) {
          Navigator.pushReplacementNamed(context, AppRoutes.authOptionsScreen);
        } else if (state is AuthenticatedAsGuestState ||
            state is AuthenticatedState) {
          Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomImage(
                AppIcons.appLogo,
              ),
              CustomText(
                context.tr('calculateEveryMove'),
                textAlign: TextAlign.center,
                fontSize: 40,
                family: 'tangerine',
              )
            ],
          ),
        ),
      ),
    );
  }
}
