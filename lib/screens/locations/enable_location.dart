import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/heading.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:permission_handler/permission_handler.dart';

class EnableLocation extends StatefulWidget {
  final bool isFirst;
  const EnableLocation({Key? key, required this.isFirst}) : super(key: key);

  @override
  State<EnableLocation> createState() => _EnableLocationState();
}

class _EnableLocationState extends State<EnableLocation> {
  final NavigationService _navigationService = sl<NavigationService>();
  String error = '';
  Position? _position;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    if (!widget.isFirst) {
      setState(() {
        isLoading = true;
      });
      Future.delayed(const Duration(seconds: 0), () async {
        await _determinePosition();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else {
          exit(0);
        }
        return true;
      },
      child: Scaffold(

        body: !isLoading
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    Assets.enableLocation,
                    width: double.maxFinite,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(
                    height: height * 0.15,
                  ),
                  if (error.isEmpty) ...[

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: HeadingStyles.boardingHeading(
                          context, UiString.enableLocationSubCaption),
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: HeadingStyles.boardingHeadingCaption(
                            context, UiString.enableLocation,
                            fontSize: 16,
                            isCenter: false)),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: HeadingStyles.boardingHeading(
                          context, UiString.oops),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: HeadingStyles.boardingHeadingCaption(
                          context,
                          error,
                        )),
                  ],
                 const Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: FillBtnX(
                        onPressed: () async {
                          _position = await _determinePosition();
                        },
                        color: red,
                        text: error.isNotEmpty
                            ? UiString.tryAgain
                            : UiString.access),
                  ),
                  SizedBox(
                    height: height * 0.07,
                  ),
                ],
              )
            : const Center(
                child: Loading(),
              ),
      ),
    );
  }

  Future<Position?> _determinePosition() async {
    try {
      LocationPermission permission;

      PermissionStatus status = await Permission.location.request();
      if (!status.isGranted) {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            error = 'Location permissions are denied';
            setState(() {});
            return null;
          }
        }
        if (permission == LocationPermission.deniedForever) {
          error =
              'Location permissions are permanently denied, we cannot request'
              'permissions.';
          setState(() {});
          return null;
        }
        error = 'Location permissions are disabled';
        setState(() {});
        return null;
      }

      _position = await Geolocator.getCurrentPosition();

      if (_position != null) {
        await updateLocation(
            lat: _position!.latitude.toString(),
            long: _position!.longitude.toString());
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on Exception catch (e) {
      error = e.toString().replaceAll("user", "you").replaceAll("User", "You");
      setState(() {});
    }
    return null;
  }

  Future<void> updateLocation(
      {required String lat, required String long}) async {
    User? user = sl<SharedPrefsManager>().getUserDataInfo();
    try {
      if (user != null &&
          double.tryParse(user.currentLat!)?.toStringAsFixed(4) ==
              double.tryParse(lat)?.toStringAsFixed(4) &&
          double.tryParse(user.currentLong!)?.toStringAsFixed(4) ==
              double.tryParse(long)?.toStringAsFixed(4)) {
        Future.delayed(const Duration(seconds: 0), () {
          _navigationService.navigateTo(
            RoutePaths.home,
            withPushAndRemoveUntil: true,
          );
        });
      } else {
        bool isInternet = await InternetConnectionService.getInstance()
            .hasInternetConnection();
        if (isInternet) {
          Map<String, dynamic> apiResponse = await UserRepository()
              .updateLocation(lat: lat, long: long, isCurrent: '1');

          if (apiResponse[UiString.successText]) {
            if (apiResponse[UiString.dataText] != null) {
              User user = User.fromJson(apiResponse[UiString.dataText]);
              await sl<SharedPrefsManager>().saveUserInfo(user);
              Future.delayed(const Duration(seconds: 0), () {
                _navigationService.navigateTo(
                  RoutePaths.home,
                  withPushAndRemoveUntil: true,
                );
              });
            }
            else {
              _navigationService.navigateTo(
                RoutePaths.login,
                withPushAndRemoveUntil: true,
              );
            }
          } else {
            Future.delayed(const Duration(seconds: 0), () {
              setState(() {
                isLoading = false;
              });
              context.showSnackBar(apiResponse[UiString.messageText]);
            });
          }
        } else {
          Future.delayed(const Duration(seconds: 0), () {
            setState(() {
              isLoading = false;
            });
            context.showSnackBar(UiString.noInternet);
          });
        }
      }
    } finally {}
  }
}
