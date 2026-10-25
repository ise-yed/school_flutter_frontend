import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/app_error.dart';
import 'package:school_flutter_frontend/core/utils/search_box_widget.dart';
import 'package:school_flutter_frontend/core/utils/snakbar.dart';
import 'package:school_flutter_frontend/core/widgets/categories_list_filter.dart';
import 'package:school_flutter_frontend/core/widgets/dropdown.dart';
import 'package:school_flutter_frontend/core/widgets/global_error_section.dart';
import 'package:school_flutter_frontend/core/widgets/global_loading_section.dart';
import 'package:school_flutter_frontend/core/widgets/main_button.dart';
import 'package:school_flutter_frontend/core/widgets/main_textfield.dart';
import 'package:toastification/toastification.dart';

import '../../schools/models/school_models.dart';
import '../../schools/service/school_service.dart';
import '../models/student_models.dart';
import '../service/student_service.dart';

class AdminStudentsHubScreen extends StatefulWidget {
  const AdminStudentsHubScreen({super.key});

  @override
  State<AdminStudentsHubScreen> createState() => _AdminStudentsHubScreenState();
}

class _AdminStudentsHubScreenState extends State<AdminStudentsHubScreen> {
  final StudentService _studentService = StudentService();
  final SchoolService _schoolService = SchoolService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;

  List<ClassroomModel> _classrooms = [];
  List<StudentModel> _students = [];
  List<ParentStudentLinkModel> _parentLinks = [];
  List<ImportLogModel> _importLogs = [];

  int? _selectedClassroomFilter;
  String _searchQuery = '';
  bool? _parentVerifiedFilter; // null = همه | false = در انتظار تأیید | true = تأییدشده

  // وضعیت ویزارد ۳ مرحله‌ای ایمپورت اکسل
  bool _importBusy = false;
  ImportAnalyzeResult? _analyzeResult;
  ImportPreviewResult? _previewResult;
  ImportCommitResult? _commitResult;
  int? _targetClassroomId;
  int _headerRow = 1;
  Map<String, dynamic> _mapping = {};
  final Map<String, Map<String, String>> _rowOverrides = {};
  bool _allowClassroomTransfer = false;
  bool _saveMapping = true;

  bool get _isAdmin => currentUserModel.isSchoolAdmin;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final clsRes = await _schoolService.getClassrooms(isActive: true);
      final stRes = await _studentService.getStudents(
        classroomId: _selectedClassroomFilter,
        query: _searchQuery,
      );

      List<ParentStudentLinkModel> links = [];
      List<ImportLogModel> logs = [];
      if (_isAdmin) {
        final linksRes = await _studentService.getParentLinks(
          isVerified: _parentVerifiedFilter,
          classroomId: _selectedClassroomFilter,
        );
        final logsRes = await _studentService.getImportLogs();
        links = linksRes.results;
        logs = logsRes.results;
      }

      if (!mounted) return;
      setState(() {
        _classrooms = clsRes.results;
        _students = stRes.results;
        _parentLinks = links;
        _importLogs = logs;
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

  Future<void> _refreshStudents() async {
    try {
      final stRes = await _studentService.getStudents(
        classroomId: _selectedClassroomFilter,
        query: _searchQuery,
      );
      if (!mounted) return;
      setState(() => _students = stRes.results);
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(
        context: context,
        title: 'خطا در جستجو',
        content: getAppErrorMessage(e),
        status: ToastificationType.error,
      );
    }
  }

  Future<void> _refreshParentLinks() async {
    if (!_isAdmin) return;
    try {
      final res = await _studentService.getParentLinks(
        isVerified: _parentVerifiedFilter,
        classroomId: _selectedClassroomFilter,
      );
      if (!mounted) return;
      setState(() => _parentLinks = res.results);
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

  // -------------------- دیالوگ ثبت یا ویرایش دانش‌آموز و کلاس --------------------
  Future<void> _showStudentFormDialog({StudentModel? existing}) async {
    final fNameCtrl = TextEditingController(text: existing?.firstName ?? '');
    final lNameCtrl = TextEditingController(text: existing?.lastName ?? '');
    final fatherCtrl = TextEditingController(text: existing?.fatherName ?? '');
    final ncCtrl = TextEditingController(text: existing?.nationalCode ?? '');
    final codeCtrl = TextEditingController(text: existing?.studentCode ?? '');
    int? selectedClassroomId =
        existing?.currentClassroomId ??
        (_classrooms.isNotEmpty ? _classrooms.first.id : null);
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
                        ? 'ثبت دانش‌آموز جدید'
                        : 'ویرایش مشخصات دانش‌آموز',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16.h),
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
                  Row(
                    children: [
                      Expanded(
                        child: CoreTextField(
                          controller: fatherCtrl,
                          hint: 'نام پدر',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: CoreTextField(
                          controller: ncCtrl,
                          keyboardType: TextInputType.number,
                          hint: 'کد ملی ۱۰ رقمی',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  CoreTextField(
                    controller: codeCtrl,
                    keyboardType: TextInputType.number,
                    hint: 'کد دانش‌آموزی / سناد (اختیاری)',
                  ),
                  if (_classrooms.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    DropdownWidget(
                      hintText: 'کلاس دانش‌آموز',
                      defaultTitle: _classrooms
                          .where((c) => c.id == selectedClassroomId)
                          .map((c) => c.name)
                          .firstOrNull,
                      dataList: _classrooms
                          .map((c) => FilterModel(name: c.name, code: c.id))
                          .toList(),
                      onChanged: (item) =>
                          setSheetState(() => selectedClassroomId = item?.code),
                    ),
                  ],
                  SizedBox(height: 20.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: existing == null ? 'ثبت دانش‌آموز' : 'ذخیره تغییرات',
                    onTap: () async {
                      if (fNameCtrl.text.trim().isEmpty ||
                          lNameCtrl.text.trim().isEmpty ||
                          ncCtrl.text.trim().isEmpty) {
                        return;
                      }
                      setSheetState(() => saving = true);
                      try {
                        StudentModel saved;
                        if (existing == null) {
                          saved = await _studentService.createStudent(
                            firstName: fNameCtrl.text,
                            lastName: lNameCtrl.text,
                            fatherName: fatherCtrl.text,
                            nationalCode: ncCtrl.text,
                            studentCode: codeCtrl.text,
                          );
                        } else {
                          saved = await _studentService.updateStudent(
                            id: existing.id,
                            firstName: fNameCtrl.text,
                            lastName: lNameCtrl.text,
                            fatherName: fatherCtrl.text,
                            nationalCode: ncCtrl.text,
                            studentCode: codeCtrl.text,
                          );
                        }

                        if (selectedClassroomId != null &&
                            selectedClassroomId !=
                                existing?.currentClassroomId) {
                          await _studentService.enrollStudent(
                            studentId: saved.id,
                            classroomId: selectedClassroomId!,
                          );
                        }

                        if (ctx.mounted) Navigator.pop(ctx);
                        _refreshStudents();
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

  // -------------------- دیالوگ اتصال دستی ولی به دانش‌آموز --------------------
  Future<void> _showAssignParentDialog({StudentModel? student}) async {
    final ncCtrl = TextEditingController(text: student?.nationalCode ?? '');
    final phoneCtrl = TextEditingController();
    String selectedRelation = 'FATHER';
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
                    student != null
                        ? 'ثبت ولی برای «${student.displayName}»'
                        : 'ثبت و اتصال ولی به دانش‌آموز',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16.h),
                  if (student == null) ...[
                    CoreTextField(
                      controller: ncCtrl,
                      keyboardType: TextInputType.number,
                      hint: 'کد ملی دانش‌آموز',
                    ),
                    SizedBox(height: 12.h),
                  ],
                  CoreTextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    hint: 'شماره موبایل ولی (0912xxxxxxx)',
                  ),
                  SizedBox(height: 12.h),
                  DropdownWidget(
                    hintText: 'نسبت با دانش‌آموز',
                    enableSearch: false,
                    defaultTitle: 'پدر',
                    dataList: [
                      FilterModel(name: 'پدر', code: 1),
                      FilterModel(name: 'مادر', code: 2),
                      FilterModel(name: 'سرپرست', code: 3),
                    ],
                    onChanged: (item) {
                      setSheetState(() {
                        if (item?.code == 1) selectedRelation = 'FATHER';
                        if (item?.code == 2) selectedRelation = 'MOTHER';
                        if (item?.code == 3) selectedRelation = 'GUARDIAN';
                      });
                    },
                  ),
                  SizedBox(height: 20.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: 'ثبت و تأیید اتصال ولی',
                    onTap: () async {
                      if (phoneCtrl.text.trim().isEmpty) return;
                      setSheetState(() => saving = true);
                      try {
                        await _studentService.assignParentToStudent(
                          studentId: student?.id,
                          studentNationalCode: student == null
                              ? ncCtrl.text
                              : null,
                          phoneNumber: phoneCtrl.text,
                          relation: selectedRelation,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        _refreshParentLinks();
                        if (mounted) {
                          showCustomSnackBar(
                            context: context,
                            title: 'موفق',
                            content: 'شماره ولی با موفقیت متصل و تأیید شد.',
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

  // -------------------- دیالوگ تغییر شماره موبایل ولی --------------------
  Future<void> _showChangeParentPhoneDialog(ParentStudentLinkModel link) async {
    final phoneCtrl = TextEditingController(text: link.parentPhone);
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
                    'تغییر شماره موبایل ولی (${link.studentFullName})',
                    style: Theme.of(ctx).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 14.h),
                  CoreTextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    hint: 'شماره موبایل جدید (0912xxxxxxx)',
                  ),
                  SizedBox(height: 18.h),
                  CustomElevatedButton(
                    loading: saving,
                    text: 'ذخیره شماره جدید',
                    onTap: () async {
                      if (phoneCtrl.text.trim().isEmpty) return;
                      setSheetState(() => saving = true);
                      try {
                        await _studentService.changeParentPhone(
                          linkId: link.id,
                          phoneNumber: phoneCtrl.text,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        _refreshParentLinks();
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

  // -------------------- عملیات انتخاب و آپلود فایل اکسل --------------------
  Future<({Uint8List bytes, String name})?> _pickExcelFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xlsm'],
    );
    if (result.isEmpty) return null;
    final picked = result.first;
    final bytes = await picked.readAsBytes();

    return (bytes: bytes, name: picked.name);
  }

  Future<void> _handleStep1AnalyzeExcel() async {
    final file = await _pickExcelFile();
    if (file == null) return;

    setState(() {
      _importBusy = true;
      _previewResult = null;
      _commitResult = null;
      _rowOverrides.clear();
    });

    try {
      final analyzed = await _studentService.analyzeExcel(
        fileBytes: file.bytes,
        fileName: file.name,
      );
      if (!mounted) return;
      setState(() {
        _analyzeResult = analyzed;
        _headerRow = analyzed.guessedHeaderRow;
        _mapping = Map<String, dynamic>.from(analyzed.suggestedMapping);
        _targetClassroomId =
            analyzed.suggestedClassroomId ??
            (_classrooms.isNotEmpty ? _classrooms.first.id : null);
        _importBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _importBusy = false);
      showCustomSnackBar(
        context: context,
        title: 'خطا در تحلیل اکسل',
        content: getAppErrorMessage(e),
        status: ToastificationType.error,
      );
    }
  }

  Future<void> _handleStep2PreviewExcel() async {
    if (_analyzeResult == null || _targetClassroomId == null) {
      showCustomSnackBar(
        context: context,
        title: 'انتخاب کلاس',
        content: 'لطفاً کلاس مقصد را مشخص کنید.',
        status: ToastificationType.warning,
      );
      return;
    }

    setState(() => _importBusy = true);
    try {
      final preview = await _studentService.previewExcel(
        importLogId: _analyzeResult!.importLogId,
        classroomId: _targetClassroomId!,
        mapping: _mapping,
        sheetName: _analyzeResult!.selectedSheet,
        headerRow: _headerRow,
        rowOverrides: _rowOverrides,
      );
      if (!mounted) return;
      setState(() {
        _previewResult = preview;
        _importBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _importBusy = false);
      showCustomSnackBar(
        context: context,
        title: 'خطا در پیش‌نمایش',
        content: getAppErrorMessage(e),
        status: ToastificationType.error,
      );
    }
  }

  Future<void> _handleStep3CommitExcel() async {
    if (_analyzeResult == null || _targetClassroomId == null) return;
    setState(() => _importBusy = true);
    try {
      final committed = await _studentService.commitExcel(
        importLogId: _analyzeResult!.importLogId,
        classroomId: _targetClassroomId!,
        mapping: _mapping,
        allowClassroomTransfer: _allowClassroomTransfer,
        saveMapping: _saveMapping,
        sheetName: _analyzeResult!.selectedSheet,
        headerRow: _headerRow,
        rowOverrides: _rowOverrides,
      );
      if (!mounted) return;
      setState(() {
        _commitResult = committed;
        _analyzeResult = null;
        _previewResult = null;
        _importBusy = false;
      });
      _loadInitialData();
      showCustomSnackBar(
        context: context,
        title: 'ثبت نهایی انجام شد',
        content:
            '${committed.createdCount} دانش‌آموز جدید و ${committed.updatedCount} بروزرسانی ثبت شد.',
        status: ToastificationType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _importBusy = false);
      showCustomSnackBar(
        context: context,
        title: 'خطا در ثبت نهایی',
        content: getAppErrorMessage(e),
        status: ToastificationType.error,
      );
    }
  }

  Future<void> _handleParentExcelImport() async {
    final file = await _pickExcelFile();
    if (file == null) return;

    setState(() => _importBusy = true);
    try {
      final res = await _studentService.importParentsExcel(
        fileBytes: file.bytes,
        fileName: file.name,
      );
      if (!mounted) return;
      setState(() => _importBusy = false);
      _refreshParentLinks();
      showCustomSnackBar(
        context: context,
        title: 'ایمپورت اولیا انجام شد',
        content:
            'تعداد اتصال موفق: ${res['linked_count']} | خطا: ${res['error_count']}',
        status: ToastificationType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _importBusy = false);
      showCustomSnackBar(
        context: context,
        title: 'خطا در ایمپورت اولیا',
        content: getAppErrorMessage(e),
        status: ToastificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = _isAdmin ? 3 : 1;

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
                    Text(
                      _isAdmin
                          ? 'دانش‌آموزان، اولیا و اکسل'
                          : 'جستجو و لیست دانش‌آموزان کلاس من',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    IconButton(
                      onPressed: _loadInitialData,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              if (_isAdmin)
                TabBar(
                  labelColor: AppColors.primary500,
                  unselectedLabelColor: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                  indicatorColor: AppColors.primary500,
                  tabs: const [
                    Tab(text: 'دانش‌آموزان'),
                    Tab(text: 'اتصال اولیا'),
                    Tab(text: 'ایمپورت اکسل'),
                  ],
                ),
              Expanded(
                child: _isLoading
                    ? GlobalLoadingSection()
                    : _error != null
                    ? GlobalErrorSection(
                        message: _error!,
                        onRetry: _loadInitialData,
                      )
                    : TabBarView(
                        children: [
                          _buildStudentsTab(),
                          if (_isAdmin) _buildParentLinksTab(),
                          if (_isAdmin) _buildExcelImportTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== تب ۱: دانش‌آموزان و جستجوی فازی ====================
  Widget _buildStudentsTab() {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              onPressed: () => _showStudentFormDialog(),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('دانش‌آموز جدید'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
            child: SearchBoxWidget(
              controller: _searchController,
              backColor: theme.colorScheme.surfaceBright,
              haveFilter: false,
              onChanged: (val) {
                _searchQuery = val;
                _refreshStudents();
              },
              onCloseTap: () {
                _searchController.clear();
                _searchQuery = '';
                _refreshStudents();
              },
            ),
          ),
          if (_classrooms.isNotEmpty)
            CategoriesListFilter(
              categories: ['همه کلاس‌ها', ..._classrooms.map((c) => c.name)],
              onCategorySelected: (selectedName) {
                if (selectedName == 'همه کلاس‌ها') {
                  _selectedClassroomFilter = null;
                } else {
                  _selectedClassroomFilter = _classrooms
                      .firstWhere((c) => c.name == selectedName)
                      .id;
                }
                _refreshStudents();
              },
            ),
          SizedBox(height: 8.h),
          Expanded(
            child: _students.isEmpty
                ? const Center(child: Text('دانش‌آموزی یافت نشد.'))
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 88.h),
                    itemCount: _students.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final st = _students[index];
                      return Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: theme.colorScheme.surfaceDim,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary500.withValues(
                                alpha: 0.12,
                              ),
                              child: Text(
                                st.firstName.isNotEmpty
                                    ? st.firstName.characters.first
                                    : 'د',
                                style: const TextStyle(
                                  color: AppColors.primary500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${st.displayName} (فرزند ${st.fatherName.isNotEmpty ? st.fatherName : "—"})',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'کد ملی: ${st.nationalCode} • کلاس: ${st.currentClassroomName ?? "ثبت‌نام نشده"}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (_isAdmin) ...[
                              IconButton(
                                tooltip: 'افزودن ولی',
                                onPressed: () =>
                                    _showAssignParentDialog(student: st),
                                icon: const Icon(
                                  Icons.family_restroom_rounded,
                                  color: AppColors.primary500,
                                ),
                              ),
                              IconButton(
                                tooltip: 'ویرایش دانش‌آموز',
                                onPressed: () =>
                                    _showStudentFormDialog(existing: st),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==================== تب ۲: مدیریت اتصال اولیا ====================
  Widget _buildParentLinksTab() {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        onPressed: () => _showAssignParentDialog(),
        icon: const Icon(Icons.add_link_rounded),
        label: const Text('اتصال دستی ولی'),
      ),
      body: Column(
        children: [
          SizedBox(height: 12.h),
          CategoriesListFilter(
            categories: const ['همه اولیا', 'در انتظار تأیید', 'تأییدشده'],
            onCategorySelected: (val) {
              if (val == 'همه اولیا') _parentVerifiedFilter = null;
              if (val == 'در انتظار تأیید') _parentVerifiedFilter = false;
              if (val == 'تأییدشده') _parentVerifiedFilter = true;
              _refreshParentLinks();
            },
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: _parentLinks.isEmpty
                ? const Center(child: Text('هیچ رکورد اتصال ولی یافت نشد.'))
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 88.h),
                    itemCount: _parentLinks.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final link = _parentLinks[index];
                      return Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: link.isVerified
                                ? theme.colorScheme.surfaceDim
                                : AppColors.yellow,
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
                                    'دانش‌آموز: ${link.studentFullName} (کد ملی: ${link.studentNationalCode})',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: link.isVerified
                                        ? AppColors.statusConfirmedBg
                                        : AppColors.statusPendingPaymentBg,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    link.isVerified
                                        ? 'تأییدشده'
                                        : 'در انتظار تأیید مدرسه',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: link.isVerified
                                          ? AppColors.statusConfirmedFg
                                          : AppColors.statusPendingPaymentFg,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'موبایل ولی (${link.relationDisplayFa}): ${link.parentPhone}',
                              style: theme.textTheme.bodySmall,
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _showChangeParentPhoneDialog(link),
                                  icon: const Icon(
                                    Icons.phone_callback_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('تغییر شماره'),
                                ),
                                SizedBox(width: 8.w),
                                if (!link.isVerified)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.green,
                                      fixedSize: const Size(125, 36),
                                    ),
                                    onPressed: () async {
                                      await _studentService.verifyParentLink(
                                        link.id,
                                      );
                                      _refreshParentLinks();
                                    },
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('تأیید اتصال'),
                                  )
                                else
                                  TextButton(
                                    onPressed: () async {
                                      await _studentService.unverifyParentLink(
                                        link.id,
                                      );
                                      _refreshParentLinks();
                                    },
                                    child: const Text(
                                      'لغو تأیید',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==================== تب ۳: ویزارد ۳ مرحله‌ای ایمپورت اکسل ====================
  Widget _buildExcelImportTab() {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        // کارت آپلود فایل اکسل دانش‌آموزان (مرحله ۱)
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: theme.colorScheme.surfaceDim),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ایمپورت ۳ مرحله‌ای اکسل دانش‌آموزان کلاس',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: 6.h),
              Text(
                'فایل اکسل (.xlsx) کلاس را انتخاب کنید؛ سیستم سرستون‌ها و نام‌های ترکیبی را هوشمند تشخیص می‌دهد.',
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      loading: _importBusy,
                      text: '۱. انتخاب و تحلیل اکسل کلاس',
                      onTap: _handleStep1AnalyzeExcel,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              OutlinedButton.icon(
                onPressed: _importBusy ? null : _handleParentExcelImport,
                icon: const Icon(Icons.contact_phone_outlined),
                label: const Text(
                  'ایمپورت اکسل دوم (کد ملی دانش‌آموز + موبایل ولی)',
                ),
              ),
            ],
          ),
        ),

        // نمایش مرحله ۲: تنظیم کلاس مقصد و نگاشت ستون‌ها پس از Analyze
        if (_analyzeResult != null) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary500),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '۲. تنظیم کلاس مقصد و نگاشت ستون‌ها',
                  style: theme.textTheme.headlineMedium,
                ),
                SizedBox(height: 6.h),
                Text(
                  'شیت: ${_analyzeResult!.selectedSheet} • ردیف سرستون تشخیص‌داده‌شده: $_headerRow',
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: 12.h),
                DropdownWidget(
                  hintText: 'انتخاب کلاس مقصد',
                  defaultTitle: _classrooms
                      .where((c) => c.id == _targetClassroomId)
                      .map((c) => c.name)
                      .firstOrNull,
                  dataList: _classrooms
                      .map((c) => FilterModel(name: c.name, code: c.id))
                      .toList(),
                  onChanged: (item) =>
                      setState(() => _targetClassroomId = item?.code),
                ),
                SizedBox(height: 12.h),
                _buildColumnMappingDropdown(
                  label: 'ستون کد ملی (الزامی)',
                  fieldKey: 'national_code',
                ),
                _buildColumnMappingDropdown(
                  label: 'ستون ترکیبی اسم و فامیل',
                  fieldKey: 'full_name',
                ),
                _buildColumnMappingDropdown(
                  label: 'ستون نام (در صورت جدا بودن)',
                  fieldKey: 'first_name',
                ),
                _buildColumnMappingDropdown(
                  label: 'ستون نام خانوادگی (در صورت جدا بودن)',
                  fieldKey: 'last_name',
                ),
                _buildColumnMappingDropdown(
                  label: 'ستون نام پدر',
                  fieldKey: 'father_name',
                ),
                _buildColumnMappingDropdown(
                  label: 'ستون موبایل ولی (اختیاری)',
                  fieldKey: 'parent_phone',
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'تفکیک خودکار ستون اسم به نام و نام خانوادگی',
                  ),
                  value: _mapping['split_full_name'] == true,
                  activeColor: AppColors.primary500,
                  onChanged: (v) =>
                      setState(() => _mapping['split_full_name'] = v),
                ),
                SizedBox(height: 10.h),
                CustomElevatedButton(
                  loading: _importBusy,
                  text: '۲. مشاهده پیش‌نمایش و بررسی خطاها',
                  onTap: _handleStep2PreviewExcel,
                ),
              ],
            ),
          ),
        ],

        // نمایش مرحله ۳: نتیجه پیش‌نمایش، اصلاح نام‌های چندکلمه‌ای و دکمه ثبت نهایی (Commit)
        if (_previewResult != null) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.green, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '۳. پیش‌نمایش پیش از ثبت در کلاس «${_previewResult!.classroomName}»',
                  style: theme.textTheme.headlineMedium,
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    Chip(
                      label: Text('کل ردیف‌ها: ${_previewResult!.totalRows}'),
                    ),
                    Chip(
                      label: Text('سالم: ${_previewResult!.validCount}'),
                      backgroundColor: AppColors.statusConfirmedBg,
                    ),
                    Chip(
                      label: Text(
                        'جدید: ${_previewResult!.newStudents.length}',
                      ),
                    ),
                    Chip(
                      label: Text(
                        'موجود: ${_previewResult!.existingStudents.length}',
                      ),
                    ),
                    if (_previewResult!.errorCount > 0)
                      Chip(
                        label: Text('خطا: ${_previewResult!.errorCount}'),
                        backgroundColor: AppColors.statusCancelledBg,
                      ),
                  ],
                ),

                // هشدارهای نام‌های بیش از دو کلمه با امکان ویرایش دستی (row_overrides)
                if (_previewResult!.warnings.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    'هشدار نام‌های چندکلمه‌ای (در صورت نیاز اصلاح کنید):',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.yellow,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  ..._previewResult!.warnings.map((w) {
                    final rowNum = w['row_number'].toString();
                    final fCtrl = TextEditingController(
                      text:
                          _rowOverrides[rowNum]?['first_name'] ??
                          w['first_name']?.toString() ??
                          '',
                    );
                    final lCtrl = TextEditingController(
                      text:
                          _rowOverrides[rowNum]?['last_name'] ??
                          w['last_name']?.toString() ??
                          '',
                    );
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.statusPendingPaymentBg,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ردیف $rowNum: ${w['student_name']}',
                            style: theme.textTheme.bodySmall,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: fCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'نام',
                                    isDense: true,
                                  ),
                                  onChanged: (v) {
                                    _rowOverrides.putIfAbsent(rowNum, () => {});
                                    _rowOverrides[rowNum]!['first_name'] = v;
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: lCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'نام خانوادگی',
                                    isDense: true,
                                  ),
                                  onChanged: (v) {
                                    _rowOverrides.putIfAbsent(rowNum, () => {});
                                    _rowOverrides[rowNum]!['last_name'] = v;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // نمایش خطاهای داخل فایل
                if (_previewResult!.errors.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    'ردیف‌های دارای خطا (ثبت نخواهند شد):',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ..._previewResult!.errors.map(
                    (err) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Text(
                        '• ردیف ${err['row_number']}: ${err['error_reason']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],

                if (_previewResult!.hasTransferCandidates)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'تأیید جابه‌جایی دانش‌آموزانی که قبلاً در کلاس دیگری بوده‌اند',
                    ),
                    value: _allowClassroomTransfer,
                    activeColor: AppColors.primary500,
                    onChanged: (v) =>
                        setState(() => _allowClassroomTransfer = v),
                  ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ذخیره الگوی نگاشت ستون‌ها برای دفعات بعد'),
                  value: _saveMapping,
                  activeColor: AppColors.primary500,
                  onChanged: (v) => setState(() => _saveMapping = v),
                ),

                SizedBox(height: 12.h),
                CustomElevatedButton(
                  loading: _importBusy,
                  text: '۳. تأیید و ثبت نهایی در دیتابیس',
                  onTap: _handleStep3CommitExcel,
                ),
              ],
            ),
          ),
        ],

        // تاریخچه لاگ‌های ایمپورت قبلی
        SizedBox(height: 24.h),
        Text('تاریخچه ایمپورت‌های اکسل', style: theme.textTheme.headlineMedium),
        SizedBox(height: 8.h),
        if (_importLogs.isEmpty)
          Text('هنوز فایلی ایمپورت نشده است.', style: theme.textTheme.bodySmall)
        else
          ..._importLogs.map(
            (log) => Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceBright,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: theme.colorScheme.surfaceDim),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${log.originalFilename} (${log.classroomName ?? "—"})',
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'کل: ${log.totalRows} | ایجاد: ${log.createdCount} | بروزرسانی: ${log.updatedCount} | خطا: ${log.errorCount}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(log.status, style: theme.textTheme.titleSmall),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColumnMappingDropdown({
    required String label,
    required String fieldKey,
  }) {
    final columns = _analyzeResult?.columns ?? [];
    final currentCol = _mapping[fieldKey]?.toString();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 4.h),
          DropdownWidget(
            height: 48,
            enableSearch: false,
            hintText: 'انتخاب ستون',
            defaultTitle: (currentCol != null && columns.contains(currentCol))
                ? currentCol
                : '— انتخاب نشده —',
            dataList: [
              FilterModel(name: '— انتخاب نشده —', code: -1),
              ...List.generate(
                columns.length,
                (i) => FilterModel(name: columns[i], code: i),
              ),
            ],
            onChanged: (item) {
              setState(() {
                if (item == null || item.code == -1) {
                  _mapping[fieldKey] = null;
                } else {
                  _mapping[fieldKey] = columns[item.code];
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
