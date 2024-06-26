import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionService {
  //This creates the single instance by calling the `_internal` constructor specified below
  static final InternetConnectionService _singleton = InternetConnectionService._internal();

  InternetConnectionService._internal();
  //This is what's used to retrieve the instance through the app
  static InternetConnectionService getInstance() => _singleton;
  //This tracks the current connection status
  bool hasConnection = false;
  //This is how we'll allow subscribing to connection changes
  StreamController connectionChangeController = StreamController.broadcast();
  //flutter_connectivity
  final Connectivity _connectivity = Connectivity();
  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
  }
  //flutter_connectivity's listener
  void _connectionChange(ConnectivityResult result) {
    hasInternetConnection();
  }
  Stream get connectionChange => connectionChangeController.stream;

  Future<bool> hasInternetConnection() async {
    try{
      bool previousConnection = hasConnection;
      var connectivityResult = await (Connectivity().checkConnectivity());


      //Check if device is just connect with mobile network or wifi
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        //Check there is actual internet connection with a mobile network or wifi
        var checker = await InternetConnectionCheckerPlus().hasConnection;

        if (checker) {
          // Network data detected & internet connection confirmed.
          hasConnection = true;
        } else {
          // Network data detected but no internet connection found.
          hasConnection = false;
        }
      }
      // device has no mobile network and wifi connection at all
      else {
        hasConnection = false;
      }
      // The connection status changed send out an update to all listeners
      if (previousConnection != hasConnection) {
        connectionChangeController.add(hasConnection);
      }
      return hasConnection;
    }catch(e){
      if (kDebugMode) {
        // // print(e);
      }
      return false;
    }
  }

}