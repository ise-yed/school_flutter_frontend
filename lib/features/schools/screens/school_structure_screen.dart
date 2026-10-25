import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/app_error.dart';
import 'package:school_flutter_frontend/core/utils/snakbar.dart';
import 'package:school_flutter_frontend/core/widgets/dropdown.dart';
import 'package:school_flutter_frontend/core/widgets/global_error_section.dart';
import 'package:school_flutter_frontend/core/widgets/global_loading_section.dart';
import 'package:school_flutter_frontend/core/widgets/main_button.dart';
import 'package:school_flutter_frontend/core/widgets/main_textfield.dart';
import 'package:toastification/toastification.dart';

import '../models/school_models.dart';
import '../service/school_service.dart';

class SchoolStructureScreen extends StatefulWidget {
  const SchoolStructureScreen({super.key});

  @override
  State<SchoolStructureScreen> createState() => _SchoolStructureScreenState();
}

class _SchoolStructureScreenState extends State<SchoolStructureScreen> {
  final SchoolService _service = SchoolService();

  bool _isLoading = true;
  String? _error;

  List<AcademicYearModel> _years = [];
  List<GradeModel> _grades = [];
  List<ClassroomModel> _classrooms = [];
  List<TeacherAssignmentModel> _assignments = [];
  List<StaffMemberModel> _staff = [];

  bool get _isAdmin => currentUserModel.isSchoolAdmin;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getAcademicYears(),
        _service.getGrades(),
        _service.getClassrooms(),
        _service.getTeacherAssignments(),
        if (_isAdmin) _service.getStaff(),
      ]);

      if (!mounted) return;
      setState(() {
        _years = (results[0] as PaginatedResponse<AcademicYearModel>).results;
        _grades = (results[1] as PaginatedResponse<GradeModel>).results;
        _classrooms = (results[2] as PaginatedResponse<ClassroomModel>).results;
        _assignments =
            (results[3] as PaginatedResponse<TeacherAssignmentModel>).results;
        if (_isAdmin && results.length > 4) {
          _staff = (results[4] as PaginatedResponse<StaffMemberModel>).results;
        }
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

  Future<String?> _pickJalaliDate(BuildContext context) async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1395, 1),
      lastDate: Jalali(1420, 12),
    );
    if (picked == null) return null;
    final y = picked.year.toString();
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // -------------------- دیالوگ ساخت کلاس جدید --------------------
  Future<void> _showCreateClassroomDialog() async {
    if (_years.isEmpty || _grades.isEmpty) {
      showCustomSnackBar(
        context: context,
        title: 'پیش‌نیاز ساختار آموزشی',
        content: 'لطفاً ابتدا حداقل یک سال تحصیلی و یک پایه تعریف کنید.',
        status: ToastificationType.warning,
      );
      return;
    }

    final nameCtrl = TextEditingController();
    int? selectedYearId = _years
        .firstWhere((y) => y.isCurrent, orElse: () => _years.first)
        .id;
    int? selectedGradeId = _grades.first.id;
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعریف کلاس جدید',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16.h),
                  DropdownWidget(
                    hintText: 'انتخاب سال تحصیلی',
                    enableSearch: false,
                    defaultTitle: _years
                        .firstWhere((y) => y.id == selectedYearId)
                        .title,
                    dataList: _years
                        .map((y) => FilterModel(name: y.title, code: y.id))
                        .toList(),
                    onChanged: (item) =>
                        setSheetState(() => selectedYearId = item?.code),
                  ),
                  SizedBox(height: 12.h),
                  DropdownWidget(
                    hintText: 'انتخاب پایه تحصیلی',
                    enableSearch: false,
                    defaultTitle: _grades
                        .firstWhere((g) => g.id == selectedGradeId)
                        .title,
                    dataList: _grades
                        .map((g) => FilterModel(name: g.title, code: g.id))
                        .toList(),
                    onChanged: (item) =>
                        setSheetState(() => selectedGradeId = item?.code),
                  ),
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: nameCtrl,
                    hint: 'نام کلاس (مثال: هفتم الف)',
                  ),
                  SizedBox(height: 20.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: 'ثبت کلاس',
                    onTap: () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          selectedYearId == null ||
                          selectedGradeId == null) {
                        return;
                      }
                      setSheetState(() => saving = true);
                      try {
                        await _service.createClassroom(
                          academicYearId: selectedYearId!,
                          gradeId: selectedGradeId!,
                          name: nameCtrl.text,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadAll();
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
            );
          },
        );
      },
    );
  }

  // -------------------- دیالوگ تخصیص معلم و زنگ --------------------
  Future<void> _showCreateAssignmentDialog() async {
    final teachers = _staff.where((s) => s.role == 'TEACHER').toList();
    if (teachers.isEmpty || _classrooms.isEmpty) {
      showCustomSnackBar(
        context: context,
        title: 'پیش‌نیاز برنامه کلاسی',
        content: 'ابتدا حداقل یک معلم و یک کلاس فعال تعریف کنید.',
        status: ToastificationType.warning,
      );
      return;
    }

    final subjectCtrl = TextEditingController();
    int? selectedTeacherId = teachers.first.id;
    int? selectedClassroomId = _classrooms.first.id;
    int? selectedDayOfWeek; // null = همه روزها
    int selectedSession = 1;
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تخصیص معلم و زنگ به کلاس',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16.h),
                  DropdownWidget(
                    hintText: 'انتخاب معلم',
                    defaultTitle: teachers.first.fullName,
                    dataList: teachers
                        .map((t) => FilterModel(name: t.fullName, code: t.id))
                        .toList(),
                    onChanged: (item) =>
                        setSheetState(() => selectedTeacherId = item?.code),
                  ),
                  SizedBox(height: 12.h),
                  DropdownWidget(
                    hintText: 'انتخاب کلاس',
                    defaultTitle: _classrooms.first.name,
                    dataList: _classrooms
                        .map((c) => FilterModel(name: c.name, code: c.id))
                        .toList(),
                    onChanged: (item) =>
                        setSheetState(() => selectedClassroomId = item?.code),
                  ),
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: subjectCtrl,
                    hint: 'نام درس (مثال: ریاضی)',
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownWidget(
                          hintText: 'روز هفته',
                          enableSearch: false,
                          defaultTitle: 'همه روزها',
                          dataList: [
                            FilterModel(name: 'همه روزها', code: -1),
                            ...TeacherAssignmentModel.persianWeekDays.entries
                                .map(
                                  (e) =>
                                      FilterModel(name: e.value, code: e.key),
                                ),
                          ],
                          onChanged: (item) {
                            setSheetState(() {
                              selectedDayOfWeek =
                                  (item == null || item.code == -1)
                                  ? null
                                  : item.code;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: DropdownWidget(
                          hintText: 'شماره زنگ',
                          enableSearch: false,
                          defaultTitle: 'زنگ ۱',
                          dataList: List.generate(
                            6,
                            (i) =>
                                FilterModel(name: 'زنگ ${i + 1}', code: i + 1),
                          ),
                          onChanged: (item) {
                            if (item != null) {
                              setSheetState(() => selectedSession = item.code);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: 'ثبت در برنامه کلاسی',
                    onTap: () async {
                      if (subjectCtrl.text.trim().isEmpty ||
                          selectedTeacherId == null ||
                          selectedClassroomId == null) {
                        return;
                      }
                      setSheetState(() => saving = true);
                      try {
                        await _service.createTeacherAssignment(
                          teacherId: selectedTeacherId!,
                          classroomId: selectedClassroomId!,
                          subjectName: subjectCtrl.text,
                          dayOfWeek: selectedDayOfWeek,
                          sessionNumber: selectedSession,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadAll();
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
            );
          },
        );
      },
    );
  }

  // -------------------- دیالوگ افزودن کادر یا معلم --------------------
  Future<void> _showCreateStaffDialog() async {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final fNameCtrl = TextEditingController();
    final lNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedRole = 'TEACHER';
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'افزودن معلم یا کادر آموزشی',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16.h),
                  DropdownWidget(
                    hintText: 'نقش کاربر',
                    enableSearch: false,
                    defaultTitle: 'معلم',
                    dataList: [
                      FilterModel(name: 'معلم', code: 1),
                      FilterModel(name: 'کادر آموزشی / ادمین', code: 2),
                    ],
                    onChanged: (item) {
                      setSheetState(() {
                        selectedRole = item?.code == 2
                            ? 'SCHOOL_ADMIN'
                            : 'TEACHER';
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: CoreTextField(
                          controller: fNameCtrl,
                          hint: 'نام',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: CoreTextField(
                          controller: lNameCtrl,
                          hint: 'نام خانوادگی',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: userCtrl,
                    hint: 'نام کاربری (انگلیسی)',
                  ),
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: passCtrl,
                    obscure: true,
                    hint: 'رمز عبور (حداقل ۶ کاراکتر)',
                  ),
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    hint: 'شماره موبایل (اختیاری)',
                  ),
                  SizedBox(height: 20.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: 'ایجاد کاربر',
                    onTap: () async {
                      if (userCtrl.text.trim().isEmpty ||
                          passCtrl.text.length < 6) {
                        return;
                      }
                      setSheetState(() => saving = true);
                      try {
                        await _service.createStaff(
                          username: userCtrl.text,
                          password: passCtrl.text,
                          firstName: fNameCtrl.text,
                          lastName: lNameCtrl.text,
                          phoneNumber: phoneCtrl.text,
                          role: selectedRole,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadAll();
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
            );
          },
        );
      },
    );
  }

  // -------------------- دیالوگ سال تحصیلی و پایه --------------------
  Future<void> _showCreateAcademicYearDialog() async {
    final titleCtrl = TextEditingController();
    String? startDate;
    String? endDate;
    bool isCurrent = _years.isEmpty;
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعریف سال تحصیلی',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 14.h),
                  CoreTextField(
                    controller: titleCtrl,
                    hint: 'عنوان سال تحصیلی (مثال: ۱۴۰۴-۱۴۰۵)',
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final d = await _pickJalaliDate(ctx);
                            if (d != null) setSheetState(() => startDate = d);
                          },
                          icon: const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                          ),
                          label: Text(startDate ?? 'تاریخ شروع'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final d = await _pickJalaliDate(ctx);
                            if (d != null) setSheetState(() => endDate = d);
                          },
                          icon: const Icon(Icons.event_rounded, size: 16),
                          label: Text(endDate ?? 'تاریخ پایان'),
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('سال تحصیلی جاری مدرسه'),
                    value: isCurrent,
                    activeColor: AppColors.primary500,
                    onChanged: (v) => setSheetState(() => isCurrent = v),
                  ),
                  SizedBox(height: 14.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: 'ثبت سال تحصیلی',
                    onTap: () async {
                      if (titleCtrl.text.trim().isEmpty ||
                          startDate == null ||
                          endDate == null) {
                        return;
                      }
                      setSheetState(() => saving = true);
                      try {
                        await _service.createAcademicYear(
                          title: titleCtrl.text,
                          startDate: startDate!,
                          endDate: endDate!,
                          isCurrent: isCurrent,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadAll();
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
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateGradeDialog() async {
    final titleCtrl = TextEditingController();
    final orderCtrl = TextEditingController(text: '7');
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعریف پایه تحصیلی',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 14.h),
                  CoreTextField(
                    controller: titleCtrl,
                    hint: 'عنوان پایه (مثال: هفتم)',
                  ),
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    hint: 'ترتیب عددی پایه (مثال: 7)',
                  ),
                  SizedBox(height: 16.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: 'ثبت پایه',
                    onTap: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      setSheetState(() => saving = true);
                      try {
                        await _service.createGrade(
                          title: titleCtrl.text,
                          levelOrder: int.tryParse(orderCtrl.text) ?? 1,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadAll();
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = _isAdmin ? 4 : 2;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAdmin
                              ? 'ساختار آموزشی و کادر مدرسه'
                              : 'کلاس‌ها و برنامه هفتگی من',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${currentUserModel.displayName} • ${currentUserModel.roleDisplayFa}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _loadAll,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              TabBar(
                isScrollable: _isAdmin,
                labelColor: AppColors.primary500,
                unselectedLabelColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                indicatorColor: AppColors.primary500,
                tabs: [
                  const Tab(text: 'کلاس‌ها'),
                  const Tab(text: 'برنامه معلمان'),
                  if (_isAdmin) const Tab(text: 'سال تحصیلی و پایه'),
                  if (_isAdmin) const Tab(text: 'کادر و معلمان'),
                ],
              ),
              Expanded(
                child: _isLoading
                    ? GlobalLoadingSection()
                    : _error != null
                    ? GlobalErrorSection(message: _error!, onRetry: _loadAll)
                    : TabBarView(
                        children: [
                          _buildClassroomsTab(),
                          _buildAssignmentsTab(),
                          if (_isAdmin) _buildAcademicYearsAndGradesTab(),
                          if (_isAdmin) _buildStaffTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassroomsTab() {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              onPressed: _showCreateClassroomDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('کلاس جدید'),
            )
          : null,
      body: _classrooms.isEmpty
          ? const Center(child: Text('هیچ کلاسی یافت نشد.'))
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 88.h),
              itemCount: _classrooms.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final c = _classrooms[index];
                return Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceBright,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: theme.colorScheme.surfaceDim),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: const Icon(
                          Icons.class_rounded,
                          color: AppColors.primary500,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: theme.textTheme.headlineMedium),
                            SizedBox(height: 4.h),
                            Text(
                              'پایه ${c.gradeTitle} • سال تحصیلی ${c.academicYearTitle}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (_isAdmin)
                        Switch(
                          value: c.isActive,
                          activeColor: AppColors.primary500,
                          onChanged: (val) async {
                            await _service.updateClassroom(
                              id: c.id,
                              isActive: val,
                            );
                            _loadAll();
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAssignmentsTab() {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              onPressed: _showCreateAssignmentDialog,
              icon: const Icon(Icons.schedule_rounded),
              label: const Text('تخصیص زنگ جدید'),
            )
          : null,
      body: _assignments.isEmpty
          ? const Center(child: Text('هیچ برنامه کلاسی ثبت نشده است.'))
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 88.h),
              itemCount: _assignments.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final a = _assignments[index];
                return Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceBright,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: theme.colorScheme.surfaceDim),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'زنگ ${a.sessionNumber}',
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${a.subjectName} — کلاس ${a.classroomName}',
                              style: theme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'معلم: ${a.teacherName} • روز: ${a.dayOfWeekDisplay ?? "همه روزها"}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (_isAdmin)
                        IconButton(
                          onPressed: () async {
                            await _service.deleteTeacherAssignment(a.id);
                            _loadAll();
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAcademicYearsAndGradesTab() {
    final theme = Theme.of(context);
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('سال‌های تحصیلی', style: theme.textTheme.headlineMedium),
            TextButton.icon(
              onPressed: _showCreateAcademicYearDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('سال جدید'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ..._years.map(
          (y) => Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: y.isCurrent
                    ? AppColors.primary500
                    : theme.colorScheme.surfaceDim,
                width: y.isCurrent ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(y.title, style: theme.textTheme.titleMedium),
                          SizedBox(height: 4.h),
                          Text(
                            'از ${y.startDate} تا ${y.endDate}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (y.isCurrent)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusConfirmedBg,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'سال جاری',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.statusConfirmedFg,
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              try {
                                await _service.updateAcademicYear(
                                  id: y.id,
                                  isCurrent: true,
                                );
                                _loadAll();
                                if (mounted) {
                                  showCustomSnackBar(
                                    context: context,
                                    title: 'به‌روزرسانی شد',
                                    content:
                                        'سال تحصیلی «${y.title}» به عنوان سال جاری انتخاب شد.',
                                    status: ToastificationType.success,
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  showCustomSnackBar(
                                    context: context,
                                    title: 'خطا',
                                    content: getAppErrorMessage(e),
                                    status: ToastificationType.error,
                                  );
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('انتخاب به‌عنوان سال جاری'),
                          ),
                          IconButton(
                            tooltip: 'حذف سال تحصیلی',
                            onPressed: () async {
                              try {
                                await _service.deleteAcademicYear(y.id);
                                _loadAll();
                              } catch (e) {
                                if (mounted) {
                                  showCustomSnackBar(
                                    context: context,
                                    title: 'خطا در حذف',
                                    content: getAppErrorMessage(e),
                                    status: ToastificationType.error,
                                  );
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('پایه‌های تحصیلی', style: theme.textTheme.headlineMedium),
            TextButton.icon(
              onPressed: _showCreateGradeDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('پایه جدید'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _grades
              .map(
                (g) => Chip(
                  label: Text('${g.title} (ترتیب ${g.levelOrder})'),
                  backgroundColor: theme.colorScheme.surfaceBright,
                  onDeleted: () async {
                    try {
                      await _service.deleteGrade(g.id);
                      _loadAll();
                    } catch (e) {
                      if (mounted) {
                        showCustomSnackBar(
                          context: context,
                          title: 'خطا در حذف پایه',
                          content: getAppErrorMessage(e),
                          status: ToastificationType.error,
                        );
                      }
                    }
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStaffTab() {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        onPressed: _showCreateStaffDialog,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('کاربر جدید'),
      ),
      body: _staff.isEmpty
          ? const Center(child: Text('هیچ کادری ثبت نشده است.'))
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 88.h),
              itemCount: _staff.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final s = _staff[index];
                return Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceBright,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: theme.colorScheme.surfaceDim),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary500.withValues(
                          alpha: 0.12,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary500,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.fullName,
                              style: theme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${s.roleDisplayFa} • نام کاربری: ${s.username}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
