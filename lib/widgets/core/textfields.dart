import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';

import 'bottomsheets.dart';

class TextFieldX extends StatefulWidget {
  const TextFieldX({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.hintStyle,
    this.leading,
    this.label,
    this.trailing,
    this.fillColor,
    this.validator,
    this.onChanged,
    this.maxlines,
    this.maxlength,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final bool obscureText;
  final TextStyle? hintStyle;
  final TextInputType keyboardType;
  final Widget? leading;
  final Widget? trailing;
  final Color? fillColor;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int? maxlines;
  final int? maxlength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<TextFieldX> createState() => _TextFieldXState();
}

class _TextFieldXState extends State<TextFieldX> {
  bool isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText ? isPasswordVisible : widget.obscureText,
      // minLines: 1,
      style: TextStyle(
        color: 0xff002055.toColor,
      ),
      cursorColor: 0xffE94057.toColor,
      validator: widget.validator,
      maxLines: widget.maxlines,
      maxLength: widget.maxlength,
      enableIMEPersonalizedLearning: false,

      decoration: InputDecoration(
        fillColor: widget.fillColor ?? context.theme.primaryColor,
        filled: widget.fillColor != null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        prefixIcon: widget.leading,
        suffixIcon: widget.trailing ??
            (!widget.obscureText
                ? null
                : IconButton(
                    onPressed: () {
                      isPasswordVisible = !isPasswordVisible;
                      setState(() {});
                    },
                    icon: !isPasswordVisible
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off_rounded))),
        hintText: widget.hint,
        labelText: widget.label,
        hintStyle: widget.hintStyle,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: 0xffE94057.toColor,
            width: 1,
          ),
        ),
        alignLabelWithHint: (widget.maxlines ?? 0) > 2 ? true : false,
        focusColor: 0xffE94057.toColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: 0xffD9D9D9.toColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: 0xffD9D9D9.toColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: 0xffD9D9D9.toColor,
          ),
        ),
      ),
      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters ?? [],
    );
  }
}

class DateTextFieldX extends StatelessWidget {
  const DateTextFieldX({
    super.key,
    required this.controller,
    required this.hint,
    this.hintStyle,
    this.leading,
    this.label,
    this.trailing,
    this.fillColor,
    this.onChanged,
    this.validator,
    this.maxlines,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final TextStyle? hintStyle;
  final Widget? leading;
  final Widget? trailing;
  final Color? fillColor;
  final String? Function(String?)? validator;
  final int? maxlines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      // minLines: 1,
      style: TextStyle(
        color: 0xff002055.toColor,
      ),
      keyboardType: TextInputType.datetime,
      cursorColor: 0xffE94057.toColor,
      validator: validator,
      maxLines: maxlines,
      readOnly: true,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
        LengthLimitingTextInputFormatter(10),
        _DateFormatter(),
      ],
      onChanged: onChanged,
      onTap: () async {
        var stringVal = await BottomSheetService.showDateBottomSheet(
            context, controller.text);
        controller.text = stringVal;
        if (onChanged != null) {
          onChanged!(controller.text);
        }
      },
      decoration: InputDecoration(
        fillColor: fillColor ?? context.theme.primaryColor,
        filled: fillColor != null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        prefixIcon: leading,
        suffixIcon: trailing ??
            IconButton(
              onPressed: () async {
                var stringVal = await BottomSheetService.showDateBottomSheet(
                    context, controller.text);
                controller.text = stringVal;
                if (onChanged != null) {
                  onChanged!(controller.text);
                }
              },
              icon: const Icon(Icons.calendar_month_outlined),
            ),
        hintText: hint,
        labelText: label,
        hintStyle: hintStyle ??
            TextStyle(
                color: 0xff868D95.toColor,
                fontWeight: FontWeight.w400,
                fontSize: 14),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: 0xffE94057.toColor,
            width: 1,
          ),
        ),
        focusColor: 0xffE94057.toColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: 0xffD9D9D9.toColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: 0xffD9D9D9.toColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: 0xffD9D9D9.toColor,
          ),
        ),
      ),
    );
  }
}

class DropDownX extends StatelessWidget {
  const DropDownX({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.items,
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 28,
      ),
      decoration: InputDecoration(
        suffixIconColor: Colors.red,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        focusColor: context.theme.primaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        // labelText: 'Title',
      ),
      dropdownColor: white,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      value: controller.text,
      onChanged: (value) {
        if (value == null) {
          return;
        }
        onChanged(value);
      },
      items: [
        const DropdownMenuItem(
          value: '',
          child: Text('Select'),
        ),
        ...List.generate(items.length, (index) {
          return DropdownMenuItem(
            value: items[index],
            child: Text(
              items[index],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: controller.text == items[index]
                    ? context.theme.primaryColor
                    : null,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class RequiredTitle extends StatelessWidget {
  const RequiredTitle({
    super.key,
    required this.title,
    this.fontSize,
  });

  final String title;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: context.textTheme.titleMedium!.copyWith(
              fontSize: fontSize,
            ),
          ),
          TextSpan(
            text: '*',
            style: context.textTheme.titleMedium!.copyWith(
              color: Colors.red,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue prevText, TextEditingValue currText) {
    int selectionIndex;

    // Get the previous and current input strings
    String pText = prevText.text;
    String cText = currText.text;
    // Abbreviate lengths
    int cLen = cText.length;
    int pLen = pText.length;

    DateTime before18 =
        DateTime.now().subtract(const Duration(days: (18 * 365 + 5)));
    List<String> today = before18.year.toString().split("");

    if (cLen == 1) {
      // Can only be 0, 1, 2 or 3
      if (int.parse(cText) > 3) {
        // Remove char
        cText = '';
      }
    } else if (cLen == 2 && pLen == 1) {
      // Days cannot be greater than 31
      int dd = int.parse(cText.substring(0, 2));
      if (dd == 0 || dd > 31) {
        // Remove char
        cText = cText.substring(0, 1);
      } else {
        // Add a / char
        cText += '/';
      }
    } else if (cLen == 3 && pLen == 2) {
      if (cText.substring(2, 3) != '/') {
        cText = '${cText.substring(0, 2)}/${cText.substring(2, 3)}';
        if (int.parse(cText.substring(3, 4)) > 1 &&
            int.parse(cText.substring(3, 4)) <= 9) {
          // Remove char
          cText = '${cText.substring(0, 3)}0${cText.substring(3, 4)}';
          int mm = int.parse(cText.substring(3, 5));
          if (mm == 0 || mm > 12) {
            // Remove char
            cText = cText.substring(0, 4);
          } else {
            // Add a / char
            cText += '/';
          }
        } else if (int.parse(cText.substring(3, 4)) == 0) {
        } else {
          cText = cText.substring(0, 4);
        }
      }
    } else if (cLen == 4) {
      // Can only be 0 or 1
      if (int.parse(cText.substring(3, 4)) > 1 &&
          int.parse(cText.substring(3, 4)) <= 9) {
        // Remove char
        cText = '${cText.substring(0, 3)}0${cText.substring(3, 4)}';
        int mm = int.parse(cText.substring(3, 5));
        if (mm == 0 || mm > 12) {
          // Remove char
          cText = cText.substring(0, 4);
        } else {
          // Add a / char
          cText += '/';
        }
      } else if (int.parse(cText.substring(3, 4)) == 0) {
      } else {
        cText = cText.substring(0, 4);
      }
    } else if (cLen == 5 && pLen == 4) {
      // Month cannot be greater than 12
      int mm = int.parse(cText.substring(3, 5));
      if (mm == 0 || mm > 12) {
        // Remove char
        cText = cText.substring(0, 4);
      } else {
        // Add a / char
        cText += '/';
      }
    } else if ((cLen == 3 && pLen == 4) || (cLen == 6 && pLen == 7)) {
      // Remove / char
      cText = cText.substring(0, cText.length - 1);
    } else if (cLen == 3 && pLen == 2) {
      if (int.parse(cText.substring(2, 3)) > 1) {
        // Replace char
        cText = '${cText.substring(0, 2)}/';
      } else {
        // Insert / char
        cText =
            '${cText.substring(0, pLen)}/${cText.substring(pLen, pLen + 1)}';
      }
    } else if (cLen == 6 && pLen == 5) {
      // Can only be 1 or 2 - if so insert a / char
      int y1 = int.parse(cText.substring(5, 6));

      if (y1 < 1 || y1 > int.parse(today[0])) {
        // Replace char
        cText = '${cText.substring(0, 5)}/';
      } else {
        // Insert / char
        cText = '${cText.substring(0, 5)}/${cText.substring(5, 6)}';
      }
    } else if (cLen == 7) {
      // Can only be 1 or 2
      int y1 = int.parse(cText.substring(6, 7));

      if (y1 < 1 || y1 > int.parse(today[0])) {
        // Remove char
        cText = cText.substring(0, 6);
      }
    } else if (cLen == 8) {
      // Can only be 19 or 20
      int y2 = int.parse(cText.substring(6, 8));

      if (y2 < 19 || y2 > int.parse(today[0] + today[1])) {
        // Remove char
        cText = cText.substring(0, 7);
      }
    } else if (cLen == 10) {
      // Can only be 19 or 20
      int y2 = int.parse(cText.substring(6, 10));

      if (y2 > int.parse(today.join())) {
        // Remove char
        cText = cText.substring(0, 9);
      } else if (before18.difference(cText.toDate()).inDays < 0) {
        cText = cText.substring(0, 9);
      }
    }

    selectionIndex = cText.length;
    return TextEditingValue(
      text: cText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class EmojiInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Filter out any emoji characters
    final filteredText =
        newValue.text.replaceAll(RegExp(r'[^\w\s#@&.,?!()-_]+'), '');

    // Return the new text value with the emoji characters removed
    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}
