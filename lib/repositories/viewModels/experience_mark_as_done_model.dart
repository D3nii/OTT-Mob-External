import 'dart:async';

import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_model.dart';

const String WAZE = 'Waze';
const String GOOGLE_MAPS = 'Google Maps';
const String IOS_MAPS = 'IOS Map';

class ExperienceMarkAsDoneModel extends BaseModel {
  final TrailService _trailService;

  int _like = 0;

  int get like => _like;

  set like(int value) {
    _like = value;
    notifyListeners();
  }

  ExperienceMarkAsDoneModel(this._trailService);

  Future<bool> changeItineraryStatus(int experienceInTrailId, int itineraryId) async {
    String likeEvaluation = "";
    switch (_like) {
      case 1:
        {
          likeEvaluation = "liked";
          break;
        }
      case 2:
        {
          likeEvaluation = "disliked";
          break;
        }
      default:
        {
          likeEvaluation = "NA";
        }
    }
    var experienceInTrail = {
      'id': experienceInTrailId,
      'visited_on_itinerary': true,
    };
    if (likeEvaluation != "NA") {
      experienceInTrail['evaluation'] = likeEvaluation;
    }
    bool success = await _trailService.updateItineraryExperience(itineraryId, experienceInTrail);
    setState(ViewState.Idle);
    return success;
  }
}
