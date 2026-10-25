import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:school_flutter_frontend/core/widgets/format_reminder_date.dart';
import 'package:school_flutter_frontend/core/widgets/global_error_section.dart';
import 'package:school_flutter_frontend/core/widgets/global_loading_section.dart';
import 'package:school_flutter_frontend/core/widgets/pagination_error.dart';
import 'package:school_flutter_frontend/core/widgets/pagination_indicator.dart';
import 'package:school_flutter_frontend/core/widgets/reminders_appbar_widget.dart';
import 'package:school_flutter_frontend/features/profile/bloc/profile_bloc.dart';
import 'package:school_flutter_frontend/features/profile/model/notification_model.dart';
import 'package:school_flutter_frontend/features/profile/widgets/notification/notification_item_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final PagingController<int, NotificationDoc> _pagingController =
      PagingController(firstPageKey: 1);

  final int listLimit = 20;

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<ProfileBloc>(context);

    _pagingController.addPageRequestListener((pageKey) {
      bloc.add(NotificationDataEvent(page: pageKey, limit: listLimit));
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _onNotificationTap(NotificationDoc item) {
    if (!item.isRead) {
      // Mark as read in backend
      context.read<ProfileBloc>().add(MarkNotificationAsReadEvent(id: item.id));

      // Optimistically update locally
      final currentList = _pagingController.itemList;
      if (currentList != null) {
        final index = currentList.indexWhere((e) => e.id == item.id);
        if (index != -1) {
          final updated = item.copyWith(isRead: true, readAt: DateTime.now());
          currentList[index] = updated;
          setState(() {});
        }
      }
    }

    _showNotificationDetailsModal(context, item);
  }

  void _showNotificationDetailsModal(
    BuildContext context,
    NotificationDoc item,
  ) {
    final dateInfo = formatReminderDateTime(item.createdAt.toIso8601String());
    final dateStr = dateInfo['date'] ?? '';
    final timeStr = dateInfo['time'] ?? '';
    final formattedTime = timeStr.isNotEmpty
        ? '$dateStr  •  $timeStr'
        : dateStr;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        item.isRead ? 'read'.tr() : 'unread'.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formattedTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.5.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SelectableText(
                    item.message.isNotEmpty ? item.message : item.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.5.sp,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    child: Text('close'.tr()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _markAllAsRead() {
    final bloc = context.read<ProfileBloc>();
    bloc.add(MarkAllNotificationsAsReadEvent());

    // Optimistically mark all currently loaded items as read
    final currentList = _pagingController.itemList;
    if (currentList != null && currentList.isNotEmpty) {
      final updatedList = currentList
          .map((e) => e.copyWith(isRead: true))
          .toList();
      _pagingController.itemList = updatedList;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == ui.TextDirection.rtl;
    final bloc = BlocProvider.of<ProfileBloc>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            RemindersAppbarWidget(
              title: "notifications".tr(),
              leadingIcon: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
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
              trailingIcon: InkWell(
                borderRadius: BorderRadius.circular(50.r),
                onTap: _markAllAsRead,
                child: Tooltip(
                  message: "mark_all_read".tr(),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.1),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/seen.svg",
                      width: 20.r,
                      height: 20.r,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            BlocConsumer<ProfileBloc, ProfileState>(
              buildWhen: (previous, current) =>
                  current is NotificationDataLoadingState ||
                  current is NotificationDataSuccessState ||
                  current is NotificationDataFailedState,
              listener: (context, state) {
                if (state is NotificationDataSuccessState) {
                  final dataModel = state.notificationModel;
                  if (dataModel == null) return;

                  final newItems = dataModel.results;
                  final nextPageKey = dataModel.nextPage;

                  if (dataModel.page == 1) {
                    _pagingController.value = PagingState(
                      nextPageKey: nextPageKey,
                      error: null,
                      itemList: [],
                    );
                  }

                  if (nextPageKey == null) {
                    _pagingController.appendLastPage(newItems);
                  } else {
                    _pagingController.appendPage(newItems, nextPageKey);
                  }
                } else if (state is NotificationDataFailedState) {
                  _pagingController.error = state.message;
                } else if (state is MarkNotificationAsReadSuccessState) {
                  final currentList = _pagingController.itemList;
                  if (currentList != null) {
                    final index = currentList.indexWhere(
                      (e) => e.id == state.notification.id,
                    );
                    if (index != -1) {
                      currentList[index] = state.notification;
                      setState(() {});
                    }
                  }
                } else if (state is MarkAllNotificationsAsReadSuccessState) {
                  final currentList = _pagingController.itemList;
                  if (currentList != null) {
                    _pagingController.itemList = currentList
                        .map((e) => e.copyWith(isRead: true))
                        .toList();
                    setState(() {});
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("all_read_success".tr()),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is NotificationDataLoadingState &&
                    (_pagingController.itemList == null ||
                        _pagingController.itemList!.isEmpty)) {
                  return Expanded(child: GlobalLoadingSection());
                } else if (state is NotificationDataFailedState &&
                    (_pagingController.itemList == null ||
                        _pagingController.itemList!.isEmpty)) {
                  return Expanded(
                    child: GlobalErrorSection(
                      message: state.message,
                      onRetry: () {
                        _pagingController.refresh();
                      },
                    ),
                  );
                } else {
                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _pagingController.refresh();
                      },
                      child: PagedListView<int, NotificationDoc>(
                        pagingController: _pagingController,
                        padding: EdgeInsets.only(top: 8.h, bottom: 80.h),
                        builderDelegate:
                            PagedChildBuilderDelegate<NotificationDoc>(
                              itemBuilder: (context, item, index) =>
                                  NotificationsItemWidget(
                                    isActive: true,
                                    notificationdata: item,
                                    onTap: () => _onNotificationTap(item),
                                  ),
                              firstPageProgressIndicatorBuilder: (_) =>
                                  GlobalLoadingSection(),
                              firstPageErrorIndicatorBuilder: (context) =>
                                  GlobalErrorSection(
                                    message: _pagingController.error
                                        .toString()
                                        .replaceFirst('Exception: ', ''),
                                    onRetry: _pagingController
                                        .retryLastFailedRequest,
                                  ),
                              noItemsFoundIndicatorBuilder: (context) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32.w,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 80.r,
                                          height: 80.r,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              "assets/icons/notification.svg",
                                              width: 36.r,
                                              height: 36.r,
                                              colorFilter: ColorFilter.mode(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withValues(alpha: 0.5),
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 18.h),
                                        Text(
                                          "notif_empty".tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              newPageProgressIndicatorBuilder: (_) =>
                                  GlobalPaginationLoadingSection(),
                              newPageErrorIndicatorBuilder: (context) =>
                                  GlobalPaginationErrorSection(
                                    message: _pagingController.error
                                        .toString()
                                        .replaceFirst('Exception: ', ''),
                                    onRetry: () {
                                      final failedPageKey =
                                          _pagingController.nextPageKey ?? 1;
                                      bloc.add(
                                        NotificationDataEvent(
                                          page: failedPageKey,
                                          limit: listLimit,
                                        ),
                                      );
                                    },
                                  ),
                            ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
