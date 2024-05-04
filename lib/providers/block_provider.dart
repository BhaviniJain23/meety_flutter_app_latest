 // ignore_for_file: iterable_contains_unrelated_type, unnecessary_null_comparison, non_constant_identifier_names, unrelated_type_equality_checks, camel_case_types, list_remove_unrelated_type, prefer_typing_uninitialized_variables
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/data/repository/block_repo.dart';
import 'package:meety_dating_app/models/block_user_model.dart';
import 'package:meety_dating_app/models/contact_model.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

import '../constants/enums.dart';
import '../constants/ui_strings.dart';

class BlockProvider extends ChangeNotifier {
  List<ContactModel> _contactsList = [];
  List<BlockUser> _blockNumber = [];
  final List<BlockUser> _blockUser = [];

  List<BlockUser> _selectedContacts = [];
  List<ContactModel> _selectedContactModel = [];

  String? errorMessageForImport = '';
  String? errorMessageForBlockNumber = '';
  String? errorMessageForBlockUser = '';

  LoadingState blockNumberLoading = LoadingState.Uninitialized;
  LoadingState importContactLoading = LoadingState.Uninitialized;
  LoadingState blockUserLoading = LoadingState.Uninitialized;

  List<BlockUser> get blockUser => _blockUser;
  List<BlockUser> get blockNumber => _blockNumber;
  List<ContactModel> get contactsList => _contactsList;

  List<BlockUser> get selectedContacts => _selectedContacts;
  List<ContactModel> get selectedContactModel => _selectedContactModel;

  TextEditingController searchController = TextEditingController();

  bool _isSelectAll = false;
  bool get isSelectAll => _isSelectAll;

  bool _isSelectAllContact = false;
  bool get isSelectAllContact => _isSelectAllContact;

  init() async {
    await fetchBlockUser();
    await loadContact();
  }

  void selectBlockContact(BlockUser selectingContact) {
    try {
      int index = selectedContacts.indexWhere(
          (element) => element.blockedId == selectingContact.blockedId);

      if (index != -1) {
        _selectedContacts.removeAt(index);
      } else {
        _selectedContacts.add(selectingContact);
      }
      if (_selectedContacts.length == _blockNumber.length) {
        _isSelectAll = true;
      } else {
        _isSelectAll = false;
      }

    } finally {
      notifyListeners();
    }
  }

  void selectAllForBlockTap(bool checkSelectAll) {
    try {
      _selectedContacts.clear();

      if (checkSelectAll) {
        _selectedContacts.addAll(blockNumber);
        _isSelectAll = true;
      } else {
        _isSelectAll = false;
      }
    } finally {
      notifyListeners();
    }
  }

  void selectContactModel(ContactModel selectingContact) {
    try {
      int index = _selectedContactModel
          .indexWhere((element) => element.phone == selectingContact.phone);

      if (index != -1) {
        _selectedContactModel.removeAt(index);
      } else {
        _selectedContactModel.add(selectingContact);
      }
      if (_selectedContactModel.length == _contactsList.length) {
        _isSelectAllContact = true;
      } else {
        _isSelectAllContact = false;
      }
    } finally {
      notifyListeners();
    }
  }

  void selectAllForContactTap(bool checkSelectAll) {
    try {
      _selectedContactModel.clear();

      if (checkSelectAll) {
        _selectedContactModel.addAll(contactsList);
        _isSelectAll = true;
      } else {
        _isSelectAll = false;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadContact({showLoader = true}) async {
    try {
      if (showLoader) {
        importContactLoading = LoadingState.Loading;
        notifyListeners();
      }
      List<Contact> contacts = (await ContactsService.getContacts(
          withThumbnails: false,
          androidLocalizedLabels: EditableText.debugDeterministicCursor));

      List<ContactModel> tempBlocked = [];
      List<ContactModel> tempUnblocked = [];

      for (var element in contacts) {
        bool isBlocked = _blockUser.any((user) => user.pName == element.displayName);

        if (isBlocked) {
          tempBlocked.add(ContactModel.fromContact(element));
        } else {
          tempUnblocked.add(ContactModel.fromContact(element));
        }
      }

      _contactsList.clear();
      _contactsList.addAll(tempBlocked);
      _contactsList.addAll(tempUnblocked);

      importContactLoading = LoadingState.Success;

      errorMessageForImport = "";
    } on Exception catch (e) {
      importContactLoading = LoadingState.Failure;
      errorMessageForImport = "$e";
    } finally {
      notifyListeners();
    }
  }


  // Future<void> loadContact({showLoader = true}) async {
  //   try {
  //     if (showLoader) {
  //       importContactLoading = LoadingState.Loading;
  //       notifyListeners();
  //     }
  //     List<Contact> contacts = (await ContactsService.getContacts(
  //         withThumbnails: false,
  //         androidLocalizedLabels: EditableText.debugDeterministicCursor));
  //     final temp = [];
  //     for (var element in contacts) {
  //       for (Item phoneDetails in (element.phones ?? [])) {
  //         bool isAvailable =
  //             _blockNumber.any((user) => user.pNumber == phoneDetails.value);
  //
  //         if (!isAvailable) {
  //           temp.add(ContactModel.fromContact(element)
  //               .copyWith(phone: phoneDetails.value));
  //         }
  //       }
  //     }
  //     _contactsList = List.from(temp);
  //     importContactLoading = LoadingState.Success;
  //
  //     errorMessageForImport = "";
  //   } on Exception catch (e) {
  //     importContactLoading = LoadingState.Failure;
  //     errorMessageForImport = "$e";
  //   } finally {
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchBlockUser({showLoader = true}) async {
    try {
      if (showLoader) {
        blockNumberLoading = LoadingState.Loading;
        notifyListeners();
      }
      final apiResponse = await BlockRepository().fetchedBlockedNumber();

      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        List<BlockUser> tempList =
            List.from((apiResponse[UiString.dataText] as List).map((e) {
          return BlockUser.fromJson(e);
        }));

        if (tempList.isNotEmpty) {
          _blockNumber = List.from(tempList.map((e) {
            if (e.pNumber != null && e.pNumber.isNotEmpty) {
              _contactsList.removeWhere(
                  (element) {
                    return element.phone?.contains(e.pNumber) ?? false;
                  });
            }
            if (e.pEmail != null && e.pEmail.isNotEmpty) {
              _contactsList.removeWhere(
                  (element) => element.email?.contains(e.pEmail) ?? false);
            }
            return e;
          }));

          _contactsList = [...contactsList];
        } else {
          _blockNumber.clear();
        }

        blockNumberLoading = LoadingState.Success;
        errorMessageForBlockNumber = "";
      } else {
        _blockNumber.clear();
        blockNumberLoading = LoadingState.Failure;
        errorMessageForBlockNumber = "No Data found.";
      }
    } on Exception catch (e) {
      _blockNumber.clear();
      blockNumberLoading = LoadingState.Failure;
      errorMessageForBlockNumber = "$e";
    } finally {
      notifyListeners();
    }
  }

  // same way
  Future<void> blockUserAPICall(
    BuildContext context,
  {ContactModel? c}
  ) async {
    try {
      if(c != null){
        _selectedContactModel.add(c);
      }
      final apiResponse = await BlockRepository().blockUserNumber({
        "users": _selectedContactModel.map((e) {
          return {
            "name": e.displayName,
            "number": e.phone,
            "email": e.email,
            "identifier": e.identifier
          };
        }).toList()
      });

      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        List<BlockUser> tempList =
            List.from((apiResponse[UiString.dataText] as List).map((e) {
          return BlockUser.fromJson(e);
        }));

        _blockNumber.addAll(tempList);

        for (var val in _selectedContactModel) {
          _contactsList.removeWhere((element) => element.phone == val.phone);
        }
        _contactsList = [..._contactsList];
        _blockNumber = [..._blockNumber];
        _selectedContactModel = [];
      } else {
        // ignore: use_build_context_synchronously
        context.showSnackBar(
            "Error in blocking user: ${apiResponse[UiString.messageText]}");
      }
    } on Exception catch (e) {
      // ignore: use_build_context_synchronously
      context.showSnackBar("Error in blocking user: $e");
    } finally {
      notifyListeners();
      fetchBlockUser();
    }
  }

  // same way
  Future<void> unBlockAPICall(BuildContext context) async {
    try {
      final apiResponse = await BlockRepository().unBlock({
        "p_blocked_ids": selectedContacts
            .map((e) => e.blockedId.toString())
            .toList()
            .join(",")
      });

      if (apiResponse[UiString.successText]) {
        _blockNumber
            .removeWhere((element) => selectedContacts.contains(element));
        _selectedContacts = [];
        await loadContact();
      } else {
        // ignore: use_build_context_synchronously
        context.showSnackBar(
            "Error in blocking user: ${apiResponse[UiString.messageText]}");
      }
    } on Exception catch (e) {
      // ignore: use_build_context_synchronously
      context.showSnackBar("Error in blocking user: $e");
    } finally {
      notifyListeners();
    }
  }
}
