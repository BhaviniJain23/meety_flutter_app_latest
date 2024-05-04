// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:intl/intl.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

class BottomSheetService {
  static Future<String> showDateBottomSheet(
      BuildContext context,String text) async {
    DateTime date = DateTime(2000, 1, 1);

    if (text.isNotEmpty) {
      date = text.toDate();
    }
    var datePicked = await DatePicker.showSimpleDatePicker(
      reverse: true,
      pickerMode: DateTimePickerMode.datetime,
      context,
      titleText: "Select Your Birth Date",
      textColor: red,
      itemTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: black),
      initialDate: date,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: (18 * 365 + 5))),
      dateFormat: "dd/MM/yyyy",
      locale: DateTimePickerLocale.en_us,
    );
    if (datePicked != null) {
      return DateFormat('dd/MM/yyyy').format(datePicked);
    }

    return text;
  }

  static void showBottomSheet(
      {required BuildContext context,
      required Widget Function(BuildContext, void Function(void Function()))
          builder,
      Widget? heading,
      isDismissible = true,
      useRootNavigator = true}) {
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        isDismissible: isDismissible,
        useRootNavigator: useRootNavigator,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.25,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        backgroundColor: Colors.transparent,
        builder: (bottomSheet) {
          return StatefulBuilder(builder: (stateContext, setState) {
            return Container(
              decoration: const BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (heading == null) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        right: 8.0,
                        left: 8.0,
                      ),
                      child: Container(
                        height: 50,
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(bottomSheet);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    )
                  ] else ...[
                    heading
                  ],
                  Flexible(child: builder(bottomSheet, setState)),
                ],
              ),
            );
          });
        });
  }

  void showImagePicker(BuildContext context,
      {GestureTapCallback? onCameraTap, GestureTapCallback? onGalleryTap}) {
    Widget iconWithTitle(
        {required Widget icon,
        required String title,
        required GestureTapCallback onTap}) {
      return InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Material(
              elevation: 5,
              shape: const CircleBorder(),
              shadowColor: const Color(0xffff9999),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: red,
                ),
                child: icon,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: context.textTheme.titleMedium,
            )
          ],
        ),
      );
    }

    BottomSheetService.showBottomSheet(
        context: context,
        builder: (bottomSheet, state) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Wrap(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    iconWithTitle(
                        onTap: () {
                          Navigator.pop(bottomSheet);
                          if (onGalleryTap != null) {
                            onGalleryTap.call();
                          }
                          // imagePicker(UiString.gallery, index, provider);
                        },
                        icon: const Icon(
                          Icons.photo_library,
                          color: white,
                          size: 25,
                        ),
                        title: UiString.gallery),
                    iconWithTitle(
                        icon: const Icon(
                          Icons.camera_enhance,
                          color: white,
                          size: 25,
                        ),
                        title: UiString.camera,
                        onTap: () {
                          Navigator.pop(bottomSheet);
                          if (onCameraTap != null) {
                            onCameraTap.call();
                          }
                        }),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        });
  }
}
