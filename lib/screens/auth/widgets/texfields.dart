import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/widgets/core/textfields.dart';
import 'package:meety_dating_app/widgets/core/validator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';

class EmailTextField extends StatelessWidget with ValidateMixin {
  const EmailTextField({
    super.key,
    required TextEditingController textController,  this.onChanged,
  }) : _textController = textController;

  final TextEditingController _textController;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFieldX(
      hint: UiString.enterYourEmailAddress,
      keyboardType: TextInputType.emailAddress,
      controller: _textController,
      validator: emailValidator,
      onChanged: onChanged,
    );
  }
}

class PassTextField extends StatelessWidget with ValidateMixin {
  const PassTextField(
      {super.key,
      required TextEditingController textController,
      this.showIcon = true})
      : _textController = textController;

  final TextEditingController _textController;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return TextFieldX(
      hint: UiString.enterYourPassword,
      controller: _textController,
      obscureText: true,
      maxlines: 1,
      validator: passwordValidator,
      trailing: showIcon ? null : const SizedBox(),
    );
  }
}

class ConfirmPassTextField extends StatelessWidget with ValidateMixin {
  const ConfirmPassTextField(
      {super.key,
      required TextEditingController textController,
      required TextEditingController passwordTextController,
      this.showIcon = true})
      : _textController = textController,
        _passwordTextController = passwordTextController;

  final TextEditingController _textController;
  final TextEditingController _passwordTextController;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return TextFieldX(
      hint: UiString.enterYourConfirmPassword,
      controller: _textController,
      obscureText: true,
      maxlines: 1,
      validator: (value) {
        return confirmPasswordValidator(_passwordTextController.text, value);
      },
      trailing: showIcon ? null : const SizedBox(),
    );
  }
}

class PhoneTextField extends StatelessWidget with ValidateMixin {
  const PhoneTextField(
      {super.key,
      required TextEditingController textController,
      this.onChanged,
      this.leading,
      this.isRequired = true,
      this.validator})
      : _textController = textController;

  final TextEditingController _textController;
  final ValueChanged<String>? onChanged;
  final Widget? leading;
  final bool? isRequired;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _textController,
      keyboardType: const TextInputType.numberWithOptions(),
      decoration: InputDecoration(
        prefixIcon: leading,
        fillColor: context.theme.primaryColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintText: UiString.phoneText,
        //labelText: UiString.phoneText,
        hintStyle: TextStyle(
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: 0xffE94057.toColor,
            width: 1,
          ),
        ),
        counter: Container(),
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
        errorStyle: const TextStyle(
            color: Colors.red, fontWeight: FontWeight.w400, fontSize: 14),
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: validator ??
          (value) {
            if (isRequired ?? true) {
              return phoneValidator(value);
            }
            return (!(isRequired ?? true) &&
                    (value == null || value.toString().isEmpty))
                ? null
                : phoneValidator(value);
          },
      onChanged: onChanged,
    );
  }
}

class KeyboardKey extends StatelessWidget {
  final dynamic label;
  final dynamic value;
  final ValueSetter<dynamic> onTap;

  const KeyboardKey({
    Key? key,
    required this.label,
    required this.value,
    required this.onTap,
  }) : super(key: key);

  renderLabel() {
    if (label is Widget) {
      return label;
    }

    return Text(
      label,
      style: const TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: value == ''
          ? null
          : () {
              onTap(value);
            },
      child: AspectRatio(
        aspectRatio: 2,
        child: Center(
          child: renderLabel(),
        ),
      ),
    );
  }
}
