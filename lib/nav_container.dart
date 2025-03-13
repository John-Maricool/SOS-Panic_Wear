import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_state.dart';
import 'app_text_theme.dart';
import 'colors.dart';

class NavContainerButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final double width, height, radius, textSize, padding, iconSize, spacing;
  final Color? iconColor, color, textColor;
  final isEnabled;
  final Color progressColor;
  final Widget? prefix;
  final AppState appState;
  const NavContainerButton({
    this.prefix,
    this.radius = 25,
    this.appState = AppState.idle,
    this.isEnabled = true,
    this.width = double.maxFinite,
    this.height = 54,
    this.progressColor = Colors.white,
    this.color = AppColor.green,
    this.textColor = AppColor.white,
    this.iconColor,
    required this.text,
    this.onTap,
    this.textSize = 16,
    this.iconSize = 17,
    this.padding = 0,
    this.spacing = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: appState == AppState.busy || isEnabled == false ? null : onTap,
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: isEnabled ? color : color!.withAlpha(120),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: appState == AppState.busy
                ? SizedBox(
                    height: 13,
                    width: 13,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (prefix != null) prefix!,
                      prefix != null
                          ? Expanded(
                              child: Center(
                                  child: Text(
                              text,
                              style: AppTextTheme.h14.copyWith(
                                  fontSize: textSize,
                                  fontWeight: FontWeight.w600,
                                  color: textColor ??
                                      (onTap == null
                                          ? const Color(0xff797979)
                                          : AppColor.white)),
                            )))
                          : Text(
                              text,
                              style: AppTextTheme.h14.copyWith(
                                  fontSize: textSize.sp,
                                  fontWeight: FontWeight.w600,
                                  color: textColor ??
                                      (onTap == null
                                          ? const Color(0xff797979)
                                          : AppColor.white)),
                            ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
