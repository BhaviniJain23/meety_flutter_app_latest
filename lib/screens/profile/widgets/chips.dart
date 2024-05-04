import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';


class CustomChip extends StatelessWidget {
  final String label;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final Function(bool selected) onSelect;

  const CustomChip({
    Key? key,
    required this.label,
    this.color,
    this.width,
    this.height,
    this.margin,
    this.selected = false,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return  InkWell(
      borderRadius: BorderRadius.all(Radius.circular(selected ? 25 : 10)),
      onTap: () => onSelect(!selected),

      child: AnimatedContainer(
        height: 45,
        margin: margin ?? const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        duration: const Duration(milliseconds: 300),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected
              ? (color ?? red)
              : white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: selected
                ? (color ?? red)
                : theme.colorScheme.onSurface.withOpacity(.38),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(selected ? 25 : 10)),
          onTap: () => onSelect(!selected),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? white :
                theme.colorScheme.onSurface,
              fontSize: 16
            ),
          ),
        ),
      ),
    );
  }
}
