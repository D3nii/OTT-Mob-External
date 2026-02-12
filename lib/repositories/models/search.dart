import 'package:onetwotrail/repositories/models/filters.dart';

class Search {
  int id;
  String name;
  List<String> images;
  double latitude;
  double longitude;
  String address;
  Filters filters;
  bool applyFilters;
  Map<String, dynamic> filterFromFilterView;

  Search({
    required this.id,
    required this.name,
    required this.images,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.filters,
    required this.applyFilters,
    required this.filterFromFilterView,
  });

  Search.init()
      : id = 0,
        name = "",
        images = [],
        latitude = 0.0,
        longitude = 0.0,
        address = "",
        filters = Filters.init(),
        applyFilters = false,
        filterFromFilterView = Map();

  ///get the json and parse the data into variables that are required to create a search object
  factory Search.fromJson(Map<String, dynamic> json) {
    var tempImages = json['images'] ?? "";
    List<String> images = [];
    if (tempImages != "") {
      images = List<String>.from(tempImages as List);
    }

    return Search(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      images: images,
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      address: json['address'] ?? "",
      filters: Filters.init(),
      applyFilters: false,
      filterFromFilterView: {},
    );
  }
}
