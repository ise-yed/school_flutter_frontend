import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/constants/app_constants.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';
import 'package:school_flutter_frontend/core/widgets/app_cached_image.dart';
import 'package:school_flutter_frontend/features/profile/screens/notification_screen.dart';
import 'package:school_flutter_frontend/features/profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final AnimationController _pulseController;
  bool _isSearchFocused = false;

  // لیست تخصص‌ها (آماده اتصال به GET /api/v1/categories/)
  final List<_SpecialtyItem> _specialties = const [
    _SpecialtyItem(
      id: 'cardiology',
      title: 'قلب و عروق',
      icon: Icons.monitor_heart_rounded,
      usePrimaryColor: true,
    ),
    _SpecialtyItem(
      id: 'dermatology',
      title: 'پوست و مو',
      icon: Icons.face_retouching_natural_rounded,
      usePrimaryColor: false,
    ),
    _SpecialtyItem(
      id: 'neurology',
      title: 'مغز و اعصاب',
      icon: Icons.psychology_rounded,
      usePrimaryColor: true,
    ),
    _SpecialtyItem(
      id: 'pediatrics',
      title: 'کودکان',
      icon: Icons.child_care_rounded,
      usePrimaryColor: false,
    ),
    _SpecialtyItem(
      id: 'obgyn',
      title: 'زنان و زایمان',
      icon: Icons.pregnant_woman_rounded,
      usePrimaryColor: true,
    ),
    _SpecialtyItem(
      id: 'orthopedics',
      title: 'ارتوپدی',
      icon: Icons.accessibility_new_rounded,
      usePrimaryColor: false,
    ),
    _SpecialtyItem(
      id: 'ophthalmology',
      title: 'چشم‌پزشکی',
      icon: Icons.visibility_rounded,
      usePrimaryColor: true,
    ),
    _SpecialtyItem(
      id: 'dentistry',
      title: 'دندان‌پزشکی',
      icon: Icons.medical_services_rounded,
      usePrimaryColor: false,
    ),
  ];

  // لیست پزشکان نمونه (آماده اتصال به GET /api/v1/providers/)
  final List<_DoctorItemModel> _doctors = [
    _DoctorItemModel(
      id: '1',
      name: 'دکتر مریم صادقی',
      specialty: 'فوق تخصص قلب و عروق و اکوکاردیوگرافی',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBaivf4mRYB_mgxeKxpoOOrc2R_Wk09Q7d7n3YI1Ll_WelviZmaPUJJ-7BpiBi_Ixm7871l_H431z8JNBmooMS2cp0cA33GLN_JD78CpwObNocuvwgWXiWFgvNRSJjgusUp8dmVkoHb9XUPgWWnxihNZXeFaIxzauFslyUCYgKfwLaHerFuOWImiwm5Z-DP7M4JquvW_26jca29dq-If1bDjcI2DIjQaJI6WiTgihTj4krm2CMG5rKg',
      rating: '۴.۹',
      reviewsCount: '۱۴۲',
      medicalCode: '۸۴۳۲۰',
      isOnline: true,
      hasInPerson: true,
      onlineTagText: 'مشاوره متنی آنلاین',
      onlineTagIcon: Icons.chat_bubble_outline_rounded,
      availabilityPrefix: 'اولین نوبت خالی: ',
      availabilityValue: 'امروز ۱۷:۳۰',
      isInstantOnline: false,
      ctaText: 'دریافت نوبت',
      isPrimaryCta: true,
    ),
    _DoctorItemModel(
      id: '2',
      name: 'دکتر آرش فرهمند',
      specialty: 'متخصص و بورد تخصصی پوست، مو و زیبایی',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCI7U8dX2Y_-S4H228kNjlcmjokA3khvAHTU8f4hW470sJXxAKPiS2-d2a8FhudhulpYeRBjxBldlncAvsjC2LBhbBLfAi7ou1UEWgExLZpw09eT_d4rFEs7fnGhiYMcP3Ve-9_SebotabOYHVb7QQw0S9zQomr2rxq1CvUmY021nrpDGfS5bHxEEEZnH-ky9-S_e3UmqKZuYXKBVh3wvMwqM2ngLO6AKGa_02AAd8o54sl3KtdEJZK',
      rating: '۴.۸',
      reviewsCount: '۹۸',
      medicalCode: '۹۲۱۰۴',
      isOnline: true,
      hasInPerson: true,
      onlineTagText: 'مشاوره تصویری',
      onlineTagIcon: Icons.videocam_outlined,
      availabilityPrefix: 'مشاوره آنلاین: ',
      availabilityValue: 'پاسخ‌گویی ظرف ۲۰ دقیقه',
      isInstantOnline: true,
      ctaText: 'دریافت نوبت',
      isPrimaryCta: true,
    ),
    _DoctorItemModel(
      id: '3',
      name: 'دکتر سارا کاظمی',
      specialty: 'متخصص کودکان، نوزادان و رشد کودک',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAmfSbvwOXnsB1HefvPPcSmZTzalZ6NEzSxtQjWvuqwtG9hE8pjG9u6iz1j4HsyvVzQvek94mssz5FYXbX58H3iC-yFKMnLbz31deeq0sbaWgPCYciSBa77nrK1rjuspgGO94MN5zi4tbDXCwGDvey1UKsV1Am7_2XRmCFrHDevKLvr4B_rI2umkOC3tgRi42OQtGddkBAUvMFsumQ2XFeOU8qNB3TcxDAiLLEWJ1aaby4yHhm_RtL3',
      rating: '۴.۹',
      reviewsCount: '۲۱۵',
      medicalCode: '۶۷۵۱۸',
      isOnline: true,
      hasInPerson: true,
      onlineTagText: 'مشاوره متنی آنلاین',
      onlineTagIcon: Icons.chat_bubble_outline_rounded,
      availabilityPrefix: 'اولین نوبت خالی: ',
      availabilityValue: 'فردا ۱۰:۰۰',
      isInstantOnline: false,
      ctaText: 'دریافت نوبت',
      isPrimaryCta: true,
    ),
    _DoctorItemModel(
      id: '4',
      name: 'دکتر کامران بهرامی',
      specialty: 'جراح مغز و اعصاب و ستون فقرات',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC6g_DP3Hc4rYCpkgIwsJo4ZLTulhLFC5EYTzIN4OqPh3WWJncwdkNSenz-ZBvOkj_91gU_gYNgXkIuDo5v2zhtHUV_aZgOeKFHb7Yq3YgYNBqs_IfvvL3eXxTkNDrGxUnl4I0tc8LWoOzEbp0s-lHwl3cLvL599ArIgoGhVrAph7JTbM5AR2Ka6MmCfR5oiI8N44Ag5KEpjAXtWEXIgkTZ4nbIwijXt25ZZ8N1F0qh1RjbwB70q1-8',
      rating: '۴.۷',
      reviewsCount: '۷۶',
      medicalCode: '۵۱۲۰۴',
      isOnline: false,
      hasInPerson: true,
      onlineTagText: null,
      onlineTagIcon: null,
      availabilityPrefix: 'اولین نوبت خالی: ',
      availabilityValue: 'دوشنبه ۱۶:۱۵',
      isInstantOnline: false,
      ctaText: 'مشاهده تقویم',
      isPrimaryCta: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _searchController.addListener(() {
      setState(() {});
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // ۱. هدر ثابت بالای صفحه
            _buildTopHeader(context),

            // ۲. محتوای قابل اسکرول صفحه
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 96.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // کادر جستجو و دکمه فیلتر پیشرفته
                    _buildSearchAndFilterBar(context),

                    // بخش دسته‌بندی تخصص‌ها (Grid 4 ستونه)
                    _buildSpecialtiesSection(context),

                    // بنر گرادینت مشاوره فوری ۲۴ ساعته
                    _buildUrgentConsultationBanner(context),

                    // بخش لیست پزشکان برتر و متخصصان در دسترس
                    _buildDoctorsListSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ۱. هدر بالای صفحه (Header)
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final String userName =
        (currentUserModel.fullName != null &&
            currentUserModel.fullName!.trim().isNotEmpty)
        ? currentUserModel.fullName!
        : 'سارا احمدی';

    final String userAvatar =
        (currentUserModel.avatar != null &&
            currentUserModel.avatar!.trim().isNotEmpty)
        ? '${AppConstants.appImgBaseUrl}${currentUserModel.avatar}'
        : 'https://lh3.googleusercontent.com/aida-public/AB6AXuBqn4mMZwtJ5RfBEDeH2LnDGcu8WVOk4PrSXw_WpIFsM89K7TBofJ3VowDUNwuY6dEXEOiBHtLX6iFveZKrjVhd7IZolcYrjKUtJN7zljMTyVcoHm3uxCtQAsfTwdrToQfq4f7-CW9BSojaB7MSCeTPZ0cjGQ-5228zLDWQZh6Gg3AuSkx1Z3eWOaUiu9eTxUhLGkjkIE2ETL-yVW8kZq-0Iw1-CRDpi3MSOCM0mRrAJiWkB5mCvkAU';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: AppColors.text700Light.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // سمت راست: لوگو، نام برنامه و موقعیت مکانی/خوش‌آمدگویی
              Expanded(
                child: Row(
                  children: [
                    // لوگوی درمانیار
                    Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: AppCachedImage(
                          url: 'https://lh3.googleusercontent.com/aida/AEtjO1VvpJbmkpL4u4WM8jPX6v0QkiD84urbGXKg8iXu__MREpes97mWl6jUfX8uBajxCkxYyRQK144yV7xN5yCf5OCeEZfdqHL6LnrN-UaSKtocBjQtUNTLEPav1tFrTAosNPYAzmUrIoEnZnHNxVPGLhRTFVYW6OAWXn7ZehsxrZ7WK9otWVJaVZx5b0Cb9WhXCoSeyUX5KfmAniUISvaghLx11LeHTYOhk3kydXAWrp2T41yQ8X8yGmhnVfw',
                          fit: BoxFit.contain,
                          error: Icon(
                            Icons.local_hospital_rounded,
                            color: AppColors.primary500,
                            size: 22.r,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'درمانیار',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: AppColors.primary500,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'Home',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontSize: 10.sp,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14.r,
                                color: AppColors.primary500,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  'تهران • روزبخیر، $userName',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // سمت چپ: دکمه اعلان‌ها و آواتار پروفایل کاربر
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // دکمه اعلان‌ها
                  InkWell(
                    borderRadius: BorderRadius.circular(50.r),
                    onTap: () {
                      goScreen(context: context, screen: NotificationScreen());
                    },
                    child: SizedBox(
                      width: 42.r,
                      height: 42.r,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 24.r,
                            color: AppColors.onSurfaceVariant,
                          ),
                          Positioned(
                            top: 10.r,
                            left: 10.r,
                            child: Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                color: AppColors.tertiary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surfaceContainerLowest,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),

                  // تصویر پروفایل کاربر همراه با نشانگر آنلاین
                  GestureDetector(
                    onTap: () {
                      goScreen(context: context, screen: const ProfileScreen());
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 34.r,
                          height: 34.r,
                          padding: EdgeInsets.all(1.5.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary500.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: AppCachedImage(
                              url: userAvatar,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -1.r,
                          right: -1.r,
                          child: Container(
                            width: 10.r,
                            height: 10.r,
                            decoration: BoxDecoration(
                              color: AppColors.primary500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surfaceContainerLowest,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ۲. نوار جستجو و دکمه فیلتر پیشرفته
  // ---------------------------------------------------------------------------
  Widget _buildSearchAndFilterBar(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
      child: Row(
        children: [
          // فیلد جستجو (هماهنگ با Input Fields در design.md)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48.h,
              decoration: BoxDecoration(
                color: _isSearchFocused
                    ? AppColors.surfaceContainerLowest
                    : AppColors.text50Light,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _isSearchFocused
                      ? AppColors.primary300
                      : AppColors.text200Light,
                  width: _isSearchFocused ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text700Light.withOpacity(
                      _isSearchFocused ? 0.06 : 0.03,
                    ),
                    blurRadius: _isSearchFocused ? 10 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  filled: false,
                  hintText: 'جستجوی پزشک، تخصص یا بیماری...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.outline,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary500,
                    size: 22.r,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: Container(
                            width: 22.r,
                            height: 22.r,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 15.r,
                              color: AppColors.outline,
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // دکمه فیلتر پیشرفته
          Material(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () {
                // باز کردن باتم‌شیت فیلتر پیشرفته
              },
              child: Container(
                width: 48.h,
                height: 48.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.text200Light),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text700Light.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary500,
                  size: 22.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ۳. بخش دسته‌بندی تخصص‌ها (Grid 4x2)
  // ---------------------------------------------------------------------------
  Widget _buildSpecialtiesSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        children: [
          // عنوان بخش
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 18.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'دسته‌بندی تخصص‌ها',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'مشاهده همه',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 14.r,
                          color: AppColors.primary500,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // شبکه ۴ ستونه تخصص‌ها
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _specialties.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 0.88,
              ),
              itemBuilder: (context, index) {
                final item = _specialties[index];
                final Color accentColor = item.usePrimaryColor
                    ? AppColors.primary500
                    : AppColors.secondary;

                return Material(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () {
                      // فیلتر پزشکان بر اساس تخصص انتخاب‌شده
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.surfaceContainerLow,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.text700Light.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 46.r,
                            height: 46.r,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              item.icon,
                              size: 26.r,
                              color: accentColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ۴. بنر گرادینت مشاوره فوری پزشکی متنی و تلفنی
  // ---------------------------------------------------------------------------
  Widget _buildUrgentConsultationBanner(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              AppColors.primary500,
              AppColors.primary400,
              AppColors.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary300.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // دایره دکوراتیو پایین-چپ
            Positioned(
              left: -24.r,
              bottom: -24.r,
              child: IgnorePointer(
                child: Container(
                  width: 112.r,
                  height: 112.r,
                  decoration: BoxDecoration(
                    color: AppColors.text700Dark.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // محتوای اصلی بنر
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // بج بالای بنر همراه با دایره چشمک‌زن
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.text700Dark.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeTransition(
                                opacity: Tween<double>(
                                  begin: 0.35,
                                  end: 1.0,
                                ).animate(_pulseController),
                                child: Container(
                                  width: 6.r,
                                  height: 6.r,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondaryFixed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'پاسخگویی سریع ۲۴ ساعته',
                                style: textTheme.titleSmall?.copyWith(
                                  color: AppColors.text700Dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'مشاوره فوری پزشکی متنی و تلفنی',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text700Dark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'ارتباط مستقیم با برترین پزشکان شیفت بدون نیاز به معطلی در مطب',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.surfaceContainerHigh,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: AppColors.text700Dark.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.bolt_rounded,
                      color: AppColors.text700Dark,
                      size: 26.r,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ۵. لیست پزشکان برتر و متخصصان در دسترس
  // ---------------------------------------------------------------------------
  Widget _buildDoctorsListSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
      child: Column(
        children: [
          // هدر لیست پزشکان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'پزشکان برتر و متخصصان در دسترس',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '۴۲ متخصص فعال',
                style: textTheme.titleSmall?.copyWith(color: AppColors.outline),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // کارت‌های پزشکان
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _doctors.length,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              final doc = _doctors[index];
              return _buildDoctorCard(context, doc);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, _DoctorItemModel doc) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.text200Light, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.text700Light.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ردیف بالا: عکس پزشک، نام، تخصص، امتیاز، کد نظام پزشکی و دکمه نشان کردن
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // تصویر پزشک + نشانگر وضعیت آنلاین/آفلاین
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: AppCachedImage(
                      url: doc.avatarUrl,
                      width: 64.r,
                      height: 64.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: -3.r,
                    right: -3.r,
                    child: Container(
                      width: 14.r,
                      height: 14.r,
                      decoration: BoxDecoration(
                        color: doc.isOnline
                            ? AppColors.primary500
                            : AppColors.outline,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceContainerLowest,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),

              // اطلاعات پزشک
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                doc.specialty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(8.r),
                          onTap: () {
                            setState(() {
                              doc.isBookmarked = !doc.isBookmarked;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(4.r),
                            child: Icon(
                              doc.isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 20.r,
                              color: doc.isBookmarked
                                  ? AppColors.tertiary
                                  : AppColors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // امتیاز و کد نظام پزشکی
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 15.r,
                                color: AppColors.tertiaryContainer,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                doc.rating,
                                style: textTheme.titleSmall?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                '(${doc.reviewsCount} نظر)',
                                style: textTheme.titleSmall?.copyWith(
                                  color: AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 14.r,
                              color: AppColors.primary500,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'کد نظام پزشکی: ${doc.medicalCode}',
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ردیف وسط: تگ‌های نوع ویزیت (حضوری / مشاوره آنلاین)
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              if (doc.hasInPerson)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inPersonVisitBg,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: 15.r,
                        color: AppColors.inPersonVisitFg,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'ویزیت حضوری مطب',
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.inPersonVisitFg,
                        ),
                      ),
                    ],
                  ),
                ),
              if (doc.onlineTagText != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        doc.onlineTagIcon ?? Icons.chat_bubble_outline_rounded,
                        size: 15.r,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        doc.onlineTagText!,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),

          // ردیف پایین: اولین نوبت خالی و دکمه دریافت نوبت / مشاهده تقویم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      doc.isInstantOnline
                          ? Icons.check_circle_outline_rounded
                          : Icons.calendar_month_rounded,
                      size: 16.r,
                      color: doc.isInstantOnline
                          ? AppColors.secondary
                          : AppColors.primary500,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: textTheme.bodySmall?.copyWith(
                            fontFamily: 'IRANYekan',
                            color: AppColors.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(text: doc.availabilityPrefix),
                            TextSpan(
                              text: doc.availabilityValue,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: doc.isInstantOnline
                                    ? AppColors.secondary
                                    : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // دکمه عملیات (دریافت نوبت / مشاهده تقویم)
              Material(
                color: doc.isPrimaryCta
                    ? AppColors.primary500
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () {},
                  child: Container(
                    height: 40.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          doc.ctaText,
                          style: textTheme.labelMedium?.copyWith(
                            color: doc.isPrimaryCta
                                ? AppColors.text700Dark
                                : AppColors.primary500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.chevron_left_rounded,
                          size: 18.r,
                          color: doc.isPrimaryCta
                              ? AppColors.text700Dark
                              : AppColors.primary500,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// مدل‌های داده داخلی صفحه
// -----------------------------------------------------------------------------
class _SpecialtyItem {
  final String id;
  final String title;
  final IconData icon;
  final bool usePrimaryColor;

  const _SpecialtyItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.usePrimaryColor,
  });
}

class _DoctorItemModel {
  final String id;
  final String name;
  final String specialty;
  final String avatarUrl;
  final String rating;
  final String reviewsCount;
  final String medicalCode;
  final bool isOnline;
  final bool hasInPerson;
  final String? onlineTagText;
  final IconData? onlineTagIcon;
  final String availabilityPrefix;
  final String availabilityValue;
  final bool isInstantOnline;
  final String ctaText;
  final bool isPrimaryCta;
  bool isBookmarked;

  _DoctorItemModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.rating,
    required this.reviewsCount,
    required this.medicalCode,
    required this.isOnline,
    required this.hasInPerson,
    this.onlineTagText,
    this.onlineTagIcon,
    required this.availabilityPrefix,
    required this.availabilityValue,
    required this.isInstantOnline,
    required this.ctaText,
    required this.isPrimaryCta,
    this.isBookmarked = false,
  });
}
