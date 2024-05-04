
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

class NoInternetScreen extends StatelessWidget {
  final AsyncCallback? onTryAgainTap;
  const NoInternetScreen({super.key, this.onTryAgainTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 20),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                  height: 150,
                  child: Image.asset('assets/images/dummy/no_internet.png',)),
              const SizedBox(height: 20),
              const Text(
                UiString.noInternet,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(UiString.noInternetCaption,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              FillBtnX(
                onPressed:() async {
                  if(onTryAgainTap != null){
                    onTryAgainTap?.call();
                  }
                },
                text: 'Try Again',
                width: context.width*0.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
