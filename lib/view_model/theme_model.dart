import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class ThemeModel with ChangeNotifier {
  static IconThemeData tittleTheMme =
      const IconThemeData(color: Color(0xff666666));
  static TextStyle tittleStyle = TextStyle(
      fontSize: 36.sp,
      fontWeight: FontWeight.normal,
      color: const Color(0xff333333));

  static const fontValueList = ['system', 'kuaile'];
  // 顶部appBar高度
  static Size appBarHeight = const Size.fromHeight(50.0);

  /// 用户选择的明暗模式
  late bool _userDarkMode;

  /// 当前主题颜色
  late MaterialColor _themeColor;

  ThemeModel() {
    /// 用户选择的明暗模式
    _userDarkMode = false;

    /// 获取主题色
    _themeColor = Colors.blue;
  }

  static Widget makeBaseText12(String val) {
    return Text(val, style: TextStyle(color: Colors.grey, fontSize: 24.sp));
  }

  static Widget makeLive3AppBar(BuildContext context, String tittleStr,
      {List<Widget>? actionArr,
      ValueChanged? onPressedHandle,
      bool isSet = false}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(100.w),
      child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Image(
                height: 36.w,
                image: const AssetImage('assets/img/common/left_btn.png')),
            onPressed: () {
              if (onPressedHandle != null) {
                onPressedHandle(context);
              }
            },
          ),
          title: Text(
            tittleStr,
            style: ThemeModel.tittleStyle,
          ),
          centerTitle: true,
          actions: actionArr),
    );
  }

  /// 根据主题 明暗 和 颜色 生成对应的主题
  /// [dark]系统的Dark Mode
  themeData({bool platformDarkMode = false}) {
    var isDark = platformDarkMode || _userDarkMode;
    Brightness brightness = isDark ? Brightness.dark : Brightness.light;

    var themeColor = _themeColor;
    var accentColor = Colors.transparent;
    var themeData = ThemeData(
        //取消水波纹
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        brightness: brightness,
        primarySwatch: themeColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColor),
        fontFamily: fontValueList[0]);

    themeData = themeData.copyWith(
      brightness: brightness,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColor),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: themeColor,
        brightness: brightness,
      ),
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: Colors.transparent),
      appBarTheme: themeData.appBarTheme.copyWith(elevation: 0),
      splashColor: themeColor.withAlpha(50),
      hintColor: themeData.hintColor.withAlpha(90),
      errorColor: Colors.red,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentColor,
        selectionColor: accentColor.withAlpha(60),
        selectionHandleColor: accentColor.withAlpha(60),
      ),
      textTheme: themeData.textTheme.copyWith(

          /// 解决中文hint不居中的问题 https://github.com/flutter/flutter/issues/40248
          headline6: themeData.textTheme.headline6
              ?.copyWith(textBaseline: TextBaseline.alphabetic)),
      toggleableActiveColor: accentColor,
      chipTheme: themeData.chipTheme.copyWith(
        pressElevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        labelStyle: themeData.textTheme.caption,
      ),
      inputDecorationTheme: ThemeHelper.inputDecorationTheme(themeData),
    );
    return themeData;
  }

  /// 根据索引获取字体名称,这里牵涉到国际化
  static String fontName(index, context) {
    switch (index) {
      case 0:
        return "跟随系统";
      default:
        return '';
    }
  }
}

class ThemeHelper {
  static InputDecorationTheme inputDecorationTheme(ThemeData theme) {
    var primaryColor = theme.primaryColor;
    var dividerColor = theme.dividerColor;
    var errorColor = theme.errorColor;
    var disabledColor = theme.disabledColor;

    var width = 0.5;

    return InputDecorationTheme(
      hintStyle: const TextStyle(fontSize: 14),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: errorColor)),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 0.7, color: errorColor)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: primaryColor)),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: dividerColor)),
      border: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: dividerColor)),
      disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: width, color: disabledColor)),
    );
  }
}
