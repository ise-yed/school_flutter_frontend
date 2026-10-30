import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/app_error.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';
import 'package:school_flutter_frontend/core/widgets/global_error_section.dart';
import 'package:school_flutter_frontend/core/widgets/global_loading_section.dart';
import 'package:school_flutter_frontend/features/profile/screens/notification_screen.dart';
import 'package:school_flutter_frontend/core/widgets/notification_bell_button.dart';

import '../../students/models/student_models.dart';
import '../../students/service/student_service.dart';
import '../models/operations_models.dart';
import '../service/operations_service.dart';

class ParentDashboardScreen extends StatefulWidget {
  final int initialSection; // 0 = خلاصه، 1 = حضور و غیاب، 2 = پرونده انضباطی

  const ParentDashboardScreen({super.key, this.initialSection = 0});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final StudentService _studentService = StudentService();
  final OperationsService _opsService = OperationsService();

  bool _isLoading = true;
  String? _error;

  List<StudentModel> _children = [];
  int? _selectedChildId;
  List<AttendanceRecordModel> _attendances = [];
  List<DisciplinaryRecordModel> _disciplines = [];

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData({int? childId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final childrenRes = await _studentService.getStudents();
      final children = childrenRes.results;
      final activeChildId =
          childId ??
          _selectedChildId ??
          (children.isNotEmpty ? children.first.id : null);

      final attRes = await _opsService.getAttendanceRecords(
        studentId: activeChildId,
      );
      final discRes = await _opsService.getDisciplinaryRecords(
        studentId: activeChildId,
      );

      if (!mounted) return;
      setState(() {
        _children = children;
        _selectedChildId = activeChildId;
        _attendances = attRes.results;
        _disciplines = discRes.results;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? GlobalLoadingSection()
            : _error != null
            ? GlobalErrorSection(
                message: _error!,
                onRetry: () => _loadParentData(),
              )
            : RefreshIndicator(
                onRefresh: () => _loadParentData(childId: _selectedChildId),
                child: ListView(
                  padding: EdgeInsets.all(20.r),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'پنل اولیا • ${currentUserModel.displayName}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'مشاهده وضعیت تحصیلی، حضور و غیاب و انضباط فرزند',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            goScreen(
                              context: context,
                              screen: const NotificationBellButton(),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // انتخاب فرزند (در صورتی که ولی بیش از یک فرزند در مدرسه داشته باشد)
                    if (_children.isNotEmpty)
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _children.map((child) {
                          final selected = child.id == _selectedChildId;
                          return ChoiceChip(
                            label: Text(
                              '${child.displayName} (${child.currentClassroomName ?? "بدون کلاس"})',
                            ),
                            selected: selected,
                            selectedColor: AppColors.primary500,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) =>
                                _loadParentData(childId: child.id),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 16.h),

                    if (widget.initialSection == 0) _buildOverviewSection(),
                    if (widget.initialSection == 0 ||
                        widget.initialSection == 1) ...[
                      SizedBox(height: 16.h),
                      Text(
                        'سوابق حضور و غیاب فرزند',
                        style: theme.textTheme.headlineMedium,
                      ),
                      SizedBox(height: 8.h),
                      _buildAttendanceList(),
                    ],
                    if (widget.initialSection == 0 ||
                        widget.initialSection == 2) ...[
                      SizedBox(height: 20.h),
                      Text(
                        'پرونده انضباطی و تشویقی فرزند',
                        style: theme.textTheme.headlineMedium,
                      ),
                      SizedBox(height: 8.h),
                      _buildDisciplineList(),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    final presentCount = _attendances
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final lateCount = _attendances
        .where((a) => a.status == AttendanceStatus.late)
        .length;
    final absentCount = _attendances
        .where(
          (a) =>
              a.status == AttendanceStatus.unexcusedAbsence ||
              a.status == AttendanceStatus.excusedAbsence,
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'حاضر',
            count: presentCount,
            color: AppColors.green,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildStatCard(
            label: 'تأخیر',
            count: lateCount,
            color: AppColors.yellow,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildStatCard(
            label: 'غیبت',
            count: absentCount,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(color: color),
          ),
          SizedBox(height: 4.h),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    final theme = Theme.of(context);
    if (_attendances.isEmpty) {
      return Text(
        'هنوز سابقه حضور و غیابی ثبت نشده است.',
        style: theme.textTheme.bodySmall,
      );
    }

    return Column(
      children: _attendances
          .map(
            (rec) => Container(
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
                          'تاریخ ${rec.date} (${rec.sessionLabelFa})',
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'کلاس ${rec.classroomName}${rec.note.isNotEmpty ? " • ${rec.note}" : ""}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: rec.status == AttendanceStatus.present
                          ? AppColors.statusConfirmedBg
                          : AppColors.statusCancelledBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      AttendanceStatus.labelFa(rec.status),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: rec.status == AttendanceStatus.present
                            ? AppColors.statusConfirmedFg
                            : AppColors.statusCancelledFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDisciplineList() {
    final theme = Theme.of(context);
    if (_disciplines.isEmpty) {
      return Text(
        'هیچ مورد انضباطی یا تشویقی ثبت نشده است.',
        style: theme.textTheme.bodySmall,
      );
    }

    return Column(
      children: _disciplines
          .map(
            (d) => Container(
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
                      Text(
                        d.categoryDisplay,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(d.date, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(d.description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
