import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/widgets/core/responsive.dart';
import 'package:timeago/timeago.dart' as timeago;

extension ContextExtensions on BuildContext {
  // /// Is the device a phone
  // bool get isSmallScreen => MediaQuery.of(this).size.width < 650;

  // /// Is the device a tablet
  // bool get isMediumScreen =>
  //     MediaQuery.of(this).size.width >= 650 &&
  //     MediaQuery.of(this).size.width < 1100;

  // /// Is the device a desktop
  // bool get isBigScreen => MediaQuery.of(this).size.width >= 1100;

  /// Returns the current [ThemeData] of the [BuildContext].
  ThemeData get theme => Theme.of(this);

  /// Returns the current [MediaQueryData] of the [BuildContext].
  MediaQueryData get mq => MediaQuery.of(this);

  OverlayState? get overlay => Overlay.of(this);

  /// Returns the current [ModalRoute] args of the [BuildContext].
  dynamic get routeArgs => ModalRoute.of(this)!.settings.arguments;

  /// Returns the current [TextTheme] of the [BuildContext].
  TextTheme get textTheme => theme.textTheme;

  /// Returns the current [Size] of the [BuildContext].
  Size get mqSize => mq.size;

  /// Returns the current [MediaQueryData.size.width] of the [BuildContext].
  double get width => mq.size.width;

  /// Returns the current [MediaQueryData.size.height] of the [BuildContext].
  double get height => mq.size.height;

  /// Shows a [SnackBar] with the given [message] and [backgroundColor] acc
  /// to the [snackType].
  /// [duration] defaults to 2 seconds.
  /// [backgroundColor] defaults to [Colors.black].
  /// [backgroundRadius] defaults to 8.
  /// [textColor] defaults to [white].
  /// [snackType] defaults to [SnackType.info].
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    double backgroundRadius = 8,
    Color textColor = white,
    SnackType snackType = SnackType.info,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: isSmallScreen
          ? const EdgeInsets.all(8)
          : EdgeInsets.symmetric(horizontal: width * 0.3, vertical: 8),
      content: Text(
        message,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: black,
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(backgroundRadius),
      ),
    );

    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}

enum SnackType { success, error, warning, info }

extension on SnackType {
  // ignore: unused_element
  Color get color {
    switch (this) {
      case SnackType.success:
        return Colors.green;
      case SnackType.error:
        return Colors.red;
      case SnackType.warning:
        return Colors.orange;
      case SnackType.info:
        return Colors.black;
    }
  }
}

extension NumOperations on num {
  /// Returns random integer, where max range is
  /// based on the number applied upon.
  String randomInt() => Random().nextInt(toInt()).toString();
}

extension StringExtensions on String {
  /// Camelcase string extension
  String toCamelCase() {
    if (trim().isEmpty) return this;
    final wordList = split(UiString.space).toList();
    if (wordList.length > 1) {
      return wordList
          .takeWhile((String e) => e.trim().isNotEmpty)
          .map((String e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
          .toList()
          .join(UiString.space);
    }
    return wordList.first[0].toUpperCase() +
        wordList.first.substring(1).toLowerCase();
  }

  /// Normalize Firebase or Platform exception message
  String normalizeMessage() {
    if (trim().isEmpty) return this;
    return replaceAll(
      UiString.normalizationRegEx,
      UiString.space,
    ).toCamelCase();
  }

  /// Provide name initials of any provided string
  String initials() {
    if (trim().isEmpty) return this;
    final wordList = split(UiString.space).toList();
    if (wordList.length > 1) {
      return wordList
          .takeWhile((String e) => e.trim().isNotEmpty)
          .map((String e) => e[0].toUpperCase())
          .toList()
          .join();
    }
    return wordList.first[0].toUpperCase();
  }

  DateTime toDate() {
    assert(isNotEmpty, 'String must be non-empty to be able to parse');
    final dateTime = DateFormat('dd/MM/yyyy').parse(this);
    return dateTime;
  }

  bool isDateBefore() {
    assert(isNotEmpty, 'String must be non-empty to be able to parse');
    final dateTime = DateTime.parse(this).add(const Duration(days: 14));
    return DateTime.now().isBefore(dateTime);
  }

  bool isUrl() {
    if (startsWith("http://") || startsWith("https://")) {
      return true;
    }
    return false;
  }

  String extractNameFromFilePath() {
    return split("/").last;
  }

  bool isHtml() {
    RegExp htmlRegExp = RegExp(r"<[^>]*>");
    return htmlRegExp.hasMatch(this);
  }
}

extension DateExtensions on DateTime {
  String toStandardDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  String toDayMonthYear() {
    return DateFormat('EEE, dd MMM yyyy').format(this);
  }

  String toDayMonthYearTime() {
    return DateFormat('EEE, dd MMM yyyy, hh:mm aa').format(this);
  }

  String toTime() {
    return DateFormat('hh:mm aa').format(this);
  }

  String toStartTimeFormat() {
    return DateFormat.jm().format(this);
  }

  String toEndTimeFormat() {
    return DateFormat.jm().format(this);
  }

  String toEdMMMyAgoString() {
    DateTime? parsedDate =
        DateTime.parse(toIso8601String());
    return timeago.format(parsedDate,locale: 'en_short');
  }
}

extension DoubleExtension on double {
  String show() {

      var  newVal = showTwoDigit();

      if (newVal % 1 == 0) {
        return newVal.round().toString();
      } else {
        return newVal.toString();
      }
  }


  double showTwoDigit() {
    if (this % 1 == 0) {
      return double.tryParse(round().toStringAsFixed(0)) ?? 0;
    } else {
      return double.tryParse(toStringAsFixed(2)) ?? roundToDouble();
    }
  }

}


extension DurationExtension on Duration {
  String toMinSecond() {
    return toString().substring(2, 7);
  }
}

extension ListExtensions<T> on List<T> {
  bool equals(List list) {
    if (length != list.length) return false;
    return every((item) => list.contains(item));
  }

  bool containAllItem(List list) {
    return every((item) => list.contains(item));
  }

  void sortByCreatedAt() {
    sort((dynamic a, dynamic b) {
      if (a is! ChatUser1 ||
          b is! ChatUser1 ||
          a.lastMessage == null ||
          b.lastMessage == null) {
        return 0;
      }
      return b.lastMessage!.createdAt.compareTo(a.lastMessage!.createdAt);
    });
  }

  int countWhere(bool Function(dynamic) predicate) {
    return where(predicate).length;
  }

  List<T> addWhere(bool Function(T) test, T element) {
    int index = indexWhere(test);

    if (index == -1) {
      add(element);
    }
    return this;
  }

  List<T> updateAtIndex(int index, T model) {
    // Make sure the index is within the valid range
    if (index >= 0 && index < length) {
      // Create a new list with the elements of the original list
      List<T> updatedList = List.from(this);
      // Update the element at the specified index with the given model
      updatedList[index] = model;
      // Return the updated list
      return updatedList;
    } else {
      // If the index is out of range, return the original list unchanged
      return List.from(this);
    }
  }

  List<T> sortBySelected(List<T> selectedList) {
    if (isEmpty) {
      return selectedList;
    }

    List<T> remainingList = List.from(this);
    List<T> result = [];

    // Add selected elements to the result list
    for (var selected in selectedList) {
      if (remainingList.contains(selected)) {
        result.add(selected);
        remainingList.remove(selected);
      }
    }

    // Add remaining elements to the result list
    result.addAll(remainingList);

    return result;
  }
}

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

class Late<T> {
  final ValueNotifier<bool> _initialization = ValueNotifier(false);
  late T _val;

  Late([T? value]) {
    if (value != null) {
      this.val = value;
    }
  }

  get isInitialized {
    return _initialization.value;
  }

  T get val => _val;

  set val(T val) => this
    .._initialization.value = true
    .._val = val;
}

extension LateExtension<T> on T {
  Late<T> get late => Late<T>();
}

extension ExtLate on Late {
  Future<bool> get wait {
    Completer<bool> completer = Completer();
    _initialization.addListener(() async {
      completer.complete(_initialization.value);
    });

    return completer.future;
  }
}