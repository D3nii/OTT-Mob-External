import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/enums/face_selection.dart';
import 'package:onetwotrail/repositories/enums/trail_status.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/issue.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class ReportIssueModel extends BaseModel {
  final Logger _log = Logger('ReportIssueModel');
  late Experience _experience;
  late Issue _newIssue;
  bool _abuseRudeness = false;
  bool _scam = false;
  bool _hygiene = false;
  bool _personal = false;
  bool _other = false;
  TextEditingController _addCommentController = TextEditingController();
  FocusNode _addCommentFocusNode = FocusNode();
  double _faceSelection = 0.0;
  FaceSelection finalSelection = FaceSelection.SAD; // Default to SAD
  Map<String, bool> _isSelected = {'null': false};
  bool showLoading = false;
  late ApplicationApi _applicationApi;

  List<String> _list = [];

  Experience get experience => _experience;

  bool get abuseRudeness => _abuseRudeness;

  bool get scam => _scam;

  bool get hygiene => _hygiene;

  bool get personal => _personal;

  bool get other => _other;

  TextEditingController get addCommentController => _addCommentController;

  FocusNode get addCommentFocusNode => _addCommentFocusNode;

  Issue get newIssue => _newIssue;

  double get faceSelection => _faceSelection;

  List<String> get list => _list;

  Map<String, bool> get isSelected => _isSelected;

  set applicationApi(ApplicationApi api) {
    _applicationApi = api;
    notifyListeners();
  }

  set isSelected(Map<String, bool> value) {
    _isSelected = value;
    notifyListeners();
  }

  set list(List<String> value) {
    _list = value;
    notifyListeners();
  }

  set faceSelection(double value) {
    _faceSelection = value;
    if (faceSelection == 0) {
      finalSelection = FaceSelection.SAD;
    } else if (faceSelection == 0.5) {
      finalSelection = FaceSelection.VERY_SAD;
    } else if (faceSelection == 1.0) {
      finalSelection = FaceSelection.ANGRY;
    }
    notifyListeners();
  }

  set newIssue(Issue value) {
    _newIssue = value;
    notifyListeners();
  }

  set addCommentFocusNode(FocusNode value) {
    _addCommentFocusNode = value;

    notifyListeners();
  }

  set addCommentController(TextEditingController value) {
    _addCommentController = value;
    notifyListeners();
  }

  set other(bool value) {
    _other = value;
    notifyListeners();
  }

  set personal(bool value) {
    _personal = value;
    notifyListeners();
  }

  set hygiene(bool value) {
    _hygiene = value;
    notifyListeners();
  }

  set scam(bool value) {
    _scam = value;
    notifyListeners();
  }

  set abuseRudeness(bool value) {
    _abuseRudeness = value;
    notifyListeners();
  }

  set experience(Experience value) {
    _experience = value;
    notifyListeners();
  }

  ///First Method to load data
  init(BuildContext context) {
    list = [
      AppLocalizations.of(context)?.abuseRudenessText ?? 'Abuse/Rudeness',
      AppLocalizations.of(context)?.scamText ?? 'Scam',
      AppLocalizations.of(context)?.hygieneText ?? 'Hygiene',
      AppLocalizations.of(context)?.personalText ?? 'Personal',
      AppLocalizations.of(context)?.otherText ?? 'Other',
    ];
    isSelected = {AppLocalizations.of(context)?.abuseRudenessText ?? 'Abuse/Rudeness': true};

    // Ensure face selection is initialized
    _faceSelection = 0.0;
    finalSelection = FaceSelection.SAD;

    addCommentFocusNode.addListener(() {
      notifyListeners();
    });

    _log.fine("ReportIssueModel initialized with default face selection: ${finalSelection}");
  }

  /// Send request to the api to report an issue
  Future<ApplicationApiResponse> reportIssue(BuildContext context) async {
    _log.info("Reporting issue for experience ${experience.experienceId}");
    showLoading = true;
    notifyListeners();

    // Get selected report types
    List<String> listReportType = [];
    isSelected.forEach((key, value) {
      if (value) {
        listReportType.add(key);
        _log.fine("Selected report type: $key");
      }
    });

    // Create a new list with standardized report types
    List<String> standardizedReportTypes = [];
    for (String item in listReportType) {
      if (item == (AppLocalizations.of(context)?.otherText ?? 'Other')) {
        standardizedReportTypes.add("Other");
      } else if (item == (AppLocalizations.of(context)?.personalText ?? 'Personal')) {
        standardizedReportTypes.add("Personal");
      } else if (item == (AppLocalizations.of(context)?.hygieneText ?? 'Hygiene')) {
        standardizedReportTypes.add("Hygiene");
      } else if (item == (AppLocalizations.of(context)?.scamText ?? 'Scam')) {
        standardizedReportTypes.add("Scam");
      } else if (item == (AppLocalizations.of(context)?.abuseRudenessText ?? 'Abuse/Rudeness')) {
        standardizedReportTypes.add("Abuse/Rudeness");
      } else {
        // If we don't recognize the type, add it as is
        standardizedReportTypes.add(item);
      }
    }

    newIssue = Issue(experience.experienceId, experience.name, standardizedReportTypes, addCommentController.text,
        experience: experience,
        trail: Trail(
          id: 0,
          author: '',
          collaborators: [],
          description: '',
          experiences: [],
          itineraryEstimatedTime: Duration.zero,
          itineraryId: 0,
          latitude: 0.0,
          listingDescription: '',
          lockVersion: 0,
          longitude: 0.0,
          name: '',
          status: TrailStatus.PAUSED,
        ));

    String faceSelection = '';
    switch (finalSelection) {
      case FaceSelection.SAD:
        {
          faceSelection = 'neutral';
        }
        break;

      case FaceSelection.VERY_SAD:
        {
          faceSelection = "bad";
        }
        break;

      case FaceSelection.ANGRY:
        {
          faceSelection = "terrible";
        }
        break;

      // No NEUTRAL case in the enum
    }

    _log.info("Sending report with types: ${standardizedReportTypes}");
    _log.info("Face selection: $faceSelection");
    ApplicationApiResponse response = await _applicationApi.reportExperience(newIssue, faceSelection);

    if (response.result) {
      _log.info("Successfully reported issue for experience ${experience.experienceId}");
    } else {
      _log.warning("Failed to report issue for experience ${experience.experienceId}: ${response.statusCode}");
      _log.warning("Response body: ${response.responseBody}");
    }

    showLoading = false;
    if (mounted) {
      notifyListeners();
    }
    return response;
  }

  void setSelection(String selection) {
    // First, set all selections to false
    Map<String, bool> newSelections = {};
    isSelected.forEach((key, value) {
      newSelections[key] = false;
    });

    // Then set the selected one to true
    bool currentValue = isSelected.containsKey(selection) ? isSelected[selection]! : false;
    newSelections[selection] = !currentValue;

    // Update the isSelected map
    isSelected = newSelections;

    _log.fine("Selected report type: $selection, value: ${isSelected[selection]}");
    notifyListeners();
  }

  bool getValueKey(String keyValue) {
    bool result = false;

    isSelected.forEach((key, value) {
      if (key == keyValue) {
        result = value;
      }
    });
    return result;
  }

  bool atLeastOneTypeOfIssueSelected() {
    bool atLeastOneSelected = false;
    isSelected.forEach((key, value) {
      if (value) {
        atLeastOneSelected = true;
      }
    });
    return atLeastOneSelected;
  }
}
