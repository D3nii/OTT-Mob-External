import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/enums/enum_prices.dart';
import 'package:onetwotrail/repositories/enums/enum_type_of_route.dart';

class Filters {
  Prices prices;
  TypeOfRoute typeOfRoute;
  TimeOfDay initHour;
  TimeOfDay finalHour;
  bool cardPayment;
  bool amexPayment;
  bool kidsAllowed;
  bool ageOver;
  bool accessibleForLimitedMobility;
  bool wheelchairAccessible;
  bool petFriendly;
  bool applyFilters;

  Filters({
    required this.prices,
    required this.typeOfRoute,
    required this.initHour,
    required this.finalHour,
    required this.cardPayment,
    required this.amexPayment,
    required this.kidsAllowed,
    required this.ageOver,
    required this.accessibleForLimitedMobility,
    required this.wheelchairAccessible,
    required this.petFriendly,
    required this.applyFilters,
  });

  Filters.init()
      : prices = Prices.LOW,
        typeOfRoute = TypeOfRoute.EASY,
        initHour = TimeOfDay(hour: 0, minute: 0),
        finalHour = TimeOfDay(hour: 0, minute: 0),
        cardPayment = false,
        amexPayment = false,
        kidsAllowed = false,
        ageOver = false,
        accessibleForLimitedMobility = false,
        wheelchairAccessible = false,
        petFriendly = false,
        applyFilters = false;

  @override
  String toString() {
    return 'Filters{prices: $prices,\n'
        ' typeOfRoute: $typeOfRoute,\n'
        ' initHour: $initHour,\n'
        ' finalHour: $finalHour,\n'
        ' cardPayment: $cardPayment,\n'
        ' amexPayment: $amexPayment,\n'
        ' kidsAllowed: $kidsAllowed,\n'
        ' ageOver: $ageOver,\n'
        ' accessibleForLimitedMobility: $accessibleForLimitedMobility,\n'
        ' wheelchairAccessible: $wheelchairAccessible,\n'
        ' petFriendly: $petFriendly,\n'
        ' applyFilters: $applyFilters}';
  }
}
