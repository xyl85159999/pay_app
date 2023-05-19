import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bobi_pay_out/utils/theme_utils.dart';

/// 搜索页的AppBar
class SearchBar extends StatefulWidget {
  const SearchBar({
    Key? key,
    this.hintText = '',
    this.backImg = '',
    this.onPressed,
  }) : super(key: key);

  final String backImg;
  final String hintText;
  final Function(String)? onPressed;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeUtils.isDark(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Material(
        color: ThemeUtils.getBackgroundColor(context),
        child: CupertinoPageScaffold(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 16.w),
                  child: CupertinoSearchTextField(
                    controller: _controller,
                    onSubmitted: (value) {
                      // FocusScope.of(context).unfocus();
                      // 点击软键盘的动作按钮时的回调
                      widget.onPressed!(value);
                    },
                    autocorrect: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
