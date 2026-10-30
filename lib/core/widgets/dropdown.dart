import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:flutter/widgets.dart' as ui;

class FilterModel {
  final String name;
  final bool disabled;
  final String? id;
  final int code;

  FilterModel({
    required this.name,
    required this.code,
    this.disabled = false,
    this.id,
  });

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(name: json['name'], id: json['id'], code: json['code']);
  }
}

class DropdownWidget extends StatefulWidget {
  DropdownWidget({
    super.key,
    required this.dataList,
    required this.onChanged,
    this.defaultTitle,
    this.hintText = 'انتخاب',
    this.validator,
    this.isEnabled = true,
    this.enableSearch = true,
    this.isLoading = false,
    this.loadingText = 'در حال بارگذاری...',
    this.errorText,
    this.onRetry,
    this.retryLabel = 'تلاش مجدد',
    this.borderRadius = 12.0,
    this.height = 58.0,
    this.selectedItemStyle,
    this.errorBorder,
    this.buttonStyleDataPadding,
    this.buttonStyleDataColor,
    this.hintTextstyle,
    this.invertIconOnOpen = false,
  });

  final List<FilterModel> dataList;
  final Function(FilterModel?) onChanged;
  final String? defaultTitle;
  final String hintText;
  final FormFieldValidator<int?>? validator;
  final bool isEnabled;
  final bool enableSearch;
  final bool isLoading;
  final String loadingText;
  final String? errorText;
  final VoidCallback? onRetry;
  final String retryLabel;
  double? borderRadius;
  double? height;
  TextStyle? selectedItemStyle;
  bool? errorBorder;
  EdgeInsetsGeometry? buttonStyleDataPadding;
  Color? buttonStyleDataColor;
  TextStyle? hintTextstyle;
  bool invertIconOnOpen;

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isMenuOpen = false;
  int? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = _deriveFromDefaultTitle(
      widget.defaultTitle,
      widget.dataList,
    );
  }

  @override
  void didUpdateWidget(covariant DropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final defaultChanged = oldWidget.defaultTitle != widget.defaultTitle;
    final currentStillExists =
        _selectedValue != null &&
        widget.dataList.any((d) => d.code == _selectedValue);

    if (defaultChanged) {
      final newCode = _deriveFromDefaultTitle(
        widget.defaultTitle,
        widget.dataList,
      );
      if (newCode != _selectedValue) {
        setState(() => _selectedValue = newCode);
      }
    } else if (!currentStillExists) {
      final fallbackCode = _deriveFromDefaultTitle(
        widget.defaultTitle,
        widget.dataList,
      );
      if (fallbackCode != _selectedValue) {
        setState(() => _selectedValue = fallbackCode);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int? _deriveFromDefaultTitle(String? title, List<FilterModel> list) {
    if (title == null || title.isEmpty) return null;
    try {
      return list.firstWhere((i) => i.name == title).code;
    } catch (_) {
      return null;
    }
  }

  FilterModel? _findByCode(int? code) {
    if (code == null) return null;
    try {
      return widget.dataList.firstWhere((d) => d.code == code);
    } catch (_) {
      return null;
    }
  }

  Widget _shell({
    required BuildContext context,
    required Widget child,
    bool hasFieldError = false,
    bool disabled = false,
    bool isErrorState = false,
  }) {
    final borderColor = (hasFieldError || isErrorState)
        ? Colors.red
        : Theme.of(context).colorScheme.surfaceDim;
    double height = widget.height!;

    return Container(
      height: height.h,
      width: double.infinity,
      padding: EdgeInsets.only(left: 16.w, right: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius!),
        border: Border.all(width: 1.w, color: borderColor),
        color: Theme.of(context).colorScheme.surfaceBright,
      ),
      alignment: Alignment.centerRight,
      child: child,
    );
  }

  Widget _loadingBox(BuildContext context, FormFieldState<int?> field) {
    return _shell(
      context: context,
      hasFieldError: field.hasError,
      disabled: true,
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.h,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              widget.loadingText,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(BuildContext context, FormFieldState<int?> field) {
    return _shell(
      context: context,
      hasFieldError: field.hasError,
      disabled: true,
      isErrorState: true,
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 20,
            color: Colors.red,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              widget.errorText ?? 'خطا در بارگذاری',
              style: Theme.of(context).textTheme.bodySmall!
                  .copyWith(color: Colors.red),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.onRetry != null) ...[
            SizedBox(width: 8.w),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: widget.onRetry,
              child: Text(
                widget.retryLabel,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == ui.TextDirection.rtl;

    widget.selectedItemStyle =
        widget.selectedItemStyle ??
        Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        );

    if (_selectedValue != null &&
        widget.dataList.indexWhere((d) => d.code == _selectedValue) == -1) {
      _selectedValue = null;
    }

    return FormField<int?>(
      initialValue: _selectedValue,
      autovalidateMode: AutovalidateMode.disabled,
      validator: widget.validator,
      builder: (field) {
        if (widget.isLoading) {
          return _loadingBox(context, field);
        }
        if (widget.errorText != null) {
          return _errorBox(context, field);
        }

        final dropdown = DropdownButtonHideUnderline(
          child: DropdownButton2<int>(
            isExpanded: true,
            alignment: Alignment.center,
            hint: Align(
              alignment: ui.Directionality.of(context) == ui.TextDirection.rtl
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                widget.hintText,
                style:
                    widget.hintTextstyle ??
                    Theme.of(context).textTheme.bodyMedium,
                textAlign: ui.Directionality.of(context) == ui.TextDirection.rtl
                    ? TextAlign.right
                    : TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            items: widget.dataList.map((item) {
              return DropdownMenuItem<int>(
                value: item.code,
                enabled: !item.disabled,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.h),
                  width: double.infinity,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: _selectedValue == item.code
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dialogTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      if (_selectedValue == item.code)
                        Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.surface,
                              size: 18,
                            ),
                            SizedBox(width: 6.w),
                          ],
                        ),
                      Expanded(
                        child: Text(
                          item.name,
                          textAlign:
                              ui.Directionality.of(context) ==
                                  ui.TextDirection.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: (_selectedValue == item.code)
                                ? Theme.of(context).colorScheme.surface
                                : (item.disabled
                                      ? Theme.of(context).disabledColor
                                      : Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            selectedItemBuilder: (context) {
              return widget.dataList.map((item) {
                return Container(
                  alignment:
                      ui.Directionality.of(context) == ui.TextDirection.rtl
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Text(
                    item.name,
                    style: widget.selectedItemStyle!,
                    textAlign:
                        ui.Directionality.of(context) == ui.TextDirection.rtl
                        ? TextAlign.right
                        : TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
            value: widget.dataList.any((d) => d.code == _selectedValue)
                ? _selectedValue
                : null,
            onChanged: widget.isEnabled
                ? (value) {
                    setState(() {
                      _selectedValue = value;
                      final selected = _findByCode(value);
                      field.didChange(value);
                      widget.onChanged(selected);
                    });
                  }
                : null,
            onMenuStateChange: (isOpen) {
              setState(() {
                _isMenuOpen = isOpen;
                if (!isOpen) _searchController.clear();
              });
            },
            buttonStyleData: ButtonStyleData(
              height: widget.height!.h,
              width: double.infinity,
              padding:
                  widget.buttonStyleDataPadding ??
                  EdgeInsets.only(left: 16.w, right: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius!.r),
                border: widget.invertIconOnOpen
                    ? null
                    : Border.all(
                        width: 1,
                        color: !widget.isEnabled
                            ? Colors.grey.shade800
                            : (field.hasError ||
                                  (widget.errorBorder != false &&
                                      widget.errorBorder != null))
                            ? Colors.red
                            : Theme.of(context).colorScheme.surfaceDim,
                      ),
                color:
                    widget.buttonStyleDataColor ??
                    Theme.of(context).colorScheme.surfaceBright,
              ),
              elevation: 0,
            ),
            iconStyleData: IconStyleData(
              icon: AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState:
                    (widget.invertIconOnOpen ? !_isMenuOpen : _isMenuOpen)
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: widget.invertIconOnOpen
                    ? RotatedBox(
                        quarterTurns: isRTL ? 0 : 2,
                        child: SvgPicture.asset(
                          "assets/icons/direction-left 2.svg",
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : const Icon(Icons.keyboard_arrow_up_rounded, size: 22),
                secondChild: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                ),
              ),
              iconSize: 22,
              iconEnabledColor: Theme.of(context).colorScheme.onSecondary,
              iconDisabledColor: Theme.of(context).colorScheme.onSecondary,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // color: Theme.of(context).colorScheme.surface,
                color: isThemeLight.value
                    ? AppColors.bg1Light
                    : AppColors.bg1Dark,
              ),
              offset: const Offset(0, 6),
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStatePropertyAll(
                  // Theme.of(context).colorScheme.primary,
                  AppColors.text500Light,
                ),
                thickness: const WidgetStatePropertyAll(6),
                radius: const Radius.circular(40),
                thumbVisibility: const WidgetStatePropertyAll(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: 14),
            ),
            dropdownSearchData: widget.enableSearch
                ? DropdownSearchData(
                    searchController: _searchController,
                    searchInnerWidgetHeight: 52,
                    searchInnerWidget: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: TextFormField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          hintText: 'search'.tr(),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      final original = widget.dataList.firstWhere(
                        (d) => d.code == item.value,
                        orElse: () => FilterModel(name: '', code: -999),
                      );
                      return original.name.toLowerCase().contains(
                        searchValue.toLowerCase(),
                      );
                    },
                  )
                : null,
          ),
        );

        final errorText = (field.hasError && (field.errorText ?? '').isNotEmpty)
            ? Padding(
                padding: EdgeInsets.only(top: 4.h, right: 12.w, left: 12.w),
                child: Text(
                  field.errorText!,
                  style:
                      Theme.of(context).inputDecorationTheme.errorStyle ??
                      Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.red),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [dropdown, errorText],
        );
      },
    );
  }
}
