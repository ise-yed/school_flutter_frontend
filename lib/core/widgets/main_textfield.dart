import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoreTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  double? textFieldHeight;
  int? maxLines;
  Color? focusBorderColor;
  final ValueChanged<String>? onChanged;
  double? textFieldborderRadius;
  final String? errorText;

  CoreTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.textFieldborderRadius = 12,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.inputFormatters,
    this.textFieldHeight = 58,
    this.maxLines = 1,
    this.focusBorderColor,
    this.errorText,
  });

  @override
  State<CoreTextField> createState() => _CoreTextFieldState();
}

class _CoreTextFieldState extends State<CoreTextField> {
  bool _obscure = false;
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.disabled,
      initialValue: _effectiveController.text,
      builder: (state) {
        void _listener() => state.didChange(_effectiveController.text);
        _effectiveController.removeListener(_listener);
        _effectiveController.addListener(_listener);

        final theme = Theme.of(context);
        final errorStyleFromTheme =
            theme.inputDecorationTheme.errorStyle ??
            theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error);

        final displayError = state.errorText ?? widget.errorText;
        final hasDisplayError = displayError != null && displayError.isNotEmpty;

        final field = SizedBox(
          height: hasDisplayError
              ? (widget.textFieldHeight ?? 58).h + 20
              : (widget.textFieldHeight ?? 58).h,
          child: TextField(
            onChanged: widget.onChanged,
            controller: _effectiveController,
            obscureText: _obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
            style: TextStyle(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: widget.prefix != null
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 17.h,
                      ),
                      child: widget.prefix,
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 20.h,
              ),
              labelText: widget.label,
              hintText: widget.hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              errorText: hasDisplayError ? '' : null,
              errorStyle: const TextStyle(height: 0, fontSize: 0),

              suffixIcon: widget.suffix != null
                  ? GestureDetector(
                      onTap: widget.obscure
                          ? () => setState(() => _obscure = !_obscure)
                          : null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 17.h,
                        ),
                        child: widget.suffix,
                      ),
                    )
                  : null,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.textFieldborderRadius!.r,
                ),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceDim,
                ),
              ),
              focusedBorder: (widget.focusBorderColor != null)
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        widget.textFieldborderRadius!.r,
                      ),
                      borderSide: BorderSide(color: widget.focusBorderColor!),
                    )
                  : null,
              fillColor: Theme.of(context).colorScheme.surfaceBright,
              filled: true,
            ),
          ),
        );

        final errorText = hasDisplayError
            ? Padding(
                padding: EdgeInsets.only(right: 4.w, left: 4.w, top: 4.h),
                child: Text(
                  displayError,
                  style: errorStyleFromTheme,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [field, errorText],
        );
      },
    );
  }
}

class CoreTextFieldNormal extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  double? textFieldHeight;
  int? maxLines;
  Color? focusBorderColor;
  final ValueChanged<String>? onChanged;
  double? textFieldborderRadius;

  CoreTextFieldNormal({
    super.key,
    this.controller,
    this.onChanged,
    this.textFieldborderRadius = 12,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.inputFormatters,
    this.textFieldHeight = 58,
    this.maxLines = 1,
    this.focusBorderColor,
  });

  @override
  State<CoreTextFieldNormal> createState() => _CoreTextFieldNormalState();
}

class _CoreTextFieldNormalState extends State<CoreTextFieldNormal> {
  bool _obscure = false;
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: (widget.textFieldHeight ?? 58).h,
      child: TextField(
        onChanged: widget.onChanged,
        controller: _effectiveController,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        maxLines: widget.maxLines,
        style: TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: widget.prefix != null
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 17.h,
                  ),
                  child: widget.prefix,
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 20.h,
          ),
          labelText: widget.label,
          hintText: widget.hint,
          hintStyle: theme.textTheme.bodyMedium,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.textFieldborderRadius!.r,
            ),
            borderSide: BorderSide(color: theme.colorScheme.surfaceDim),
          ),
          focusedBorder: (widget.focusBorderColor != null)
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    widget.textFieldborderRadius!.r,
                  ),
                  borderSide: BorderSide(color: widget.focusBorderColor!),
                )
              : null,
          fillColor: theme.colorScheme.surfaceBright,
          filled: true,
          suffixIcon: widget.suffix != null
              ? GestureDetector(
                  onTap: widget.obscure
                      ? () => setState(() => _obscure = !_obscure)
                      : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 17.h,
                    ),
                    child: widget.suffix,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
