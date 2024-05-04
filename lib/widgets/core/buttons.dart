import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';

class FillBtnX extends StatefulWidget {
  const FillBtnX({
    super.key,
    required this.onPressed,
    required this.text,
    this.radius,
    this.color,
    this.textStyle,
    this.width,
    this.elevation,
    this.shadowColor,
    this.textColor,
    this.leading,
    this.isDisabled = false
  });

  final AsyncCallback onPressed;
  final String text;
  final double? radius;
  final double? width;

  final double? elevation;
  final Color? color;
  final bool isDisabled;

  final Color? shadowColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final Widget? leading;

  @override
  State<FillBtnX> createState() => _FillBtnXState();
}

class _FillBtnXState extends State<FillBtnX> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color,
          gradient: widget.color != null ?  null :
          widget.isDisabled ? disabledGradient : buttonGradient,
          borderRadius: BorderRadius.circular(widget.radius ?? 15),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.transparent.withOpacity(0.38),
            disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
            shadowColor: Colors.transparent,
            elevation: 0,
          ),
          onPressed: () async {
            try {
              if(!isLoading){
                setState(() {
                  isLoading = true;
                });
                await widget.onPressed();
                if (!mounted) {
                  return;
                }
                setState(() {
                  isLoading = false;
                });
              }
            } finally {
              // // log(e.toString());
              if(mounted){
                setState(() {
                  isLoading = false;
                });
              }
            }
          },
          child: isLoading
              ? LoadingAnimationWidget.staggeredDotsWave(
                color: white,
                size: 35,
              )
              : Row(
                  mainAxisAlignment: widget.leading != null
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (widget.leading != null) widget.leading!,
                    if (widget.leading != null) const SizedBox(width: 20),
                    Text(
                      widget.text,
                      style: widget.textStyle?.copyWith(
                            color: widget.textColor ?? white,
                          ) ??
                          context.textTheme.titleMedium!.copyWith(
                              color: widget.textColor ?? white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


class IconButtonX extends StatelessWidget {
  const IconButtonX({
    super.key,
    required this.onPressed,
    this.radius,
    this.color,
    this.elevation,
    this.shadowColor,
    this.padding,
    required this.icon,
  });

  final AsyncCallback onPressed;
  final double? radius;
  final EdgeInsets? padding;

  final double? elevation;
  final Color? color;

  final Color? shadowColor;
  final Widget icon;


  @override
  Widget build(BuildContext context) {
    return     Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: OutlinedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            const CircleBorder(
            ),
          ),
          side: MaterialStateProperty.all(
              BorderSide(color: color ?? Colors.white)),

          padding: MaterialStateProperty.all(
            EdgeInsets.zero,
          ),
          backgroundColor: MaterialStateProperty.all(color ?? white),
        ),
        onPressed: onPressed ,
        child: icon,
      ),
    );
  }
}

class CheckBtnX<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String text;
  final double height;
  final ValueChanged<T?> onChanged;

  const CheckBtnX({
    super.key,
    required this.value,
    required this.groupValue,
    required this.text,
    required this.onChanged,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: isSelected ? red : grey,
              )),
          backgroundColor: isSelected ? red : white,
          elevation: 0,
        ),
        onPressed: () => onChanged(value),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: context.textTheme.titleMedium!.copyWith(
                  color: isSelected ? white : Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.1),
            ),
            Icon(
              Icons.check,
              color: isSelected ? white : grey,
            )
          ],
        ),
      ),
    );
  }
}

class MultipleCheckBtnX<T> extends StatelessWidget {
  final T value;
  final bool isSelected;
  final String text;
  final double height;
  final ValueChanged<T?> onChanged;

  const MultipleCheckBtnX(
      {super.key,
      required this.value,
      required this.isSelected,
      required this.text,
      required this.onChanged,
      this.height = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width * 0.5 -30,
      height: 45,
      child: InkWell(
        onTap: () => onChanged(value),
        child: Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? red :grey.toMaterialColor.shade100),
            boxShadow:  <BoxShadow>[
              BoxShadow(
                  color:isSelected ? red :grey.toMaterialColor.shade100,
                  blurRadius: 3.0,
                  offset: const Offset(0.0, 0.75)
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: context.textTheme.titleMedium!.copyWith(
                    color: isSelected ? red : Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.1),
              ),
              if(isSelected)...[

                Icon(
                  Icons.check,
                  color: isSelected ? red : grey,
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// Outline button with rounded corners.
class OutLineBtnX extends StatelessWidget {
  const OutLineBtnX({
    super.key,
    required this.onPressed,
    this.text,
    this.radius = 4,
    this.color,
    this.textColor,
    this.fillColor,
    this.fontWeight,
    this.child,
    this.borderRadius,
  }) : assert(text != null || child != null, 'text or child is required');

  final VoidCallback onPressed;
  final String? text;
  final double radius;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? fillColor;
  final Color? textColor;
  final FontWeight? fontWeight;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(radius),
            ),
          ),
          side: MaterialStateProperty.all(
            BorderSide(
              color: color ?? Colors.black,
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
            fillColor ?? Colors.transparent,
          ),
          minimumSize: MaterialStateProperty.all(const Size.fromHeight(56)),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed)) {
              return red.toMaterialColor.withOpacity(.1);
            }
            return Colors.transparent;
          })),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: child ??
            Text(
              text!,
              style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? color,
                  fontWeight: fontWeight ?? FontWeight.w700,
                  letterSpacing: 0.1),
            ),
      ),
    );
  }
}

/// Circular button with a icon inside.
class OutLineBtnX2 extends StatelessWidget {
  const OutLineBtnX2({
    super.key,
    required this.onPressed,
    this.icon,
    this.child,
    this.elevation,
    this.bgColor,
    this.iconColor,
    this.radius,
  }) : assert(
          icon != null || child != null,
          'Either one of icon or child must not be null',
        );

  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? child;
  final Color? bgColor;
  final Color? iconColor;
  final double? radius;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(
            radius != null
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius!),
                  )
                : const CircleBorder(
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
              bgColor ?? Colors.transparent),
          padding: MaterialStateProperty.all(
            EdgeInsets.zero,
          ),
          elevation: MaterialStateProperty.all(elevation ?? 0)),
      onPressed: onPressed,
      child: child ??
          Icon(
            icon,
            color: iconColor ?? 0xff002055.toColor,
            size: 18,
          ),
    );
  }
}

class SocialBtnX extends StatelessWidget {
  const SocialBtnX({super.key, required this.icon, required this.onPressed});

  final Widget icon;
  final AsyncCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      color: white.toMaterialColor.shade50,
      child: SizedBox(
        height: ResponsiveDesign.height(65, context),
        width: ResponsiveDesign.width(65, context),
        child: OutlinedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: red.toMaterialColor,
                  strokeAlign: 5
                )
              ),
            ),
            overlayColor: MaterialStateProperty.all(whitesmoke),

          ),
          onPressed: onPressed,
          child: icon,
        ),
      ),
    );
  }
}

class BackBtnX extends StatelessWidget {
  const BackBtnX({super.key, this.iconColor, this.bgColor, this.onPressed, this.padding});
  final Color? iconColor;
  final Color? bgColor;
  final GestureTapCallback? onPressed;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: OutlinedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
           const CircleBorder(),
          ),
          padding: MaterialStateProperty.all(
            EdgeInsets.zero,
          ),
          backgroundColor: MaterialStateProperty.all(bgColor ?? white),
        ),
        onPressed: onPressed ??
            () {
              sl<NavigationService>().pop();
            },
        child: Icon(
          Icons.arrow_back_ios_new,
          color: iconColor ?? black,
          size: 20,
        ),
      ),
    );
  }
}

class UnderlineTextBtnX extends StatelessWidget {
  const UnderlineTextBtnX({
    super.key,
    required this.onPressed,
    required this.text,
    this.color,
    this.fontSize,
    this.textStyle,
  });
  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final double? fontSize;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Text(
          text,
          style: textStyle?.copyWith(
                color: color,
                decoration: TextDecoration.underline,
              ) ??
              context.textTheme.titleMedium!.copyWith(
                  color: color ?? context.theme.primaryColor,
                  // decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize ?? 14),
        ),
      ),
    );
  }
}

class TextBtnX extends StatelessWidget {
  const TextBtnX({
    super.key,
    required this.onPressed,
    required this.text,
    this.color,
    this.fontSize,
    this.textStyle,
    this.child,
    this.radius = 4,
  });
  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final double? fontSize;
  final double? radius;
  final TextStyle? textStyle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          radius != null
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius!),
                )
              : const CircleBorder(),
        ),
        padding: MaterialStateProperty.all(
          EdgeInsets.zero,
        ),
      ),
      onPressed: onPressed,
      child: child ??
          Text(
            text,
            style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1),
          ),
    );
  }
}
