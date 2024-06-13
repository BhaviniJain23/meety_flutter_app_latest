import 'package:flutter/material.dart';
import '../../../../../widgets/utils/extensions.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/constants.dart';
import '../../../../../constants/ui_strings.dart';
import '../../../../../data/repository/user_repo.dart';
import '../../../../../models/user.dart';
import '../../../../../services/shared_pref_manager.dart';
import '../../../../../services/singleton_locator.dart';
import '../../../../../widgets/core/alerts.dart';
import '../../../../../widgets/core/appbars.dart';
import '../../../../../widgets/core/buttons.dart';
import '../../../../auth/widgets/texfields.dart';

class DeleteAccountScreen extends StatefulWidget {
  final bool isDeactivate;
  const DeleteAccountScreen({Key? key, required this.isDeactivate})
      : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  User? loginUser;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  ValueNotifier<int> isVerify = ValueNotifier(-1);
  static List<String> deactivateDaysList = [
    "15 ${UiString.days}",
    "20 ${UiString.days}",
    "25 ${UiString.days}",
    "30 ${UiString.days}",
    "50 ${UiString.days}",
    "100 ${UiString.days}",
  ];
  ValueNotifier<String> selectedDays = ValueNotifier(deactivateDaysList[0]);

  @override
  void initState() {
    loginUser = sl<SharedPrefsManager>().getUserDataInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whitesmoke,
      appBar: const AppBarX(
        title: UiString.deleteAccount,
        height: 60,
        elevation: 2.5,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isDeactivate
                    ? 'Deactivate your account will:'
                    : 'Deleting your account will:',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: red),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                widget.isDeactivate
                    ? '\u2022 Your account information, including personal data and preferences, will be deleted until and unless ypu couldn\'t logged in.'
                    : '\u2022 Deleting your identify info and profile photo.',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                widget.isDeactivate
                    ? '\u2022 Active subscriptions, purchases, or services linked to your account will be terminated.'
                    : '\u2022 Delete your subscription from the account.',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.isDeactivate
                    ? "If you understand the consequences and still wish to deactivate your account, please enter your password below to confirm:"
                    : 'When you delete your account, you won’t be able to retrieve the content or information after it. Once you \'ll submit, your account will no longer be visible on Meety.',
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ValueListenableBuilder(
                  valueListenable: isVerify,
                  builder: (BuildContext context, value, _) {
                    if (value == 1) {
                      return const SizedBox();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!widget.isDeactivate) ...[
                          const Text(
                            'To delete account, enter below detail:',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 15,
                        ),
                        if (widget.isDeactivate) ...[
                          ValueListenableBuilder<String>(
                            valueListenable: selectedDays,
                            builder: (context, value, child) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: DropdownButton<String>(
                                  hint: const Text(
                                      "Select user who paid the bill"),
                                  value: selectedDays.value,
                                  isExpanded: true,
                                  style: const TextStyle(color: black),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      selectedDays.value = newValue;
                                    }
                                  },
                                  items: deactivateDaysList
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                        Row(
                          children: [
                            if (loginUser!.loginType.toString() ==
                                Constants.normalLogin) ...[
                              Expanded(
                                child: PassTextField(
                                  textController: _password,
                                  showIcon: false,
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                  child:
                                      EmailTextField(textController: _email)),
                            ],
                            const SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              height: 48,
                              child: FillBtnX(
                                  onPressed: () async {
                                    verifyUser(context);
                                  },
                                  width: 110,
                                  radius: 8,
                                  color: red,
                                  text: UiString.submitText),
                            )
                          ],
                        )
                      ],
                    );
                  }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: isVerify,
          builder: (BuildContext context, value, _) {
            if (value != 1) {
              return const SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: FillBtnX(
                  onPressed: () async {
                    if (value == 1) {
                      showDeleteAccount();
                    }
                  },
                  color: value == 1 ? null : grey,
                  text: UiString.deleteAccount),
            );
          }),
    );
  }

  void showDeleteAccount() {
    AlertService.showAlertMessageWithTwoBtn(
        context: context,
        alertTitle: "Are you sure you want to delete your account?",
        alertMsg:
            "If you delete your account, you will permanently lose your profile, messages, photos, and matches. If you delete your account, this action cannot be undone.",
        positiveText: "Delete",
        negativeText: "Cancel",
        yesTap: () {
          deleteAccount(context);
        });
  }

  void showDeactivateAccount() {
    AlertService.showAlertMessageWithTwoBtn(
        context: context,
        alertTitle: "Are you sure you want to deactivate your account?",
        alertMsg:
            "Your account information, including personal data and preferences, will be deleted until and unless ypu couldn't logged in.\n",
        positiveText: "Deactivate",
        negativeText: "Cancel",
        yesTap: () {
          deleteAccount(context);
        });
  }

  Future<void> verifyUser(BuildContext context) async {
    try {
      Map<String, dynamic> apiResponse = await UserRepository().verifyUser(
        email: _email.text,
        password: _password.text,
      );

      if (apiResponse[UiString.successText]) {
        if (apiResponse[UiString.dataText] != null &&
            apiResponse[UiString.dataText].containsKey('is_verify')) {
          isVerify.value = apiResponse[UiString.dataText]['is_verify'];
          if (isVerify.value != 1) {
            Future.delayed(Duration.zero, () {
              context.showSnackBar("You have enter wrong details");
            });
          }
        }
      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      Map<String, dynamic> apiResponse = {};
      if (widget.isDeactivate) {
        apiResponse =
            await UserRepository().deactivateAccount(days: selectedDays.value);
      } else {
        apiResponse = await UserRepository().deleteAccount();
      }
      if (apiResponse[UiString.successText]) {
        Future.delayed(const Duration(seconds: 0), () {
          sl<SharedPrefsManager>().logoutUser(context);
        });
      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(UiString.error);
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
