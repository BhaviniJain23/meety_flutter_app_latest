import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class CircularProgressDialog {
  /// [_progress] Listens to the value of progress.
  //  Not directly accessible.
  final ValueNotifier _progress = ValueNotifier(0);

  /// [_msg] Listens to the msg value.
  // Value assignment is done later.
  final ValueNotifier _msg = ValueNotifier('');

  /// [_dialogIsOpen] Shows whether the dialog is open.
  //  Not directly accessible.
  bool _dialogIsOpen = false;

  /// [_context] Required to show the alert.
  // Can only be accessed with the constructor.
  late BuildContext _context;

  CircularProgressDialog({required context}) {
    _context = context;
  }

  /// [update] Pass the new value to this method to update the status.
  //  Msg not required.
  void update({required int value, String? msg}) {
    if (value > 0) {
      _progress.value = value;
    }
    if (msg != null) _msg.value = msg;
  }

  /// [close] Closes the progress dialog.
  void close() {
    if (_dialogIsOpen) {
      Navigator.pop(_context);
      _dialogIsOpen = false;
    }
  }

  ///[isOpen] Returns whether the dialog box is open.
  bool isOpen() {
    return _dialogIsOpen;
  }

  /// [max] Assign the maximum value of the upload. @required
  //  Dialog closes automatically when its progress status equals the max value.

  /// [msg] Show a message @required

  /// [barrierDismissible] Determines whether the dialog closes when the back button or screen is clicked.
  // True or False (Default: false)

  /// [msgMaxLines] Use when text value doesn't fit
  // Int (Default: 1)

  /// [completed] Widgets that will be displayed when the process is completed are assigned through this class.
  // If an assignment is not made, the dialog closes without showing anything.

  show({
    required int max,
    required String msg,
    Completed? completed,
    Color backgroundColor = Colors.white,
    Color barrierColor = Colors.transparent,
    Color progressValueColor = Colors.blueAccent,
    Color progressBgColor = Colors.blueGrey,
    Color valueColor = Colors.black87,
    Color msgColor = Colors.black87,
    TextAlign msgTextAlign = TextAlign.center,
    FontWeight msgFontWeight = FontWeight.bold,
    FontWeight valueFontWeight = FontWeight.normal,
    double valueFontSize = 12.0,
    double msgFontSize = 17.0,
    int msgMaxLines = 1,
    double elevation = 5.0,
    double borderRadius = 15.0,
    bool barrierDismissible = false,
    bool hideValue = false,
  }) {
    _dialogIsOpen = true;
    _msg.value = msg;
    return showDialog(
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      context: _context,
      builder: (context) => WillPopScope(
        child: AlertDialog(
          backgroundColor: backgroundColor,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius),
            ),
          ),
          insetPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.3,
              vertical: MediaQuery.of(context).size.height * 0.3),
          content: ValueListenableBuilder(
            valueListenable: _progress,
            builder: (BuildContext context, dynamic value, Widget? child) {
              return value == max && completed != null
                  ? Image(
                      width: 40,
                      height: 40,
                      image: completed.completedImage ??
                          const AssetImage(
                            "assets/completed.png",
                            package: "sn_progress_dialog",
                          ),
                    )
                  : SizedBox(
                      height: 120.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularPercentIndicator(
                            radius: 40.0,
                            lineWidth: 4.0,
                            percent: (value / max),
                            center: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                '${_progress.value}%',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: valueColor,
                                  fontWeight: valueFontWeight,
                                ),
                              ),
                            ),
                            progressColor: progressValueColor,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            value == max && completed != null
                                ? completed.completedMsg
                                : _msg.value,
                            textAlign: msgTextAlign,
                            maxLines: msgMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              color: msgColor,
                              letterSpacing: 0.1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ));
            },
          ),
        ),
        onWillPop: () {
          if (barrierDismissible) {
            _dialogIsOpen = false;
          }
          return Future.value(barrierDismissible);
        },
      ),
    );
  }
}
