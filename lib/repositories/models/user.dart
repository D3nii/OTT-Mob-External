import 'dart:convert';
import 'package:logging/logging.dart';

import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/ui/share/country_list.dart';
import 'package:onetwotrail/repositories/models/country.dart';

class User {
  static final _log = Logger('User');

  int id;
  String firstName;
  String lastName;
  String email;
  bool isLogged;
  List<Trail> trails;
  bool pickTopics;
  bool selectCountry;
  String country;
  String phoneNumber;
  String avatar;
  List<Experience> visitedExperiences;
  bool password;

  // Get the country name from the country code
  String get countryName {
    if (country.isEmpty) {
      return "";
    }

    try {
      // Check if the country code exists in our list
      bool validCountry = false;
      for (Country c in CountryList.countryList) {
        if (c.code == country) {
          validCountry = true;
          break;
        }
      }

      // If valid, return the country name, otherwise return empty string
      if (validCountry) {
        return CountryList.countryFromCode(country).name;
      } else {
        _log.warning("Unknown country code: $country - defaulting to empty string");
        return ""; // Default to empty string if code not found
      }
    } catch (e) {
      _log.warning("Failed to get country name for code: $country - ${e.toString()}");
      return ""; // Default to empty string on error
    }
  }

  // Get the Country object from the country code
  Country get countryObject {
    return CountryList.countryFromCode(country);
  }

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isLogged,
    required this.trails,
    required this.pickTopics,
    required this.country,
    required this.phoneNumber,
    required this.avatar,
    required this.selectCountry,
    required this.visitedExperiences,
    required this.password,
  });

  User.initial()
      : id = 0,
        firstName = '',
        lastName = '',
        email = '',
        isLogged = false,
        trails = [],
        pickTopics = false,
        selectCountry = true,
        country = "",
        phoneNumber = "",
        avatar = "",
        visitedExperiences = [],
        password = false;

  factory User.fromJson(Map<String, dynamic> json) {
    String firstName = json['first_name'] ?? "";
    String lastName = json['last_name'] ?? "";
    String email = json['email'] ?? "";
    String phoneNumber = json['phone_number'] ?? "";

    // Handle country code - ensure it's a string and not null
    String country = "";
    if (json['country'] != null) {
      country = json['country'].toString();

      // Validate that the country code exists in our list
      bool validCountry = false;
      for (Country c in CountryList.countryList) {
        if (c.code == country) {
          validCountry = true;
          break;
        }
      }

      // If not valid, log a warning but keep the code
      // The countryName getter will handle returning an empty string for display
      if (!validCountry && country.isNotEmpty) {
        _log.warning("Unknown country code received from API: $country");
      }
    }

    String avatar = json['avatar'] ?? "";
    List<Experience> visitedExperiences = [];
    if (json['visited_experiences'] != null) {
      for (var val in json['visited_experiences'] as List) {
        Experience experience = Experience.fromJson(val as Map<String, dynamic>);
        visitedExperiences.add(experience);
      }
    }
    bool password = json['password'] ?? false;
    return User(
      id: json['id'] ?? 0,
      firstName: firstName,
      lastName: lastName,
      email: email,
      isLogged: json['is_logged'] ?? false,
      trails: [],  // Default to empty list
      pickTopics: json['pick_topics'] ?? false,
      selectCountry: json['select_country'] ?? true,
      country: country,
      phoneNumber: phoneNumber,
      avatar: avatar,
      visitedExperiences: visitedExperiences,
      password: password,
    );
  }

  String toJsonString() {
    var jsonMap = {
      "first_name": this.firstName,
      "last_name": this.lastName,
      "email": this.email,
      "phone_number": this.phoneNumber,
      "country": this.country,
    };

    if (this.avatar.isNotEmpty) {
      jsonMap["avatar"] = this.avatar;
    }

    return jsonEncode(jsonMap);
  }

  User copy() {
    return User(
      id: this.id,
      firstName: this.firstName,
      lastName: this.lastName,
      email: this.email,
      isLogged: this.isLogged,
      trails: this.trails,
      pickTopics: this.pickTopics,
      selectCountry: this.selectCountry,
      country: this.country,
      phoneNumber: this.phoneNumber,
      avatar: this.avatar,
      visitedExperiences: this.visitedExperiences,
      password: this.password,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email}';
  }
}
