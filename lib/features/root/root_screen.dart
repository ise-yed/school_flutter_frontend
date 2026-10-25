import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/constants/app_constants.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/localization/locale_initializer.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';
import 'package:school_flutter_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:school_flutter_frontend/features/auth/models/user_model.dart';
import 'package:school_flutter_frontend/features/auth/screens/login.dart';
import 'package:school_flutter_frontend/features/operations/screens/attendance_and_discipline_screen.dart';
import 'package:school_flutter_frontend/features/operations/screens/parent_dashboard_screen.dart';
import 'package:school_flutter_frontend/features/profile/screens/notification_screen.dart';
import 'package:school_flutter_frontend/features/schools/screens/school_structure_screen.dart';
import 'package:school_flutter_frontend/features/schools/screens/superuser_schools_screen.dart';
import 'package:school_flutter_frontend/features/students/screens/admin_students_hub_screen.dart';

ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    currentIndex.value = 0;
    isLogin.addListener(_onAuthStatusChanged);
  }

  @override
  void dispose() {
    isLogin.removeListener(_onAuthStatusChanged);
    super.dispose();
  }

  void _onAuthStatusChanged() {
    if (!isLogin.value && mounted) {
      goScreen(
        context: context,
        screen: const LoginScreen(),
        closeAllScreen: true,
      );
    }
  }

  List<_RoleNavTab> _buildRoleTabs(BuildContext context) {
    final role = currentUserModel.role ?? '';
    final isEn = context.locale.languageCode == 'en';

    switch (role) {
      case UserRole.superuser:
        return [
          _RoleNavTab(
            label: isEn ? 'Schools' : 'مدارس',
            icon: Icons.domain_rounded,
            page: const SuperuserSchoolsScreen(),
          ),
          _RoleNavTab(
            label: isEn ? 'Profile' : 'حساب کاربری',
            icon: Icons.person_rounded,
            page: const _RoleProfileAndSettingsView(),
          ),
        ];

      case UserRole.schoolAdmin:
        return [
          _RoleNavTab(
            label: isEn ? 'Structure' : 'ساختار و کادر',
            icon: Icons.account_tree_rounded,
            page: const SchoolStructureScreen(),
          ),
          _RoleNavTab(
            label: isEn ? 'Students' : 'دانش‌آموزان و اکسل',
            icon: Icons.groups_rounded,
            page: const AdminStudentsHubScreen(),
          ),
          _RoleNavTab(
            label: isEn ? 'Operations' : 'حضور، انضباط و اعلان',
            icon: Icons.fact_check_rounded,
            page: const AttendanceAndDisciplineScreen(),
          ),
          _RoleNavTab(
            label: isEn ? 'Settings' : 'حساب و تنظیمات',
            icon: Icons.settings_suggest_rounded,
            page: const _RoleProfileAndSettingsView(),
          ),
        ];

      case UserRole.teacher:
        return [
          _RoleNavTab(
            label: isEn ? 'My Classes' : 'کلاس‌های من',
            icon: Icons.class_rounded,
            page: const SchoolStructureScreen(),
          ),
          _RoleNavTab(
            label: isEn ? 'Attendance' : 'حضور و انضباط',
            icon: Icons.how_to_reg_rounded,
            page: const AttendanceAndDisciplineScreen(),
          ),
          _RoleNavTab(
            label: isEn ? 'Students' : 'جستجوی دانش‌آموز',
            icon: Icons.person_search_rounded,
            page: const AdminStudentsHubScreen(),
          ),
          _RoleNavTab(
            label: isEn ? 'Profile' : 'حساب کاربری',
            icon: Icons.person_rounded,
            page: const _RoleProfileAndSettingsView(),
          ),
        ];

      case UserRole.parent:
      default:
        return [
          _RoleNavTab(
            label: isEn ? 'Overview' : 'فرزندان من',
            icon: Icons.child_care_rounded,
            page: const ParentDashboardScreen(initialSection: 0),
          ),
          _RoleNavTab(
            label: isEn ? 'Attendance' : 'حضور و غیاب',
            icon: Icons.event_available_rounded,
            page: const ParentDashboardScreen(initialSection: 1),
          ),
          _RoleNavTab(
            label: isEn ? 'Discipline' : 'پرونده انضباطی',
            icon: Icons.assignment_rounded,
            page: const ParentDashboardScreen(initialSection: 2),
          ),
          _RoleNavTab(
            label: isEn ? 'Profile' : 'حساب و پیام‌ها',
            icon: Icons.person_rounded,
            page: const _RoleProfileAndSettingsView(),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildRoleTabs(context);

    return ValueListenableBuilder<int>(
      valueListenable: currentIndex,
      builder: (context, idx, _) {
        final safeIndex = idx < tabs.length ? idx : 0;

        return Scaffold(
          body: IndexedStack(
            index: safeIndex,
            children: tabs.map((t) => t.page).toList(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: (newIndex) => currentIndex.value = newIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary500,
            unselectedItemColor: Theme.of(context).colorScheme.onSecondary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedLabelStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
            ),
            items: tabs
                .map(
                  (t) => BottomNavigationBarItem(
                    icon: Icon(t.icon),
                    label: t.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _RoleNavTab {
  final String label;
  final IconData icon;
  final Widget page;

  const _RoleNavTab({
    required this.label,
    required this.icon,
    required this.page,
  });
}

class _RoleProfileAndSettingsView extends StatelessWidget {
  const _RoleProfileAndSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEn = context.locale.languageCode == 'en';

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        children: [
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: theme.colorScheme.surfaceDim),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.primary500.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person_rounded,
                    size: 30.r,
                    color: AppColors.primary500,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUserModel.displayName,
                        style: theme.textTheme.headlineMedium,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        currentUserModel.roleDisplayFa,
                        style: theme.textTheme.labelMedium,
                      ),
                      if (currentUserModel.phoneNumber != null &&
                          currentUserModel.phoneNumber!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          currentUserModel.phoneNumber!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          if (currentUserModel.schoolId != null)
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              tileColor: theme.colorScheme.surfaceBright,
              leading: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary500,
              ),
              title: Text(
                "notifications".tr(),
                style: theme.textTheme.titleMedium,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                goScreen(context: context, screen: const NotificationScreen());
              },
            ),
          if (currentUserModel.schoolId != null) SizedBox(height: 12.h),
          ValueListenableBuilder<bool>(
            valueListenable: isThemeLight,
            builder: (context, isLight, _) {
              return SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                tileColor: theme.colorScheme.surfaceBright,
                secondary: Icon(
                  isLight ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
                  color: AppColors.primary500,
                ),
                title: Text(
                  isEn ? 'Dark Mode' : 'حالت تیره',
                  style: theme.textTheme.titleMedium,
                ),
                value: !isLight,
                activeColor: AppColors.primary500,
                onChanged: (dark) {
                  isThemeLight.value = !dark;
                  prefs.setBool(AppConstants.isThemeLight, !dark);
                },
              );
            },
          ),
          SizedBox(height: 12.h),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            tileColor: theme.colorScheme.surfaceBright,
            leading: const Icon(
              Icons.language_rounded,
              color: AppColors.primary500,
            ),
            title: Text(
              isEn ? 'App Language' : 'زبان برنامه',
              style: theme.textTheme.titleMedium,
            ),
            trailing: SegmentedButton<Locale>(
              segments: const [
                ButtonSegment(value: AppLanguages.fa, label: Text('فارسی')),
                ButtonSegment(value: AppLanguages.en, label: Text('EN')),
              ],
              selected: {context.locale},
              onSelectionChanged: (selected) async {
                final newLocale = selected.first;
                await context.setLocale(newLocale);
                await persistUserSelectedLocale(newLocale);
              },
            ),
          ),
          SizedBox(height: 24.h),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            tileColor: AppColors.errorContainer.withValues(alpha: 0.35),
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: Text(
              isEn ? 'Logout' : 'خروج از حساب کاربری',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dlgCtx) => AlertDialog(
                  title: Text(isEn ? 'Logout' : 'خروج از حساب'),
                  content: Text(
                    isEn
                        ? 'Are you sure you want to log out?'
                        : 'آیا از خروج از حساب کاربری خود اطمینان دارید؟',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dlgCtx, false),
                      child: Text(isEn ? 'Cancel' : 'انصراف'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dlgCtx, true),
                      child: Text(
                        isEn ? 'Logout' : 'خروج',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                context.read<AuthBloc>().add(LogoutEvent());
              }
            },
          ),
        ],
      ),
    );
  }
}
