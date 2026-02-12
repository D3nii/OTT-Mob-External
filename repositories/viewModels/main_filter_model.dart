import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onetwotrail/repositories/enums/enum_prices.dart';
import 'package:onetwotrail/repositories/enums/enum_type_of_route.dart';
import 'package:onetwotrail/repositories/models/api_filter.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/services/filter_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

class MainFilterModel extends BaseModel {
  late FilterService _filterService;
  double _price = 0.0;
  double _difficultMode = 0.0;
  Prices? _priceSelected;
  TypeOfRoute? _typeOfRoute;
  String _query = '';
  Stream<BaseResponse<List<ApiFilters>>>? filtersStream;
  List<ApiFilters> _apiFilters = [];
  Map<String, dynamic> selectedFiltersValues = {};
  Map<String, dynamic> checkboxCheckedValues = {};
  Map<String, double> sliderSelectedValue = {};
  Map<String, RangeValues> rangeSliderValues = {};
  TimeOfDay? _initHour;
  TimeOfDay? _finalHour;
  double _lowerValue = 0;
  double _upperValue = 48;
  RangeValues? _values;
  String? _start;
  String? _end;
  bool _cardPayment = false;
  bool _amexPayment = false;
  bool _kidsAllowed = false;
  bool _ageOver = false;
  bool _accessibleForLimitedMobility = false;
  bool _wheelchairAccessible = false;
  bool _petFriendly = false;
  List<TimeOfDay> _timeOfDayList = [];

  double get price => _price;

  Prices? get priceSelected => _priceSelected;

  TimeOfDay? get initHour => _initHour;

  TimeOfDay? get finalHour => _finalHour;

  double get lowerValue => _lowerValue;

  double get upperValue => _upperValue;

  RangeValues? get values => _values;

  String? get end => _end;

  String? get start => _start;

  double get difficultMode => _difficultMode;

  TypeOfRoute? get typeOfRoute => _typeOfRoute;

  bool get cardPayment => _cardPayment;

  bool get amexPayment => _amexPayment;

  bool get kidsAllowed => _kidsAllowed;

  bool get accessibleForLimitedMobility => _accessibleForLimitedMobility;

  bool get wheelchairAccessible => _wheelchairAccessible;

  bool get petFriendly => _petFriendly;

  get rangeOfValues => null;

  bool get ageOver => _ageOver;

  // Query with getter/setter for proper notification
  String get query => _query;

  set query(String value) {
    _query = value;
    notifyListeners();
  }

  List<ApiFilters> get apiFilters => _apiFilters;

  set apiFilters(List<ApiFilters> value) {
    _apiFilters = value;
    notifyListeners();
  }

  set petFriendly(bool value) {
    _petFriendly = value;
    notifyListeners();
  }

  set wheelchairAccessible(bool value) {
    _wheelchairAccessible = value;
    notifyListeners();
  }

  set accessibleForLimitedMobility(bool value) {
    _accessibleForLimitedMobility = value;
    notifyListeners();
  }

  set kidsAllowed(bool value) {
    _kidsAllowed = value;
    notifyListeners();
  }

  set amexPayment(bool value) {
    _amexPayment = value;
    notifyListeners();
  }

  set cardPayment(bool value) {
    _cardPayment = value;
    notifyListeners();
  }

  set typeOfRoute(TypeOfRoute? value) {
    _typeOfRoute = value;
    notifyListeners();
  }

  set difficultMode(double value) {
    _difficultMode = value;
    var val = value.floor();
    if (val == 0) {
      _typeOfRoute = TypeOfRoute.EASY;
    } else if (val == 50) {
      _typeOfRoute = TypeOfRoute.MEDIUM;
    } else {
      _typeOfRoute = TypeOfRoute.HARD;
    }
    notifyListeners();
  }

  set start(String? value) {
    _start = value;
    notifyListeners();
  }

  set end(String? value) {
    _end = value;
    notifyListeners();
  }

  set values(RangeValues? value) {
    _values = value;
    notifyListeners();
  }

  set upperValue(double value) {
    _upperValue = value;
    notifyListeners();
  }

  set lowerValue(double value) {
    _lowerValue = value;
    notifyListeners();
  }

  set ageOver(bool value) {
    _ageOver = value;
    notifyListeners();
  }

  set initHour(TimeOfDay? value) {
    _initHour = value;
    notifyListeners();
  }

  set finalHour(TimeOfDay? value) {
    _finalHour = value;
    notifyListeners();
  }

  set priceSelected(Prices? value) {
    _priceSelected = value;
    notifyListeners();
  }

  set price(double value) {
    _price = value;
    var val = price.floor();

    if (val == 0) {
      _priceSelected = Prices.FREE;
    } else if (val == 33) {
      _priceSelected = Prices.LOW;
    } else if (val == 66) {
      _priceSelected = Prices.MEDIUM;
    } else {
      _priceSelected = Prices.EXPENSIVE;
    }

    notifyListeners();
  }

  MainFilterModel(this._filterService) {
    filtersStream = _filterService.getApiFilters();
    _values = RangeValues(lowerValue, upperValue);
    initHour = TimeOfDay(hour: 00, minute: 00);
    finalHour = TimeOfDay(hour: 23, minute: 30);
    start = '00:00';
    end = '23:00';
    notifyListeners();
  }

  setSelectedSliderValue(String id, double value) {
    sliderSelectedValue[id] = value;
    notifyListeners();
  }

  setRangeSliderValue(String id, RangeValues value) {
    rangeSliderValues[id] = value;
    notifyListeners();
  }

  setCheckBoxTypeValue(String id, dynamic value, bool add) {
    if (checkboxCheckedValues[id] == null) {
      checkboxCheckedValues[id] = {
        value: {'id': value, 'selected': add}
      };
    } else {
      checkboxCheckedValues[id][value] = {'id': value, 'selected': add};
    }

    selectedFiltersValues[id] = selectedFiltersValues[id] ?? {'id': id, 'values': []};
    if (add) {
      (selectedFiltersValues[id]['values'] as List<dynamic>).add(value);
    } else {
      (selectedFiltersValues[id]['values'] as List<dynamic>).remove(value);
    }

    notifyListeners();
  }

  setOptionsRangeTypeValue(String id, dynamic value) {
    selectedFiltersValues[id] = selectedFiltersValues[id] ?? {'id': id, 'values': []};
    (selectedFiltersValues[id]['values'] as List<dynamic>).clear();
    (selectedFiltersValues[id]['values'] as List<dynamic>).add(value);
  }

  setTimeRangeTypeValue(String id, int start, int end) {
    String formatStart =
        DateFormat("HH:mm").format(DateTime(2000, 1, 1, _timeOfDayList[start].hour, _timeOfDayList[start].minute));
    String formatEnd =
        DateFormat("HH:mm").format(DateTime(2000, 1, 1, _timeOfDayList[end].hour, _timeOfDayList[end].minute));
    selectedFiltersValues[id] =
        selectedFiltersValues[id] ?? {'id': id, 'start_time': formatStart, 'end_time': formatEnd};

    selectedFiltersValues[id]['start_time'] = formatStart;
    selectedFiltersValues[id]['end_time'] = formatEnd;
  }

  List<String> getRangedLabels(TimeOfDay start, TimeOfDay end, BuildContext context) {
    List<String> labels = [];
    for (int i = start.hour; i <= end.hour; i++) {
      if (i == start.hour && start.minute < 30 && start.minute > 0) {
        _timeOfDayList.add(start);
        labels.add(_timeOfDayList.last.format(context));
        _timeOfDayList.add(TimeOfDay(hour: start.hour, minute: 30));
        labels.add(_timeOfDayList.last.format(context));
      } else if (i == start.hour && start.minute >= 30) {
        _timeOfDayList.add(start);
        labels.add(_timeOfDayList.last.format(context));
        _timeOfDayList.add(TimeOfDay(hour: start.hour + 1, minute: 0));
        labels.add(_timeOfDayList.last.format(context));
      } else if (i == end.hour) {
        if (end.minute >= 30) {
          _timeOfDayList.add(TimeOfDay(hour: i, minute: 0));
          labels.add(_timeOfDayList.last.format(context));
        }
        _timeOfDayList.add(TimeOfDay(hour: i, minute: end.minute));
        labels.add(_timeOfDayList.last.format(context));
      } else {
        _timeOfDayList.add(TimeOfDay(hour: i, minute: 0));
        labels.add(_timeOfDayList.last.format(context));
        _timeOfDayList.add(TimeOfDay(hour: i, minute: 30));
        labels.add(_timeOfDayList.last.format(context));
      }
    }

    return labels;
  }

  bool getStatus(String id, dynamic value) {
    return ((checkboxCheckedValues[id] ??
            {
              value: {'selected': false}
            })[value] ??
        {'selected': false})['selected'];
  }

  void clearFilters() {
    selectedFiltersValues = {};
    checkboxCheckedValues = {};
    sliderSelectedValue = {};
    rangeSliderValues = {};
  }
}
