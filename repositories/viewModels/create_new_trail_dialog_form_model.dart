import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:rxdart/rxdart.dart';

class CreateNewTrailDialogFormModel extends BaseModel {
  Experience? _experience;
  List<String> _listOfCollaborators = [];
  StreamController _streamControllerOfCollaborators = BehaviorSubject();
  String _errorMessage = "";
  String _errorInName = "";
  String _errorInDescription = "";
  bool _show = false;
  ScrollController _viewController = ScrollController();
  late TrailService _trailService;
  bool _showCircular = false;

  TextEditingController _addNameController = TextEditingController();
  TextEditingController _addCollaboratorEmailController = TextEditingController();
  TextEditingController _addSmallDescriptionController = TextEditingController();
  FocusNode _addSmallDescriptionFocusNode = FocusNode();
  FocusNode _addCollaboratorEmailFocusNode = FocusNode();
  FocusNode _addNameFocusNode = FocusNode();

  TextEditingController get addNameController => _addNameController;

  TextEditingController get addCollaboratorEmailController => _addCollaboratorEmailController;

  TextEditingController get addSmallDescriptionController => _addSmallDescriptionController;

  FocusNode get addSmallDescriptionFocusNode => _addSmallDescriptionFocusNode;

  FocusNode get addCollaboratorEmailFocusNode => _addCollaboratorEmailFocusNode;

  FocusNode get addNameFocusNode => _addNameFocusNode;

  List<String> get listOfCollaborators => _listOfCollaborators;

  StreamController get streamControllerOfCollaborators => _streamControllerOfCollaborators;

  String get errorMessage => _errorMessage;

  bool get show => _show;

  ScrollController get viewController => _viewController;

  String get errorInName => _errorInName;

  String get errorInDescription => _errorInDescription;

  TrailService get trailService => _trailService;

  Experience? get experience => _experience;

  bool get showCircular => _showCircular;

  set showCircular(bool value) {
    _showCircular = value;
    notifyListeners();
  }

  set experience(Experience? value) {
    _experience = value;
    notifyListeners();
  }

  set trailService(TrailService value) {
    _trailService = value;
    notifyListeners();
  }

  set errorInName(String value) {
    _errorInName = value;
    notifyListeners();
  }

  set errorInDescription(String value) {
    _errorInDescription = value;
    notifyListeners();
  }

  set viewController(ScrollController value) {
    _viewController = value;
    notifyListeners();
  }

  set show(bool value) {
    _show = value;
    notifyListeners();
  }

  set errorMessage(String value) {
    _errorMessage = value;
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

  set addNameController(TextEditingController value) {
    _addNameController = value;
    notifyListeners();
  }

  set addCollaboratorEmailController(TextEditingController value) {
    _addCollaboratorEmailController = value;
    notifyListeners();
  }

  set addSmallDescriptionController(TextEditingController value) {
    _addSmallDescriptionController = value;
    notifyListeners();
  }

  set addSmallDescriptionFocusNode(FocusNode value) {
    _addSmallDescriptionFocusNode = value;
    notifyListeners();
  }

  set addCollaboratorEmailFocusNode(FocusNode value) {
    _addCollaboratorEmailFocusNode = value;
    notifyListeners();
  }

  set addNameFocusNode(FocusNode value) {
    _addNameFocusNode = value;
    notifyListeners();
  }

  /// Remove focus from all textfields.
  unfocusAllTextFields() {
    addNameFocusNode.unfocus();
    addCollaboratorEmailFocusNode.unfocus();
    addSmallDescriptionFocusNode.unfocus();
  }

  Future<bool> saveTrail() async {
    if (state == ViewState.Busy) {
      throw StateError("fetching posts again when the current request haven't finished");
    }
    setState(ViewState.Busy);

    var data = {
      'name': addNameController.text,
      'description': addSmallDescriptionController.text,
      'collaborators': listOfCollaborators,
    };

    data['experience_ids'] = [experience?.experienceId];

    BaseResponse<Trail> response = await _trailService.createTrail(data);
    setState(ViewState.Idle);
    if (response.responseStatus == SUCCESS) {
      return true;
    } else {
      return false;
    }
  }

  ///Add collaborator to list of collaborators
  void addToCollaboratorList(BuildContext context) {
    if (state == ViewState.Busy) {
      throw StateError("fetching posts again when the current request haven't finished");
    }

    if (addCollaboratorEmailController.text.isNotEmpty || addCollaboratorEmailController.text != "") {
      bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(addCollaboratorEmailController.text);
      if (emailValid) {
        String emailToAdd = addCollaboratorEmailController.text;
        listOfCollaborators.add(emailToAdd);
        streamControllerOfCollaborators.add(listOfCollaborators);
        addCollaboratorEmailController.clear();
        nameAndEmailsCheck(context);
      } else {
        errorMessage = AppLocalizations.of(context)?.insertACorrectEmailText ?? 'Please enter a valid email';
      }
    } else {
      errorMessage = AppLocalizations.of(context)?.spaceIsInBlankText ?? 'This field cannot be empty';
    }
  }

  ///Check the name and the email
  void nameAndEmailsCheck(BuildContext context) {
    if (addNameController.text.isEmpty) {
      if (addNameController.text.isEmpty) {
        show = false;
        errorInName = AppLocalizations.of(context)?.nameEmptyText ?? 'Name cannot be empty';
      }
      // show = false;
    } else {
      show = true;
    }
  }

  void removeCollaboratorOfTheList(String data) {
    for (int i = 0; listOfCollaborators.length > i; i++) {
      if (listOfCollaborators[i] == data) {
        listOfCollaborators.removeAt(i);
      }
    }
    notifyListeners();
  }
}
