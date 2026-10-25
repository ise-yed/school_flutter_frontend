import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/widgets.dart' as ui;

class SearchBoxWidget extends StatefulWidget {
  final TextEditingController controller;
  final EdgeInsetsGeometry? margin;
  final Color backColor;
  final bool haveFilter;
  Function? justTap;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;

  final VoidCallback? onCloseTap;

  SearchBoxWidget({
    super.key,
    required this.controller,
    required this.backColor,
    this.margin,
    this.justTap,
    this.haveFilter = true,
    this.onFilterTap,
    this.onCloseTap,
    this.onChanged,
  });

  @override
  State<SearchBoxWidget> createState() => _SearchBoxWidgetState();
}

class _SearchBoxWidgetState extends State<SearchBoxWidget> {
  bool _isOpen = false;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _isOpen = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  void _handleCloseTap() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isOpen = false;
    });
    widget.onCloseTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == ui.TextDirection.rtl;
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (widget.justTap != null) {
                  widget.justTap!();
                } else {
                  FocusScope.of(context).requestFocus(_focusNode);
                }
              },
              child: Container(
                height: 57.h,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  // vertical: 16.5.w,
                ),
                decoration: BoxDecoration(
                  color: widget.backColor,
                  borderRadius: BorderRadius.circular(17).r,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        "assets/icons/search 2.svg",
                        width: 24.w,
                        height: 24.h,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        enabled: widget.justTap != null ? false : true,
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 500),
                            () {
                              widget.onChanged?.call(value);
                            },
                          );
                        },
                        controller: widget.controller,
                        focusNode: _focusNode,
                        textAlignVertical: TextAlignVertical.center,
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          fillColor: widget.backColor,
                          hintText: "search2".tr(),
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    if (widget.haveFilter)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.onFilterTap,
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/icons/filter.svg",
                            width: 24.w,
                            height: 24.h,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_isOpen) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _handleCloseTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 57.h,
                width: 57.h,
                decoration: BoxDecoration(
                  color: widget.backColor,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/remove.svg",
                    width: 24.w,
                    height: 24.h,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
