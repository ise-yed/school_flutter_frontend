import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/widgets/main_button.dart';
import 'package:school_flutter_frontend/core/widgets/main_textfield.dart';
import 'package:school_flutter_frontend/features/profile/bloc/profile_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_setting.dart';
import '../../../core/utils/snakbar.dart';
import '../../auth/models/user_model.dart';
import '../../auth/widgets/back_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.isEdit, this.initial});

  final UserModel? initial;
  final bool isEdit;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _canScroll = false;
  GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initial != null) {
      final u = widget.initial!;
      _firstNameController.text = u.firstName ?? '';
      _lastNameController.text = u.lastName ?? '';
      _phoneNumberController.text = u.phoneNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
          child: MultiBlocListener(
            listeners: [
              BlocListener<ProfileBloc, ProfileState>(
                listenWhen: (prev, curr) =>
                    curr is EditProfileSuccess || curr is EditProfileError,
                listener: (context, state) async {
                  if (state is EditProfileSuccess) {
                    currentUserModel = state.user;
                    prefs.setBool(AppConstants.isAppStarted, true);
                    if (widget.isEdit) {
                      Navigator.pop(context);
                      showCustomSnackBar(
                        context: context,
                        title: 'success'.tr(),
                        content: 'snack_success'.tr(),
                        status: ToastificationType.success,
                      );
                    }
                  }
                  if (state is EditProfileError) {
                    showCustomSnackBar(
                      context: context,
                      title: 'error_title'.tr(),
                      content: state.message,
                      status: ToastificationType.error,
                    );
                  }
                },
              ),
            ],
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: (n) {
                final can = n.metrics.maxScrollExtent > 0;
                if (can != _canScroll) setState(() => _canScroll = can);
                return false;
              },
              child: CustomScrollView(
                physics: _canScroll
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isEdit) ...[
                          AuthBackButton(
                            onPressed: () => Navigator.pop(context),
                          ),
                          SizedBox(height: 16.h),
                        ],
                        Center(
                          child: Text(
                            widget.isEdit
                                ? 'edit_profile_info'.tr()
                                : "complete_account_info".tr(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        SizedBox(height: 26.h),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "first_name".tr(),
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 9.h),
                          CoreTextField(
                            controller: _firstNameController,
                            hint: "first_name".tr(),
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: (String? e) =>
                                (e == null || e.trim().isEmpty)
                                ? tr('required_field')
                                : null,
                          ),
                          SizedBox(height: 17.h),
                          Text(
                            "last_name".tr(),
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 9.h),
                          CoreTextField(
                            controller: _lastNameController,
                            hint: "last_name".tr(),
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: (String? e) =>
                                (e == null || e.trim().isEmpty)
                                ? tr('required_field')
                                : null,
                          ),
                          SizedBox(height: 17.h),
                          Text(
                            "phone_number".tr(),
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 9.h),
                          CoreTextField(
                            controller: _phoneNumberController,
                            hint: "0912xxxxxxx",
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: (String? e) {
                              if (e == null || e.trim().isEmpty) {
                                return tr('required_field');
                              }
                              final text = e.trim();
                              if (text.length != 11 || !text.startsWith('09')) {
                                return 'شماره موبایل باید ۱۱ رقم و با ۰۹ شروع شود';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24.h),
                          const Spacer(),
                          SafeArea(
                            top: false,
                            minimum: EdgeInsets.only(bottom: 20.h),
                            child: BlocBuilder<ProfileBloc, ProfileState>(
                              buildWhen: (prev, curr) =>
                                  curr is EditProfileLoading ||
                                  curr is EditProfileSuccess ||
                                  curr is EditProfileError,
                              builder: (context, state) {
                                final isSaving = state is EditProfileLoading;
                                return CustomElevatedButton(
                                  loading: isSaving,
                                  onTap: () async {
                                    if (formKey.currentState!.validate()) {
                                      UserModel user = UserModel(
                                        firstName: _firstNameController.text
                                            .trim(),
                                        lastName: _lastNameController.text
                                            .trim(),
                                        phoneNumber: _phoneNumberController.text
                                            .trim(),
                                      );
                                      BlocProvider.of<ProfileBloc>(context)
                                          .add(EditProfileEvent(user: user));
                                    }
                                  },
                                  text: widget.isEdit
                                      ? 'save'.tr()
                                      : "enter_to_app".tr(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
