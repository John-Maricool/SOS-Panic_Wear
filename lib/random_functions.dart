import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_text_theme.dart';
import 'colors.dart';

enum ToastType { success, error, info }

class RandomFunction {
  static bool isLessThanAnHourAgo(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);
    return difference.inHours < 1;
  }

  static Color getRandomColor() {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
    ];

    Random random = Random();
    return colors[random.nextInt(colors.length)];
  }

  static String maskPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters (e.g., spaces, hyphens, parentheses)
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // If the phone number is too short, return it as is
    if (digitsOnly.length <= 2) {
      return digitsOnly;
    }

    // Mask the middle digits
    String maskedDigits = '*' * (digitsOnly.length - 2);

    // Combine the first digit, masked digits, and the last digit
    String maskedPhoneNumber =
        '${digitsOnly[0]}$maskedDigits${digitsOnly[digitsOnly.length - 1]}';

    return maskedPhoneNumber;
  }

  static String maskEmail(String email) {
    if (!email.contains("@")) return email; // Return as is if not a valid email

    List<String> parts = email.split("@");
    String username = parts[0];
    String domain = parts[1];

    if (username.length <= 2) {
      return "${username[0]}***@$domain";
    }

    String maskedUsername =
        "${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}";

    return "$maskedUsername@$domain";
  }
  //
  // static String formatDate(DateTime dateTime) {
  //   final now = DateTime.now();
  //   final difference = now.difference(dateTime);
  //
  //   String formattedTime = DateFormat('hh:mm a').format(dateTime);
  //   String formattedDate = DateFormat('d MMM yyyy').format(dateTime);
  //
  //   if (difference.inDays == 0) {
  //     // If the date is today
  //     return 'Today, $formattedTime';
  //   } else if (difference.inDays == 1) {
  //     // If the date is yesterday
  //     return 'Yesterday, $formattedTime';
  //   } else {
  //     // If the date is older than yesterday
  //     return '$formattedDate, $formattedTime';
  //   }
  // }

  static void toast(ToastType type, String msg) {
    // Set default properties for the toast based on its type
    Icon icon;
    Color backgroundColor;
    String title;
    TextStyle titleStyle;
    Alignment align = Alignment.topCenter;

    switch (type) {
      case ToastType.success:
        icon = const Icon(Icons.check_circle_outline,
            color: Colors.white, size: 24);
        backgroundColor = Colors.green;
        title = "Success";
        titleStyle = AppTextTheme.h14.copyWith(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        );
        break;
      case ToastType.error:
        icon = const Icon(Icons.error_outline, color: Colors.white, size: 24);
        backgroundColor = Colors.red;
        title = "Error";
        titleStyle = AppTextTheme.h14.copyWith(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        );
        break;
      case ToastType.info:
        icon = const Icon(Icons.info_outline, color: Colors.white, size: 24);
        backgroundColor = Colors.orange;
        title = "Info";
        titleStyle = AppTextTheme.h14.copyWith(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        );
        break;
    }

    // Show the toast
    BotToast.showSimpleNotification(
      subTitle: msg,
      title: title,
      duration: Duration(seconds: 3),
      backgroundColor: backgroundColor,
      subTitleStyle: titleStyle,
      titleStyle: titleStyle,
      align: align,
      wrapToastAnimation: (controller, cancelFunc, child) {
        return FadeTransition(
            opacity: controller,
            child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(controller),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20.sp,
                            width: 20.sp,
                            margin: EdgeInsets.only(top: 2.h),
                            decoration: BoxDecoration(
                              color: AppColor.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: type == ToastType.success
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 10.sp,
                                  )
                                : type == ToastType.error
                                    ? Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 10.sp,
                                      )
                                    : type == ToastType.info
                                        ? Center(
                                            child: Text(
                                              "i",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              "!",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Flexible(
                                  child: Text(
                                    msg,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )));
      },
      closeIcon: const Icon(
        Icons.close,
        color: Colors.white,
        size: 16,
      ),
      onClose: () {
        debugPrint("Toast closed");
      },
      crossPage: true,
    );
  }

  static String generateRandomCode() {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
        5, (index) => characters[random.nextInt(characters.length)]).join();
  }
  //
  // static String formatTime(DateTime dateTime) {
  //   return DateFormat.jm().format(dateTime); // Formats time in "h:mm a" format
  // }

  static String formatNumberToShortcut(String number) {
    try {
      double num =
          double.tryParse(number) ?? 0; // Default to 0 if parsing fails

      if (num >= 1000000) {
        double result = num / 1000000;
        String formatted =
            result.toStringAsFixed(1); // Ensure at least one decimal
        return formatted.endsWith(".0")
            ? formatted.substring(0, formatted.length - 2) + 'M'
            : formatted + 'M';
      } else if (num >= 1000) {
        double result = num / 1000;
        String formatted =
            result.toStringAsFixed(1); // Ensure at least one decimal
        return formatted.endsWith(".0")
            ? formatted.substring(0, formatted.length - 2) + 'k'
            : formatted + 'k';
      } else {
        if (num == num.toInt()) {
          return num.toInt()
              .toString(); // Return integer value without decimal part
        } else {
          return num.toString();
        }
      }
    } catch (e) {
      return number;
    }
  }

  // static String formatDateTime(DateTime date) {
  //   return DateFormat('MM/dd/yy').format(date);
  // }
  //
  // static String formatDateTimeFromString(String date) {
  //   return DateFormat('MM/dd/yy').format(DateTime.parse(date));
  // }
  //

  static String ensureHttps(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }
  //
  // static void giveFeedback() async {
  //   String url;
  //
  //   if (Platform.isIOS) {
  //     url = 'https://apps.apple.com/us/app/your-app/id6504285381';
  //   } else {
  //     url =
  //         'https://play.google.com/store/apps/details?id=com.desdev.booboo_eats_user';
  //   }
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url));
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
  //
  // static void loadUrl(String url) async {
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url));
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  static String convertFileToBase64String(File img) {
    List<int> imageBytes = img.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  static List<String> convertListFileToBase64String(List<File> img) {
    if (img.isEmpty) {
      return [];
    }
    List<String> base64Images = [];
    for (File image in img) {
      String base64Image = convertFileToBase64String(image);
      base64Images.add(base64Image);
    }
    return base64Images;
  }

  // static Future callNumber(String phoneNumber) async {
  //   Uri url = Uri.parse("tel:$phoneNumber");
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(number % 1000000 == 0 ? 0 : 1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k";
    } else {
      return number.toString();
    }
  }

  static String formatMoney(String amount, String currency) {
    // Remove any existing commas from the amount string
    String cleanAmount = amount.replaceAll(',', '');

    // Parse the string into an integer
    double parsedAmount = double.tryParse(cleanAmount) ?? 0;

    // Format the integer as a currency string with Naira symbol and comma separators
    String formattedAmount = parsedAmount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},');

    formattedAmount = '$currency$formattedAmount';

    return formattedAmount;
  }

  static String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input; // Check for empty string
    return input[0].toUpperCase() + input.substring(1);
  }

  static void setStatusColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  static void resetStatusColor() {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  static String formatDateChatPattern(DateTime date) {
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return '${_formatDay(date.day)} ${_getMonthName(date.month)}, ${date.year}';
    }
  }

  static String _formatDay(int day) {
    if (day == 1 || day == 21 || day == 31) {
      return '$day' + 'st';
    } else if (day == 2 || day == 22) {
      return '$day' + 'nd';
    } else if (day == 3 || day == 23) {
      return '$day' + 'rd';
    } else {
      return '$day' + 'th';
    }
  }

  static String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  static bool isDateBefore(String date1, String date2) {
    var date11 = DateTime.parse(date1);
    var date22 = DateTime.parse(date2);
    return date11.isBefore(date22);
  }
}
