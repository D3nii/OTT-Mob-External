import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @abandonText.
  ///
  /// In en, this message translates to:
  /// **'Abandon'**
  String get abandonText;

  /// No description provided for @abandonTrailText.
  ///
  /// In en, this message translates to:
  /// **'Abandon trail'**
  String get abandonTrailText;

  /// No description provided for @aboutThePlace.
  ///
  /// In en, this message translates to:
  /// **'About the place'**
  String get aboutThePlace;

  /// No description provided for @abuseRudenessText.
  ///
  /// In en, this message translates to:
  /// **'Abuse/rudeness'**
  String get abuseRudenessText;

  /// No description provided for @accountDeleteConfirmationBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile information and trails will be deleted.'**
  String get accountDeleteConfirmationBody;

  /// No description provided for @accountDeleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get accountDeleteConfirmationTitle;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @addAllTheDestinationText.
  ///
  /// In en, this message translates to:
  /// **'Create boards with your friends and add activities and places to inspire your trip.'**
  String get addAllTheDestinationText;

  /// No description provided for @addAnExperienceText.
  ///
  /// In en, this message translates to:
  /// **'Add an experience!'**
  String get addAnExperienceText;

  /// No description provided for @addCollaboratorEmailText.
  ///
  /// In en, this message translates to:
  /// **'Add collaborator email'**
  String get addCollaboratorEmailText;

  /// No description provided for @addCommentText.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get addCommentText;

  /// No description provided for @addNameText.
  ///
  /// In en, this message translates to:
  /// **'Add name'**
  String get addNameText;

  /// No description provided for @addSmallDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Add a small description'**
  String get addSmallDescriptionText;

  /// No description provided for @addText.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addText;

  /// No description provided for @addToMyTrailsText.
  ///
  /// In en, this message translates to:
  /// **'Add to my trails'**
  String get addToMyTrailsText;

  /// No description provided for @addToOneOfYourTrails.
  ///
  /// In en, this message translates to:
  /// **'Add to one of your trails'**
  String get addToOneOfYourTrails;

  /// No description provided for @addToTrailText.
  ///
  /// In en, this message translates to:
  /// **'Add to trail'**
  String get addToTrailText;

  /// No description provided for @adultText.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adultText;

  /// No description provided for @allDayText.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDayText;

  /// No description provided for @applyFiltersText.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFiltersText;

  /// No description provided for @applyText.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyText;

  /// No description provided for @backText.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backText;

  /// No description provided for @boardText.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get boardText;

  /// No description provided for @byCheckingThisBoxYouAgreeText.
  ///
  /// In en, this message translates to:
  /// **'By checking this box you agree to OneTwoTrail terms and conditions. Don\'t worry we won\'t spam you with useless information.'**
  String get byCheckingThisBoxYouAgreeText;

  /// No description provided for @cancelText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelText;

  /// No description provided for @cannotAddAuthorAsCollaboratorText.
  ///
  /// In en, this message translates to:
  /// **'Cannot add the author as a collaborator'**
  String get cannotAddAuthorAsCollaboratorText;

  /// No description provided for @cashAndCreditCardText.
  ///
  /// In en, this message translates to:
  /// **'Cash & credit card'**
  String get cashAndCreditCardText;

  /// No description provided for @cashText.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashText;

  /// No description provided for @changeMyPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Change my password'**
  String get changeMyPasswordText;

  /// No description provided for @changePasswordText.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordText;

  /// No description provided for @changeText.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeText;

  /// No description provided for @changesSavedText.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSavedText;

  /// No description provided for @changesWillBeLostText.
  ///
  /// In en, this message translates to:
  /// **'Changes will be lost if you abandon without saving.'**
  String get changesWillBeLostText;

  /// No description provided for @codeMessageText.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your email. Please insert the code here and to reset your password.'**
  String get codeMessageText;

  /// No description provided for @complementYourTripText.
  ///
  /// In en, this message translates to:
  /// **'Complement your trip with some of these places on your way. '**
  String get complementYourTripText;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmNewPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordText;

  /// No description provided for @confirmPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordText;

  /// No description provided for @countryText.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryText;

  /// No description provided for @createItineraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Create itinerary'**
  String get createItineraryTitle;

  /// No description provided for @createNewTrailText.
  ///
  /// In en, this message translates to:
  /// **'Create new trail'**
  String get createNewTrailText;

  /// No description provided for @creditCardText.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get creditCardText;

  /// No description provided for @currentPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordText;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this trail?'**
  String get deleteConfirmation;

  /// No description provided for @deleteMyAccountText.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccountText;

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteText;

  /// No description provided for @deleteTrailText.
  ///
  /// In en, this message translates to:
  /// **'Delete trail'**
  String get deleteTrailText;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'description'**
  String get description;

  /// No description provided for @discoverCRText.
  ///
  /// In en, this message translates to:
  /// **'Discover Costa Rica!'**
  String get discoverCRText;

  /// No description provided for @discoverHeadline.
  ///
  /// In en, this message translates to:
  /// **'An evolving feed of experiences and trails'**
  String get discoverHeadline;

  /// No description provided for @discoverNotAvailableText.
  ///
  /// In en, this message translates to:
  /// **'Discover is not available'**
  String get discoverNotAvailableText;

  /// No description provided for @discoverText.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverText;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @doneText.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneText;

  /// No description provided for @easyRoute.
  ///
  /// In en, this message translates to:
  /// **'Easy route'**
  String get easyRoute;

  /// No description provided for @editDetailsTrailText.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get editDetailsTrailText;

  /// No description provided for @editProfileText.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileText;

  /// No description provided for @editTheDetailsFromYourTrailText.
  ///
  /// In en, this message translates to:
  /// **'Edit the details of your Trail.'**
  String get editTheDetailsFromYourTrailText;

  /// No description provided for @eighteenAndOlder.
  ///
  /// In en, this message translates to:
  /// **'18 and older'**
  String get eighteenAndOlder;

  /// No description provided for @eighteenPlus.
  ///
  /// In en, this message translates to:
  /// **'18+'**
  String get eighteenPlus;

  /// No description provided for @emailNotVerifiedContent.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email to continue.'**
  String get emailNotVerifiedContent;

  /// No description provided for @emailNotVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerifiedTitle;

  /// No description provided for @emailText.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailText;

  /// No description provided for @emailUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Email address unavailable'**
  String get emailUnavailable;

  /// No description provided for @emptySearchText.
  ///
  /// In en, this message translates to:
  /// **'Experiences tailored to you!'**
  String get emptySearchText;

  /// No description provided for @enterUserNameErrorText.
  ///
  /// In en, this message translates to:
  /// **'Please enter a user name'**
  String get enterUserNameErrorText;

  /// No description provided for @enterYourEmailText.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmailText;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get estimatedTime;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'experience'**
  String get experience;

  /// No description provided for @experienceHidden.
  ///
  /// In en, this message translates to:
  /// **'Experience hidden'**
  String get experienceHidden;

  /// No description provided for @experiences.
  ///
  /// In en, this message translates to:
  /// **'experiences'**
  String get experiences;

  /// No description provided for @experiencesOnTheMap.
  ///
  /// In en, this message translates to:
  /// **'Experiences on the map'**
  String get experiencesOnTheMap;

  /// No description provided for @filterText.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterText;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @forgotPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Forgot my password'**
  String get forgotPasswordText;

  /// No description provided for @generateAnItineraryAfterAddingExperienceText.
  ///
  /// In en, this message translates to:
  /// **'Generate an itinerary after you add an experience to your trail.'**
  String get generateAnItineraryAfterAddingExperienceText;

  /// No description provided for @generateItineraryText.
  ///
  /// In en, this message translates to:
  /// **'Create itinerary'**
  String get generateItineraryText;

  /// No description provided for @generateText.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get generateText;

  /// No description provided for @geoReferenceText.
  ///
  /// In en, this message translates to:
  /// **'Important reference points regarding this place.'**
  String get geoReferenceText;

  /// No description provided for @gettingText.
  ///
  /// In en, this message translates to:
  /// **'Getting...'**
  String get gettingText;

  /// No description provided for @goNowText.
  ///
  /// In en, this message translates to:
  /// **'Go now'**
  String get goNowText;

  /// No description provided for @goToDetailText.
  ///
  /// In en, this message translates to:
  /// **'Go to detail'**
  String get goToDetailText;

  /// No description provided for @goToLoginText.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLoginText;

  /// No description provided for @goToMapText.
  ///
  /// In en, this message translates to:
  /// **'Go to map'**
  String get goToMapText;

  /// No description provided for @hardRoute.
  ///
  /// In en, this message translates to:
  /// **'Hard route'**
  String get hardRoute;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @howBadlyText.
  ///
  /// In en, this message translates to:
  /// **'How badly this affected your trip?'**
  String get howBadlyText;

  /// No description provided for @howManyPeopleText.
  ///
  /// In en, this message translates to:
  /// **'Are you traveling with someone?'**
  String get howManyPeopleText;

  /// No description provided for @hrsText.
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get hrsText;

  /// No description provided for @hygieneText.
  ///
  /// In en, this message translates to:
  /// **'Hygiene'**
  String get hygieneText;

  /// No description provided for @importantRecommendationsText.
  ///
  /// In en, this message translates to:
  /// **'Important recommendations'**
  String get importantRecommendationsText;

  /// No description provided for @includesACapitalLetterText.
  ///
  /// In en, this message translates to:
  /// **'Includes a capital letter'**
  String get includesACapitalLetterText;

  /// No description provided for @includesANumberText.
  ///
  /// In en, this message translates to:
  /// **'Includes a number'**
  String get includesANumberText;

  /// No description provided for @incorrectCodeText.
  ///
  /// In en, this message translates to:
  /// **'The code is incorrect'**
  String get incorrectCodeText;

  /// No description provided for @insertACorrectEmailText.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get insertACorrectEmailText;

  /// No description provided for @insertCodeText.
  ///
  /// In en, this message translates to:
  /// **'Insert code'**
  String get insertCodeText;

  /// No description provided for @inspireText.
  ///
  /// In en, this message translates to:
  /// **'Get\ninspired!'**
  String get inspireText;

  /// No description provided for @invalidCollaborators.
  ///
  /// In en, this message translates to:
  /// **'Invalid collaborator'**
  String get invalidCollaborators;

  /// No description provided for @invalidCollaboratorsLegend.
  ///
  /// In en, this message translates to:
  /// **'The collaborator to add is not registered.'**
  String get invalidCollaboratorsLegend;

  /// No description provided for @issueCommentText.
  ///
  /// In en, this message translates to:
  /// **'There reports will help us take action and inform the providers so this doesn\'t happen again.'**
  String get issueCommentText;

  /// No description provided for @itineraryText.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get itineraryText;

  /// No description provided for @itsAnSmallDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'It\'s a small description of the trail from the user'**
  String get itsAnSmallDescriptionText;

  /// No description provided for @kidFriendlyText.
  ///
  /// In en, this message translates to:
  /// **'Kid friendly'**
  String get kidFriendlyText;

  /// No description provided for @kidsText.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kidsText;

  /// No description provided for @lastNameText.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameText;

  /// No description provided for @leaveText.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveText;

  /// No description provided for @leaveWithoutSavingText.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get leaveWithoutSavingText;

  /// No description provided for @lessThanText.
  ///
  /// In en, this message translates to:
  /// **'Less than 12y/o'**
  String get lessThanText;

  /// No description provided for @letsStartText.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start!'**
  String get letsStartText;

  /// No description provided for @limitedText.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get limitedText;

  /// No description provided for @locationText.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationText;

  /// No description provided for @logInText.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInText;

  /// No description provided for @logOutText.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutText;

  /// No description provided for @mapText.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapText;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markAsDone;

  /// No description provided for @markAsNotVisited.
  ///
  /// In en, this message translates to:
  /// **'Mark as not visited'**
  String get markAsNotVisited;

  /// No description provided for @markAsVisited.
  ///
  /// In en, this message translates to:
  /// **'Mark as visited'**
  String get markAsVisited;

  /// No description provided for @maxCapacity.
  ///
  /// In en, this message translates to:
  /// **'Max capacity'**
  String get maxCapacity;

  /// No description provided for @mediumRoute.
  ///
  /// In en, this message translates to:
  /// **'Medium route'**
  String get mediumRoute;

  /// No description provided for @moreDetailsText.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get moreDetailsText;

  /// No description provided for @nameEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Name is empty'**
  String get nameEmptyText;

  /// No description provided for @nameForTrailText.
  ///
  /// In en, this message translates to:
  /// **'Name for trail'**
  String get nameForTrailText;

  /// No description provided for @nearbyText.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearbyText;

  /// No description provided for @newPasswordMatchText.
  ///
  /// In en, this message translates to:
  /// **'New password confirmation match'**
  String get newPasswordMatchText;

  /// No description provided for @newPasswordText.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordText;

  /// No description provided for @newTrailText.
  ///
  /// In en, this message translates to:
  /// **'New trail'**
  String get newTrailText;

  /// No description provided for @nextText.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextText;

  /// No description provided for @noExperiences.
  ///
  /// In en, this message translates to:
  /// **'No experiences'**
  String get noExperiences;

  /// No description provided for @noSearchResultText.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResultText;

  /// No description provided for @notGeoPointToShowText.
  ///
  /// In en, this message translates to:
  /// **'No geo-point to show'**
  String get notGeoPointToShowText;

  /// No description provided for @notPetFriendly.
  ///
  /// In en, this message translates to:
  /// **'Not pet friendly'**
  String get notPetFriendly;

  /// No description provided for @okText.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okText;

  /// No description provided for @oneToTwoHoursText.
  ///
  /// In en, this message translates to:
  /// **'1 to 2 hours'**
  String get oneToTwoHoursText;

  /// No description provided for @oopsText.
  ///
  /// In en, this message translates to:
  /// **'Ooooops!'**
  String get oopsText;

  /// No description provided for @openInText.
  ///
  /// In en, this message translates to:
  /// **'Open in'**
  String get openInText;

  /// No description provided for @orGoToLoginText.
  ///
  /// In en, this message translates to:
  /// **'or go to login'**
  String get orGoToLoginText;

  /// No description provided for @orLoginText.
  ///
  /// In en, this message translates to:
  /// **'or log in'**
  String get orLoginText;

  /// No description provided for @orLoginWithText.
  ///
  /// In en, this message translates to:
  /// **'or log in with'**
  String get orLoginWithText;

  /// No description provided for @orSignUpText.
  ///
  /// In en, this message translates to:
  /// **'or sign in with'**
  String get orSignUpText;

  /// No description provided for @orSignUpWithText.
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
  String get orSignUpWithText;

  /// No description provided for @otherText.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherText;

  /// No description provided for @parkingIndoorText.
  ///
  /// In en, this message translates to:
  /// **'indoor'**
  String get parkingIndoorText;

  /// No description provided for @parkingOutdoorText.
  ///
  /// In en, this message translates to:
  /// **'outdoor'**
  String get parkingOutdoorText;

  /// No description provided for @parkingText.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parkingText;

  /// No description provided for @passwordHas8CharactersText.
  ///
  /// In en, this message translates to:
  /// **'Password has 8 characters.'**
  String get passwordHas8CharactersText;

  /// No description provided for @passwordText.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordText;

  /// No description provided for @passwordToShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordToShort;

  /// No description provided for @passwordWasChangedText.
  ///
  /// In en, this message translates to:
  /// **'Password was change'**
  String get passwordWasChangedText;

  /// No description provided for @personalText.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalText;

  /// No description provided for @petFriendly.
  ///
  /// In en, this message translates to:
  /// **'Pet friendly'**
  String get petFriendly;

  /// No description provided for @phoneText.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneText;

  /// No description provided for @pinnedExperiences.
  ///
  /// In en, this message translates to:
  /// **'Pinned experiences are fixed to a date and time during your itinerary.'**
  String get pinnedExperiences;

  /// No description provided for @pleaseRegisterBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account or sign up to create a new one.'**
  String get pleaseRegisterBody;

  /// No description provided for @pleaseRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please register'**
  String get pleaseRegisterTitle;

  /// No description provided for @pleaseVerifyYourEmailText.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address'**
  String get pleaseVerifyYourEmailText;

  /// No description provided for @profileHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your profile information and saved trails'**
  String get profileHeadline;

  /// No description provided for @profileText.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileText;

  /// No description provided for @recentlyDeletedText.
  ///
  /// In en, this message translates to:
  /// **'Recently deleted'**
  String get recentlyDeletedText;

  /// No description provided for @registerUserText.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerUserText;

  /// No description provided for @relatedText.
  ///
  /// In en, this message translates to:
  /// **'Related'**
  String get relatedText;

  /// No description provided for @removeText.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeText;

  /// No description provided for @reportIssueText.
  ///
  /// In en, this message translates to:
  /// **'These reports will help us to take action and inform the providers so this does not happen again.'**
  String get reportIssueText;

  /// No description provided for @reportIssuesSelectAtLeastOneTypeOfIssueText.
  ///
  /// In en, this message translates to:
  /// **'Select at least one issue.'**
  String get reportIssuesSelectAtLeastOneTypeOfIssueText;

  /// No description provided for @reportIssuesText.
  ///
  /// In en, this message translates to:
  /// **'Report issues'**
  String get reportIssuesText;

  /// No description provided for @reportSubmittedText.
  ///
  /// In en, this message translates to:
  /// **'Thanks for reporting the issue!'**
  String get reportSubmittedText;

  /// No description provided for @reportText.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportText;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @resetMyPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Reset my password'**
  String get resetMyPasswordText;

  /// No description provided for @resetPasswordEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a verification code.'**
  String get resetPasswordEnterEmail;

  /// No description provided for @resetPasswordErrorText.
  ///
  /// In en, this message translates to:
  /// **'Something has gone wrong. Please check your email or contact support.'**
  String get resetPasswordErrorText;

  /// No description provided for @saveChangesText.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesText;

  /// No description provided for @saveText.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveText;

  /// No description provided for @savedImage.
  ///
  /// In en, this message translates to:
  /// **'Saved image'**
  String get savedImage;

  /// No description provided for @scamText.
  ///
  /// In en, this message translates to:
  /// **'Scam'**
  String get scamText;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchByCountryName.
  ///
  /// In en, this message translates to:
  /// **'Search by country name'**
  String get searchByCountryName;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @seeAllWhatCostaRica.
  ///
  /// In en, this message translates to:
  /// **'See all what Costa Rica has to offer tailored to you.'**
  String get seeAllWhatCostaRica;

  /// No description provided for @seeMoreText.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMoreText;

  /// No description provided for @seemsLikeAGoodTimeText.
  ///
  /// In en, this message translates to:
  /// **'Seems like a good time to grab a bite'**
  String get seemsLikeAGoodTimeText;

  /// No description provided for @selectAPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Select a password'**
  String get selectAPasswordText;

  /// No description provided for @selectAtLeast3TypesText.
  ///
  /// In en, this message translates to:
  /// **'Select at least 3 types of experiences you would be interested in'**
  String get selectAtLeast3TypesText;

  /// No description provided for @selectAtLeastOneAdultText.
  ///
  /// In en, this message translates to:
  /// **'Select at least one adult to create the Itinerary'**
  String get selectAtLeastOneAdultText;

  /// No description provided for @selectTrailText.
  ///
  /// In en, this message translates to:
  /// **'Select to which trail you want to add this experience.'**
  String get selectTrailText;

  /// No description provided for @selectYourStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select your start date'**
  String get selectYourStartDate;

  /// No description provided for @sendEmailText.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get sendEmailText;

  /// No description provided for @sendReportText.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get sendReportText;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @similarExperiencesText.
  ///
  /// In en, this message translates to:
  /// **'Similar places in Costa Rica'**
  String get similarExperiencesText;

  /// No description provided for @somethingWentWrongRequestText.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with your request'**
  String get somethingWentWrongRequestText;

  /// No description provided for @somethingWentWrongText.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrongText;

  /// No description provided for @spaceIsInBlankText.
  ///
  /// In en, this message translates to:
  /// **'The space is in blank.'**
  String get spaceIsInBlankText;

  /// No description provided for @startYourItineraryText.
  ///
  /// In en, this message translates to:
  /// **'Start your itinerary!'**
  String get startYourItineraryText;

  /// No description provided for @teensText.
  ///
  /// In en, this message translates to:
  /// **'Teens'**
  String get teensText;

  /// No description provided for @tellUsSomeDetailsText.
  ///
  /// In en, this message translates to:
  /// **'Tell us some details about your new trail.'**
  String get tellUsSomeDetailsText;

  /// No description provided for @tellUsWhatYouEnjoyText.
  ///
  /// In en, this message translates to:
  /// **'Tell us what do you enjoy!'**
  String get tellUsWhatYouEnjoyText;

  /// No description provided for @thanksIssueText.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get thanksIssueText;

  /// No description provided for @thisTrailWillBeReset.
  ///
  /// In en, this message translates to:
  /// **'This trail will be reset to day one and displayed as \"Ready to start\"'**
  String get thisTrailWillBeReset;

  /// No description provided for @threeToSixHoursText.
  ///
  /// In en, this message translates to:
  /// **'3 to 6 hours'**
  String get threeToSixHoursText;

  /// No description provided for @threeTopicsText.
  ///
  /// In en, this message translates to:
  /// **'3 topics '**
  String get threeTopicsText;

  /// No description provided for @trailAddedText.
  ///
  /// In en, this message translates to:
  /// **'Trail added'**
  String get trailAddedText;

  /// No description provided for @trailIsPublicText.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get trailIsPublicText;

  /// No description provided for @trailPublishedText.
  ///
  /// In en, this message translates to:
  /// **'Trail published'**
  String get trailPublishedText;

  /// No description provided for @trailRemovedText.
  ///
  /// In en, this message translates to:
  /// **'Trail removed'**
  String get trailRemovedText;

  /// No description provided for @trailUnpublishedText.
  ///
  /// In en, this message translates to:
  /// **'Trail unpublished'**
  String get trailUnpublishedText;

  /// No description provided for @trailWillBeDeletedText.
  ///
  /// In en, this message translates to:
  /// **'Trail will be deleted'**
  String get trailWillBeDeletedText;

  /// No description provided for @trailsText.
  ///
  /// In en, this message translates to:
  /// **'Trails'**
  String get trailsText;

  /// No description provided for @transformThoseBoardsText.
  ///
  /// In en, this message translates to:
  /// **'We´ll bring those boards to life through itineraries that will lay out your trip day by day.'**
  String get transformThoseBoardsText;

  /// No description provided for @travelTimeText.
  ///
  /// In en, this message translates to:
  /// **'Travel time'**
  String get travelTimeText;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @twelveToSeventeenText.
  ///
  /// In en, this message translates to:
  /// **'12-17 y/o'**
  String get twelveToSeventeenText;

  /// No description provided for @typeOfIssueText.
  ///
  /// In en, this message translates to:
  /// **'Type of issue'**
  String get typeOfIssueText;

  /// No description provided for @untilTomorrowTimeText.
  ///
  /// In en, this message translates to:
  /// **'Time to spare and rest until tomorrow'**
  String get untilTomorrowTimeText;

  /// No description provided for @updateItineraryText.
  ///
  /// In en, this message translates to:
  /// **'Update itinerary'**
  String get updateItineraryText;

  /// No description provided for @updatingText.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get updatingText;

  /// No description provided for @verifyYourEmailAndLogIn.
  ///
  /// In en, this message translates to:
  /// **'Verify your email and log in to enjoy your new adventure!'**
  String get verifyYourEmailAndLogIn;

  /// No description provided for @verifyYourEmailText.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmailText;

  /// No description provided for @weGotItCovered.
  ///
  /// In en, this message translates to:
  /// **'We got it covered!'**
  String get weGotItCovered;

  /// No description provided for @welcomeToYourAdventureText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your adventure!'**
  String get welcomeToYourAdventureText;

  /// No description provided for @wheelchairText.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair'**
  String get wheelchairText;

  /// No description provided for @whichOfTheseFixedExperiencesText.
  ///
  /// In en, this message translates to:
  /// **'Which experiences do you want to keep as pinned?'**
  String get whichOfTheseFixedExperiencesText;

  /// No description provided for @wouldYouRecommend.
  ///
  /// In en, this message translates to:
  /// **'Would you recommend this experience?'**
  String get wouldYouRecommend;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong credentials'**
  String get wrongCredentials;

  /// No description provided for @youCantLeaveCommentEmptyText.
  ///
  /// In en, this message translates to:
  /// **'You can\'t leave the comment empty'**
  String get youCantLeaveCommentEmptyText;

  /// No description provided for @youCantRemoveAllExperiencesText.
  ///
  /// In en, this message translates to:
  /// **'You can\'t remove all the experiences from the trail'**
  String get youCantRemoveAllExperiencesText;

  /// No description provided for @youCantSelectADayBeforeTheStartDayText.
  ///
  /// In en, this message translates to:
  /// **'You can\'t select a day before the start day of the trail'**
  String get youCantSelectADayBeforeTheStartDayText;

  /// No description provided for @youHaveNotCreatedText.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created an itinerary for this trail. Generate one in one step now and start your adventure!'**
  String get youHaveNotCreatedText;

  /// No description provided for @yourCurrentPasswordIsIncorrectText.
  ///
  /// In en, this message translates to:
  /// **'Your current password is incorrect'**
  String get yourCurrentPasswordIsIncorrectText;

  /// No description provided for @yourItineraryWillBeReady.
  ///
  /// In en, this message translates to:
  /// **'Your itinerary will be ready in a moment!'**
  String get yourItineraryWillBeReady;

  /// No description provided for @yourVotesCouldMakeThis.
  ///
  /// In en, this message translates to:
  /// **'Your votes could make this experience a starred recommendation.'**
  String get yourVotesCouldMakeThis;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
