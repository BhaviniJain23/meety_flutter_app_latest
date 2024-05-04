import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';

class AnimatedTextBar extends StatefulWidget {
  final bool isOnline;
  const AnimatedTextBar({super.key, this.isOnline = false});

  @override
  State<AnimatedTextBar> createState() => _AnimatedTextBarState();
}

class _AnimatedTextBarState extends State<AnimatedTextBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationUpToDownController;

  @override
  void initState() {
    _animationUpToDownController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    if (_animationUpToDownController.status != AnimationStatus.completed) {
      _animationUpToDownController.forward();
    } else {
      _animationUpToDownController.animateBack(0, duration: const Duration(seconds: 1));
    }
    super.initState();

  }

  @override
  void dispose() {
    if(_animationUpToDownController.isAnimating){
      _animationUpToDownController.dispose();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        height: 25,
        width: double.maxFinite,
        color: widget.isOnline ? Colors.green : Colors.black54,
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 18.0,vertical: 2),
            child: Center(
              child: Text(
                widget.isOnline ? 'Back to Online' : 'No Internet Connection',
                style: const TextStyle(color: white,fontSize: 12),
              ),
            ),
          ),
   /*   ),*/
    );
  }
}



