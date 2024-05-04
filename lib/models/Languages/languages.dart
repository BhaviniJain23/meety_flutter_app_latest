import 'languages.g.dart';

export 'languages.g.dart';

class Language {
  Language(this.isoCode, this.name, this.s);

  final String name;
  final String isoCode;
  final String s;

  Language.fromMap(Map<String, String> map)
      : name = map['name']!,
        isoCode = map['isoCode']!,
        s = map['nativeName']!;

  /// Returns the Language matching the given ISO code from the standard list.
  factory Language.fromIsoCode(String isoCode) =>
      Languages.defaultLanguages.firstWhere((l) => l.isoCode == isoCode);

  @override
  bool operator ==(other) =>
      other is Language &&
      name == other.name &&
      isoCode == other.isoCode &&
      s == other.s;

  @override
  int get hashCode => isoCode.hashCode;
}
