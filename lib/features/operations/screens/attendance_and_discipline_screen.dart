import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/app_error.dart';
import 'package:school_flutter_frontend/core/utils/snakbar.dart';
import 'package:school_flutter_frontend/core/widgets/categories_list_filter.dart';
import 'package:school_flutter_frontend/core/widgets/dropdown.dart';
import 'package:school_flutter_frontend/core/widgets/global_error_section.dart';
import 'package:school_flutter_frontend/core/widgets/global_loading_section.dart';
import 'package:school_flutter_frontend/core/widgets/main_button.dart';
import 'package:school_flutter_frontend/core/widgets/main_textfield.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:toastification/toastification.dart';

import '../../schools/models/school_models.dart';
import '../../schools/service/school_service.dart';
import '../../students/models/student_models.dart';
import '../../students/service/student_service.dart';
import '../models/operations_models.dart';
import '../service/operations_service.dart';

class AttendanceAndDisciplineScreen extends StatefulWidget {
  final int initialTabIndex;

  const AttendanceAndDisciplineScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AttendanceAndDisciplineScreen> createState() =>
      _AttendanceAndDisciplineScreenState();
}

class _AttendanceAndDisciplineScreenState
    extends State<AttendanceAndDisciplineScreen> {
  final OperationsService _opsService = OperationsService();
  final SchoolService _schoolService = SchoolService();
  final StudentService _studentService = StudentService();

  bool _isLoading = true;
  String? _error;

  List<ClassroomModel> _classrooms = [];
  List<GradeModel> _grades = [];
  List<StudentModel> _students = [];

  // وضعیت تب ۱: برگه حضور و غیاب کلاسی (Sheet & Bulk Submit)
  int? _sheetClassroomId;
  late String _sheetJalaliDate;
  int _sheetSessionNumber = 1;
  bool _sheetLoading = false;
  bool _sheetSubmitting = false;
  AttendanceSheetModel? _currentSheet;

  // وضعیت تب ۲: سوابق حضور و غیاب
  List<AttendanceRecordModel> _attendanceRecords = [];
  int? _historyClassroomFilter;

  // وضعیت تب ۳: پرونده انضباطی و تشویقی
  List<DisciplinaryRecordModel> _disciplineRecords = [];
  String? _disciplineCategoryFilter;

  // وضعیت تب ۴ (مخصوص ادمین مدرسه): اعلان‌ها و گزارش تحویل
  List<AnnouncementModel> _announcements = [];
  List<NotificationDeliveryModel> _deliveries = [];

  bool get _isAdmin => currentUserModel.isSchoolAdmin;

  @override
  void initState() {
    super.initState();
    final nowJ = Jalali.now();
    _sheetJalaliDate =
        '${nowJ.year}-${nowJ.month.toString().padLeft(2, '0')}-${nowJ.day.toString().padLeft(2, '0')}';
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final clsRes = await _schoolService.getClassrooms(isActive: true);
      final grdRes = await _schoolService.getGrades();
      final stRes = await _studentService.getStudents(isActive: true);
      final attRes = await _opsService.getAttendanceRecords(
        classroomId: _historyClassroomFilter,
      );
      final discRes = await _opsService.getDisciplinaryRecords(
        category: _disciplineCategoryFilter,
      );

      List<AnnouncementModel> anns = [];
      List<NotificationDeliveryModel> dels = [];
      if (_isAdmin) {
        final annRes = await _opsService.getAnnouncements();
        final delRes = await _opsService.getDeliveries();
        anns = annRes.results;
        dels = delRes.results;
      }

      if (!mounted) return;
      setState(() {
        _classrooms = clsRes.results;
        _grades = grdRes.results;
        _students = stRes.results;
        _attendanceRecords = attRes.results;
        _disciplineRecords = discRes.results;
        _announcements = anns;
        _deliveries = dels;
        if (_sheetClassroomId == null && _classrooms.isNotEmpty) {
          _sheetClassroomId = _classrooms.first.id;
        }
        _isLoading = false;
      });

      if (_sheetClassroomId != null) {
        _loadAttendanceSheet();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = getAppErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<String?> _pickJalaliDate(
    BuildContext context, {
    String? current,
  }) async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1400, 1),
      lastDate: Jalali(1415, 12),
    );
    if (picked == null) return null;
    return '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  // -------------------- عملیات تب ۱: دریافت و ثبت یک‌جای حضور و غیاب کلاس --------------------
  Future<void> _loadAttendanceSheet() async {
    if (_sheetClassroomId == null) return;
    setState(() => _sheetLoading = true);
    try {
      final sheet = await _opsService.getAttendanceSheet(
        classroomId: _sheetClassroomId!,
        date: _sheetJalaliDate,
        sessionNumber: _sheetSessionNumber,
      );
      if (!mounted) return;
      setState(() {
        _currentSheet = sheet;
        _sheetLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentSheet = null;
        _sheetLoading = false;
      });
      showCustomSnackBar(
        context: context,
        title: 'عدم دسترسی یا خطا در دریافت لیست کلاس',
        content: getAppErrorMessage(e),
        status: ToastificationType.error,
      );
    }
  }

  Future<void> _submitAttendanceSheet() async {
    if (_currentSheet == null || _currentSheet!.students.isEmpty) return;
    setState(() => _sheetSubmitting = true);
    try {
      final records = _currentSheet!.students
          .map(
            (s) => {
              'student_id': s.studentId,
              'status': s.status,
              'note': s.note,
            },
          )
          .toList();

      final result = await _opsService.bulkSubmitAttendance(
        classroomId: _currentSheet!.classroomId,
        date: _sheetJalaliDate,
        sessionNumber: _sheetSessionNumber,
        defaultPresentForOthers: true,
        records: records,
      );

      if (!mounted) return;
      setState(() => _sheetSubmitting = false);
      showCustomSnackBar(
        context: context,
        title: 'ثبت حضور و غیاب انجام شد',
        content:
            'ایجاد: ${result['created_count']} | ویرایش: ${result['updated_count']}',
        status: ToastificationType.success,
      );
      final attRes = await _opsService.getAttendanceRecords(
        classroomId: _historyClassroomFilter,
      );
      if (mounted) {
        setState(() => _attendanceRecords = attRes.results);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sheetSubmitting = false);
      showCustomSnackBar(
        context: context,
        title: 'خطا در ثبت حضور و غیاب',
        content: getAppErrorMessage(e),
        status: ToastificationType.error,
      );
    }
  }

  // -------------------- نمایش تاریخچه تغییرات (AuditLog) یک رکورد --------------------
  Future<void> _showAuditHistoryBottomSheet({
    required String title,
    required Future<List<AuditLogModel>> Function() loader,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return FutureBuilder<List<AuditLogModel>>(
          future: loader(),
          builder: (ctx, snapshot) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge),
                    SizedBox(height: 12.h),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (snapshot.hasError)
                      Text(
                        getAppErrorMessage(snapshot.error!),
                        style: const TextStyle(color: AppColors.error),
                      )
                    else if ((snapshot.data ?? []).isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('هیچ سابقه تغییری ثبت نشده است.'),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 340.h),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (_, i) {
                            final log = snapshot.data![i];
                            return Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceBright,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: theme.colorScheme.surfaceDim,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${log.actionLabelFa} توسط ${log.actorName ?? "کاربر"}',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      Text(
                                        log.actorRole ?? '',
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  ...log.changes.entries.map((entry) {
                                    final val = entry.value;
                                    if (val is Map) {
                                      return Text(
                                        '• ${entry.key}: «${val['old'] ?? "—"}» ⬅ «${val['new'] ?? "—"}»',
                                        style: theme.textTheme.bodySmall,
                                      );
                                    }
                                    return Text(
                                      '• ${entry.key}: $val',
                                      style: theme.textTheme.bodySmall,
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
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

  // -------------------- دیالوگ ثبت یا ویرایش مورد انضباطی / تشویقی --------------------
  Future<void> _showDisciplineFormDialog({
    DisciplinaryRecordModel? existing,
  }) async {
    if (_students.isEmpty) {
      showCustomSnackBar(
        context: context,
        title: 'دانش‌آموزی یافت نشد',
        content: 'هیچ دانش‌آموز فعالی در کلاس‌های شما ثبت نشده است.',
        status: ToastificationType.warning,
      );
      return;
    }

    int? selectedStudentId = existing?.student ?? _students.first.id;
    String selectedCategory =
        existing?.category ?? DisciplineCategory.behavioral;
    String selectedDate = existing?.date ?? _sheetJalaliDate;
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final scoreCtrl = TextEditingController(
      text: (existing?.scoreImpact ?? 0).toString(),
    );
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
                    existing == null
                        ? 'ثبت مورد انضباطی / تشویقی جدید'
                        : 'ویرایش پرونده انضباطی',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16.h),
                  if (existing == null) ...[
                    DropdownWidget(
                      hintText: 'انتخاب دانش‌آموز',
                      defaultTitle:
                          '${_students.first.displayName} (${_students.first.currentClassroomName ?? ""})',
                      dataList: _students
                          .map(
                            (s) => FilterModel(
                              name:
                                  '${s.displayName} (${s.currentClassroomName ?? ""})',
                              code: s.id,
                            ),
                          )
                          .toList(),
                      onChanged: (item) =>
                          setSheetState(() => selectedStudentId = item?.code),
                    ),
                    SizedBox(height: 12.h),
                  ],
                  DropdownWidget(
                    hintText: 'دسته‌بندی',
                    enableSearch: false,
                    defaultTitle: DisciplineCategory.labelsFa[selectedCategory],
                    dataList: DisciplineCategory.labelsFa.entries
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (e) => FilterModel(
                            name: e.value.value,
                            code: e.key,
                            id: e.value.key,
                          ),
                        )
                        .toList(),
                    onChanged: (item) {
                      if (item?.id != null) {
                        setSheetState(() => selectedCategory = item!.id!);
                      }
                    },
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final d = await _pickJalaliDate(ctx);
                            if (d != null) {
                              setSheetState(() => selectedDate = d);
                            }
                          },
                          icon: const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                          ),
                          label: Text('تاریخ: $selectedDate'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: CoreTextField(
                          controller: scoreCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                          ),
                          hint: 'تأثیر نمره (مثلاً -1 یا +2)',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: descCtrl,
                    maxLines: 3,
                    textFieldHeight: 96,
                    hint: 'شرح دقیق مورد انضباطی یا تشویقی...',
                  ),
                  SizedBox(height: 20.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: existing == null ? 'ثبت در پرونده' : 'ذخیره تغییرات',
                    onTap: () async {
                      if (descCtrl.text.trim().isEmpty ||
                          selectedStudentId == null) {
                        return;
                      }
                      setSheetState(() => saving = true);
                      try {
                        final impact = int.tryParse(scoreCtrl.text.trim()) ?? 0;
                        if (existing == null) {
                          await _opsService.createDisciplinaryRecord(
                            studentId: selectedStudentId!,
                            date: selectedDate,
                            category: selectedCategory,
                            description: descCtrl.text,
                            scoreImpact: impact,
                          );
                        } else {
                          await _opsService.updateDisciplinaryRecord(
                            id: existing.id,
                            date: selectedDate,
                            category: selectedCategory,
                            description: descCtrl.text,
                            scoreImpact: impact,
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        final discRes = await _opsService
                            .getDisciplinaryRecords(
                              category: _disciplineCategoryFilter,
                            );
                        if (mounted) {
                          setState(() => _disciplineRecords = discRes.results);
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
            );
          },
        );
      },
    );
  }

  // -------------------- دیالوگ ارسال اعلان جدید توسط کادر آموزشی --------------------
  Future<void> _showCreateAnnouncementDialog() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String targetType = 'SCHOOL';
    int? targetGradeId = _grades.isNotEmpty ? _grades.first.id : null;
    int? targetClassroomId = _classrooms.isNotEmpty
        ? _classrooms.first.id
        : null;
    bool chInApp = true;
    bool chPush = true;
    bool chSms = false;
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
                    'ارسال اعلان به اولیا',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 14.h),
                  DropdownWidget(
                    hintText: 'مخاطبان اعلان',
                    enableSearch: false,
                    defaultTitle: 'کل مدرسه',
                    dataList: [
                      FilterModel(name: 'کل مدرسه', code: 1, id: 'SCHOOL'),
                      FilterModel(name: 'یک پایه تحصیلی', code: 2, id: 'GRADE'),
                      FilterModel(
                        name: 'یک کلاس مشخص',
                        code: 3,
                        id: 'CLASSROOM',
                      ),
                    ],
                    onChanged: (item) {
                      if (item?.id != null) {
                        setSheetState(() => targetType = item!.id!);
                      }
                    },
                  ),
                  if (targetType == 'GRADE' && _grades.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    DropdownWidget(
                      hintText: 'انتخاب پایه هدف',
                      enableSearch: false,
                      defaultTitle: _grades.first.title,
                      dataList: _grades
                          .map((g) => FilterModel(name: g.title, code: g.id))
                          .toList(),
                      onChanged: (item) =>
                          setSheetState(() => targetGradeId = item?.code),
                    ),
                  ],
                  if (targetType == 'CLASSROOM' && _classrooms.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    DropdownWidget(
                      hintText: 'انتخاب کلاس هدف',
                      defaultTitle: _classrooms.first.name,
                      dataList: _classrooms
                          .map((c) => FilterModel(name: c.name, code: c.id))
                          .toList(),
                      onChanged: (item) =>
                          setSheetState(() => targetClassroomId = item?.code),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: titleCtrl,
                    hint: 'عنوان اعلان (مثال: جلسه اولیا و مربیان)',
                  ),
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: bodyCtrl,
                    maxLines: 3,
                    textFieldHeight: 96,
                    hint: 'متن کامل اطلاعیه...',
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    children: [
                      FilterChip(
                        label: const Text('درون‌برنامه‌ای'),
                        selected: chInApp,
                        onSelected: (v) => setSheetState(() => chInApp = v),
                      ),
                      FilterChip(
                        label: const Text('پوش‌نوتیفیکیشن (FCM)'),
                        selected: chPush,
                        onSelected: (v) => setSheetState(() => chPush = v),
                      ),
                      FilterChip(
                        label: const Text('پیامک (SMS)'),
                        selected: chSms,
                        onSelected: (v) => setSheetState(() => chSms = v),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: 'ارسال اعلان',
                    onTap: () async {
                      final channels = <String>[
                        if (chInApp) 'in_app',
                        if (chPush) 'push',
                        if (chSms) 'sms',
                      ];
                      if (titleCtrl.text.trim().isEmpty ||
                          bodyCtrl.text.trim().isEmpty ||
                          channels.isEmpty) {
                        return;
                      }
                      setSheetState(() => saving = true);
                      try {
                        await _opsService.createAnnouncement(
                          title: titleCtrl.text,
                          body: bodyCtrl.text,
                          targetType: targetType,
                          targetGradeId: targetGradeId,
                          targetClassroomId: targetClassroomId,
                          channels: channels,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadInitial();
                        if (mounted) {
                          showCustomSnackBar(
                            context: context,
                            title: 'ارسال شد',
                            content:
                                'اعلان با موفقیت ثبت و در صف ارسال قرار گرفت.',
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = _isAdmin ? 4 : 3;
    final safeInitIndex = widget.initialTabIndex < tabCount
        ? widget.initialTabIndex
        : 0;

    return DefaultTabController(
      length: tabCount,
      initialIndex: safeInitIndex,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isAdmin
                          ? 'حضور و غیاب، انضباط و اعلان‌ها'
                          : 'حضور و غیاب و انضباط کلاس من',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    IconButton(
                      onPressed: _loadInitial,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              TabBar(
                isScrollable: true,
                labelColor: AppColors.primary500,
                unselectedLabelColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                indicatorColor: AppColors.primary500,
                tabs: [
                  const Tab(text: 'ثبت حضور کلاسی'),
                  const Tab(text: 'سوابق حضور'),
                  const Tab(text: 'پرونده انضباطی'),
                  if (_isAdmin) const Tab(text: 'اعلان‌ها و لاگ ارسال'),
                ],
              ),
              Expanded(
                child: _isLoading
                    ? GlobalLoadingSection()
                    : _error != null
                    ? GlobalErrorSection(
                        message: _error!,
                        onRetry: _loadInitial,
                      )
                    : TabBarView(
                        children: [
                          _buildAttendanceSheetTab(),
                          _buildAttendanceHistoryTab(),
                          _buildDisciplineTab(),
                          if (_isAdmin) _buildAnnouncementsTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== تب ۱: برگه حضور و غیاب کلاسی (Sheet & Bulk Submit) ====================
  Widget _buildAttendanceSheetTab() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          color: theme.colorScheme.surfaceBright,
          child: Column(
            children: [
              if (_classrooms.isNotEmpty)
                DropdownWidget(
                  height: 50,
                  hintText: 'انتخاب کلاس',
                  defaultTitle: _classrooms
                      .where((c) => c.id == _sheetClassroomId)
                      .map((c) => c.name)
                      .firstOrNull,
                  dataList: _classrooms
                      .map((c) => FilterModel(name: c.name, code: c.id))
                      .toList(),
                  onChanged: (item) {
                    setState(() => _sheetClassroomId = item?.code);
                    _loadAttendanceSheet();
                  },
                ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final d = await _pickJalaliDate(context);
                        if (d != null) {
                          setState(() => _sheetJalaliDate = d);
                          _loadAttendanceSheet();
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: Text('تاریخ: $_sheetJalaliDate'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: DropdownWidget(
                      height: 44,
                      enableSearch: false,
                      hintText: 'انتخاب زنگ',
                      defaultTitle: _sheetSessionNumber == 0
                          ? 'روزانه (۰)'
                          : 'زنگ $_sheetSessionNumber',
                      dataList: [
                        FilterModel(name: 'روزانه (۰)', code: 0),
                        ...List.generate(
                          6,
                          (i) => FilterModel(name: 'زنگ ${i + 1}', code: i + 1),
                        ),
                      ],
                      onChanged: (item) {
                        if (item != null) {
                          setState(() => _sheetSessionNumber = item.code);
                          _loadAttendanceSheet();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _sheetLoading
              ? GlobalLoadingSection()
              : _currentSheet == null || _currentSheet!.students.isEmpty
              ? const Center(
                  child: Text(
                    'دانش‌آموزی در این کلاس یافت نشد یا به این زنگ دسترسی ندارید.',
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                  itemCount: _currentSheet!.students.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final st = _currentSheet!.students[index];
                    return Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceBright,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: theme.colorScheme.surfaceDim),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${index + 1}. ${st.fullName} (فرزند ${st.fatherName})',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                st.nationalCode,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 6.h,
                            children: [
                              _buildStatusChoiceChip(
                                st: st,
                                statusValue: AttendanceStatus.present,
                                label: 'حاضر',
                                activeColor: AppColors.green,
                              ),
                              _buildStatusChoiceChip(
                                st: st,
                                statusValue: AttendanceStatus.late,
                                label: 'تأخیر',
                                activeColor: AppColors.yellow,
                              ),
                              _buildStatusChoiceChip(
                                st: st,
                                statusValue: AttendanceStatus.unexcusedAbsence,
                                label: 'غایب غیرموجه',
                                activeColor: AppColors.error,
                              ),
                              _buildStatusChoiceChip(
                                st: st,
                                statusValue: AttendanceStatus.excusedAbsence,
                                label: 'غایب موجه',
                                activeColor: AppColors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (_currentSheet != null && _currentSheet!.students.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            child: CustomElevatedButton(
              loading: _sheetSubmitting,
              text:
                  'ثبت یک‌جای حضور و غیاب کلاس (${_currentSheet!.students.length} نفر)',
              onTap: _submitAttendanceSheet,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChoiceChip({
    required AttendanceSheetStudentItem st,
    required String statusValue,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = st.status == statusValue;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedColor: activeColor,
      onSelected: (_) {
        setState(() => st.status = statusValue);
      },
    );
  }

  // ==================== تب ۲: سوابق حضور و غیاب + تاریخچه تغییرات (AuditLog) ====================
  Widget _buildAttendanceHistoryTab() {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 10.h),
        if (_classrooms.isNotEmpty)
          CategoriesListFilter(
            categories: ['همه کلاس‌ها', ..._classrooms.map((c) => c.name)],
            onCategorySelected: (name) async {
              if (name == 'همه کلاس‌ها') {
                _historyClassroomFilter = null;
              } else {
                _historyClassroomFilter = _classrooms
                    .firstWhere((c) => c.name == name)
                    .id;
              }
              final res = await _opsService.getAttendanceRecords(
                classroomId: _historyClassroomFilter,
              );
              if (mounted) {
                setState(() => _attendanceRecords = res.results);
              }
            },
          ),
        SizedBox(height: 8.h),
        Expanded(
          child: _attendanceRecords.isEmpty
              ? const Center(child: Text('هیچ سابقه حضور و غیابی یافت نشد.'))
              : ListView.separated(
                  padding: EdgeInsets.all(20.r),
                  itemCount: _attendanceRecords.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final rec = _attendanceRecords[index];
                    return Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceBright,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: theme.colorScheme.surfaceDim),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${rec.studentFullName} • ${AttendanceStatus.labelFa(rec.status)}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'کلاس ${rec.classroomName} • تاریخ ${rec.date} (${rec.sessionLabelFa})',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (rec.note.isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    'توضیحات: ${rec.note}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'تاریخچه تغییرات (AuditLog)',
                            onPressed: () {
                              _showAuditHistoryBottomSheet(
                                title:
                                    'تاریخچه تغییرات حضور «${rec.studentFullName}»',
                                loader: () => _opsService
                                    .getAttendanceRecordHistory(rec.id),
                              );
                            },
                            icon: const Icon(
                              Icons.history_rounded,
                              color: AppColors.primary500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==================== تب ۳: پرونده انضباطی و تشویقی + تاریخچه تغییرات ====================
  Widget _buildDisciplineTab() {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        onPressed: () => _showDisciplineFormDialog(),
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('ثبت مورد جدید'),
      ),
      body: _disciplineRecords.isEmpty
          ? const Center(
              child: Text('هیچ مورد انضباطی یا تشویقی ثبت نشده است.'),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 88.h),
              itemCount: _disciplineRecords.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final item = _disciplineRecords[index];
                final isMerit =
                    item.category == DisciplineCategory.merit ||
                    item.scoreImpact > 0;

                return Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceBright,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isMerit ? AppColors.green : AppColors.surfaceDim,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.studentFullName} (${item.classroomName ?? ""})',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: isMerit
                                  ? AppColors.statusConfirmedBg
                                  : AppColors.statusCancelledBg,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              item.categoryDisplay,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: isMerit
                                    ? AppColors.statusConfirmedFg
                                    : AppColors.statusCancelledFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(item.description, style: theme.textTheme.bodyMedium),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تاریخ: ${item.date} • نمره: ${item.scoreImpact} • ثبت: ${item.createdByName ?? "—"}',
                            style: theme.textTheme.bodySmall,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'تاریخچه تغییرات (AuditLog)',
                                onPressed: () {
                                  _showAuditHistoryBottomSheet(
                                    title:
                                        'تاریخچه تغییرات پرونده «${item.studentFullName}»',
                                    loader: () => _opsService
                                        .getDisciplineRecordHistory(item.id),
                                  );
                                },
                                icon: const Icon(
                                  Icons.history_rounded,
                                  size: 20,
                                  color: AppColors.primary500,
                                ),
                              ),
                              IconButton(
                                tooltip: 'ویرایش',
                                onPressed: () =>
                                    _showDisciplineFormDialog(existing: item),
                                icon: const Icon(Icons.edit_outlined, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ==================== تب ۴: اعلان‌های مدرسه و لاگ ارسال (مخصوص ادمین مدرسه) ====================
  Widget _buildAnnouncementsTab() {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        onPressed: _showCreateAnnouncementDialog,
        icon: const Icon(Icons.campaign_rounded),
        label: const Text('اعلان جدید'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 88.h),
        children: [
          Text('اعلان‌های ارسال‌شده', style: theme.textTheme.headlineMedium),
          SizedBox(height: 8.h),
          if (_announcements.isEmpty)
            Text('هنوز اعلانی ثبت نشده است.', style: theme.textTheme.bodySmall)
          else
            ..._announcements.map(
              (ann) => Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceBright,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: theme.colorScheme.surfaceDim),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ann.title,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Chip(
                          label: Text(
                            ann.targetLabelFa,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(ann.body, style: theme.textTheme.bodySmall),
                    SizedBox(height: 6.h),
                    Text(
                      'کانال‌ها: ${ann.channels.join(", ")}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 20.h),
          Text(
            'لاگ وضعیت ارسال پیامک و پوش (Celery)',
            style: theme.textTheme.headlineMedium,
          ),
          SizedBox(height: 8.h),
          if (_deliveries.isEmpty)
            Text('لاگ ارسالی ثبت نشده است.', style: theme.textTheme.bodySmall)
          else
            ..._deliveries
                .take(15)
                .map(
                  (d) => Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceBright,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: theme.colorScheme.surfaceDim),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${d.channel.toUpperCase()} • گیرنده: ${d.recipient} (${d.subject})',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          d.status,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: d.status == 'sent'
                                ? AppColors.green
                                : AppColors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
