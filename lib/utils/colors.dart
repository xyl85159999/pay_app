// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';

class Colours {
  static const Color app_main = Color(0xFF4688FA);
  static const Color dark_app_main = Color(0xFF3F7AE0);

  static const Color bg_color = Color(0xfff1f1f1);
  static const Color bg_color_pink = Color(0x12ff7db6);
  static const Color bg_color_f9 = Color(0xfff9f9f9);
  static const Color dark_bg_color = Color(0xFF18191A);

  static const Color material_bg = Color(0xFFFFFFFF);
  static const Color dark_material_bg = Color(0xFF303233);

  static const Color text = Color(0xFF333333);
  static const Color text_green = Color(0xFF54c23f);
  static const Color text_yellow = Color(0xFFffeead);
  static const Color text_pink = Color(0xFFf04072);
  static const Color text_pink2 = Color(0xFFff7db6);
  static const Color text_blue = Color(0xff8de7ff);
  static const Color text_blue2 = Color(0xFF3F7AE0);
  static const Color dark_text = Color(0xFFB8B8B8);
  static const Color error_text = Color(0xFFE71D36);
  static const Color chat_user_vip = Color(0xFFFFD034);

  static const Color text_gray = Color(0xFF999999);
  static const Color dark_text_gray = Color(0xFF666666);
  static const Color line_gray = Color(0xFFededed);
  static const Color line_purple = Color(0x2069549d);
  static const Color text_gray_c = Color(0xFFcccccc);
  static const Color dark_button_text = Color(0xFFF2F2F2);

  static const Color bg_gray = Color(0xFFF6F6F6);
  static const Color dark_bg_gray = Color(0xFF1F1F1F);

  static const Color purple54 = Color(0xc81f0934);
  static const Color pink = Color(0xFFFC99C0);
  static const Color line = Color(0xFFEEEEEE);
  static const Color line2 = Color(0xFFE5E5E5);
  static const Color dark_line = Color(0xFF3A3C3D);
  static const Color pink_end = Color(0xFFff7db6);
  static const Color pink_start = Color(0xFFff226f);
  static const Color red_end = Color(0xffff6a00);
  static const Color red_start = Color(0xFFee0979);
  static const Color dialog_head_end = Color(0xFFfd7282);
  static const Color dialog_head_start = Color(0xFFf74559);
  static const Color gray_2f = Color(0xFF2f2f2f);
  static const Color red = Color(0xFFFF4759);
  static const Color dark_red = Color(0xFFE03E4E);
  static const Color dark_red2 = Color(0xFFF14373);

  static const Color yellow = Color(0xFFf3aa46);
  static const Color gold = Color(0xFFf0b883);
  static const Color purple = Color(0xFF69549d);

  static const Color text_disabled = Color(0xFFD4E2FA);
  static const Color dark_text_disabled = Color(0xFFCEDBF2);

  static const Color button_disabled = Color(0xFF96BBFA);
  static const Color dark_button_disabled = Color(0xFF83A5E0);

  static const Color button_highlight = Color(0xFF51DEC6);
  static const Color dark_button_highlight = Color(0xFF23B38E);

  static const Color unselected_item_color = Color(0xffbfbfbf);
  static const Color dark_unselected_item_color = Color(0xFF4D4D4D);

  static const Color bg_gray_ = Color(0xFFFAFAFA);
  static const Color dark_bg_gray_ = Color(0xFF242526);

  static const Color app_bg = Color(0xfff5f5f5);

  // static const Color public_transparent_bg = Color(0x37000000); //<!--通用-->
  static const Color public_transparent_bg = Color(0x42000000); //<!--通用-->
  static const Color transparent_80 = Color(0x80000000); //<!--204-->
  static const Color transparent_40 = Color(0x40000000); //<!--204-->
  static const Color transparent_48 = Color(0x48000000); //<!--204-->
  static const Color transparent_30 = Color(0x30000000); //<!--204-->
  static const Color white_19 = Color(0X19FFFFFF);

  static const Color text_dark = Color(0xFF333333);
  static const Color text_normal = Color(0xFF666666);

  static const Color divider = Color(0xffe5e5e5);
  static const Color chat_vip_bg = Color(0x4DFFC600); //vip聊天半透明背景色

  static const Color gray_33 = Color(0xFF333333); //51
  static const Color gray_66 = Color(0xFF666666); //102
  static const Color gray_99 = Color(0xFF999999); //153
  static const Color common_orange = Color(0XFFFC9153); //252 145 83
  static const Color gray_ef = Color(0XFFEFEFEF); //153

  static const Color white_fff4f4f4 = Color(0Xfff4f4f4);

  static const Color gray_f0 = Color(0xfff0f0f0); //<!--204-->
  static const Color gray_f5 = Color(0xfff5f5f5); //<!--204-->
  static const Color gray_cc = Color(0xffcccccc); //<!--204-->
  static const Color gray_ce = Color(0xffcecece); //<!--206-->
  static const Color green_1 = Color(0xff009688); //<!--204-->
  static const Color green_62 = Color(0xff626262); //<!--204-->
  static const Color green_e5 = Color(0xffe5e5e5); //<!--204-->

  static const Color green_de = Color(0xffdedede);

  static const Color bottom_sheet_black_bg = Color(0x01000000);

  static Color hexColor(int hex, {double alpha = 1}) {
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    return Color.fromRGBO((hex & 0xFF0000) >> 16, (hex & 0x00FF00) >> 8,
        (hex & 0x0000FF) >> 0, alpha);
  }

  static Color slRandomColor({int r = 255, int g = 255, int b = 255, a = 255}) {
    if (r == 0 || g == 0 || b == 0) return Colors.black;
    if (a == 0) return Colors.white;
    return Color.fromARGB(
      a,
      r != 255 ? r : Random.secure().nextInt(r),
      g != 255 ? g : Random.secure().nextInt(g),
      b != 255 ? b : Random.secure().nextInt(b),
    );
  }
}

Map<String, Color> circleAvatarMap = {
  'A': Colors.blueAccent,
  'B': Colors.blue,
  'C': Colors.cyan,
  'D': Colors.deepPurple,
  'E': Colors.deepPurpleAccent,
  'F': Colors.blue,
  'G': Colors.green,
  'H': Colors.lightBlue,
  'I': Colors.indigo,
  'J': Colors.blue,
  'K': Colors.blue,
  'L': Colors.lightGreen,
  'M': Colors.blue,
  'N': Colors.brown,
  'O': Colors.orange,
  'P': Colors.purple,
  'Q': Colors.black,
  'R': Colors.red,
  'S': Colors.blue,
  'T': Colors.teal,
  'U': Colors.purpleAccent,
  'V': Colors.black,
  'W': Colors.brown,
  'X': Colors.blue,
  'Y': Colors.yellow,
  'Z': Colors.grey,
  '#': Colors.blue,
};

Map<String, Color> themeColorMap = {
  'gray': Colours.gray_33,
  'blue': Colors.blue,
  'blueAccent': Colors.blueAccent,
  'cyan': Colors.cyan,
  'deepPurple': Colors.deepPurple,
  'deepPurpleAccent': Colors.deepPurpleAccent,
  'deepOrange': Colors.deepOrange,
  'green': Colors.green,
  'indigo': Colors.indigo,
  'indigoAccent': Colors.indigoAccent,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'pink': Colors.pink,
  'red': Colors.red,
  'teal': Colors.teal,
  'black': Colors.black,
};
