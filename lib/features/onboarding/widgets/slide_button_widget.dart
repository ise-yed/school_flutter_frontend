import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/constants/app_constants.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';
import 'package:school_flutter_frontend/features/auth/screens/login.dart';

class CustomSlideButton extends StatefulWidget {
  const CustomSlideButton({super.key});

  @override
  State<CustomSlideButton> createState() => _CustomSlideButtonState();
}

class _CustomSlideButtonState extends State<CustomSlideButton> {
  double _dx = 0.0;
  late double _maxDx;
  final double _buttonSize = 70;
  final double _margin = 8;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    double trackWidth = MediaQuery.of(context).size.width - 40;
    _maxDx = trackWidth - _buttonSize.w - (_margin * 2);
    _dx = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dx -= details.delta.dx;
      if (_dx < 0) _dx = 0;
      if (_dx > _maxDx) _dx = _maxDx;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dx >= _maxDx) {
      prefs.setBool(AppConstants.isOnboardingSeen, true);
      goScreen(
        context: context,
        screen: const LoginScreen(),
        closeAllScreen: true,
      );
    } else {
      setState(() {
        _dx = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(500),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 67.h,
          decoration: BoxDecoration(
            color: const Color(0xFF032E34),
            borderRadius: BorderRadius.circular(500),
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 50),
                      child: Text(
                        "start".tr(),
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(color: AppColors.text700Dark),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 50),
                curve: Curves.easeOut,
                right: _dx,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  child: Container(
                    margin: EdgeInsets.all(_margin),
                    width: _buttonSize.w,
                    height: 51.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(500),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
