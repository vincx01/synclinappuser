import 'dart:math';

import 'package:cutfx/model/user/salon.dart';
import 'package:cutfx/model/user/salon_user.dart';
import 'package:cutfx/screens/main/main_screen.dart';
import 'package:cutfx/service/api_service.dart';
import 'package:cutfx/utils/color_res.dart';
import 'package:cutfx/utils/shared_pref.dart';
import 'package:cutfx/utils/style_res.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'custom/custom_dialog.dart';

class AppRes {
  static const String isLogin = 'is_login';
  static double latitude = -1;
  static double longitude = -1;
  static const String user = 'user';
  static const String settings = 'settings';
  static const String topicName = 'users';
  static const String ct = 'ct';

  static String commonDateFormat = 'yyyy-MM-ddThh:mm:ssZ';

  static String currency = '';
  static int totalDays = 90;

  static Future<SnackbarController> showSnackBar(
    String msg,
    bool positive,
  ) async {
    return Get.showSnackbar(
      GetSnackBar(
        titleText: Container(),
        backgroundColor: positive ? ColorRes.white : ColorRes.bitterSweet1,
        message: msg,
        messageText: Text(
          msg,
          style: kSemiBoldThemeTextStyle.copyWith(
            color: positive ? ColorRes.themeColor : ColorRes.bitterSweet,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Future<void> showCustomLoader() async {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return const CustomLoader();
      },
      barrierDismissible: false,
    );
  }

  static Future<void> hideCustomLoader() async {
    Get.back();
  }

  static Future<void> hideCustomLoaderWithBack() async {
    Get.back();
    Get.back();
  }

  static bool isSalonIsOpen(SalonData? salon) {
    int currentDay = DateTime.now().weekday;
    int todayTime = int.parse('${DateTime.now().hour}${DateTime.now().minute}');
    if (salon?.satSunFrom == null ||
        salon?.satSunTo == null ||
        salon?.monFriFrom == null ||
        salon?.monFriTo == null) {
      return false;
    }
    if (currentDay > 5) {
      return int.parse('${salon?.satSunFrom}') < todayTime &&
          int.parse('${salon?.satSunTo}') > todayTime;
    } else {
      return int.parse('${salon?.monFriFrom}') < todayTime &&
          int.parse('${salon?.monFriTo}') > todayTime;
    }
  }

  static double calculateDistance(double lat1, double lon1) {
    var p = 0.017453292519943295;
    var c = cos;

    var a = 0.5 -
        c((AppRes.latitude - lat1) * p) / 2 +
        c(lat1 * p) *
            c(AppRes.latitude * p) *
            (1 - c((AppRes.longitude - lon1) * p)) /
            2;
    return (12742 * asin(sqrt(a))).toPrecision(2);
  }

  static String getGenderTypeInStringFromNumber(
      BuildContext context, int genderType) {
    return genderType == 0
        ? AppLocalizations.of(context)!.male.toUpperCase()
        : genderType == 1
            ? AppLocalizations.of(context)!.female.toUpperCase()
            : AppLocalizations.of(context)!.unisex.toUpperCase();
  }

  static String convert24HoursInto12Hours(String? value) {
    DateTime dateTime = DateTime(
      DateTime.now().year,
      1,
      1,
      int.parse(value?.substring(0, 2) ?? '0'),
      int.parse(value?.substring(2, 4) ?? '0'),
    );
    return DateFormat('hh:mm a').format(dateTime);
  }

  ///------------------------ Image quality ------------------------///
  static const int imageQuality = 40;
  static const double maxWidth = 720;
  static const double maxHeight = 720;

  static String formatDate(DateTime dateTime,
      {String pattern = 'dd MMM, yyyy - EEE - h:mm a', bool isUtc = true}) {
    return DateFormat(pattern).format(isUtc ? dateTime.toLocal() : dateTime);
  }

  static DateTime parseDate(String dateTime,
      {String pattern = 'yyyy-MM-ddThh:mm:ssZ', bool isUtc = true}) {
    return DateFormat(pattern).parse(dateTime).copyWith(isUtc: isUtc);
  }

  static int getHourFromTime(String? time) {
    if (time == null) return 0;
    return int.parse(time.split(":")[0]) +
        (time.split(":")[1].split(" ")[1].contains("PM") &&
                int.parse(time.split(":")[0]) != 12
            ? 12
            : 0);
  }

  static String getMinFromTime(String? time) {
    return time?.split(":")[1].split(" ")[0] ?? "0";
  }

  static Color getColorByStatus(int status) {
    return status == 0
        ? ColorRes.seashell
        : status == 1
            ? ColorRes.themeColor10
            : status == 2
                ? ColorRes.panache
                : ColorRes.mistyRose;
  }

  static Color getTextColorByStatus(int status) {
    return status == 0
        ? ColorRes.pumpkin
        : status == 1
            ? ColorRes.themeColor
            : status == 2
                ? ColorRes.apple
                : ColorRes.bitterSweet;
  }

  static String getTextByStatus(int status) {
    return status == 0
        ? AppLocalizations.of(Get.context!)!.bookingPending
        : status == 1
            ? AppLocalizations.of(Get.context!)!.bookingConfirmed
            : status == 2
                ? AppLocalizations.of(Get.context!)!.completed
                : status == 3
                    ? AppLocalizations.of(Get.context!)!.cancelledBySalon
                    : AppLocalizations.of(Get.context!)!.cancelledByYou;
  }

  static String convertMonthNumberToName(BuildContext context, int month) {
    String name = '';
    if (month == 1) {
      name = AppLocalizations.of(context)!.january;
    } else if (month == 2) {
      name = AppLocalizations.of(context)!.february;
    } else if (month == 3) {
      name = AppLocalizations.of(context)!.march;
    } else if (month == 4) {
      name = AppLocalizations.of(context)!.april;
    } else if (month == 5) {
      name = AppLocalizations.of(context)!.may;
    } else if (month == 6) {
      name = AppLocalizations.of(context)!.june;
    } else if (month == 7) {
      name = AppLocalizations.of(context)!.july;
    } else if (month == 8) {
      name = AppLocalizations.of(context)!.august;
    } else if (month == 9) {
      name = AppLocalizations.of(context)!.september;
    } else if (month == 10) {
      name = AppLocalizations.of(context)!.october;
    } else if (month == 11) {
      name = AppLocalizations.of(context)!.november;
    } else if (month == 12) {
      name = AppLocalizations.of(context)!.december;
    }
    return name;
  }

  static String convertTimeForService(int min) {
    if (min >= 60) {
      if (min == 60) {
        return '1 Hour';
      } else {
        if (min.remainder(60) == 0) {
          return '${min.minutes.inHours} Hours';
        }
        return '${min.minutes.inHours} hr ${min.remainder(60)} min';
      }
    } else {
      return '$min min';
    }
  }

  static String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"}";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"}";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"}";
    }
    if (diff.inDays > 0) {
      if (diff.inDays == 1) {
        return "Yesterday";
      }
      return "${diff.inDays} days";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"}";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"}";
    }
    return "just now";
  }

  static String getStringOfStatusByType(num status) {
    return status == 0
        ? 'Pending'
        : status == 1
            ? 'Completed'
            : 'Rejected';
  }

  static String getStringOfWalletByType(num status) {
    return status == 0
        ? AppLocalizations.of(Get.context!)!.deposit
        : status == 1
            ? AppLocalizations.of(Get.context!)!.purchase
            : status == 2
                ? AppLocalizations.of(Get.context!)!.withdraw
                : AppLocalizations.of(Get.context!)!.refund;
  }

  static Color getColorOfWalletByType(num status) {
    return status == 0 ? ColorRes.bitterSweet : ColorRes.islamicGreen;
  }

  static String getPlusOrMinusOfWalletByType(num status) {
    return status == 0 ? '-' : '+';
  }

  static Color getBackgroundColorByStatus(num status) {
    return status == 0
        ? const Color(0xFFFF7A19)
        : status == 1
            ? const Color(0xFF35AB21)
            : const Color(0xFFFF2424);
  }

  static void loginWithFirebase(User? user, int loginType) async {
    if (user == null) {
      AppRes.hideCustomLoader();
      return;
    }

    SalonUser salonUser = await ApiService().registerUser(
      email: user.email ?? '',
      fullname: user.displayName ?? '',
      loginType: loginType,
    );
    AppRes.hideCustomLoader();
    if (salonUser.status != null && salonUser.status!) {
      Get.off(() => MainScreen());
    }
  }

  static num calculateDiscountByPercentage(int? price, int? discount) {
    if (discount == null || discount == 0 || price == null || price == 0) {
      return 0;
    }
    return (price * discount) / 100;
  }

  static int? findSelectLanguageCode(List<String> languageCode) {
    return languageCode.indexOf(SharePref.selectedLanguage);
  }
}
