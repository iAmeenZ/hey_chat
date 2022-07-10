import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget? child;
  final Color? splashColor;
  final double? width;
  final double? height;
  final Color? color;
  final Color? shadowColor;
  final EdgeInsetsGeometry? padding;
  final double? shadowRadius;
  final VoidCallback? onTap;
  final Offset? shadowOffset;
  final bool? isShadow;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? hoverColor;
  const CustomButton({Key? key, this.onTap, required this.child, this.color, this.margin, this.hoverColor, this.shadowOffset, this.shadowColor, this.borderRadius, this.isShadow, this.shadowRadius, this.padding, this.width, this.height, this.splashColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        margin: margin ?? EdgeInsets.all(25),
        child: Ink(
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            boxShadow: isShadow == true || isShadow == null ? [
              BoxShadow(
                color: shadowColor ?? Colors.black.withOpacity(0.1),
                blurRadius: shadowRadius != null ? shadowRadius! + 7 : 7,
                spreadRadius: shadowRadius != null ? shadowRadius! + 2 : 2,
                offset: shadowOffset ?? Offset(0,3)
              )
            ] : null
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            splashColor: splashColor ?? Colors.grey.shade400,
            hoverColor: hoverColor,
            onTap: onTap,
            child: Container(
              padding: padding ?? EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}