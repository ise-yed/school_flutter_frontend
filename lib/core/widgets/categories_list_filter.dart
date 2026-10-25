import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoriesListFilter extends StatefulWidget {
  final List<String> categories;
  final ValueChanged<String> onCategorySelected;

  const CategoriesListFilter({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategoriesListFilter> createState() => _HandoverCategoriesWidgetState();
}

class _HandoverCategoriesWidgetState extends State<CategoriesListFilter> {
  int selectedindex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37.h,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        // padding: const EdgeInsetsDirectional.only(start: 22),
        itemBuilder: (context, index) {
          final isSelected = selectedindex == index;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                selectedindex = index;
              });
              widget.onCategorySelected(widget.categories[index]);
            },
            child: Container(
              alignment: Alignment.center,
              height: 37.h,
              margin: EdgeInsetsDirectional.only(
                start: index == 0 ? 24.w : 6.w,
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.shadow,

                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                widget.categories[index],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
