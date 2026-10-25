// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:school_flutter_frontend/core/constants/app_constants.dart';
// import 'package:school_flutter_frontend/core/utils/navigator.dart';
// import 'package:school_flutter_frontend/core/widgets/app_cached_image.dart';
// import 'package:school_flutter_frontend/core/widgets/global_loading_section.dart';
// import 'package:school_flutter_frontend/core/widgets/pagination_error.dart';
// import 'package:school_flutter_frontend/features/home/bloc/home_bloc.dart';
// import 'package:school_flutter_frontend/features/handover/screens/pet_detail_screen.dart';
// import 'package:school_flutter_frontend/features/messaging/screens/messaging_chat_screen.dart';
// import 'package:school_flutter_frontend/features/reminder/screens/add_reminder.dart';
// import 'package:school_flutter_frontend/features/shop/screens/product_detail_screen.dart';
// import 'package:toastification/toastification.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../core/constants/app_setting.dart';
// import '../../../core/utils/snakbar.dart';

// class HomeAdsCarousel extends StatefulWidget {
//   const HomeAdsCarousel({super.key});

//   @override
//   State<HomeAdsCarousel> createState() => _HomeAdsCarouselState();
// }

// class _HomeAdsCarouselState extends State<HomeAdsCarousel> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<HomeBloc, HomeState>(
//       buildWhen: (previous, current) {
//         return current is GetAdsSuccessState ||
//             current is GetAdsLoadingState ||
//             current is GetAdsFailedState;
//       },
//       builder: (context, state) {
//         if (state is GetAdsLoadingState) {
//           return SizedBox(
//             height: 175.h,
//             child: GlobalLoadingSection(
//               padding: EdgeInsets.symmetric(horizontal: 24.w),
//             ),
//           );
//         }

//         if (state is GetAdsFailedState) {
//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24.w),
//             child: SizedBox(
//               height: 175.h,
//               child: GlobalPaginationErrorSection(
//                 message: state.message,
//                 onRetry: () => context.read<HomeBloc>().add(GetAdsEvent()),
//               ),
//             ),
//           );
//         }

//         if (state is GetAdsSuccessState) {
//           final ads = state.ads;

//           if (ads.isEmpty) {
//             return SizedBox(height: 175.h);
//           }

//           final hasIndicator = ads.length > 1;

//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24.w),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(25.r),
//                   child: SizedBox(
//                     height: 175.h,
//                     width: double.infinity,
//                     child: CarouselSlider.builder(
//                       itemCount: ads.length,
//                       itemBuilder: (context, index, realIndex) {
//                         final ad = ads[index];

//                         return Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 4.w),
//                           child: GestureDetector(
//                             behavior: HitTestBehavior.opaque,
//                             onTap: () => _onBannerTap(
//                               context,
//                               state,
//                               adId: ad.id,
//                               index: index,
//                             ),
//                             child: SizedBox(
//                               height: 175.h,
//                               width: double.infinity,
//                               child: AppCachedImage(
//                                 url: AppConstants.appImgBaseUrl + ad.image,
//                                 fit: BoxFit.fill,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                       options: CarouselOptions(
//                         height: 175.h,
//                         viewportFraction: 1,
//                         enableInfiniteScroll: hasIndicator,
//                         autoPlay: hasIndicator,
//                         autoPlayInterval: const Duration(seconds: 5),
//                         autoPlayAnimationDuration: const Duration(
//                           milliseconds: 800,
//                         ),
//                         autoPlayCurve: Curves.easeInOut,
//                         onPageChanged: (index, reason) {
//                           setState(() => _currentIndex = index);
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               if (hasIndicator) ...[
//                 SizedBox(height: 8.h),
//                 _buildIndicator(
//                   count: ads.length,
//                   currentIndex: _currentIndex,
//                   context: context,
//                 ),
//               ],
//             ],
//           );
//         }

//         return SizedBox(height: 175.h);
//       },
//     );
//   }

//   Widget _buildIndicator({
//     required int count,
//     required int currentIndex,
//     required BuildContext context,
//   }) {
//     final activeColor = Theme.of(context).colorScheme.primary;
//     final inactiveColor = Theme.of(
//       context,
//     ).colorScheme.onSurface.withOpacity(0.6);

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(count, (index) {
//         final isActive = index == currentIndex;

//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: EdgeInsets.symmetric(horizontal: 4.w),
//           height: 6.h,
//           width: isActive ? 15.w : 6.w,
//           decoration: BoxDecoration(
//             color: isActive ? activeColor : inactiveColor,
//             borderRadius: BorderRadius.circular(50),
//           ),
//         );
//       }),
//     );
//   }

//   Future<void> _onBannerTap(
//     BuildContext context,
//     GetAdsSuccessState state, {
//     required String adId,
//     required int index,
//   }) async {
//     final ad = state.ads[index];

//     switch (ad.type) {
//       case "link":
//         final urlStr = (ad.content ?? "").toString().trim();
//         if (urlStr.isEmpty) return;

//         final ok = await launchUrl(
//           Uri.parse(urlStr),
//           mode: LaunchMode.externalApplication,
//         );

//         if (!ok && context.mounted) {
//           showCustomSnackBar(
//             context: context,
//             title: "error_title".tr(),
//             content: "error.link".tr(),
//             status: ToastificationType.error,
//           );
//         }
//         break;

//       case "reminder":
//         goScreen(
//           context: context,
//           screen: AddReminderScreen(fromAds: true, editReminder: ad.content),
//         );
//         break;

//       case "vet":
//         final chat = state.chats[adId];
//         if (chat == null) return;

//         final target = chat.getTargetProfile(currentUserModel.id ?? "");

//         goScreen(
//           context: context,
//           screen: MessagingChatScreen(
//             fromHome: true,
//             chatRoomDoc: chat,
//             targetProfile: target,
//             fromHandover: false,
//             fromTicket: false,
//           ),
//         );
//         break;

//       case "product":
//         final product = state.products[adId];
//         if (product == null) return;

//         goScreen(
//           context: context,
//           screen: ShopProductDetailScreen(product: product),
//         );
//         break;

//       case "handover":
//         final handover = state.handovers[adId];
//         if (handover == null) return;

//         goScreen(
//           context: context,
//           screen: HandoverPetDetailScreen(
//             handover: handover,
//             canEdit: false,
//             canDelete: false,
//           ),
//         );
//         break;
//     }
//   }
// }
