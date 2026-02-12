import 'package:onetwotrail/repositories/enums/enum_filter_type.dart';
import 'package:onetwotrail/repositories/models/api_filters_values.dart';

class ApiFilters {
  String id;
  String type;
  String label;
  List<int> positions;
  List<ApiFiltersValues> apiFiltersValues;
  FilterType filterType = FilterType.NONE;

  ApiFilters.init()
      : id = '',
        type = '',
        label = '',
        positions = [],
        apiFiltersValues = [],
        filterType = FilterType.NONE;

  ApiFilters({
    required this.id,
    required this.type,
    required this.label,
    required this.positions,
    required this.apiFiltersValues,
    required this.filterType,
  });

  factory ApiFilters.fromJson(Map<String, dynamic> json) {
    String id = json['id'] != null ? json['id'] : "";
    String type = json['type'] != null ? json['type'] : '';
    String label = json['label'] != null ? json['label'] : '';
    List<dynamic> temp = json['values'] != null ? json['values'] : [];
    FilterType filterType = FilterType.NONE;
    switch (type) {
      case "OPTIONS_RANGE":
        {
          filterType = FilterType.OPTIONS_RANGE;
        }
        break;

      case "VALUES_RANGE":
        {
          filterType = FilterType.VALUES_RANGE;
        }
        break;

      case "CHECKBOX":
        {
          filterType = FilterType.CHECK_BOX;
        }
        break;

      default:
        {
          filterType = FilterType.NONE;
        }
        break;
    }

    List<ApiFiltersValues> values = [];
    if (temp.isNotEmpty) {
      for (int i = 0; temp.length > i; i++) {
        values.add(ApiFiltersValues.fromJson(temp[i]));
      }
    }

    return ApiFilters(
      id: id,
      type: type,
      label: label,
      positions: [],  // Default to empty list since it's not in the JSON
      apiFiltersValues: values,
      filterType: filterType,
    );
  }

  @override
  String toString() {
    return 'ApiFilters{id: $id, type: $type, label: $label, positions: $positions, apiFiltersValues: ${apiFiltersValues.toString()}, filterType: $filterType}';
  }
}
