
import 'package:contacts_service/contacts_service.dart';

class ContactModel {
  ContactModel({
    this.displayName,
    this.givenName,
    this.middleName,
    this.prefix,
    this.suffix,
    this.email,
    this.phone,
    this.androidAccountType,
    this.androidAccountTypeRaw,
    this.androidAccountName,
  });

  String? identifier,
      displayName,
      givenName,
      middleName,
      prefix,
      suffix,
      familyName,
      company,
      jobTitle;
  String? androidAccountTypeRaw, androidAccountName;
  AndroidAccountType? androidAccountType;
  String? email = "";
  String? phone = "";

  String initials() {
    return ((givenName?.isNotEmpty == true ? givenName![0] : ""))
        .toUpperCase();
  }

  ContactModel.fromMap(Map m) {
    identifier = m["identifier"];
    displayName = m["displayName"];
    givenName = m["givenName"];
    middleName = m["middleName"];
    prefix = m["prefix"];
    suffix = m["suffix"];
    androidAccountTypeRaw = m["androidAccountType"];
    androidAccountType = accountTypeFromString(androidAccountTypeRaw);
    androidAccountName = m["androidAccountName"];
    email = m["email"];
    phone = m["phone"];

  }

  ContactModel.fromContact(Contact m) {
    identifier = m.identifier;
    displayName = m.displayName;
    givenName = m.givenName;
    middleName = m.middleName;
    prefix = m.prefix;
    suffix = m.suffix;
    androidAccountTypeRaw = m.androidAccountTypeRaw;
    androidAccountType = accountTypeFromString(androidAccountTypeRaw);
    androidAccountName = m.androidAccountName;
    email = (m.emails?.isNotEmpty ?? false) ? m.emails?.first.value : '';
    phone = m.phones?.first.value ?? '';
  }

  ContactModel copyWith({
    String? displayName,
    String? givenName,
    String? middleName,
    String? prefix,
    String? suffix,
    String? email,
    String? phone,
    String? androidAccountTypeRaw,
    AndroidAccountType? androidAccountType,
    String? androidAccountName,
  }) {
    return ContactModel(
      displayName: displayName ?? this.displayName,
      givenName: givenName ?? this.givenName,
      middleName: middleName ?? this.middleName,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      androidAccountTypeRaw: androidAccountTypeRaw ?? this.androidAccountTypeRaw,
      androidAccountType: androidAccountType ?? this.androidAccountType,
      androidAccountName: androidAccountName ?? this.androidAccountName,
    );
  }

  static Map _toMap(ContactModel contact) {
    return {
      "identifier": contact.identifier,
      "displayName": contact.displayName,
      "givenName": contact.givenName,
      "middleName": contact.middleName,
      "prefix": contact.prefix,
      "suffix": contact.suffix,
      "androidAccountType": contact.androidAccountTypeRaw,
      "androidAccountName": contact.androidAccountName,
      "email": contact.email,
      "phone": contact.phone,
    };
  }

  Map toMap() {
    return ContactModel._toMap(this);
  }


  /// Returns true if all items in this contact are identical.
  @override
  bool operator ==(Object other) {
    return other is ContactModel &&
        company == other.company &&
        displayName == other.displayName &&
        givenName == other.givenName &&
        familyName == other.familyName &&
        identifier == other.identifier &&
        jobTitle == other.jobTitle &&
        androidAccountType == other.androidAccountType &&
        androidAccountName == other.androidAccountName &&
        middleName == other.middleName &&
        prefix == other.prefix &&
        suffix == other.suffix ;
  }


  AndroidAccountType? accountTypeFromString(String? androidAccountType) {
    if (androidAccountType == null) {
      return null;
    }
    if (androidAccountType.startsWith("com.google")) {
      return AndroidAccountType.google;
    } else if (androidAccountType.startsWith("com.whatsapp")) {
      return AndroidAccountType.whatsapp;
    } else if (androidAccountType.startsWith("com.facebook")) {
      return AndroidAccountType.facebook;
    }

    /// Other account types are not supported on Android
    /// such as Samsung, htc etc...
    return AndroidAccountType.other;
  }


  @override
  // ignore: unnecessary_overrides,
  int get hashCode => super.hashCode;



}


