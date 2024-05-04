// ignore_for_file: recursive_getters

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meety_dating_app/data/repository/location_repo.dart';
import 'package:meety_dating_app/models/location.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';

import '../services/singleton_locator.dart';

class SearchProvider extends ChangeNotifier {
  String _searchText = '';
  bool _isLoading = false;

  List<Location> _searchResults = [];
  List<String> allResults = [];
  List<Location> filteredLocations = [];

  String get searchText => _searchText;

  bool get isLoading => _isLoading;

  List<Location> get filteredLocation => filteredLocations;

  List<Location> get searchResults => _searchResults;

  void setSearchText(String text) {
    _searchText = text;
    _isLoading = text.isNotEmpty;
    notifyListeners();
  }

  Future<void> search(String text) async {
    if (text.isEmpty) {
      _searchText = text;
      _searchResults = [];
      notifyListeners();
    } else {
      bool isSearchedLocationAtTop = _searchResults.isNotEmpty &&
          _searchResults.first.name!.toLowerCase() == text.toLowerCase();

      if (!isSearchedLocationAtTop) {
        _searchText = text;
        _isLoading = true;
        notifyListeners();
        final response = await LocationRepo().searchLocations(cityName: text);

        response.fold(
              (l) {
            _isLoading = false;
            _searchResults = [];
            notifyListeners();
          },
              (r) {
            _isLoading = false;
            _searchResults = List.from(r);
            moveSearchedLocationToTop(text);
            filterResultsByFirstChar();
            sl<SharedPrefsManager>().saveFilteredLocations(filteredLocations);
            notifyListeners();
          },
        );
      } else {
        // If the searched location is already at the top, no need to fetch again
        // Just filter and notify
        filterResultsByFirstChar();
        notifyListeners();
      }
    }
  }

// Helper method to move searched location to the top of the list
  void moveSearchedLocationToTop(String text) {
    // Assuming _searchResults is a List<Location>
    for (int i = 0; i < _searchResults.length; i++) {
      if (_searchResults[i].name!.toLowerCase() == text.toLowerCase()) {
        Location temp = _searchResults[i];
        _searchResults.removeAt(i);
        _searchResults.insert(0, temp);
        break;
      }
    }
  }

  void filterResultsByFirstChar() {
    filteredLocations.clear();

    if (_searchText.isEmpty) {
      filteredLocations.addAll(_searchResults);
      return;
    }

    String firstChar = _searchText[0].toUpperCase();

    // filteredLocations.addAll(
    //   _searchResults
    //       .where((result) => result.name!.toUpperCase().startsWith(firstChar)),
    // );
    filteredLocations.addAll(_searchResults.where((element) =>
        element.name!.toLowerCase().startsWith(firstChar) ==
        searchText.toLowerCase().startsWith(firstChar)));
  }

  Future<void> initSearch(List<Location> locations,
      {String cityName = ''}) async {
    if (locations.isNotEmpty) {
      if (cityName.isNotEmpty) {
        _searchResults = locations
            .where((location) =>
                location.name!.toLowerCase().contains(cityName.toLowerCase()))
            .toList();
      } else {
        _searchResults = List.from(locations);
      }
      notifyListeners();
    } else {
      // Call API to search for cities
      _isLoading = true;
      notifyListeners();
      final response = await LocationRepo().searchLocationsWithoutCity();
      response.fold((l) {
        _isLoading = false;
        _searchResults = [];
        notifyListeners();
      }, (r) {
        _isLoading = false;
        if (cityName.isNotEmpty) {
          _searchResults = r;
          sl<SharedPrefsManager>().saveLocation(searchResults);
        } else {
          _searchResults = r;
          sl<SharedPrefsManager>().getLocationList();
        }
        notifyListeners();
      });
    }
  }
}
