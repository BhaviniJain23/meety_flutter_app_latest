import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/models/gender_model.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';

class CustomRadio extends StatelessWidget {
  final Gender _gender;

  const CustomRadio(this._gender, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width * 0.5 - 30,
      height: 52,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: _gender.isSelected ? red : grey.toMaterialColor.shade100),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: _gender.isSelected ? red : grey.toMaterialColor.shade100,
              blurRadius: 5.0,
              offset: const Offset(0.0, 0.75))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _gender.val,
            style: TextStyle(
              fontSize: 14,
              color: _gender.isSelected ? red : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_gender.isSelected) ...[
            Container(
              height: 10,
              width: 10,
              decoration:
                  const BoxDecoration(color: red, shape: BoxShape.circle),
            )
          ],
        ],
      ),
    );
  }
}

class LookingForCard extends StatelessWidget {
  final LookingFor lookingFor;

  const LookingForCard({Key? key, required this.lookingFor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: (context.width * 0.40),
      width: ResponsiveDesign.screenWidth(context) * 0.41,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: lookingFor.isSelected ? red : grey.toMaterialColor.shade100),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color:
                  lookingFor.isSelected ? red : grey.toMaterialColor.shade100,
              blurRadius: 5.0,
              offset: const Offset(0.0, 0.75))
        ],
      ),
      constraints: BoxConstraints(
          minWidth: ResponsiveDesign.width(120, context),
          minHeight: ResponsiveDesign.height(90, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lookingFor.val,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: ResponsiveDesign.fontSize(12, context),
                color: lookingFor.isSelected ? red : Colors.black),
          )
        ],
      ),
    );
  }
}

class EducationCard extends StatelessWidget {
  final Education education;

  const EducationCard({super.key, required this.education});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (context.width * 0.43),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: education.isSelected ? red : grey.toMaterialColor.shade100),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: education.isSelected ? red : grey.toMaterialColor.shade100,
              blurRadius: 3.0,
              offset: const Offset(0.0, 0.75))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        education.val.name.toString(),
        style: context.textTheme.titleMedium!.copyWith(
            color: education.isSelected ? red : Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.1),
      ),
    );
  }
}
