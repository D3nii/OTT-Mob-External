import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/base_response.dart' as Base;
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/country.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/services/crash_reporter.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';

class ProfileEditViewModel extends BaseModel {
  StreamSubscription<Base.BaseResponse<User>>? _userLoadStreamSubscription;
  late AuthenticationService _authenticationService;
  late ProfileService _profileService;
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _lastNameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  List<Experience> _experiences = [];
  File? _image;
  ImagePicker _imagePicker = ImagePicker();
  ImageProvider _profileImage = AssetImage('assets/icons/user.png');
  bool _unsavedChanges = false;
  bool _unsavedCountry = false;
  bool _saveWarningVisible = false;
  bool _successToastVisible = false;
  String _selectedCountry = "";
  String _initialSelectedCountry = "";
  bool _loadedProfile = false;
  Timer? _debounce;
  bool _savingChanges = false;
  String userAvatar = '';
  String userCountry = '';
  User? _user; // Store the user object

  bool get savingChanges => _savingChanges;

  AuthenticationService get authenticationService => _authenticationService;

  FocusNode get firstNameFocusNode => _nameFocusNode;

  FocusNode get lastNameFocusNode => _lastNameFocusNode;

  FocusNode get emailFocusNode => _emailFocusNode;

  FocusNode get phoneFocusNode => _phoneFocusNode;

  TextEditingController get firstNameTextController => _nameTextController;

  TextEditingController get lastNameTextController => _lastNameTextController;

  TextEditingController get emailTextController => _emailTextController;

  ProfileService get profileService => _profileService;

  List<Experience> get experiences => _experiences;

  ImageProvider get profileImage => _profileImage;

  bool get unsavedChanges => _unsavedChanges;

  bool get unsavedCountry => _unsavedCountry;

  bool get successToastVisible => _successToastVisible;

  bool get saveWarningVisible => _saveWarningVisible;

  String get selectedCountry => _selectedCountry;

  String get initialSelectedCountry => _initialSelectedCountry;

  PhoneNumber _number = PhoneNumber(dialCode: '506');

  PhoneNumber get number => _number;
  String _phone = '';

  String get phone => _phone;

  TextEditingController _phoneNumberController = MaskedTextController(mask: '0000-0000-0000-0000');

  TextEditingController get phoneNumberController => _phoneNumberController;

  set phoneNumberController(TextEditingController value) {
    _phoneNumberController = value;
    notifyListeners();
  }

  // Setters
  set phone(String value) {
    _phone = value;
    notifyListeners();
  }

  set number(PhoneNumber value) {
    _number = value;
    notifyListeners();
  }

  set unsavedCountry(bool value) {
    _unsavedCountry = value;
    notifyListeners();
  }

  set initialSelectedCountry(String value) {
    _initialSelectedCountry = value;
    notifyListeners();
  }

  set selectedCountry(String value) {
    _selectedCountry = value;
    notifyListeners();
  }

  set saveWarningVisible(bool value) {
    _saveWarningVisible = value;
    notifyListeners();
  }

  set successToastVisible(bool value) {
    _successToastVisible = value;
    notifyListeners();
  }

  set unsavedChanges(bool value) {
    if (!_loadedProfile) {
      return;
    }
    _unsavedChanges = value;
    notifyListeners();
  }

  set profileImage(ImageProvider value) {
    _profileImage = value;
    notifyListeners();
  }

  set profileService(ProfileService value) {
    _profileService = value;
    notifyListeners();
  }

  set authenticationService(AuthenticationService value) {
    _authenticationService = value;
    notifyListeners();
  }

  set experiences(List<Experience> value) {
    _experiences = value;
    notifyListeners();
  }

  set firstNameFocusNode(FocusNode focusNode) {
    if (firstNameFocusNode != _nameFocusNode) {
      _nameFocusNode = firstNameFocusNode;
      notifyListeners();
    }
  }

  set lastNameFocusNode(FocusNode focusNode) {
    if (lastNameFocusNode != _lastNameFocusNode) {
      _lastNameFocusNode = lastNameFocusNode;
      notifyListeners();
    }
  }

  set emailFocusNode(FocusNode focusNode) {
    if (emailFocusNode != _emailFocusNode) {
      _emailFocusNode = emailFocusNode;
      notifyListeners();
    }
  }

  set phoneFocusNode(FocusNode focusNode) {
    if (phoneFocusNode != _phoneFocusNode) {
      _phoneFocusNode = phoneFocusNode;
      notifyListeners();
    }
  }

  set firstNameTextController(TextEditingController nameTextController) {
    if (nameTextController != _nameTextController) {
      _nameTextController = nameTextController;
      notifyListeners();
    }
  }

  set emailTextController(TextEditingController emailTextController) {
    if (emailTextController != _emailTextController) {
      _emailTextController = emailTextController;
      notifyListeners();
    }
  }

  Future<void> init() async {
    // Initialize user profile from service
    await loadUserProfile(profileService.user);
    _userLoadStreamSubscription = profileService.userResponseStream.listen((event) async {
      if (event.responseStatus == "SUCCESS") {
        await loadUserProfile(event.data);
      }
    });
  }

  loadProfileImage(String avatarUrl) {
    if (avatarUrl != "") {
      profileImage = NetworkImage(avatarUrl + ".png");
    } else {
      profileImage = AssetImage("assets/icons/user.png");
    }
  }

  Future<void> loadUserProfile(User user) async {
    _loadedProfile = false;
    _user = user; // Store the user object
    loadProfileImage(user.avatar);
    firstNameTextController.text = user.firstName;
    lastNameTextController.text = user.lastName;
    emailTextController.text = user.email;
    initialSelectedCountry = user.country;
    userAvatar = user.avatar;
    userCountry = user.country;
    experiences = user.visitedExperiences;
    if (user.phoneNumber != '') {
      // Parse the phone number using intl_phone_number_input package
      try {
        // Attempt to parse the phone number
        PhoneNumber parsedNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(user.phoneNumber);

        // Set the parsed values
        phone = parsedNumber.phoneNumber ?? user.phoneNumber;
        number = parsedNumber;
        phoneNumberController.text = parsedNumber.phoneNumber ?? user.phoneNumber;
      } catch (e, stackTrace) {
        CrashReporter.reportError(
          e,
          stackTrace,
          context: 'Failed to parse phone number',
          attributes: {
            'phone_number': user.phoneNumber,
            'user_id': user.id,
          },
        );
        // Fallback if parsing fails
        phone = user.phoneNumber;
        number = PhoneNumber(phoneNumber: user.phoneNumber);
        phoneNumberController.text = phone;
      }
    }
    notifyListeners();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _loadedProfile = true;
    });
  }

  updateCountry(Country selectedCountry) {
    unsavedCountry = initialSelectedCountry != selectedCountry.code;
    this.selectedCountry = selectedCountry.code;
    this.userCountry = selectedCountry.code;

    // Update the user object's country if it exists
    if (_user != null) {
      _user!.country = selectedCountry.code;
    }

    notifyListeners();
  }

  // Get the country name from the User model
  String getUserCountryName() {
    // If we have no country code, return empty string
    if (userCountry.isEmpty) {
      return "";
    }

    // If we have a user object, use its countryName getter
    if (_user != null) {
      return _user!.countryName;
    }

    // Fallback if user object is not available (should not happen)
    return "";
  }


  unfocusAllTextFields() {
    firstNameFocusNode.unfocus();
    lastNameFocusNode.unfocus();
    phoneFocusNode.unfocus();
    emailFocusNode.unfocus();
  }

  saveChanges(BuildContext context, {bool popView = false}) async {
    saveWarningVisible = false;
    if (!unsavedChanges && !unsavedCountry) {
      return;
    }

    _savingChanges = true;
    notifyListeners();

    // Only include the fields that can be updated by the user
    // The phone number is not editable in the UI, so we don't include it
    Map<String, String> data = {
      'email': emailTextController.text,
      'first_name': firstNameTextController.text,
      'last_name': lastNameTextController.text,
      'country': selectedCountry
    };

    // Send the update request
    var updatedUser = await profileService.putProfileInfo(data);

    // Update our stored user object with the response
    if (updatedUser.responseStatus == SUCCESS) {
      _user = updatedUser.data;
    }

    unsavedChanges = false;
    unsavedCountry = false;
    _savingChanges = false;
    await Future.delayed(Duration(milliseconds: 300));

    if (updatedUser.responseStatus == SUCCESS) {
      if (popView) {
        Navigator.pop(context);
      } else {
        showSavedChanges();
        notifyListeners();
      }
    } else {
      Dialogs.showSomethingWentWrongDialog(context);
    }
  }

  logout() {
    authenticationService.signOut();
  }

  tryToLeave(BuildContext context) {
    if (unsavedChanges || unsavedCountry) {
      saveWarningVisible = true;
    } else {
      Navigator.pop(context);
    }
  }

  leaveView(BuildContext context) {
    saveWarningVisible = false;
    Navigator.pop(context);
  }

  updateEmail() {
    // String email = emailTextController.text;
    // var emailValid = _isValidEmail(email) ? true : false;
    notifyListeners();
  }

  showSavedChanges() async {
    _successToastVisible = true;
    notifyListeners();
    Future.delayed(Duration(seconds: 2)).then((value) {
      _successToastVisible = false;
      notifyListeners();
    });
  }

  Future<void> pickImage(BuildContext context) async {
    try {
      setState(ViewState.Busy);
      _savingChanges = true;
      notifyListeners();

      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        return;
      }

      _image = File(pickedFile.path);
      List<int> imageBytes = _image!.readAsBytesSync();
      String imageBase64 = base64.encode(imageBytes);
      imageBase64 = "data:image/png;base64," + imageBase64;
      Map<String, String> data = {'avatar': imageBase64};

      Base.BaseResponse<User> response = await profileService.putProfileInfo(data);

      if (response.responseStatus == Base.SUCCESS) {
        // Update our stored user object with the response
        _user = response.data;

        if (_image != null) {
          _profileImage = FileImage(_image!);
        }
      } else {
        Dialogs.showSomethingWentWrongDialog(context);
      }
    } catch (error, stackTrace) {
      CrashReporter.reportError(
        error,
        stackTrace,
        context: 'Failed to pick and upload profile image',
      );
      Dialogs.showSomethingWentWrongDialog(context);
    } finally {
      setState(ViewState.Idle);
      _savingChanges = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userLoadStreamSubscription?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> deleteAccount(BuildContext context) async {
    _savingChanges = true;
    notifyListeners();

    var dialog = await Dialogs.showErrorDialog(
      context: context,
      title: AppLocalizations.of(context)?.accountDeleteConfirmationTitle ?? 'Delete Account',
      body: AppLocalizations.of(context)?.accountDeleteConfirmationBody ?? 'Are you sure you want to delete your account?',
      action: DialogAction(
        title: AppLocalizations.of(context)?.deleteMyAccountText ?? 'Delete My Account',
        onPressed: (context) async {
          var deleted = await _profileService.deleteAccount();
          Navigator.pop(context, deleted ? 'deleted' : 'error');
        },
        onDismissed: (context) => Navigator.pop(context, 'dismissed'),
      ),
    );

    switch (dialog) {
      case 'deleted':
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.accountDeleted ?? 'Account deleted',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: black70Transparent,
            textColor: Colors.white,
            fontSize: 16.0);
        break;
      case 'error':
        Dialogs.showSomethingWentWrongDialog(context);
        break;
      case 'dismissed':
        break;
    }

    _savingChanges = false;
    notifyListeners();
  }
}
