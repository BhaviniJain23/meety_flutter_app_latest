import 'package:meety_dating_app/models/education_model.dart';

class Gender {
  String val;
  bool isSelected;

  Gender({required this.val, required this.isSelected});

  @override
  String toString() {
    return Gender(val: val, isSelected: isSelected).val.toString();
  }
}

class SexOrientation {
  String val;
  bool isSelected;

  SexOrientation({required this.val, required this.isSelected});

  @override
  String toString() {
    return SexOrientation(val: val, isSelected: isSelected).val.toString();
  }
}

class LookingFor {
  String val;
  bool isSelected;

  LookingFor({required this.val, required this.isSelected});
}

class Education {
  EducationModel val;
  bool isSelected;

  Education({required this.val, required this.isSelected});
}

class FuturePlan {
  String val;
  bool isSelected;

  FuturePlan({required this.val, required this.isSelected});
}
