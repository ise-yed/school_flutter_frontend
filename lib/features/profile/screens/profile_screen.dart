import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';
import 'package:school_flutter_frontend/core/widgets/dropdown.dart';
import 'package:school_flutter_frontend/core/widgets/reminders_appbar_widget.dart';
import 'package:school_flutter_frontend/features/profile/bloc/profile_bloc.dart';
import 'package:school_flutter_frontend/features/profile/screens/notification_screen.dart';
import 'package:school_flutter_frontend/features/profile/screens/update_screen.dart';
import 'package:school_flutter_frontend/features/profile/widgets/profile_home_item_widget.dart';
import 'package:flutter/widgets.dart' as ui;

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_setting.dart';
import '../../../core/widgets/app_cached_image.dart';
import '../../root/root_screen.dart';
import '../widgets/logout_dialog.dart';
import 'edit_profile_screen.dart';

import 'package:school_flutter_frontend/core/localization/locale_initializer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<ProfileBloc>(context);
    bloc.add(GetCurrentUserEvent());
    bloc.add(NotificationDataEvent(page: 1, limit: 2, callSeen: false));
  }

  bool? answeredTicket = false;

  @override
  Widget build(BuildContext context) {
    final bool hasUpdate =
        (int.tryParse(appBuildVersion) ?? 0) <
        (appConstSetting.currentVersion ?? 0);
    final bool isRTL = Directionality.of(context) == ui.TextDirection.rtl;
    final List<FilterModel> languageOptions = [
      FilterModel(name: 'language_fa'.tr(), code: AppLanguages.codeFa),
      FilterModel(name: 'language_en'.tr(), code: AppLanguages.codeEn),
    ];
    final String defaultLanguageTitle =
        context.locale.languageCode == AppLanguages.fa.languageCode
        ? 'language_fa'.tr()
        : 'language_en'.tr();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              RemindersAppbarWidget(
                title: "user_account".tr(),
                leadingIcon: GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      currentIndex.value = 0;
                    }
                  },
                  child: RotatedBox(
                    quarterTurns: isRTL ? 0 : 2,
                    child: SvgPicture.asset(
                      "assets/icons/arrow-right.svg",
                      width: 24.w,
                      height: 24.h,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                trailingIcon: GestureDetector(
                  onTap: () {
                    goScreen(context: context, screen: NotificationScreen());
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 28.h,
                        child: SvgPicture.asset(
                          "assets/icons/notification.svg",
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      // if (hasBadge)
                      BlocBuilder<ProfileBloc, ProfileState>(
                        buildWhen: (previous, current) =>
                            current is NotificationDataSuccessState ||
                            current is NotificationDataLoadingState ||
                            current is NotificationDataFailedState,
                        builder: (context, state) {
                          if (state is NotificationDataSuccessState) {
                            bool hasBadge =
                                (state.notificationModel != null &&
                                state.notificationModel!.unseen != 0);
                            return hasBadge
                                ? Positioned(
                                    right: 1.w,
                                    top: 0.h,
                                    child: Container(
                                      width: 11.w,
                                      height: 11.h,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .shadow,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink();
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                buildWhen: (previous, current) =>
                    current is EditProfileSuccess ||
                    current is GetCurrentUserSuccess,
                builder: (context, state) {
                  final user = currentUserModel;
                  final avatarUrl = user.avatar?.trim();
                  final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

                  Widget defaultAvatar = Container(
                    width: 82.r,
                    height: 82.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary
                          .withOpacity(0.12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary
                            .withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        "assets/icons/user-circle.svg",
                        width: 44.r,
                        height: 44.r,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  );

                  String displayName = '';
                  if (user.fullName != null &&
                      user.fullName!.trim().isNotEmpty) {
                    displayName = user.fullName!.trim();
                  } else if (user.firstName != null &&
                      user.firstName!.trim().isNotEmpty) {
                    displayName = '${user.firstName} ${user.lastName ?? ''}'
                        .trim();
                  } else if (user.email != null &&
                      user.email!.trim().isNotEmpty) {
                    displayName = user.email!.trim();
                  }

                  String subInfo = '';
                  if (user.phoneNumber != null &&
                      user.phoneNumber!.trim().isNotEmpty) {
                    subInfo = user.phoneNumber!.trim();
                  } else if (user.email != null &&
                      user.email!.trim().isNotEmpty &&
                      displayName != user.email) {
                    subInfo = user.email!.trim();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 82.r,
                        width: 82.r,
                        child: ClipOval(
                          child: hasAvatar
                              ? AppCachedImage(
                                  url:
                                      "${AppConstants.appImgBaseUrl}$avatarUrl",
                                  placeholder: defaultAvatar,
                                  error: defaultAvatar,
                                )
                              : defaultAvatar,
                        ),
                      ),
                      if (displayName.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                      if (subInfo.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subInfo,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary,
                              ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              SizedBox(height: 16.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Text(
                        "profile".tr(),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20.h,
                        horizontal: 20.w,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.shadow,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Column(
                        children: [
                          ProfileHomeItem(
                            iconPath: "assets/icons/edit_fill.svg",
                            title: "user_account_edit".tr(),
                            onTap: () => goScreen(
                              context: context,
                              screen: EditProfileScreen(
                                initial: currentUserModel,
                                isEdit: true,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ProfileHomeItem(
                            iconPath: "assets/icons/lock.svg",
                            title: "change_password".tr(),
                            onTap: () {
                              // goScreen(
                              //   context: context,
                              //   screen: ChangePasswordScreen(
                              //     isReset: false,
                              //     email: currentUserModel.email,
                              //   ),
                              // );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                // height: 302.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Text(
                        "settings".tr(),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20.h,
                        horizontal: 20.w,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.shadow,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Column(
                        spacing: 8.h,
                        children: [
                          ProfileHomeItem(
                            trailing: Container(
                              margin: EdgeInsets.only(left: 4.w),
                              width: 32.w,
                              height: 32.h,
                              child: Transform.scale(
                                scale: 0.65,
                                child: Directionality(
                                  textDirection: ui.TextDirection.ltr,
                                  child: CupertinoSwitch(
                                    value: !isThemeLight.value,
                                    onChanged: (val) async {
                                      isThemeLight.value = !isThemeLight.value;
                                      await prefs.setBool(
                                        AppConstants.isThemeLight,
                                        isThemeLight.value,
                                      );
                                    },
                                    thumbColor: AppColors.primary400,
                                    inactiveThumbColor: Colors.grey.shade500,
                                    // !must check
                                    activeColor: AppColors.primary400
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            iconPath: "assets/icons/half_moon.svg",
                            title: "dark_mode".tr(),
                          ),

                          Row(
                            children: [
                              SizedBox(
                                height: 24.h,
                                width: 24.w,
                                child: Icon(
                                  Icons.language_rounded,
                                  size: 24.r,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary,
                                ),
                              ),
                              SizedBox(width: 8.w),

                              Expanded(
                                child: DropdownWidget(
                                  invertIconOnOpen: true,

                                  defaultTitle: defaultLanguageTitle,
                                  hintTextstyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),

                                  buttonStyleDataColor: Theme.of(context)
                                      .colorScheme
                                      .shadow,
                                  buttonStyleDataPadding:
                                      EdgeInsetsDirectional.only(end: 0),
                                  height: 52,
                                  dataList: languageOptions,
                                  hintText: "select_language".tr(),
                                  onChanged: (value) async {
                                    if (value == null) return;

                                    if (value.code == AppLanguages.codeFa &&
                                        context.locale.languageCode !=
                                            AppLanguages.fa.languageCode) {
                                      await context.setLocale(AppLanguages.fa);
                                      await persistUserSelectedLocale(
                                        AppLanguages.fa,
                                      );
                                    } else if (value.code ==
                                            AppLanguages.codeEn &&
                                        context.locale.languageCode !=
                                            AppLanguages.en.languageCode) {
                                      await context.setLocale(AppLanguages.en);
                                      await persistUserSelectedLocale(
                                        AppLanguages.en,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          ProfileHomeItem(
                            showRedDot: hasUpdate,
                            iconPath: "assets/icons/reload.svg",
                            title: "update".tr(),
                            onTap: () {
                              goScreen(
                                context: context,
                                screen: UpdateScreen(
                                  hasUpdate: hasUpdate,
                                  showBack: true,
                                ),
                              );
                            },
                          ),
                          BlocListener<ProfileBloc, ProfileState>(
                            listener: (context, state) {},
                            child: ProfileHomeItem(
                              onTap: () {},
                              showRedDot: answeredTicket!,
                              iconPath: "assets/icons/headphones.svg",
                              title: "support".tr(),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return LogoutDialog();
                                },
                              );
                            },
                            child: ProfileHomeItem(
                              iconPath: "assets/icons/logout.svg",
                              title: "logout".tr(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 43.h),
            ],
          ),
        ),
      ),
    );
  }
}
