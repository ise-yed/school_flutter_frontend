// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:school_flutter_frontend/features/profile/bloc/profile_bloc.dart';

// import '../../../core/constants/app_constants.dart';
// import '../../../core/widgets/app_cached_image.dart';

// class AvatarPicker extends StatelessWidget {
//   const AvatarPicker({
//     super.key,
//     required this.uploadedAvatarFileName,
//     required this.imageFile,
//     this.webImageBytes,
//     required this.uploadError,
//     required this.onPickTap,
//     required this.onRetryTap,
//   });

//   final String? uploadedAvatarFileName;
//   final XFile? imageFile;
//   final Uint8List? webImageBytes;
//   final bool uploadError;
//   final VoidCallback onPickTap;
//   final VoidCallback onRetryTap;

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ProfileBloc, ProfileState>(
//       buildWhen: (prev, curr) =>
//           curr is UploadFileLoading ||
//           curr is UploadFileSuccess ||
//           curr is UploadFileError,
//       builder: (context, state) {
//         final isUploading = state is UploadFileLoading;
//         final hasServerAvatar =
//             (uploadedAvatarFileName != null &&
//             uploadedAvatarFileName!.trim().isNotEmpty);

//         Widget avatarChild;
//         if (isUploading) {
//           avatarChild = const Center(
//             child: CircularProgressIndicator(strokeWidth: 3),
//           );
//         } else if (hasServerAvatar) {
//           final url = AppConstants.appImgBaseUrl + uploadedAvatarFileName!;
//           avatarChild = ClipOval(
//             child: AppCachedImage(
//               url: url,
//               width: 118.w,
//               height: 118.h,
//               fit: BoxFit.cover,
//               backgroundColor: Theme.of(context).colorScheme.surfaceBright,
//             ),
//           );
//         } else if (imageFile != null) {
//           final filePath = imageFile!.path;
//           avatarChild = ClipOval(
//             child: kIsWeb
//                 ? (webImageBytes != null
//                       ? Image.memory(
//                           webImageBytes!,
//                           fit: BoxFit.cover,
//                           width: 118.w,
//                           height: 118.h,
//                         )
//                       : Image.network(
//                           filePath,
//                           fit: BoxFit.cover,
//                           width: 118.w,
//                           height: 118.h,
//                         ))
//                 : Image.file(
//                     File(filePath),
//                     fit: BoxFit.cover,
//                     width: 118.w,
//                     height: 118.h,
//                   ),
//           );
//         } else {
//           avatarChild = Padding(
//             padding: EdgeInsets.symmetric(horizontal: 39.w, vertical: 39.h),
//             child: SvgPicture.asset(
//               "assets/icons/paw.svg",
//               height: 40.h,
//               width: 40.w,
//               colorFilter: ColorFilter.mode(
//                 Theme.of(context).colorScheme.onSecondary,
//                 BlendMode.srcIn,
//               ),
//             ),
//           );
//         }

//         return Stack(
//           children: [
//             GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: onPickTap,
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Theme.of(context).colorScheme.surfaceDim,
//                   ),
//                   color: Theme.of(context).colorScheme.surfaceBright,
//                   shape: BoxShape.circle,
//                 ),
//                 height: 118.r,
//                 width: 118.r,
//                 child: avatarChild,
//               ),
//             ),
//             Positioned(
//               bottom: 2,
//               right: 2,
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: onPickTap,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 7.h),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.primary,
//                     shape: BoxShape.circle,
//                   ),
//                   height: 32.h,
//                   width: 32.w,
//                   child: SvgPicture.asset(
//                     "assets/icons/edit.svg",
//                     height: 18.h,
//                     width: 18.w,
//                     colorFilter: const ColorFilter.mode(
//                       Colors.white,
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             if (uploadError && imageFile != null)
//               Positioned(
//                 top: 2,
//                 left: 2,
//                 child: GestureDetector(
//                   onTap: onRetryTap,
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: Colors.redAccent,
//                       shape: BoxShape.circle,
//                     ),
//                     padding: EdgeInsets.all(6.w),
//                     child: Icon(
//                       Icons.refresh_rounded,
//                       size: 18.w,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
