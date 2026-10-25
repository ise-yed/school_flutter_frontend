import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as UI;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';

// import 'package:school_flutter_frontend/features/around_you_feature/views/screens/map_screen.dart';

class HomeAroundYouShopBannerWidget extends StatelessWidget {
  const HomeAroundYouShopBannerWidget({super.key, required this.isRTL});

  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // goScreen(context: context, screen: MapScreen());
      },
      child: Container(
        height: 130.h,

        margin: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          color: Theme.of(context).colorScheme.shadow,
        ),
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Row(
                // spacing: 16.w,
                children: [
                  Container(
                    height: 98.h,
                    width: MediaQuery.of(context).size.width * 0.270,
                    child: Image.asset("assets/images/petstore2.png"),
                    //  SvgPicture.asset("assets/images/petstore.svg"),
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: 45.h,
                        // bottom: 10.h,
                        end: 4.w,
                        // left: isRTL ? 4.w : 0,
                        // right: isRTL ? 0 : 4.w,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "around_you_shops_des".tr(),
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(height: 1.5.h, fontSize: 11.sp),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5.h),
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: 10.w),

                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.all(
                                      Radius.circular(10.r),
                                    ),
                                  ),
                                ),

                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.zero,
                                ),
                                backgroundColor: WidgetStatePropertyAll(
                                  AppColors.aroundYouHomeBannerColor,
                                ),
                                fixedSize: WidgetStatePropertyAll(
                                  Size(100.w, 30.h),
                                ),
                              ),
                              onPressed: () {
                                // goScreen(context: context, screen: MapScreen());
                              },
                              child: Text(
                                "search_2".tr(),

                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color: AppColors.bg1Light,
                                      // reminderItem.status !=
                                      //     'active'
                                      // ? AppColors.green2
                                      // : Theme.of(context)
                                      //       .colorScheme
                                      //       .onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ! top blue
            SizedBox(
              height: 37.h,
              width: MediaQuery.of(context).size.width,
              child: Transform(
                transform: Matrix4.identity()..scale(isRTL ? 1.0 : -1.0, 1.0),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.r),
                    topRight: Radius.circular(25.r),
                  ),
                  child: SvgPicture.asset(
                    colorFilter: ColorFilter.mode(
                      AppColors.aroundYouHomeBannerColor,
                      BlendMode.srcIn,
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 37.h,
                    fit: BoxFit.fill,
                    "assets/images/home_vet_frame.svg",
                  ),
                ),
              ),
            ),
            // ! title
            Positioned.directional(
              top: 10.5.h,
              textDirection: isRTL
                  ? UI.TextDirection.rtl
                  : UI.TextDirection.ltr,
              start: (MediaQuery.of(context).size.width * 0.3).w,

              child: Center(
                child: Text(
                  "search_petshop".tr(),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bg1Light,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
