import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/notification_repo.dart';
import 'package:meety_dating_app/models/notification_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationProvider with ChangeNotifier {
  static const recordSize = 10;

  int _pageNo = 1;

  DataState _notificationLoader = DataState.Uninitialized;
  String errorMessage = '';

  DataState get notificationLoader => _notificationLoader;
  List<NotificationModel> get notificationList =>_notificationList;
  List<NotificationModel> _notificationList = [];
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  set pageNo(int value) {
    _pageNo = value;
    notifyListeners();
  }

  Future<void> fetchNotification() async {
    try {
      _notificationLoader =
          _pageNo == 1 ? DataState.Initial_Fetching : DataState.More_Fetching;

      final apiResponse = await NotificationRepository().getAllNotification(
          {"page_number": _pageNo, "records_per_page": recordSize});
      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        final tempNotificationList = List.from((apiResponse[UiString.dataText])
            .map((e) => NotificationModel.fromJson(e))).toList();
        if (_pageNo == 1) {
          _notificationList = List.from(tempNotificationList);
          _notificationLoader = DataState.Fetched;
          refreshController.resetNoData();
        } else {
          _notificationList.addAll(List.from(tempNotificationList));
          refreshController.loadComplete();
          if (tempNotificationList.length < recordSize) {
            refreshController.loadNoData();
          }
          _notificationLoader = DataState.More_Fetching;
        }
        _pageNo++;
        _notificationLoader = DataState.Fetched;
      } else {
        _notificationLoader = DataState.Error;
        errorMessage = apiResponse[UiString.messageText];
      }
    } on Exception catch (e) {
      _notificationLoader = DataState.Error;
      errorMessage = e.toString();
      // TODO
    } finally {
      notifyListeners();
    }
  }

  void onRefresh() {
    _pageNo = 1;
    Future.delayed(const Duration(milliseconds: 100), () async {
      fetchNotification();
      refreshController.refreshCompleted();
    });
  }

  void onLoadMore() {
    _pageNo += 1;
    Future.delayed(const Duration(milliseconds: 100), () {
      fetchNotification();
    });
  }
}
