import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';
import 'package:onetwotrail/services/crash_reporter.dart';

class ShowDialogComponentDeleteViewModel extends BaseModel {
  Trail? _trail;
  TrailService? _trailService;

  Trail get trail => _trail!;

  TrailService get trailService => _trailService!;

  set trailService(TrailService value) {
    _trailService = value;
    notifyListeners();
  }

  set trail(Trail value) {
    _trail = value;
    notifyListeners();
  }

  void init() {
    // Initialize any required state
  }

  Future<ApplicationApiResponse> deleteCurrentTrail() async {
    try {
      ApplicationApiResponse result = await trailService.deleteTrail(trail);
      return result;
    } catch (e, stackTrace) {
      CrashReporter.reportError(
        e,
        stackTrace,
        context: 'Failed to delete trail',
        attributes: {
          'trail_id': trail.id,
          'trail_name': trail.name,
        },
      );
      return ApplicationApiResponse(
        result: false,
        statusCode: 400,
        responseBody: "Error deleting trail: ${e.toString()}",
        responseObject: (null as dynamic),
      );
    }
  }
}
