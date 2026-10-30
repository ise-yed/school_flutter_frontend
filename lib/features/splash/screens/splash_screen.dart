import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_flutter_frontend/core/constants/app_constants.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';
import 'package:school_flutter_frontend/features/auth/screens/login.dart';
import 'package:school_flutter_frontend/features/onboarding/screens/onboarding_screen.dart';
import 'package:school_flutter_frontend/features/root/root_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final bool onboardingSeen =
        prefs.getBool(AppConstants.isOnboardingSeen) ?? false;

    if (!onboardingSeen) {
      goScreen(
        context: context,
        screen: const OnboardingsScreen(),
        closeAllScreen: true,
      );
      return;
    }

    if (isLogin.value &&
        currentUserModel.role != null &&
        currentUserModel.role!.isNotEmpty) {
      goScreen(
        context: context,
        screen: const RootScreen(),
        closeAllScreen: true,
      );
    } else {
      goScreen(
        context: context,
        screen: const LoginScreen(),
        closeAllScreen: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                !isThemeLight.value
                    ? "assets/logo/logo_dark.svg"
                    : "assets/logo/logo_light.svg",
                height: 110.h,
                width: 110.w,
              ),
              SizedBox(height: 28.h),
              const CircularProgressIndicator(color: AppColors.primary500),
            ],
          ),
        ),
      ),
    );
  }
}
