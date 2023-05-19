import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bobi_pay_out/model/constant.dart';

class SizeBoxIconButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget? icon;
  final double? height;
  const SizeBoxIconButton({super.key, this.onPressed, this.icon, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height ?? 30.w,
        child: IconButton(
          onPressed: onPressed,
          icon: icon ??
              const Icon(
                Icons.refresh,
                size: 20,
                color: mainColor,
              ),
        ));
  }
}
