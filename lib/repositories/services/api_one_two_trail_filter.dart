import 'dart:async';
import 'dart:convert' as JSON;

import 'package:onetwotrail/repositories/models/api_filter.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/services/crash_reporter.dart';
import 'package:rxdart/rxdart.dart';

class FilterApiProxy {
  late ApplicationApi _applicationApi;

  FilterApiProxy(this._applicationApi);

  StreamController<BaseResponse<List<ApiFilters>>> _cacheFilters = BehaviorSubject<BaseResponse<List<ApiFilters>>>();
  List<ApiFilters> _cacheList = [];

  Stream<BaseResponse<List<ApiFilters>>> getApiFilters() {
    _cacheFilters.add(BaseResponse(_cacheList, LOADING));

    try {
      _applicationApi.getSearchFilters().then((value) {
        if (value.statusCode == 200) {
          List<ApiFilters> list = parseBody(value.body);
          _cacheList = list;
          _cacheFilters.add(BaseResponse(_cacheList, SUCCESS));
        } else {
          _cacheFilters.add(BaseResponse(_cacheList, ERROR));
        }
      }).catchError((Object error, StackTrace stackTrace) {
        CrashReporter.reportError(
          error,
          stackTrace,
          context: 'Failed to get search filters',
        );
        _cacheFilters.add(BaseResponse(_cacheList, ERROR));
        return null;
      });
    } catch (e, stackTrace) {
      CrashReporter.reportError(
        e,
        stackTrace,
        context: 'Failed to get API filters',
      );
      _cacheFilters.add(BaseResponse(_cacheList, ERROR));
    }

    return _cacheFilters.stream;
  }

  List<ApiFilters> parseBody(String body) {
    Map<String, dynamic> parsed = JSON.json.decode(body);
    List<ApiFilters> list = [];
    for (var value in parsed['entries'] as List) {
      list.add(ApiFilters.fromJson(value as Map<String, dynamic>));
    }

    return list;
  }
}
