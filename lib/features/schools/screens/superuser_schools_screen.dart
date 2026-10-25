import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/app_error.dart';
import 'package:school_flutter_frontend/core/utils/snakbar.dart';
import 'package:school_flutter_frontend/core/widgets/global_error_section.dart';
import 'package:school_flutter_frontend/core/widgets/global_loading_section.dart';
import 'package:school_flutter_frontend/core/widgets/main_button.dart';
import 'package:school_flutter_frontend/core/widgets/main_textfield.dart';
import 'package:toastification/toastification.dart';

import '../models/school_models.dart';
import '../service/school_service.dart';

class SuperuserSchoolsScreen extends StatefulWidget {
  const SuperuserSchoolsScreen({super.key});

  @override
  State<SuperuserSchoolsScreen> createState() => _SuperuserSchoolsScreenState();
}

class _SuperuserSchoolsScreenState extends State<SuperuserSchoolsScreen> {
  final SchoolService _service = SchoolService();
  bool _isLoading = true;
  String? _error;
  List<SchoolModel> _schools = [];

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _service.getSchools();
      if (!mounted) return;
      setState(() {
        _schools = res.results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = getAppErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSchoolActive(SchoolModel school) async {
    try {
      final updated = await _service.updateSchool(
        id: school.id,
        isActive: !school.isActive,
      );
      if (!mounted) return;
      setState(() {
        final idx = _schools.indexWhere((s) => s.id == school.id);
        if (idx != -1) _schools[idx] = updated;
      });
      showCustomSnackBar(
        context: context,
        title: 'به‌روزرسانی شد',
        content: updated.isActive ? 'مدرسه فعال شد.' : 'مدرسه غیرفعال شد.',
        status: ToastificationType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(
        context: context,
        title: 'خطا',
        content: getAppErrorMessage(e),
        status: ToastificationType.error,
      );
    }
  }

  Future<void> _showCreateSchoolDialog() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعریف مدرسه جدید',
                      style: Theme.of(ctx).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 16.h),
                    CoreTextField(
                      controller: nameCtrl,
                      hint: 'نام مدرسه (مثال: دبیرستان البرز)',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'الزامی است' : null,
                    ),
                    SizedBox(height: 12.h),
                    CoreTextField(
                      controller: codeCtrl,
                      hint: 'کد یکتای انگلیسی (مثال: alborz)',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'الزامی است' : null,
                    ),
                    SizedBox(height: 20.h),
                    CustomElevatedButton(
                      loading: saving,
                      text: 'ثبت مدرسه',
                      onTap: () async {
                        if (!formKey.currentState!.validate()) return;
                        setSheetState(() => saving = true);
                        try {
                          await _service.createSchool(
                            name: nameCtrl.text,
                            code: codeCtrl.text,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadSchools();
                          if (mounted) {
                            showCustomSnackBar(
                              context: context,
                              title: 'موفق',
                              content: 'مدرسه جدید با موفقیت ایجاد شد.',
                              status: ToastificationType.success,
                            );
                          }
                        } catch (e) {
                          setSheetState(() => saving = false);
                          if (ctx.mounted) {
                            showCustomSnackBar(
                              context: ctx,
                              title: 'خطا',
                              content: getAppErrorMessage(e),
                              status: ToastificationType.error,
                            );
                          }
                        }
                      },
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

  Future<void> _showCreateAdminDialog(SchoolModel school) async {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final fNameCtrl = TextEditingController();
    final lNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعریف ادمین برای «${school.name}»',
                      style: Theme.of(ctx).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 16.h),
                    CoreTextField(
                      controller: userCtrl,
                      hint: 'نام کاربری ادمین (مثال: ${school.code}_admin)',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'الزامی است' : null,
                    ),
                    SizedBox(height: 12.h),
                    CoreTextField(
                      controller: passCtrl,
                      obscure: true,
                      hint: 'رمز عبور (حداقل ۶ کاراکتر)',
                      validator: (v) => (v == null || v.length < 6)
                          ? 'رمز عبور باید حداقل ۶ کاراکتر باشد'
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: CoreTextField(
                            controller: fNameCtrl,
                            hint: 'نام (اختیاری)',
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: CoreTextField(
                            controller: lNameCtrl,
                            hint: 'نام خانوادگی (اختیاری)',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    CoreTextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      hint: 'شماره موبایل (اختیاری - 0912xxxxxxx)',
                    ),
                    SizedBox(height: 20.h),
                    CustomElevatedButton(
                      loading: saving,
                      text: 'ایجاد ادمین مدرسه',
                      onTap: () async {
                        if (!formKey.currentState!.validate()) return;
                        setSheetState(() => saving = true);
                        try {
                          await _service.createSchoolAdmin(
                            schoolId: school.id,
                            username: userCtrl.text,
                            password: passCtrl.text,
                            firstName: fNameCtrl.text,
                            lastName: lNameCtrl.text,
                            phoneNumber: phoneCtrl.text,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            showCustomSnackBar(
                              context: context,
                              title: 'موفق',
                              content:
                                  'ادمین مدرسه با نام کاربری ${userCtrl.text.trim()} ساخته شد.',
                              status: ToastificationType.success,
                            );
                          }
                        } catch (e) {
                          setSheetState(() => saving = false);
                          if (ctx.mounted) {
                            showCustomSnackBar(
                              context: ctx,
                              title: 'خطا',
                              content: getAppErrorMessage(e),
                              status: ToastificationType.error,
                            );
                          }
                        }
                      },
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        onPressed: _showCreateSchoolDialog,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('مدرسه جدید'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مدیریت مدارس سامانه',
                        style: theme.textTheme.bodyLarge,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'تعریف مدارس و ساخت کادر مدیریت هر مدرسه',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _loadSchools,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? GlobalLoadingSection()
                  : _error != null
                  ? GlobalErrorSection(message: _error!, onRetry: _loadSchools)
                  : _schools.isEmpty
                  ? Center(
                      child: Text(
                        'هنوز مدرسه‌ای ثبت نشده است.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSchools,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 90.h),
                        itemCount: _schools.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final school = _schools[index];
                          return Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceBright,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: theme.colorScheme.surfaceDim,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 42.r,
                                      height: 42.r,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary500.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.school_rounded,
                                        color: AppColors.primary500,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            school.name,
                                            style:
                                                theme.textTheme.headlineMedium,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            'کد مدرسه: ${school.code}',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: school.isActive,
                                      activeColor: AppColors.primary500,
                                      onChanged: (_) =>
                                          _toggleSchoolActive(school),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: school.isActive
                                            ? AppColors.statusConfirmedBg
                                            : AppColors.statusCancelledBg,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        school.isActive ? 'فعال' : 'غیرفعال',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color: school.isActive
                                                  ? AppColors.statusConfirmedFg
                                                  : AppColors.statusCancelledFg,
                                            ),
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () =>
                                          _showCreateAdminDialog(school),
                                      icon: const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('تعریف ادمین مدرسه'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
