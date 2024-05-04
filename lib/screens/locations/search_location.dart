// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/providers/search_provider.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:provider/provider.dart';

import '../../data/repository/location_repo.dart';
import '../../services/shared_pref_manager.dart';
import '../../services/singleton_locator.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({Key? key}) : super(key: key);

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  final globalKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  SearchProvider? searchProvider1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sl<SharedPrefsManager>().getFilteredLocations().then((filteredLocations) {
      setState(() {
        searchProvider1?.filteredLocations = filteredLocations;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider(
        create: (BuildContext context) => SearchProvider(),
        child: Consumer<SearchProvider>(
          builder: (context, searchProvider, child) {
            searchProvider1 ??= searchProvider;
            return Scaffold(
              appBar: const AppBarX(
                elevation: 5,
                title: 'Location',
                //centerTitle: true,
              ),
              body: Column(
                children: [
                  SizedBox(
                    height: ResponsiveDesign.height(10, context),
                  ),
                  Padding(
                    padding: ResponsiveDesign.horizontal(20, context),
                    child: TextField(cursorColor: red,
                      controller: _searchController,
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                            onTap: () {
                              searchProvider.search(_searchController.text);
                            },
                            child: const Icon(
                              Icons.search_rounded,
                              color: black,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: grey)),
                        contentPadding:
                            const EdgeInsets.only(top: 5, bottom: 5, left: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: grey)),
                        hintText: 'Enter to search city',
                      ),
                      onChanged: (value) {
                        searchProvider.search(value);
                      },
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveDesign.height(10, context),
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (searchProvider.isLoading) {
                        return const Loading();
                      } else {
                        if (searchProvider.searchResults.isNotEmpty) {
                          return _buildSearchResults(searchProvider);
                        } else if (searchProvider.searchResults.isEmpty &&
                            searchProvider.searchText.isNotEmpty) {
                          return const Center(
                              child: EmptyWidget(
                            image: '',
                            titleText: "No Location found",
                          ));
                        }
                      }
                      return Container();
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    final results = searchProvider.filteredLocations;

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        print(result);
        return ListTile(
          title: Text(result.name ?? ''),
          // subtitle: Text('${result['latitude']}, ${result['longitude']}'),
          onTap: () {
            // TODO: Handle selection of search result
            Navigator.pop(context, result);
          },
        );
      },
    );
  }
}
