import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('rw'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AI Health Companion'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'AI-powered disease diagnosis for rural clinics'**
  String get appDescription;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @clinics.
  ///
  /// In en, this message translates to:
  /// **'Clinics'**
  String get clinics;

  /// No description provided for @aiDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnosis'**
  String get aiDiagnosis;

  /// No description provided for @runDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Run Diagnosis'**
  String get runDiagnosis;

  /// No description provided for @diagnosisResults.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Results'**
  String get diagnosisResults;

  /// No description provided for @diagnosisHistory.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis History'**
  String get diagnosisHistory;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @selectSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Select Symptoms'**
  String get selectSymptoms;

  /// No description provided for @vitalSigns.
  ///
  /// In en, this message translates to:
  /// **'Vital Signs'**
  String get vitalSigns;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @respiratoryRate.
  ///
  /// In en, this message translates to:
  /// **'Respiratory Rate'**
  String get respiratoryRate;

  /// No description provided for @oxygenSaturation.
  ///
  /// In en, this message translates to:
  /// **'Oxygen Saturation'**
  String get oxygenSaturation;

  /// No description provided for @predictions.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get predictions;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @nearbyPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Nearby Pharmacies'**
  String get nearbyPharmacies;

  /// No description provided for @pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacy;

  /// No description provided for @pharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get pharmacies;

  /// No description provided for @pharmaciesAvailable.
  ///
  /// In en, this message translates to:
  /// **'pharmacies available'**
  String get pharmaciesAvailable;

  /// No description provided for @searchPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Search by pharmacy, medicine, or location...'**
  String get searchPharmacies;

  /// No description provided for @loadingPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Loading pharmacies...'**
  String get loadingPharmacies;

  /// No description provided for @errorLoadingPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Error loading pharmacies'**
  String get errorLoadingPharmacies;

  /// No description provided for @noPharmaciesFound.
  ///
  /// In en, this message translates to:
  /// **'No pharmacies found'**
  String get noPharmaciesFound;

  /// No description provided for @noMatchingPharmacies.
  ///
  /// In en, this message translates to:
  /// **'No matching pharmacies'**
  String get noMatchingPharmacies;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @availableMedicines.
  ///
  /// In en, this message translates to:
  /// **'Available Medicines'**
  String get availableMedicines;

  /// No description provided for @noMedicinesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No medicines currently available'**
  String get noMedicinesAvailable;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening Hours'**
  String get openingHours;

  /// No description provided for @cannotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Cannot open phone dialer'**
  String get cannotOpenDialer;

  /// No description provided for @cannotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Cannot open maps'**
  String get cannotOpenMaps;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @patientInfo.
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get patientInfo;

  /// No description provided for @patientList.
  ///
  /// In en, this message translates to:
  /// **'Patient List'**
  String get patientList;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @editPatient.
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get editPatient;

  /// No description provided for @patientDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient Details'**
  String get patientDetails;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @kinyarwanda.
  ///
  /// In en, this message translates to:
  /// **'Kinyarwanda'**
  String get kinyarwanda;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatus;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get lastLogin;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection error'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @offlineError.
  ///
  /// In en, this message translates to:
  /// **'App is in offline mode'**
  String get offlineError;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully'**
  String get syncSuccess;

  /// No description provided for @diagnosisSuccess.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis completed'**
  String get diagnosisSuccess;

  /// No description provided for @patientSaved.
  ///
  /// In en, this message translates to:
  /// **'Patient information saved'**
  String get patientSaved;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password Changed'**
  String get passwordChanged;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid password'**
  String get invalidPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get admin;

  /// No description provided for @healthWorker.
  ///
  /// In en, this message translates to:
  /// **'Health Worker'**
  String get healthWorker;

  /// No description provided for @clinicStaff.
  ///
  /// In en, this message translates to:
  /// **'Clinic Staff'**
  String get clinicStaff;

  /// No description provided for @supervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisor;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @clinicsAvailable.
  ///
  /// In en, this message translates to:
  /// **'clinics available'**
  String get clinicsAvailable;

  /// No description provided for @searchClinics.
  ///
  /// In en, this message translates to:
  /// **'Search by name, specialty, or location...'**
  String get searchClinics;

  /// No description provided for @loadingClinics.
  ///
  /// In en, this message translates to:
  /// **'Loading clinics...'**
  String get loadingClinics;

  /// No description provided for @errorLoadingClinics.
  ///
  /// In en, this message translates to:
  /// **'Error loading clinics'**
  String get errorLoadingClinics;

  /// No description provided for @noClinicsFound.
  ///
  /// In en, this message translates to:
  /// **'No clinics found'**
  String get noClinicsFound;

  /// No description provided for @noMatchingClinics.
  ///
  /// In en, this message translates to:
  /// **'No matching clinics'**
  String get noMatchingClinics;

  /// No description provided for @specialties.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialties;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @generalMedicine.
  ///
  /// In en, this message translates to:
  /// **'General Medicine'**
  String get generalMedicine;

  /// No description provided for @empoweringRuralHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Empowering Rural Healthcare'**
  String get empoweringRuralHealthcare;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @emailMustContainAt.
  ///
  /// In en, this message translates to:
  /// **'Email must contain @'**
  String get emailMustContainAt;

  /// No description provided for @enterValidDomain.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid domain (e.g. gmail.com)'**
  String get enterValidDomain;

  /// No description provided for @domainMustContainDot.
  ///
  /// In en, this message translates to:
  /// **'Domain must contain a dot (e.g. .com, .org)'**
  String get domainMustContainDot;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @aiDiagnosisAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnosis Assistant'**
  String get aiDiagnosisAssistant;

  /// No description provided for @selectPatientToBegin.
  ///
  /// In en, this message translates to:
  /// **'Select a patient to begin'**
  String get selectPatientToBegin;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @selectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select Patient'**
  String get selectPatient;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @searchPatients.
  ///
  /// In en, this message translates to:
  /// **'Search patients...'**
  String get searchPatients;

  /// No description provided for @noPatientsFound.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFound;

  /// No description provided for @noMatchingPatients.
  ///
  /// In en, this message translates to:
  /// **'No matching patients'**
  String get noMatchingPatients;

  /// No description provided for @noPatientSelected.
  ///
  /// In en, this message translates to:
  /// **'No patient selected'**
  String get noPatientSelected;

  /// No description provided for @pleaseSelectPatient.
  ///
  /// In en, this message translates to:
  /// **'Please select a patient from the first tab'**
  String get pleaseSelectPatient;

  /// No description provided for @patientSelected.
  ///
  /// In en, this message translates to:
  /// **'Patient selected'**
  String get patientSelected;

  /// No description provided for @lastVisit.
  ///
  /// In en, this message translates to:
  /// **'Last Visit'**
  String get lastVisit;

  /// No description provided for @patientId.
  ///
  /// In en, this message translates to:
  /// **'Patient ID'**
  String get patientId;

  /// No description provided for @patientInfoReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Patient information is read-only. Proceed to next tab to record symptoms.'**
  String get patientInfoReadOnly;

  /// No description provided for @nextRecordSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Next: Record Symptoms'**
  String get nextRecordSymptoms;

  /// No description provided for @symptomsAssessment.
  ///
  /// In en, this message translates to:
  /// **'Symptoms Assessment'**
  String get symptomsAssessment;

  /// No description provided for @selectAllSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Select all symptoms the patient is experiencing'**
  String get selectAllSymptoms;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @additionalObservations.
  ///
  /// In en, this message translates to:
  /// **'Any additional observations or patient complaints...'**
  String get additionalObservations;

  /// No description provided for @nextRecordVitalSigns.
  ///
  /// In en, this message translates to:
  /// **'Next: Record Vital Signs'**
  String get nextRecordVitalSigns;

  /// No description provided for @recordVitalMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Record patient\'s vital measurements'**
  String get recordVitalMeasurements;

  /// No description provided for @nextReviewSubmit.
  ///
  /// In en, this message translates to:
  /// **'Next: Review & Submit'**
  String get nextReviewSubmit;

  /// No description provided for @reviewAndSubmit.
  ///
  /// In en, this message translates to:
  /// **'Review & Submit'**
  String get reviewAndSubmit;

  /// No description provided for @reviewBeforeDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Review all information before running diagnosis'**
  String get reviewBeforeDiagnosis;

  /// No description provided for @symptomsCount.
  ///
  /// In en, this message translates to:
  /// **'Symptoms ({count})'**
  String symptomsCount(Object count);

  /// No description provided for @medicalHistoryCount.
  ///
  /// In en, this message translates to:
  /// **'Medical History ({count})'**
  String medicalHistoryCount(Object count);

  /// No description provided for @noSymptomsSelected.
  ///
  /// In en, this message translates to:
  /// **'No symptoms selected'**
  String get noSymptomsSelected;

  /// No description provided for @noMedicalHistorySelected.
  ///
  /// In en, this message translates to:
  /// **'No medical history selected'**
  String get noMedicalHistorySelected;

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @reviewInformation.
  ///
  /// In en, this message translates to:
  /// **'Review the information above, then tap the button to run the AI diagnosis.'**
  String get reviewInformation;

  /// No description provided for @runAIDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Run AI Diagnosis'**
  String get runAIDiagnosis;

  /// No description provided for @pleaseSelectPatientFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a patient first'**
  String get pleaseSelectPatientFirst;

  /// No description provided for @pleaseProvideSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Please provide symptoms'**
  String get pleaseProvideSymptoms;

  /// No description provided for @runningAIDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Running AI Diagnosis...'**
  String get runningAIDiagnosis;

  /// No description provided for @thisMayTakeFewMoments.
  ///
  /// In en, this message translates to:
  /// **'This may take a few moments'**
  String get thisMayTakeFewMoments;

  /// No description provided for @diagnosisFailed.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis failed: {error}'**
  String diagnosisFailed(Object error);

  /// No description provided for @normalRange.
  ///
  /// In en, this message translates to:
  /// **'Normal: {range}'**
  String normalRange(Object range);

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @aiDiagnosisReady.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnosis Ready'**
  String get aiDiagnosisReady;

  /// No description provided for @yourAIAssistantReady.
  ///
  /// In en, this message translates to:
  /// **'Your AI assistant is ready to help with patient diagnosis'**
  String get yourAIAssistantReady;

  /// No description provided for @startNewDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Start New Diagnosis'**
  String get startNewDiagnosis;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @newPatient.
  ///
  /// In en, this message translates to:
  /// **'New Patient'**
  String get newPatient;

  /// No description provided for @viewPatients.
  ///
  /// In en, this message translates to:
  /// **'View Patients'**
  String get viewPatients;

  /// No description provided for @mainFeatures.
  ///
  /// In en, this message translates to:
  /// **'Main Features'**
  String get mainFeatures;

  /// No description provided for @getAIPoweredPredictions.
  ///
  /// In en, this message translates to:
  /// **'Get AI-powered disease predictions'**
  String get getAIPoweredPredictions;

  /// No description provided for @managePatientInformation.
  ///
  /// In en, this message translates to:
  /// **'Manage patient information'**
  String get managePatientInformation;

  /// No description provided for @findNearbyPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Find nearby pharmacies'**
  String get findNearbyPharmacies;

  /// No description provided for @viewHealthStatistics.
  ///
  /// In en, this message translates to:
  /// **'View health statistics'**
  String get viewHealthStatistics;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @diagnosisRecorded.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis recorded'**
  String get diagnosisRecorded;

  /// No description provided for @patientAdded.
  ///
  /// In en, this message translates to:
  /// **'Patient added'**
  String get patientAdded;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(Object hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(Object days);

  /// No description provided for @manageYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get manageYourAccount;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @systemAdministrator.
  ///
  /// In en, this message translates to:
  /// **'System Administrator'**
  String get systemAdministrator;

  /// No description provided for @updateYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get updateYourPassword;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinic;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @selectLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguagePrompt;

  /// No description provided for @choosePreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choosePreferredLanguage;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedTo(Object language);

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @getHelpContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and contact support'**
  String get getHelpContactSupport;

  /// No description provided for @signOutOfAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOutOfAccount;

  /// No description provided for @patientsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} patients'**
  String patientsCount(Object count);

  /// No description provided for @addFirstPatient.
  ///
  /// In en, this message translates to:
  /// **'Add First Patient'**
  String get addFirstPatient;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByName;

  /// No description provided for @noPatientYet.
  ///
  /// In en, this message translates to:
  /// **'No patients yet'**
  String get noPatientYet;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @deletePatient.
  ///
  /// In en, this message translates to:
  /// **'Delete Patient'**
  String get deletePatient;

  /// No description provided for @deletePatientConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {firstName} {lastName}?\n\nThis is a soft delete — the record can be restored by an admin.'**
  String deletePatientConfirm(Object firstName, Object lastName);

  /// No description provided for @patientDeleted.
  ///
  /// In en, this message translates to:
  /// **'{firstName} {lastName} deleted'**
  String patientDeleted(Object firstName, Object lastName);

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'yrs'**
  String get years;

  /// No description provided for @diagnosisReport.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Report'**
  String get diagnosisReport;

  /// No description provided for @noDiagnosisData.
  ///
  /// In en, this message translates to:
  /// **'No diagnosis data available'**
  String get noDiagnosisData;

  /// No description provided for @downloadPDF.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPDF;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareReport;

  /// No description provided for @historicalDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Historical Diagnosis'**
  String get historicalDiagnosis;

  /// No description provided for @historicalDiagnosisNotice.
  ///
  /// In en, this message translates to:
  /// **'Viewing past diagnosis. Clinic recommendations are based on your current location, not the original diagnosis location.'**
  String get historicalDiagnosisNotice;

  /// No description provided for @patientInformation.
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get patientInformation;

  /// No description provided for @primaryDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Primary Diagnosis'**
  String get primaryDiagnosis;

  /// No description provided for @differentialDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Differential Diagnoses'**
  String get differentialDiagnoses;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @aboutThisCondition.
  ///
  /// In en, this message translates to:
  /// **'About This Condition'**
  String get aboutThisCondition;

  /// No description provided for @recommendedDiet.
  ///
  /// In en, this message translates to:
  /// **'Recommended Diet'**
  String get recommendedDiet;

  /// No description provided for @lifestyleAndExercise.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle & Exercise'**
  String get lifestyleAndExercise;

  /// No description provided for @clinicRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Clinic Recommendations'**
  String get clinicRecommendations;

  /// No description provided for @aiHealthCompanion.
  ///
  /// In en, this message translates to:
  /// **'AI Health Companion'**
  String get aiHealthCompanion;

  /// No description provided for @diagnosisReportDate.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Report — {date}'**
  String diagnosisReportDate(Object date);

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @diagnosisDate.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Date'**
  String get diagnosisDate;

  /// No description provided for @reportID.
  ///
  /// In en, this message translates to:
  /// **'Report ID'**
  String get reportID;

  /// No description provided for @disease.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get disease;

  /// No description provided for @icd10.
  ///
  /// In en, this message translates to:
  /// **'ICD-10'**
  String get icd10;

  /// No description provided for @otherPredictions.
  ///
  /// In en, this message translates to:
  /// **'Other Predictions'**
  String get otherPredictions;

  /// No description provided for @pdfError.
  ///
  /// In en, this message translates to:
  /// **'PDF error: {error}'**
  String pdfError(Object error);

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Share error: {error}'**
  String shareError(Object error);

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @sendToPatientWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Send to patient\'s WhatsApp'**
  String get sendToPatientWhatsapp;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @sendViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Send via email'**
  String get sendViaEmail;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @shareViaAnyApp.
  ///
  /// In en, this message translates to:
  /// **'Share via any app'**
  String get shareViaAnyApp;

  /// No description provided for @hasAllMedicines.
  ///
  /// In en, this message translates to:
  /// **'Has all medicines'**
  String get hasAllMedicines;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @pharmacyRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Recommendations'**
  String get pharmacyRecommendations;

  /// No description provided for @noNearbyPharmaciesFound.
  ///
  /// In en, this message translates to:
  /// **'No Nearby Pharmacies Found'**
  String get noNearbyPharmaciesFound;

  /// No description provided for @noNearbyPharmaciesMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any pharmacies within 50 km that have the prescribed medicines in stock.'**
  String get noNearbyPharmaciesMessage;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @contactPharmaciesDirectly.
  ///
  /// In en, this message translates to:
  /// **'Contact pharmacies directly to check availability'**
  String get contactPharmaciesDirectly;

  /// No description provided for @trySearchingPharmaciesTab.
  ///
  /// In en, this message translates to:
  /// **'Try searching in the Pharmacies tab'**
  String get trySearchingPharmaciesTab;

  /// No description provided for @considerAlternativeBrands.
  ///
  /// In en, this message translates to:
  /// **'Consider alternative medicine brands'**
  String get considerAlternativeBrands;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later as stock updates regularly'**
  String get checkBackLater;

  /// No description provided for @browseAllPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Browse All Pharmacies'**
  String get browseAllPharmacies;

  /// No description provided for @clinicLocationNotice.
  ///
  /// In en, this message translates to:
  /// **'These clinic recommendations are based on your current location and updated pattern analysis.'**
  String get clinicLocationNotice;

  /// No description provided for @noSpecializedClinicsFound.
  ///
  /// In en, this message translates to:
  /// **'No Specialized Clinics Found'**
  String get noSpecializedClinicsFound;

  /// No description provided for @noSpecializedClinicsMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find clinics with the recommended specialties in your area.'**
  String get noSpecializedClinicsMessage;

  /// No description provided for @visitGeneralMedicineClinic.
  ///
  /// In en, this message translates to:
  /// **'Visit a General Medicine clinic'**
  String get visitGeneralMedicineClinic;

  /// No description provided for @expandSearchRadius.
  ///
  /// In en, this message translates to:
  /// **'Expand your search radius'**
  String get expandSearchRadius;

  /// No description provided for @contactPrimaryCareDoctor.
  ///
  /// In en, this message translates to:
  /// **'Contact your primary care doctor'**
  String get contactPrimaryCareDoctor;

  /// No description provided for @showingClinicsFiltered.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} of {total} clinics'**
  String showingClinicsFiltered(Object count, Object total);

  /// No description provided for @noClinicsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No clinics match selected specialties'**
  String get noClinicsMatchFilter;

  /// No description provided for @tryDifferentSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Try selecting different specialties or clear filters'**
  String get tryDifferentSpecialties;

  /// No description provided for @persistentConditionMessage.
  ///
  /// In en, this message translates to:
  /// **'This condition has been active for an extended period. Persistent conditions often benefit from specialized medical attention to ensure proper treatment and recovery.'**
  String get persistentConditionMessage;

  /// No description provided for @persistentConditionNoPharmacyMessage.
  ///
  /// In en, this message translates to:
  /// **'This condition has persisted for an extended period. We recommend visiting a specialized clinic for in-depth evaluation and treatment.'**
  String get persistentConditionNoPharmacyMessage;

  /// No description provided for @recurringPatternMessage.
  ///
  /// In en, this message translates to:
  /// **'Your diagnosis history shows a recurring pattern. In addition to obtaining medication from nearby pharmacies, we recommend specialized clinic care to help prevent future occurrences.'**
  String get recurringPatternMessage;

  /// No description provided for @recurringPatternNoPharmacyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your diagnosis history shows a recurring pattern. Specialized clinics can provide comprehensive care and help prevent future occurrences.'**
  String get recurringPatternNoPharmacyMessage;

  /// No description provided for @chronicConditionMessage.
  ///
  /// In en, this message translates to:
  /// **'Your symptoms match a chronic medical condition that may require specialized ongoing care. We recommend visiting a specialized clinic for comprehensive evaluation and long-term management.'**
  String get chronicConditionMessage;

  /// No description provided for @chronicConditionNoPharmacyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your symptoms match a chronic condition. Specialized clinics offer long-term management and expert care for chronic conditions.'**
  String get chronicConditionNoPharmacyMessage;

  /// No description provided for @noPharmacyFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No nearby pharmacies were found with the prescribed medications. We recommend visiting these specialized clinics for alternative treatment options.'**
  String get noPharmacyFoundMessage;

  /// No description provided for @defaultClinicMessage.
  ///
  /// In en, this message translates to:
  /// **'Based on your diagnosis, medication is available at nearby pharmacies. We also recommend consulting with these specialized clinics for comprehensive care and expert medical guidance.'**
  String get defaultClinicMessage;

  /// No description provided for @defaultClinicNoPharmacyMessage.
  ///
  /// In en, this message translates to:
  /// **'Based on your diagnosis, we recommend consulting with these specialized clinics for comprehensive care.'**
  String get defaultClinicNoPharmacyMessage;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'This report is AI-generated and intended to assist — not replace — clinical judgment. All diagnoses must be confirmed by a qualified healthcare professional.'**
  String get disclaimer;

  /// No description provided for @newDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'New Diagnosis'**
  String get newDiagnosis;

  /// No description provided for @recordsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} records found'**
  String recordsFound(Object count);

  /// No description provided for @filterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTooltip;

  /// No description provided for @exportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTooltip;

  /// No description provided for @searchDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Search diagnoses...'**
  String get searchDiagnoses;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get filterRecent;

  /// No description provided for @filterCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get filterCritical;

  /// No description provided for @filterFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get filterFollowUp;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @idPrefix.
  ///
  /// In en, this message translates to:
  /// **'ID:'**
  String get idPrefix;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence:'**
  String get confidenceLabel;

  /// No description provided for @confidencePercentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}%'**
  String confidencePercentage(Object percentage);

  /// No description provided for @symptomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Symptoms:'**
  String get symptomsLabel;

  /// No description provided for @noDiagnosesFound.
  ///
  /// In en, this message translates to:
  /// **'No diagnoses found'**
  String get noDiagnosesFound;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter criteria'**
  String get tryAdjustingSearch;

  /// No description provided for @failedToLoadDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load diagnosis details: {error}'**
  String failedToLoadDetails(Object error);

  /// No description provided for @severityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get severityMild;

  /// No description provided for @severityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityModerate;

  /// No description provided for @severitySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severitySevere;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusFollowUpRequired.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Required'**
  String get statusFollowUpRequired;

  /// No description provided for @statusUnderTreatment.
  ///
  /// In en, this message translates to:
  /// **'Under Treatment'**
  String get statusUnderTreatment;

  /// No description provided for @statusHospitalized.
  ///
  /// In en, this message translates to:
  /// **'Hospitalized'**
  String get statusHospitalized;

  /// No description provided for @exportingHistory.
  ///
  /// In en, this message translates to:
  /// **'Exporting diagnosis history...'**
  String get exportingHistory;

  /// No description provided for @addNewPatient.
  ///
  /// In en, this message translates to:
  /// **'Add New Patient'**
  String get addNewPatient;

  /// No description provided for @registerNewPatient.
  ///
  /// In en, this message translates to:
  /// **'Register a new patient'**
  String get registerNewPatient;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfBirthRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth *'**
  String get dateOfBirthRequired;

  /// No description provided for @dobPrefix.
  ///
  /// In en, this message translates to:
  /// **'DOB:'**
  String get dobPrefix;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Gender *'**
  String get genderRequired;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get emailOptional;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @medicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInformation;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @allergiesCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Allergies (comma-separated)'**
  String get allergiesCommaSeparated;

  /// No description provided for @chronicConditionsCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions (comma-separated)'**
  String get chronicConditionsCommaSeparated;

  /// No description provided for @savePatient.
  ///
  /// In en, this message translates to:
  /// **'Save Patient'**
  String get savePatient;

  /// No description provided for @pleaseSelectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get pleaseSelectDateOfBirth;

  /// No description provided for @patientCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Patient created successfully'**
  String get patientCreatedSuccessfully;

  /// No description provided for @failedToCreatePatient.
  ///
  /// In en, this message translates to:
  /// **'Failed to create patient'**
  String get failedToCreatePatient;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @updatePatientInfo.
  ///
  /// In en, this message translates to:
  /// **'Update patient information'**
  String get updatePatientInfo;

  /// No description provided for @updatePatient.
  ///
  /// In en, this message translates to:
  /// **'Update Patient'**
  String get updatePatient;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @patientUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Patient updated successfully'**
  String get patientUpdatedSuccessfully;

  /// No description provided for @failedToUpdatePatient.
  ///
  /// In en, this message translates to:
  /// **'Failed to update patient'**
  String get failedToUpdatePatient;

  /// No description provided for @patientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Patient not found'**
  String get patientNotFound;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @medical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medical;

  /// No description provided for @physicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Physical Information'**
  String get physicalInformation;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @allergiesSection.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergiesSection;

  /// No description provided for @noAllergiesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No allergies recorded'**
  String get noAllergiesRecorded;

  /// No description provided for @chronicConditions.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get chronicConditions;

  /// No description provided for @noChronicConditionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No chronic conditions recorded'**
  String get noChronicConditionsRecorded;

  /// No description provided for @currentMedications.
  ///
  /// In en, this message translates to:
  /// **'Current Medications'**
  String get currentMedications;

  /// No description provided for @fromLastDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'From last diagnosis'**
  String get fromLastDiagnosis;

  /// No description provided for @noCurrentMedications.
  ///
  /// In en, this message translates to:
  /// **'No current medications'**
  String get noCurrentMedications;

  /// No description provided for @visitInformation.
  ///
  /// In en, this message translates to:
  /// **'Visit Information'**
  String get visitInformation;

  /// No description provided for @noVisitsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No visits recorded'**
  String get noVisitsRecorded;

  /// No description provided for @diagnosisHistorySection.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis History'**
  String get diagnosisHistorySection;

  /// No description provided for @noDiagnosisHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No diagnosis history found'**
  String get noDiagnosisHistoryFound;

  /// No description provided for @startNewDiagnosisToSeeHere.
  ///
  /// In en, this message translates to:
  /// **'Start a new diagnosis to see it here'**
  String get startNewDiagnosisToSeeHere;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @diagnosisDetails.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Details'**
  String get diagnosisDetails;

  /// No description provided for @diagnosisInformation.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Information'**
  String get diagnosisInformation;

  /// No description provided for @aiPredictions.
  ///
  /// In en, this message translates to:
  /// **'AI Predictions'**
  String get aiPredictions;

  /// No description provided for @aboutCondition.
  ///
  /// In en, this message translates to:
  /// **'About {disease}'**
  String aboutCondition(Object disease);

  /// No description provided for @symptomsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Symptoms ({count})'**
  String symptomsCountLabel(Object count);

  /// No description provided for @precautions.
  ///
  /// In en, this message translates to:
  /// **'Precautions'**
  String get precautions;

  /// No description provided for @prescribedMedicationsCount.
  ///
  /// In en, this message translates to:
  /// **'Prescribed Medications ({count})'**
  String prescribedMedicationsCount(Object count);

  /// No description provided for @recommendedMedications.
  ///
  /// In en, this message translates to:
  /// **'Recommended Medications'**
  String get recommendedMedications;

  /// No description provided for @additionalRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Additional Recommendations'**
  String get additionalRecommendations;

  /// No description provided for @clinicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Clinical Notes'**
  String get clinicalNotes;

  /// No description provided for @moreSymptoms.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreSymptoms(Object count);

  /// No description provided for @changeYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Change Your Password'**
  String get changeYourPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @forSecurityChangePassword.
  ///
  /// In en, this message translates to:
  /// **'For security, please change your\ndefault password'**
  String get forSecurityChangePassword;

  /// No description provided for @enterCurrentPasswordChooseNew.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and\nchoose a new one'**
  String get enterCurrentPasswordChooseNew;

  /// No description provided for @requiredForFirstTimeLogin.
  ///
  /// In en, this message translates to:
  /// **'This is required for first-time login'**
  String get requiredForFirstTimeLogin;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordMinLength8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength8;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @strengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Strength: '**
  String get strengthLabel;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordFair;

  /// No description provided for @passwordGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordGood;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @passwordChangedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully. You can now use your new password to login.'**
  String get passwordChangedSuccessMessage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @mustChangePasswordBeforeContinuing.
  ///
  /// In en, this message translates to:
  /// **'You must change your password before continuing'**
  String get mustChangePasswordBeforeContinuing;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you\ninstructions to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email Sent'**
  String get emailSent;

  /// No description provided for @checkEmailForInstructions.
  ///
  /// In en, this message translates to:
  /// **'Check your email for password reset instructions.'**
  String get checkEmailForInstructions;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmailAddress;

  /// No description provided for @failedToSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email'**
  String get failedToSendResetEmail;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @enterCodeAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your email and\nyour new password'**
  String get enterCodeAndNewPassword;

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset Code'**
  String get resetCode;

  /// No description provided for @pleaseEnterResetCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the reset code'**
  String get pleaseEnterResetCode;

  /// No description provided for @pleaseEnterNewPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPasswordReset;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully. Please login with your new password.'**
  String get passwordResetSuccessMessage;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @failedToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get failedToResetPassword;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @getHelpLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Get help and learn more'**
  String get getHelpLearnMore;

  /// No description provided for @contactSupportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportTooltip;

  /// No description provided for @faqTab.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTab;

  /// No description provided for @tutorialsTab.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorialsTab;

  /// No description provided for @contactTab.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactTab;

  /// No description provided for @searchFAQ.
  ///
  /// In en, this message translates to:
  /// **'Search FAQ...'**
  String get searchFAQ;

  /// No description provided for @noFAQItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No FAQ items found'**
  String get noFAQItemsFound;

  /// No description provided for @interactiveTutorials.
  ///
  /// In en, this message translates to:
  /// **'Interactive Tutorials'**
  String get interactiveTutorials;

  /// No description provided for @learnHowToUseApp.
  ///
  /// In en, this message translates to:
  /// **'Learn how to use the app with step-by-step guides'**
  String get learnHowToUseApp;

  /// No description provided for @gettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStarted;

  /// No description provided for @gettingStartedDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn the basics of using the AI Health Companion app'**
  String get gettingStartedDescription;

  /// No description provided for @aiDiagnosisTutorial.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnosis'**
  String get aiDiagnosisTutorial;

  /// No description provided for @aiDiagnosisTutorialDescription.
  ///
  /// In en, this message translates to:
  /// **'How to perform AI-powered disease diagnosis'**
  String get aiDiagnosisTutorialDescription;

  /// No description provided for @patientManagementTutorial.
  ///
  /// In en, this message translates to:
  /// **'Patient Management'**
  String get patientManagementTutorial;

  /// No description provided for @patientManagementTutorialDescription.
  ///
  /// In en, this message translates to:
  /// **'Adding and managing patient records'**
  String get patientManagementTutorialDescription;

  /// No description provided for @pharmacyFinderTutorial.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Finder'**
  String get pharmacyFinderTutorial;

  /// No description provided for @pharmacyFinderTutorialDescription.
  ///
  /// In en, this message translates to:
  /// **'Finding pharmacies with available medications'**
  String get pharmacyFinderTutorialDescription;

  /// No description provided for @getSupport.
  ///
  /// In en, this message translates to:
  /// **'Get Support'**
  String get getSupport;

  /// No description provided for @needHelpContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Need help? Contact our support team'**
  String get needHelpContactSupport;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @emailSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Send us an email and we\'ll respond within 24 hours'**
  String get emailSupportDescription;

  /// No description provided for @phoneSupport.
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// No description provided for @phoneSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Call our support line for immediate assistance'**
  String get phoneSupportDescription;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @liveChatDescription.
  ///
  /// In en, this message translates to:
  /// **'Chat with our support team in real-time'**
  String get liveChatDescription;

  /// No description provided for @supportHours.
  ///
  /// In en, this message translates to:
  /// **'Support Hours'**
  String get supportHours;

  /// No description provided for @mondayFriday.
  ///
  /// In en, this message translates to:
  /// **'Monday - Friday'**
  String get mondayFriday;

  /// No description provided for @mondayFridayHours.
  ///
  /// In en, this message translates to:
  /// **'9:00 AM - 6:00 PM'**
  String get mondayFridayHours;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @saturdayHours.
  ///
  /// In en, this message translates to:
  /// **'10:00 AM - 4:00 PM'**
  String get saturdayHours;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @sundayClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get sundayClosed;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @emergency24x7.
  ///
  /// In en, this message translates to:
  /// **'24/7 via email'**
  String get emergency24x7;

  /// No description provided for @reportAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportAnIssue;

  /// No description provided for @foundBugReportIt.
  ///
  /// In en, this message translates to:
  /// **'Found a bug or experiencing issues? Report it to help us improve the app.'**
  String get foundBugReportIt;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @tutorialDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} Tutorial'**
  String tutorialDialogTitle(Object title);

  /// No description provided for @tutorialWillBeImplemented.
  ///
  /// In en, this message translates to:
  /// **'Interactive tutorial for \"{title}\" will be implemented here.'**
  String tutorialWillBeImplemented(Object title);

  /// No description provided for @closeTutorial.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTutorial;

  /// No description provided for @startTutorial.
  ///
  /// In en, this message translates to:
  /// **'Start Tutorial'**
  String get startTutorial;

  /// No description provided for @startingTutorial.
  ///
  /// In en, this message translates to:
  /// **'Starting {title} tutorial...'**
  String startingTutorial(Object title);

  /// No description provided for @contactSupportDialog.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportDialog;

  /// No description provided for @howToContactSupport.
  ///
  /// In en, this message translates to:
  /// **'How would you like to contact our support team?'**
  String get howToContactSupport;

  /// No description provided for @emailButton.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailButton;

  /// No description provided for @callButton.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callButton;

  /// No description provided for @openingEmailClient.
  ///
  /// In en, this message translates to:
  /// **'Opening email client...'**
  String get openingEmailClient;

  /// No description provided for @openingPhoneDialer.
  ///
  /// In en, this message translates to:
  /// **'Opening phone dialer...'**
  String get openingPhoneDialer;

  /// No description provided for @startingLiveChat.
  ///
  /// In en, this message translates to:
  /// **'Starting live chat...'**
  String get startingLiveChat;

  /// No description provided for @reportIssueDialog.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssueDialog;

  /// No description provided for @issueReportingFormWillBeImplemented.
  ///
  /// In en, this message translates to:
  /// **'Issue reporting form will be implemented here.'**
  String get issueReportingFormWillBeImplemented;

  /// No description provided for @issueReportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Issue reported successfully'**
  String get issueReportedSuccessfully;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @faqHowDoesAIDiagnosisWork.
  ///
  /// In en, this message translates to:
  /// **'How does AI diagnosis work?'**
  String get faqHowDoesAIDiagnosisWork;

  /// No description provided for @faqAIDiagnosisAnswer.
  ///
  /// In en, this message translates to:
  /// **'The AI diagnosis feature uses machine learning models trained on medical data to analyze symptoms, vital signs, and patient information to provide probable disease predictions with confidence scores.'**
  String get faqAIDiagnosisAnswer;

  /// No description provided for @faqHowDoIAddNewPatient.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new patient?'**
  String get faqHowDoIAddNewPatient;

  /// No description provided for @faqAddNewPatientAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to the Patients tab and tap the \"+\" button or \"Add Patient\" button. Fill out the patient information form with personal, medical, and contact details.'**
  String get faqAddNewPatientAnswer;

  /// No description provided for @faqIsMyDataSecure.
  ///
  /// In en, this message translates to:
  /// **'Is my data secure?'**
  String get faqIsMyDataSecure;

  /// No description provided for @faqDataSecurityAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, all patient data is encrypted and stored securely. The app complies with healthcare privacy standards and uses end-to-end encryption.'**
  String get faqDataSecurityAnswer;

  /// No description provided for @faqCanIExportPatientReports.
  ///
  /// In en, this message translates to:
  /// **'Can I export patient reports?'**
  String get faqCanIExportPatientReports;

  /// No description provided for @faqExportReportsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can export diagnosis reports and patient data. Use the export button in the diagnosis results or patient details pages.'**
  String get faqExportReportsAnswer;

  /// No description provided for @faqWhatIfAIDiagnosisIsWrong.
  ///
  /// In en, this message translates to:
  /// **'What if the AI diagnosis is wrong?'**
  String get faqWhatIfAIDiagnosisIsWrong;

  /// No description provided for @faqAIDiagnosisWrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'The AI provides suggestions based on symptoms, but always consult with qualified healthcare professionals for final diagnosis and treatment decisions.'**
  String get faqAIDiagnosisWrongAnswer;

  /// No description provided for @faqHowDoIUpdatePatientInfo.
  ///
  /// In en, this message translates to:
  /// **'How do I update patient information?'**
  String get faqHowDoIUpdatePatientInfo;

  /// No description provided for @faqUpdatePatientInfoAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to the patient\'s detail page and tap the edit button. You can update any patient information including medical history and contact details.'**
  String get faqUpdatePatientInfoAnswer;

  /// No description provided for @faqHowDoIFindNearbyPharmacies.
  ///
  /// In en, this message translates to:
  /// **'How do I find nearby pharmacies?'**
  String get faqHowDoIFindNearbyPharmacies;

  /// No description provided for @faqFindNearbyPharmaciesAnswer.
  ///
  /// In en, this message translates to:
  /// **'After a diagnosis, the app will show nearby pharmacies that have the prescribed medications in stock. You can also browse all pharmacies in the Pharmacies tab.'**
  String get faqFindNearbyPharmaciesAnswer;

  /// No description provided for @faqCategoryAIDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnosis'**
  String get faqCategoryAIDiagnosis;

  /// No description provided for @faqCategoryPatientManagement.
  ///
  /// In en, this message translates to:
  /// **'Patient Management'**
  String get faqCategoryPatientManagement;

  /// No description provided for @faqCategorySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get faqCategorySecurity;

  /// No description provided for @faqCategoryReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get faqCategoryReports;

  /// No description provided for @faqCategoryPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get faqCategoryPharmacies;

  /// No description provided for @medicalHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistoryTitle;

  /// No description provided for @patientIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient ID: {patientId}'**
  String patientIdLabel(Object patientId);

  /// No description provided for @addEntryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntryTooltip;

  /// No description provided for @timelineTab.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineTab;

  /// No description provided for @medicationsTab.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medicationsTab;

  /// No description provided for @labResultsTab.
  ///
  /// In en, this message translates to:
  /// **'Lab Results'**
  String get labResultsTab;

  /// No description provided for @medicalTimeline.
  ///
  /// In en, this message translates to:
  /// **'Medical Timeline'**
  String get medicalTimeline;

  /// No description provided for @entriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String entriesCount(Object count);

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String yearsOld(Object age);

  /// No description provided for @bloodTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodTypeLabel;

  /// No description provided for @allergiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergiesLabel;

  /// No description provided for @medicationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medicationsLabel;

  /// No description provided for @providerLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider: {provider}'**
  String providerLabel(Object provider);

  /// No description provided for @medicationsColon.
  ///
  /// In en, this message translates to:
  /// **'Medications:'**
  String get medicationsColon;

  /// No description provided for @resultsColon.
  ///
  /// In en, this message translates to:
  /// **'Results:'**
  String get resultsColon;

  /// No description provided for @notesColon.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notesColon;

  /// No description provided for @medicationHistory.
  ///
  /// In en, this message translates to:
  /// **'Medication History'**
  String get medicationHistory;

  /// No description provided for @noMedicationHistory.
  ///
  /// In en, this message translates to:
  /// **'No medication history'**
  String get noMedicationHistory;

  /// No description provided for @currentlyTaking.
  ///
  /// In en, this message translates to:
  /// **'Currently taking'**
  String get currentlyTaking;

  /// No description provided for @previouslyPrescribed.
  ///
  /// In en, this message translates to:
  /// **'Previously prescribed'**
  String get previouslyPrescribed;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @labResults.
  ///
  /// In en, this message translates to:
  /// **'Lab Results'**
  String get labResults;

  /// No description provided for @noLabResultsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No lab results available'**
  String get noLabResultsAvailable;

  /// No description provided for @addNewEntry.
  ///
  /// In en, this message translates to:
  /// **'Add New Entry'**
  String get addNewEntry;

  /// No description provided for @addNewEntryFormWillBeImplemented.
  ///
  /// In en, this message translates to:
  /// **'Add new medical history entry form will be implemented here.'**
  String get addNewEntryFormWillBeImplemented;

  /// No description provided for @newEntryAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'New entry added successfully'**
  String get newEntryAddedSuccessfully;

  /// No description provided for @exportingMedicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Exporting medical history...'**
  String get exportingMedicalHistory;

  /// No description provided for @diagnosisType.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosisType;

  /// No description provided for @labTestType.
  ///
  /// In en, this message translates to:
  /// **'Lab Test'**
  String get labTestType;

  /// No description provided for @medicationType.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medicationType;

  /// No description provided for @resolvedStatus.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolvedStatus;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// No description provided for @underTreatmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Under Treatment'**
  String get underTreatmentStatus;

  /// No description provided for @hospitalizedStatus.
  ///
  /// In en, this message translates to:
  /// **'Hospitalized'**
  String get hospitalizedStatus;

  /// No description provided for @pharmacySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Search'**
  String get pharmacySearchTitle;

  /// No description provided for @searchMedicationAvailability.
  ///
  /// In en, this message translates to:
  /// **'Search medication availability'**
  String get searchMedicationAvailability;

  /// No description provided for @scanBarcodeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcodeTooltip;

  /// No description provided for @searchMedicationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search medication (e.g., Amoxicillin)'**
  String get searchMedicationPlaceholder;

  /// No description provided for @allHealthCenters.
  ///
  /// In en, this message translates to:
  /// **'All Health Centers'**
  String get allHealthCenters;

  /// No description provided for @searchELMIS.
  ///
  /// In en, this message translates to:
  /// **'Search e-LMIS'**
  String get searchELMIS;

  /// No description provided for @searchForMedications.
  ///
  /// In en, this message translates to:
  /// **'Search for medications'**
  String get searchForMedications;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @enterMedicationNameToCheck.
  ///
  /// In en, this message translates to:
  /// **'Enter medication name to check availability'**
  String get enterMedicationNameToCheck;

  /// No description provided for @stockUnits.
  ///
  /// In en, this message translates to:
  /// **'Stock: {stock} units'**
  String stockUnits(Object stock);

  /// No description provided for @expiresDate.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String expiresDate(Object date);

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @stockLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stockLevelLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @expiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDateLabel;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @directionsFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Directions feature coming soon'**
  String get directionsFeatureComingSoon;

  /// No description provided for @unitsLabel.
  ///
  /// In en, this message translates to:
  /// **'{units} units'**
  String unitsLabel(Object units);

  /// No description provided for @stockManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Management'**
  String get stockManagementTitle;

  /// No description provided for @monitorMedicationInventory.
  ///
  /// In en, this message translates to:
  /// **'Monitor medication inventory'**
  String get monitorMedicationInventory;

  /// No description provided for @addStockTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Stock'**
  String get addStockTooltip;

  /// No description provided for @overviewTab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTab;

  /// No description provided for @alertsTab.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTab;

  /// No description provided for @syncELMIS.
  ///
  /// In en, this message translates to:
  /// **'Sync e-LMIS'**
  String get syncELMIS;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @allCategory.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategory;

  /// No description provided for @antibioticsCategory.
  ///
  /// In en, this message translates to:
  /// **'Antibiotics'**
  String get antibioticsCategory;

  /// No description provided for @analgesicsCategory.
  ///
  /// In en, this message translates to:
  /// **'Analgesics'**
  String get analgesicsCategory;

  /// No description provided for @antidiabeticCategory.
  ///
  /// In en, this message translates to:
  /// **'Antidiabetic'**
  String get antidiabeticCategory;

  /// No description provided for @cardiovascularCategory.
  ///
  /// In en, this message translates to:
  /// **'Cardiovascular'**
  String get cardiovascularCategory;

  /// No description provided for @respiratoryCategory.
  ///
  /// In en, this message translates to:
  /// **'Respiratory'**
  String get respiratoryCategory;

  /// No description provided for @noStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'No Stock Alerts'**
  String get noStockAlerts;

  /// No description provided for @allMedicationsAdequatelyStocked.
  ///
  /// In en, this message translates to:
  /// **'All medications are adequately stocked'**
  String get allMedicationsAdequatelyStocked;

  /// No description provided for @totalStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Stock: {stock} units'**
  String totalStockLabel(Object stock);

  /// No description provided for @thresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Threshold: {threshold} units'**
  String thresholdLabel(Object threshold);

  /// No description provided for @reorderButton.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderButton;

  /// No description provided for @stockByLocation.
  ///
  /// In en, this message translates to:
  /// **'Stock by Location'**
  String get stockByLocation;

  /// No description provided for @stockDataSynchronized.
  ///
  /// In en, this message translates to:
  /// **'Stock data synchronized with e-LMIS'**
  String get stockDataSynchronized;

  /// No description provided for @reorderMedicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder Medication'**
  String get reorderMedicationTitle;

  /// No description provided for @reorderMedicationMessage.
  ///
  /// In en, this message translates to:
  /// **'Would you like to create a reorder request for {medication}?'**
  String reorderMedicationMessage(Object medication);

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @submitRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequestButton;

  /// No description provided for @reorderRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Reorder request submitted'**
  String get reorderRequestSubmitted;

  /// No description provided for @searchSymptomsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search symptoms... (e.g., fever, headache, cough)'**
  String get searchSymptomsPlaceholder;

  /// No description provided for @noSymptomsFound.
  ///
  /// In en, this message translates to:
  /// **'No symptoms found'**
  String get noSymptomsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Search Results ({count})'**
  String searchResultsCount(Object count);

  /// No description provided for @goodSelection.
  ///
  /// In en, this message translates to:
  /// **'✓ Good selection!'**
  String get goodSelection;

  /// No description provided for @selectMoreSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Select more symptoms'**
  String get selectMoreSymptoms;

  /// No description provided for @symptomsSelected.
  ///
  /// In en, this message translates to:
  /// **'Symptoms selected'**
  String get symptomsSelected;

  /// No description provided for @accurateResultsExpected.
  ///
  /// In en, this message translates to:
  /// **'This should give accurate results'**
  String get accurateResultsExpected;

  /// No description provided for @selectEightToTenSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Select 8-10 symptoms for best accuracy'**
  String get selectEightToTenSymptoms;

  /// No description provided for @canAddMoreSymptoms.
  ///
  /// In en, this message translates to:
  /// **'You can add more if needed'**
  String get canAddMoreSymptoms;

  /// No description provided for @symptomsCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} symptoms'**
  String symptomsCategoryCount(Object count);

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryRespiratory.
  ///
  /// In en, this message translates to:
  /// **'Respiratory'**
  String get categoryRespiratory;

  /// No description provided for @categoryDigestive.
  ///
  /// In en, this message translates to:
  /// **'Digestive'**
  String get categoryDigestive;

  /// No description provided for @categorySkinNails.
  ///
  /// In en, this message translates to:
  /// **'Skin & Nails'**
  String get categorySkinNails;

  /// No description provided for @categoryPainDiscomfort.
  ///
  /// In en, this message translates to:
  /// **'Pain & Discomfort'**
  String get categoryPainDiscomfort;

  /// No description provided for @categoryNeurological.
  ///
  /// In en, this message translates to:
  /// **'Neurological'**
  String get categoryNeurological;

  /// No description provided for @categoryEyesVision.
  ///
  /// In en, this message translates to:
  /// **'Eyes & Vision'**
  String get categoryEyesVision;

  /// No description provided for @categoryUrinary.
  ///
  /// In en, this message translates to:
  /// **'Urinary'**
  String get categoryUrinary;

  /// No description provided for @categoryCardiovascular.
  ///
  /// In en, this message translates to:
  /// **'Cardiovascular'**
  String get categoryCardiovascular;

  /// No description provided for @categoryMentalBehavioral.
  ///
  /// In en, this message translates to:
  /// **'Mental & Behavioral'**
  String get categoryMentalBehavioral;

  /// No description provided for @categoryLiverDigestive.
  ///
  /// In en, this message translates to:
  /// **'Liver & Digestive System'**
  String get categoryLiverDigestive;

  /// No description provided for @categoryThroatMouth.
  ///
  /// In en, this message translates to:
  /// **'Throat & Mouth'**
  String get categoryThroatMouth;

  /// No description provided for @categoryEndocrineMetabolic.
  ///
  /// In en, this message translates to:
  /// **'Endocrine & Metabolic'**
  String get categoryEndocrineMetabolic;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @symptomAbdominalPain.
  ///
  /// In en, this message translates to:
  /// **'Abdominal Pain'**
  String get symptomAbdominalPain;

  /// No description provided for @symptomAbnormalMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Abnormal Menstruation'**
  String get symptomAbnormalMenstruation;

  /// No description provided for @symptomAcidity.
  ///
  /// In en, this message translates to:
  /// **'Acidity'**
  String get symptomAcidity;

  /// No description provided for @symptomAcuteLiverFailure.
  ///
  /// In en, this message translates to:
  /// **'Acute Liver Failure'**
  String get symptomAcuteLiverFailure;

  /// No description provided for @symptomAlteredSensorium.
  ///
  /// In en, this message translates to:
  /// **'Altered Sensorium'**
  String get symptomAlteredSensorium;

  /// No description provided for @symptomAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get symptomAnxiety;

  /// No description provided for @symptomBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back Pain'**
  String get symptomBackPain;

  /// No description provided for @symptomBellyPain.
  ///
  /// In en, this message translates to:
  /// **'Belly Pain'**
  String get symptomBellyPain;

  /// No description provided for @symptomBlackheads.
  ///
  /// In en, this message translates to:
  /// **'Blackheads'**
  String get symptomBlackheads;

  /// No description provided for @symptomBladderDiscomfort.
  ///
  /// In en, this message translates to:
  /// **'Bladder Discomfort'**
  String get symptomBladderDiscomfort;

  /// No description provided for @symptomBlister.
  ///
  /// In en, this message translates to:
  /// **'Blister'**
  String get symptomBlister;

  /// No description provided for @symptomBloodInSputum.
  ///
  /// In en, this message translates to:
  /// **'Blood In Sputum'**
  String get symptomBloodInSputum;

  /// No description provided for @symptomBloodyStool.
  ///
  /// In en, this message translates to:
  /// **'Bloody Stool'**
  String get symptomBloodyStool;

  /// No description provided for @symptomBlurredAndDistortedVision.
  ///
  /// In en, this message translates to:
  /// **'Blurred And Distorted Vision'**
  String get symptomBlurredAndDistortedVision;

  /// No description provided for @symptomBreathlessness.
  ///
  /// In en, this message translates to:
  /// **'Breathlessness'**
  String get symptomBreathlessness;

  /// No description provided for @symptomBrittleNails.
  ///
  /// In en, this message translates to:
  /// **'Brittle Nails'**
  String get symptomBrittleNails;

  /// No description provided for @symptomBruising.
  ///
  /// In en, this message translates to:
  /// **'Bruising'**
  String get symptomBruising;

  /// No description provided for @symptomBurningMicturition.
  ///
  /// In en, this message translates to:
  /// **'Burning Micturition'**
  String get symptomBurningMicturition;

  /// No description provided for @symptomChestPain.
  ///
  /// In en, this message translates to:
  /// **'Chest Pain'**
  String get symptomChestPain;

  /// No description provided for @symptomChills.
  ///
  /// In en, this message translates to:
  /// **'Chills'**
  String get symptomChills;

  /// No description provided for @symptomColdHandsAndFeets.
  ///
  /// In en, this message translates to:
  /// **'Cold Hands And Feet'**
  String get symptomColdHandsAndFeets;

  /// No description provided for @symptomComa.
  ///
  /// In en, this message translates to:
  /// **'Coma'**
  String get symptomComa;

  /// No description provided for @symptomCongestion.
  ///
  /// In en, this message translates to:
  /// **'Congestion'**
  String get symptomCongestion;

  /// No description provided for @symptomConstipation.
  ///
  /// In en, this message translates to:
  /// **'Constipation'**
  String get symptomConstipation;

  /// No description provided for @symptomContinuousFeelOfUrine.
  ///
  /// In en, this message translates to:
  /// **'Continuous Feel Of Urine'**
  String get symptomContinuousFeelOfUrine;

  /// No description provided for @symptomContinuousSneezing.
  ///
  /// In en, this message translates to:
  /// **'Continuous Sneezing'**
  String get symptomContinuousSneezing;

  /// No description provided for @symptomCough.
  ///
  /// In en, this message translates to:
  /// **'Cough'**
  String get symptomCough;

  /// No description provided for @symptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// No description provided for @symptomDarkUrine.
  ///
  /// In en, this message translates to:
  /// **'Dark Urine'**
  String get symptomDarkUrine;

  /// No description provided for @symptomDehydration.
  ///
  /// In en, this message translates to:
  /// **'Dehydration'**
  String get symptomDehydration;

  /// No description provided for @symptomDepression.
  ///
  /// In en, this message translates to:
  /// **'Depression'**
  String get symptomDepression;

  /// No description provided for @symptomDiarrhoea.
  ///
  /// In en, this message translates to:
  /// **'Diarrhoea'**
  String get symptomDiarrhoea;

  /// No description provided for @symptomDischromicPatches.
  ///
  /// In en, this message translates to:
  /// **'Dischromic Patches'**
  String get symptomDischromicPatches;

  /// No description provided for @symptomDistentionOfAbdomen.
  ///
  /// In en, this message translates to:
  /// **'Distention Of Abdomen'**
  String get symptomDistentionOfAbdomen;

  /// No description provided for @symptomDizziness.
  ///
  /// In en, this message translates to:
  /// **'Dizziness'**
  String get symptomDizziness;

  /// No description provided for @symptomDryingAndTinglingLips.
  ///
  /// In en, this message translates to:
  /// **'Drying And Tingling Lips'**
  String get symptomDryingAndTinglingLips;

  /// No description provided for @symptomEnlargedThyroid.
  ///
  /// In en, this message translates to:
  /// **'Enlarged Thyroid'**
  String get symptomEnlargedThyroid;

  /// No description provided for @symptomExcessiveHunger.
  ///
  /// In en, this message translates to:
  /// **'Excessive Hunger'**
  String get symptomExcessiveHunger;

  /// No description provided for @symptomExtraMaritalContacts.
  ///
  /// In en, this message translates to:
  /// **'Extra Marital Contacts'**
  String get symptomExtraMaritalContacts;

  /// No description provided for @symptomFamilyHistory.
  ///
  /// In en, this message translates to:
  /// **'Family History'**
  String get symptomFamilyHistory;

  /// No description provided for @symptomFastHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Fast Heart Rate'**
  String get symptomFastHeartRate;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomFluidOverload.
  ///
  /// In en, this message translates to:
  /// **'Fluid Overload'**
  String get symptomFluidOverload;

  /// No description provided for @symptomFoulSmellOfUrine.
  ///
  /// In en, this message translates to:
  /// **'Foul Smell Of Urine'**
  String get symptomFoulSmellOfUrine;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomHighFever.
  ///
  /// In en, this message translates to:
  /// **'High Fever'**
  String get symptomHighFever;

  /// No description provided for @symptomHipJointPain.
  ///
  /// In en, this message translates to:
  /// **'Hip Joint Pain'**
  String get symptomHipJointPain;

  /// No description provided for @symptomHistoryOfAlcoholConsumption.
  ///
  /// In en, this message translates to:
  /// **'History Of Alcohol Consumption'**
  String get symptomHistoryOfAlcoholConsumption;

  /// No description provided for @symptomIncreasedAppetite.
  ///
  /// In en, this message translates to:
  /// **'Increased Appetite'**
  String get symptomIncreasedAppetite;

  /// No description provided for @symptomIndigestion.
  ///
  /// In en, this message translates to:
  /// **'Indigestion'**
  String get symptomIndigestion;

  /// No description provided for @symptomInflammatoryNails.
  ///
  /// In en, this message translates to:
  /// **'Inflammatory Nails'**
  String get symptomInflammatoryNails;

  /// No description provided for @symptomInternalItching.
  ///
  /// In en, this message translates to:
  /// **'Internal Itching'**
  String get symptomInternalItching;

  /// No description provided for @symptomIrregularSugarLevel.
  ///
  /// In en, this message translates to:
  /// **'Irregular Sugar Level'**
  String get symptomIrregularSugarLevel;

  /// No description provided for @symptomIrritability.
  ///
  /// In en, this message translates to:
  /// **'Irritability'**
  String get symptomIrritability;

  /// No description provided for @symptomIrritationInAnus.
  ///
  /// In en, this message translates to:
  /// **'Irritation In Anus'**
  String get symptomIrritationInAnus;

  /// No description provided for @symptomItching.
  ///
  /// In en, this message translates to:
  /// **'Itching'**
  String get symptomItching;

  /// No description provided for @symptomJointPain.
  ///
  /// In en, this message translates to:
  /// **'Joint Pain'**
  String get symptomJointPain;

  /// No description provided for @symptomKneePain.
  ///
  /// In en, this message translates to:
  /// **'Knee Pain'**
  String get symptomKneePain;

  /// No description provided for @symptomLackOfConcentration.
  ///
  /// In en, this message translates to:
  /// **'Lack Of Concentration'**
  String get symptomLackOfConcentration;

  /// No description provided for @symptomLethargy.
  ///
  /// In en, this message translates to:
  /// **'Lethargy'**
  String get symptomLethargy;

  /// No description provided for @symptomLossOfAppetite.
  ///
  /// In en, this message translates to:
  /// **'Loss Of Appetite'**
  String get symptomLossOfAppetite;

  /// No description provided for @symptomLossOfBalance.
  ///
  /// In en, this message translates to:
  /// **'Loss Of Balance'**
  String get symptomLossOfBalance;

  /// No description provided for @symptomLossOfSmell.
  ///
  /// In en, this message translates to:
  /// **'Loss Of Smell'**
  String get symptomLossOfSmell;

  /// No description provided for @symptomMalaise.
  ///
  /// In en, this message translates to:
  /// **'Malaise'**
  String get symptomMalaise;

  /// No description provided for @symptomMildFever.
  ///
  /// In en, this message translates to:
  /// **'Mild Fever'**
  String get symptomMildFever;

  /// No description provided for @symptomMoodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood Swings'**
  String get symptomMoodSwings;

  /// No description provided for @symptomMovementStiffness.
  ///
  /// In en, this message translates to:
  /// **'Movement Stiffness'**
  String get symptomMovementStiffness;

  /// No description provided for @symptomMucoidSputum.
  ///
  /// In en, this message translates to:
  /// **'Mucoid Sputum'**
  String get symptomMucoidSputum;

  /// No description provided for @symptomMusclePain.
  ///
  /// In en, this message translates to:
  /// **'Muscle Pain'**
  String get symptomMusclePain;

  /// No description provided for @symptomMuscleWasting.
  ///
  /// In en, this message translates to:
  /// **'Muscle Wasting'**
  String get symptomMuscleWasting;

  /// No description provided for @symptomMuscleWeakness.
  ///
  /// In en, this message translates to:
  /// **'Muscle Weakness'**
  String get symptomMuscleWeakness;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomNeckPain.
  ///
  /// In en, this message translates to:
  /// **'Neck Pain'**
  String get symptomNeckPain;

  /// No description provided for @symptomNodalSkinEruptions.
  ///
  /// In en, this message translates to:
  /// **'Nodal Skin Eruptions'**
  String get symptomNodalSkinEruptions;

  /// No description provided for @symptomObesity.
  ///
  /// In en, this message translates to:
  /// **'Obesity'**
  String get symptomObesity;

  /// No description provided for @symptomPainBehindTheEyes.
  ///
  /// In en, this message translates to:
  /// **'Pain Behind The Eyes'**
  String get symptomPainBehindTheEyes;

  /// No description provided for @symptomPainDuringBowelMovements.
  ///
  /// In en, this message translates to:
  /// **'Pain During Bowel Movements'**
  String get symptomPainDuringBowelMovements;

  /// No description provided for @symptomPainInAnalRegion.
  ///
  /// In en, this message translates to:
  /// **'Pain In Anal Region'**
  String get symptomPainInAnalRegion;

  /// No description provided for @symptomPainfulWalking.
  ///
  /// In en, this message translates to:
  /// **'Painful Walking'**
  String get symptomPainfulWalking;

  /// No description provided for @symptomPalpitations.
  ///
  /// In en, this message translates to:
  /// **'Palpitations'**
  String get symptomPalpitations;

  /// No description provided for @symptomPassageOfGases.
  ///
  /// In en, this message translates to:
  /// **'Passage Of Gases'**
  String get symptomPassageOfGases;

  /// No description provided for @symptomPatchesInThroat.
  ///
  /// In en, this message translates to:
  /// **'Patches In Throat'**
  String get symptomPatchesInThroat;

  /// No description provided for @symptomPhlegm.
  ///
  /// In en, this message translates to:
  /// **'Phlegm'**
  String get symptomPhlegm;

  /// No description provided for @symptomPolyuria.
  ///
  /// In en, this message translates to:
  /// **'Polyuria'**
  String get symptomPolyuria;

  /// No description provided for @symptomProminentVeinsOnCalf.
  ///
  /// In en, this message translates to:
  /// **'Prominent Veins On Calf'**
  String get symptomProminentVeinsOnCalf;

  /// No description provided for @symptomPuffyFaceAndEyes.
  ///
  /// In en, this message translates to:
  /// **'Puffy Face And Eyes'**
  String get symptomPuffyFaceAndEyes;

  /// No description provided for @symptomPusFilledPimples.
  ///
  /// In en, this message translates to:
  /// **'Pus Filled Pimples'**
  String get symptomPusFilledPimples;

  /// No description provided for @symptomReceivingBloodTransfusion.
  ///
  /// In en, this message translates to:
  /// **'Receiving Blood Transfusion'**
  String get symptomReceivingBloodTransfusion;

  /// No description provided for @symptomReceivingUnsterileInjections.
  ///
  /// In en, this message translates to:
  /// **'Receiving Unsterile Injections'**
  String get symptomReceivingUnsterileInjections;

  /// No description provided for @symptomRedSoreAroundNose.
  ///
  /// In en, this message translates to:
  /// **'Red Sore Around Nose'**
  String get symptomRedSoreAroundNose;

  /// No description provided for @symptomRedSpotsOverBody.
  ///
  /// In en, this message translates to:
  /// **'Red Spots Over Body'**
  String get symptomRedSpotsOverBody;

  /// No description provided for @symptomRednessOfEyes.
  ///
  /// In en, this message translates to:
  /// **'Redness Of Eyes'**
  String get symptomRednessOfEyes;

  /// No description provided for @symptomRestlessness.
  ///
  /// In en, this message translates to:
  /// **'Restlessness'**
  String get symptomRestlessness;

  /// No description provided for @symptomRunnyNose.
  ///
  /// In en, this message translates to:
  /// **'Runny Nose'**
  String get symptomRunnyNose;

  /// No description provided for @symptomRustySputum.
  ///
  /// In en, this message translates to:
  /// **'Rusty Sputum'**
  String get symptomRustySputum;

  /// No description provided for @symptomScurring.
  ///
  /// In en, this message translates to:
  /// **'Scurring'**
  String get symptomScurring;

  /// No description provided for @symptomShivering.
  ///
  /// In en, this message translates to:
  /// **'Shivering'**
  String get symptomShivering;

  /// No description provided for @symptomSilverLikeDusting.
  ///
  /// In en, this message translates to:
  /// **'Silver Like Dusting'**
  String get symptomSilverLikeDusting;

  /// No description provided for @symptomSinusPressure.
  ///
  /// In en, this message translates to:
  /// **'Sinus Pressure'**
  String get symptomSinusPressure;

  /// No description provided for @symptomSkinPeeling.
  ///
  /// In en, this message translates to:
  /// **'Skin Peeling'**
  String get symptomSkinPeeling;

  /// No description provided for @symptomSkinRash.
  ///
  /// In en, this message translates to:
  /// **'Skin Rash'**
  String get symptomSkinRash;

  /// No description provided for @symptomSlurredSpeech.
  ///
  /// In en, this message translates to:
  /// **'Slurred Speech'**
  String get symptomSlurredSpeech;

  /// No description provided for @symptomSmallDentsInNails.
  ///
  /// In en, this message translates to:
  /// **'Small Dents In Nails'**
  String get symptomSmallDentsInNails;

  /// No description provided for @symptomSpinningMovements.
  ///
  /// In en, this message translates to:
  /// **'Spinning Movements'**
  String get symptomSpinningMovements;

  /// No description provided for @symptomSpottingUrination.
  ///
  /// In en, this message translates to:
  /// **'Spotting Urination'**
  String get symptomSpottingUrination;

  /// No description provided for @symptomStiffNeck.
  ///
  /// In en, this message translates to:
  /// **'Stiff Neck'**
  String get symptomStiffNeck;

  /// No description provided for @symptomStomachBleeding.
  ///
  /// In en, this message translates to:
  /// **'Stomach Bleeding'**
  String get symptomStomachBleeding;

  /// No description provided for @symptomStomachPain.
  ///
  /// In en, this message translates to:
  /// **'Stomach Pain'**
  String get symptomStomachPain;

  /// No description provided for @symptomSunkenEyes.
  ///
  /// In en, this message translates to:
  /// **'Sunken Eyes'**
  String get symptomSunkenEyes;

  /// No description provided for @symptomSweating.
  ///
  /// In en, this message translates to:
  /// **'Sweating'**
  String get symptomSweating;

  /// No description provided for @symptomSwelledLymphNodes.
  ///
  /// In en, this message translates to:
  /// **'Swelled Lymph Nodes'**
  String get symptomSwelledLymphNodes;

  /// No description provided for @symptomSwellingJoints.
  ///
  /// In en, this message translates to:
  /// **'Swelling Joints'**
  String get symptomSwellingJoints;

  /// No description provided for @symptomSwellingOfStomach.
  ///
  /// In en, this message translates to:
  /// **'Swelling Of Stomach'**
  String get symptomSwellingOfStomach;

  /// No description provided for @symptomSwollenBloodVessels.
  ///
  /// In en, this message translates to:
  /// **'Swollen Blood Vessels'**
  String get symptomSwollenBloodVessels;

  /// No description provided for @symptomSwollenExtremeties.
  ///
  /// In en, this message translates to:
  /// **'Swollen Extremeties'**
  String get symptomSwollenExtremeties;

  /// No description provided for @symptomSwollenLegs.
  ///
  /// In en, this message translates to:
  /// **'Swollen Legs'**
  String get symptomSwollenLegs;

  /// No description provided for @symptomThroatIrritation.
  ///
  /// In en, this message translates to:
  /// **'Throat Irritation'**
  String get symptomThroatIrritation;

  /// No description provided for @symptomToxicLookTyphos.
  ///
  /// In en, this message translates to:
  /// **'Toxic Look (Typhos)'**
  String get symptomToxicLookTyphos;

  /// No description provided for @symptomUlcersOnTongue.
  ///
  /// In en, this message translates to:
  /// **'Ulcers On Tongue'**
  String get symptomUlcersOnTongue;

  /// No description provided for @symptomUnsteadiness.
  ///
  /// In en, this message translates to:
  /// **'Unsteadiness'**
  String get symptomUnsteadiness;

  /// No description provided for @symptomVisualDisturbances.
  ///
  /// In en, this message translates to:
  /// **'Visual Disturbances'**
  String get symptomVisualDisturbances;

  /// No description provided for @symptomVomiting.
  ///
  /// In en, this message translates to:
  /// **'Vomiting'**
  String get symptomVomiting;

  /// No description provided for @symptomWateringFromEyes.
  ///
  /// In en, this message translates to:
  /// **'Watering From Eyes'**
  String get symptomWateringFromEyes;

  /// No description provided for @symptomWeaknessInLimbs.
  ///
  /// In en, this message translates to:
  /// **'Weakness In Limbs'**
  String get symptomWeaknessInLimbs;

  /// No description provided for @symptomWeaknessOfOneBodySide.
  ///
  /// In en, this message translates to:
  /// **'Weakness Of One Body Side'**
  String get symptomWeaknessOfOneBodySide;

  /// No description provided for @symptomWeightGain.
  ///
  /// In en, this message translates to:
  /// **'Weight Gain'**
  String get symptomWeightGain;

  /// No description provided for @symptomWeightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get symptomWeightLoss;

  /// No description provided for @symptomYellowCrustOoze.
  ///
  /// In en, this message translates to:
  /// **'Yellow Crust Ooze'**
  String get symptomYellowCrustOoze;

  /// No description provided for @symptomYellowUrine.
  ///
  /// In en, this message translates to:
  /// **'Yellow Urine'**
  String get symptomYellowUrine;

  /// No description provided for @symptomYellowingOfEyes.
  ///
  /// In en, this message translates to:
  /// **'Yellowing Of Eyes'**
  String get symptomYellowingOfEyes;

  /// No description provided for @symptomYellowishSkin.
  ///
  /// In en, this message translates to:
  /// **'Yellowish Skin'**
  String get symptomYellowishSkin;

  /// No description provided for @translatingToKinyarwanda.
  ///
  /// In en, this message translates to:
  /// **'Translating to Kinyarwanda...'**
  String get translatingToKinyarwanda;

  /// No description provided for @translationFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation service is currently unavailable. Showing English version.'**
  String get translationFailed;

  /// No description provided for @patternDetected.
  ///
  /// In en, this message translates to:
  /// **'Pattern Detected'**
  String get patternDetected;

  /// No description provided for @chronicConditionDetected.
  ///
  /// In en, this message translates to:
  /// **'Chronic Condition Detected'**
  String get chronicConditionDetected;

  /// No description provided for @persistentConditionDetected.
  ///
  /// In en, this message translates to:
  /// **'Persistent Condition Detected'**
  String get persistentConditionDetected;

  /// No description provided for @recurringConditionDetected.
  ///
  /// In en, this message translates to:
  /// **'Recurring Condition Detected'**
  String get recurringConditionDetected;

  /// No description provided for @recurringConditionMessage.
  ///
  /// In en, this message translates to:
  /// **'This condition has occurred multiple times recently. Recurring health issues may indicate an underlying problem that requires specialized medical evaluation.'**
  String get recurringConditionMessage;

  /// No description provided for @patternDetectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Based on your diagnosis history, we recommend consulting with a specialized clinic for comprehensive care.'**
  String get patternDetectedMessage;

  /// No description provided for @matchedCondition.
  ///
  /// In en, this message translates to:
  /// **'Matched condition: {condition}'**
  String matchedCondition(String condition);

  /// No description provided for @activeForDays.
  ///
  /// In en, this message translates to:
  /// **'Active for {days} days'**
  String activeForDays(int days);

  /// No description provided for @activeForDaysMonths.
  ///
  /// In en, this message translates to:
  /// **'Active for {days} days ({months} months+)'**
  String activeForDaysMonths(int days, int months);

  /// No description provided for @occurrencesInLast90Days.
  ///
  /// In en, this message translates to:
  /// **'{count} occurrences in the last 90 days'**
  String occurrencesInLast90Days(int count);
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
      <String>['en', 'fr', 'rw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'rw':
      return AppLocalizationsRw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
