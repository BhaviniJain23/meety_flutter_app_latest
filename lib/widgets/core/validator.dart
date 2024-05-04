import 'package:meety_dating_app/constants/ui_strings.dart';

import '../../constants/enums.dart';

mixin ValidateMixin {
  String? emptyValidator(value) {
    if (value!.isEmpty) {
      return 'Enter a value';
    } else {
      return null;
    }
  }

  String? nameValidator(value, message, {checkEmpty = false}) {
    final RegExp nameRegex = RegExp(r"^[a-zA-Z0-9' ]*$");
    if (!nameRegex.hasMatch(value)) {
      return message;
    } else if (checkEmpty) {
      if (value!.isEmpty) {
        return message;
      }
    }
    return null;
  }

  String? validateCVV(String value) {
    if (value.isEmpty) {
      return "Enter a CVV";
    }

    if (value.length < 3 || value.length > 4) {
      return "CVV is invalid";
    }
    return null;
  }

  String? postalCodeValidator(String? value, {bool isRequired = true}) {
    // RegExp regex = RegExp(r'^[a-zA-Z][a-zA-Z\s]*$');
    RegExp regex = RegExp(r'^[1-9][0-9]{5}$');
    if (value!.isNotEmpty && (value.length == 6) && regex.hasMatch(value)) {
      return null;
    } else if (!isRequired && value.isEmpty) {
      return null;
    } else {
      return 'Please enter valid postal code';
    }
  }

  bool containsOnlyAlphabets(String text) {
    final alphabeticRegex = RegExp(r'^[a-z|A-Z]+$');
    return alphabeticRegex.hasMatch(text);
  }

  String? validateName(String? value) {
    if (value!.isNotEmpty && containsOnlyAlphabets(value)) {
      return null;
    } else {
      return 'Please enter valid name';
    }
  }

  String? aboutValidator(value) {
    final RegExp instagramIdRegex = RegExp(r'^[a-zA-Z0-9._]{1,30}$');
    final RegExp phoneNumberRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (value!.isEmpty) {
      return UiString.enterYourAbout;
    } else if (instagramIdRegex.hasMatch(value) ||
        phoneNumberRegex.hasMatch(value)) {
      return 'Please enter a valid about.You can\'t add instagram id and phone number.';
    }
    return null;
  }

  String? emailValidator(value) {
    const pattern = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
    final regExp = RegExp(pattern);

    if (value!.isEmpty) {
      return 'Enter an email';
    } else if (!regExp.hasMatch(
      value.toString().trim(),
    )) {
      return 'Enter a valid email';
    } else {
      return null;
    }
  }

  String? phoneValidator(value) {
    const pattern2 = r'^[6-9]\d{9}$';
    final regNum = RegExp(pattern2);
    if (value == "") {
      return '* Required ';
    } else if (!regNum.hasMatch(value.toString())) {
      return 'Invalid mobile number';
    } else {
      return null;
    }
  }

  String? passwordValidator(value) {


    if (value!.isEmpty) {
      return 'Enter Password';
    } else if (value!.length < 8) {
      return 'Password must be of length 8';
    } else {
      return null;
    }
  }

  String? confirmPasswordValidator(value1, value2) {

    if (value2!.isEmpty || value1.isEmpty) {
      return 'Enter Confirm Password';
    } else if (value2! != value1!) {
      return 'Both Password must be same';
    } else {
      return null;
    }
  }

  String? inValidOtp(value) {
    if (value == "" || value == null) {
      return "Wrong OTP";
    } else {
      return null;
    }
  }
  String? requiredField(value) {
    if (value == "" || value == null) {
      return "Please enter the field(s).";
    } else {
      return null;
    }
  }
   String getCleanedNumber(String text) {
    RegExp regExp = RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

   CardType? getCardTypeFrmNumber(String input) {
    CardType cardType;
    if (input.startsWith(RegExp(
        r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
      cardType = CardType.Master;
    } else if (input.startsWith(RegExp(r'[4]'))) {
      cardType = CardType.Visa;
    } else if (input.startsWith(RegExp(r'((34)|(37))'))) {
      cardType = CardType.AmericanExpress;
    } else if (input.startsWith(RegExp(r'((6[45])|(6011))'))) {
      cardType = CardType.Discover;
    } else if (input.startsWith(RegExp(r'((30[0-5])|(3[89])|(36)|(3095))'))) {
      cardType = CardType.DinersClub;
    } else if (input.startsWith(RegExp(r'(352[89]|35[3-8][0-9])'))) {
      cardType = CardType.Jcb;
    } else {
      return null;
    }
    return cardType;
  }

  String? validateCardNum(String? input) {
    if (input == null || input.isEmpty) {
      return "This field is required";
    }
    input = getCleanedNumber(input);
    if (input.length < 8) {
      return "Card is invalid";
    }
    int sum = 0;
    int length = input.length;
    for (var i = 0; i < length; i++) {
      // get digits in reverse order
      int digit = int.parse(input[length - i - 1]);
// every 2nd number multiply with 2
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }
    if (sum % 10 == 0) {
      return null;
    }
    return "Card is invalid";
  }
}
