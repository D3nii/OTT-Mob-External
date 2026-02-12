import 'package:onetwotrail/repositories/models/api_filter.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/services/api_one_two_trail_filter.dart';

class FilterService {
  FilterApiProxy _api;

  FilterService(this._api);

  Stream<BaseResponse<List<ApiFilters>>> getApiFilters() {
    return _api.getApiFilters();
  }
}
