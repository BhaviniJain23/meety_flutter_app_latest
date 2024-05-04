
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future navigateTo(String routeName,
      {Object? arguments, bool withPushAndRemoveUntil = false,
        bool withPopAndPush = false,
        BuildContext? context,
        Widget? nextScreen}) {
    if (nextScreen != null) {

      return PersistentNavBarNavigator.pushNewScreen(
        navigatorKey.currentContext!,
        screen: nextScreen,
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else if (withPushAndRemoveUntil) {
      return navigatorKey.currentState!.pushNamedAndRemoveUntil(
          routeName, (route) => false,
          arguments: arguments);
    } else if (withPushAndRemoveUntil) {
      return navigatorKey.currentState!.popAndPushNamed(
          routeName,
          arguments: arguments);
    } else {
      return navigatorKey.currentState!
          .pushNamed(routeName, arguments: arguments);
    }
  }


  Future customMaterialPageRoute(Widget nextScreen) {

      return navigatorKey.currentState!.push(
        MaterialPageRoute(
            builder: (context) {
              return nextScreen;
            }),
      );

  }

  void pop({Object? result}) {
    navigatorKey.currentState!.pop(result);
  }

  void popUntil(RoutePredicate predicate) {
    navigatorKey.currentState!.popUntil(predicate);
  }
  bool canPop() {
    return navigatorKey.currentState!.canPop();
  }
}
