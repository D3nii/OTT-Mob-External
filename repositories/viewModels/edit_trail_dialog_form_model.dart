import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:rxdart/rxdart.dart';

class EditTrailDialogFormModel extends BaseModel {
  late ProfileService _profileService;
  Stream<BaseResponse<User>>? _userProfile;
  late Trail trail;
  late TrailService _trailService;
  late ScrollController _viewController;
  TextEditingController _addNameController = TextEditingController();
  TextEditingController _addEmailController = TextEditingController();
  TextEditingController _addSmallDescriptionController = TextEditingController();
  bool _emailValid = false;
  bool _nameValid = false;
  FocusNode _addNameFocusNode = FocusNode();
  FocusNode _addEmailFocusNode = FocusNode();
  List<String> _originalListOfCollaborators = [];
  String errorMessage = "";
  List<String> _listOfCollaborators = [];
  StreamController _streamControllerOfCollaborators = BehaviorSubject();
  bool _saveChanges = false;
  bool _saving = false;
  bool _trailRefreshed = false;
  final _controller = ScrollController();
  bool _publishingVisibility = false;

  get controller => _controller;

  ScrollController get viewController => _viewController;

  TextEditingController get addNameController => _addNameController;

  FocusNode get addNameFocusNode => _addNameFocusNode;

  TextEditingController get addEmailController => _addEmailController;

  FocusNode get addEmailFocusNode => _addEmailFocusNode;

  bool get emailValid => _emailValid;

  bool get nameValid => _nameValid;

  List<String> get listOfCollaborators => _listOfCollaborators;

  StreamController get streamControllerOfCollaborators => _streamControllerOfCollaborators;

  bool get saveChanges => _saveChanges;

  List<String> get originalListOfCollaborators => _originalListOfCollaborators;

  bool get saving => _saving;

  bool get publishingVisibility => _publishingVisibility;

  bool get isPublic => trail.isPublic;

  set saving(bool value) {
    _saving = value;
    notifyListeners();
  }

  set trailService(TrailService value) {
    _trailService = value;
  }

  set originalListOfCollaborators(List<String> value) {
    _originalListOfCollaborators = value;
    notifyListeners();
  }

  set saveChanges(bool value) {
    _saveChanges = value;
    notifyListeners();
  }

  set streamControllerOfCollaborators(StreamController value) {
    _streamControllerOfCollaborators = value;
    notifyListeners();
  }

  set listOfCollaborators(List<String> value) {
    _listOfCollaborators = value;
    notifyListeners();
  }

  TextEditingController get addSmallDescriptionController => _addSmallDescriptionController;

  set nameValid(bool value) {
    _nameValid = value;
    notifyListeners();
  }

  set emailValid(bool value) {
    _emailValid = value;
    notifyListeners();
  }

  set addEmailFocusNode(FocusNode value) {
    _addEmailFocusNode = value;
    notifyListeners();
  }

  set addNameFocusNode(FocusNode value) {
    _addNameFocusNode = value;
    notifyListeners();
  }

  set viewController(ScrollController value) {
    _viewController = value;
    notifyListeners();
  }

  set profileService(ProfileService value) {
    _profileService = value;
  }

  Stream<BaseResponse<User>>? get userProfile => _userProfile;

  bool get trailRefreshed => _trailRefreshed;

  ///First Method
  init() async {
    _userProfile = _profileService.getProfileInfo();
    BaseResponse<Trail> trailFromApi = await _trailService.getTrailDetails(trailId: trail.id);
    if (trailFromApi.responseStatus == SUCCESS) {
      trail = trailFromApi.data;
      _trailRefreshed = true;
    }

    _addEmailController.addListener(() {
      validateChanges();
    });
    _addNameController.addListener(() {
      validateChanges();
    });
    _addSmallDescriptionController.addListener(() {
      validateChanges();
    });

    listOfCollaborators.clear();
    originalListOfCollaborators.clear();
    for (String value in trail.collaborators) {
      originalListOfCollaborators.add(value);
      listOfCollaborators.add(value);
    }

    streamControllerOfCollaborators.add(listOfCollaborators);
    validateChanges();
  }

  ///Method to validate email
  void validateEmail() {
    if (addEmailController.text.isEmpty || addEmailController.text == "") {
      emailValid = false;
    } else {
      var email = addEmailController.text;
      emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    }
  }

  ///Add collaborator to list of collaborators
  void addToCollaboratorList(BuildContext context) {
    if (addEmailController.text.isNotEmpty || addEmailController.text != "") {
      bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(addEmailController.text);
      if (emailValid) {
        String emailToAdd = addEmailController.text;

        if (!listOfCollaborators.contains(emailToAdd)) {
          listOfCollaborators.add(emailToAdd);
          streamControllerOfCollaborators.add(listOfCollaborators);
          Future.delayed(Duration(milliseconds: 300), () {
            _controller.animateTo(
              _controller.position.maxScrollExtent,
              duration: Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
            );
          });
        }
        addEmailController.clear();
        validateChanges();
      } else {
        errorMessage = AppLocalizations.of(context)?.insertACorrectEmailText ?? 'Please enter a valid email';
      }
    } else {
      errorMessage = AppLocalizations.of(context)?.spaceIsInBlankText ?? 'This field cannot be empty';
    }
    validateChanges();
  }

  void removeCollaboratorOfTheList(String data) {
    for (int i = 0; listOfCollaborators.length > i; i++) {
      if (listOfCollaborators[i] == data) {
        listOfCollaborators.removeAt(i);
      }
    }
    validateChanges();
    notifyListeners();
  }

  void validateChanges() {
    if (_addNameController.text.trim().isEmpty) {
      saveChanges = false;
      notifyListeners();
      return;
    }

    bool nameChanged = _addNameController.text.trim() != trail.name.trim();
    bool descriptionChanged = _addSmallDescriptionController.text.trim() != trail.description.trim();

    bool collaboratorsChanged = false;
    if (_listOfCollaborators.length != _originalListOfCollaborators.length) {
      collaboratorsChanged = true;
    } else {
      for (String email in _listOfCollaborators) {
        if (!_originalListOfCollaborators.contains(email)) {
          collaboratorsChanged = true;
          break;
        }
      }

      for (String email in _originalListOfCollaborators) {
        if (!_listOfCollaborators.contains(email)) {
          collaboratorsChanged = true;
          break;
        }
      }
    }

    saveChanges = nameChanged || descriptionChanged || collaboratorsChanged;

    notifyListeners();
  }

  Future<ApplicationApiResponse> saveChangesInApi() async {
    List<String> valuesToEmails = [];
    saving = true;
    valuesToEmails = listOfCollaborators;

    ApplicationApiResponse result = await _trailService.updateTrailFromEditView(
        addNameController.text, addSmallDescriptionController.text, valuesToEmails, trail.id, true);
    saving = false;
    if (result.result) {
      Trail temp = result.responseObject as Trail;
      addNameController.text = temp.name;
      addSmallDescriptionController.text = temp.description;
      originalListOfCollaborators = temp.collaborators;
    }
    return result;
  }

  Future<ApplicationApiResponse<Trail>> setPublic(bool value) async {
    final bool previousValue = trail.isPublic;
    _publishingVisibility = true;
    trail.isPublic = value;
    notifyListeners();

    ApplicationApiResponse<Trail> response = value
        ? await _trailService.publishTrail(trail)
        : await _trailService.unpublishTrail(trail);

    _publishingVisibility = false;

    if (response.statusCode == 200 && response.result) {
      trail = response.responseObject;
    } else {
      trail.isPublic = previousValue;
    }

    notifyListeners();
    return response;
  }
}
