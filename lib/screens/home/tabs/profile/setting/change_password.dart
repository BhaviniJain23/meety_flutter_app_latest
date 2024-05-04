import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/textfields.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordCont = TextEditingController();
  final TextEditingController _newPasswordCont = TextEditingController();
  final TextEditingController _confirmPasswordCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarX(
        title: UiString.changePasswordText,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                TextFieldX(
                  controller: _oldPasswordCont,
                  hint: UiString.passwordHintText,
                  label: UiString.passwordHintText,
                ),
                const SizedBox(height: 10),
                TextFieldX(
                  controller: _newPasswordCont,
                  hint: UiString.newPasswordHintText,
                  label: UiString.newPasswordHintText,
                ),
                const SizedBox(height: 10),
                TextFieldX(
                  controller: _confirmPasswordCont,
                  hint: UiString.confirmPasswordHintText,
                  label: UiString.confirmPasswordHintText,
                ),
                const SizedBox(height: 50),
                FillBtnX(onPressed: () async {}, text: UiString.update)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
