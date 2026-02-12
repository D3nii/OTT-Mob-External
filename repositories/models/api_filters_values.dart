import 'package:flutter/material.dart';

class ApiFiltersValues {
  int position;
  dynamic value;
  String label;
  TimeOfDay time;
  String valueType;

  ApiFiltersValues.init()
      : position = -1,
        value = null,
        label = '',
        time = TimeOfDay(hour: 0, minute: 0),
        valueType = '';

  ApiFiltersValues({
    required this.position,
    this.value,
    required this.label,
    required this.time,
    required this.valueType,
  });

  factory ApiFiltersValues.fromJson(Map<String, dynamic> json) {
    int position = json['position'] != null ? json['position'] : -1;
    TimeOfDay time = TimeOfDay(hour: 0, minute: 0);
    dynamic value;
    if (json['value_type'] == 'time') {
      if (json['value'] != null) {
        String temp = json['value'];
        List<String> split = temp.split(':');
        time = TimeOfDay(hour: int.parse(split[0]), minute: int.parse(split[1]));
      }
    } else {
      value = json['value'];
    }

    String label = json['label'] != null ? json['label'] : '';

    return ApiFiltersValues(
        position: position, value: value, label: label, time: time, valueType: json['value_type'] ?? '');
  }

  @override
  String toString() {
    return 'ApiFiltersValues{position: $position, value: $value, label: $label, time: ${time.toString()}}';
  }
}
