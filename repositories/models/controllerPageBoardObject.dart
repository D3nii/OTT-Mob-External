import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/enums/trail_status.dart';

class ControllerPageBoardObject {
  Trail trail;
  bool comeFromCreatingItinerary;

  ControllerPageBoardObject({required this.trail, required this.comeFromCreatingItinerary});

  ControllerPageBoardObject.init()
      : trail = Trail(
          id: 0,
          author: '',
          collaborators: [],
          description: '',
          experiences: [],
          itineraryEstimatedTime: Duration.zero,
          itineraryId: 0,
          latitude: 0.0,
          listingDescription: '',
          lockVersion: 0,
          longitude: 0.0,
          name: '',
          status: TrailStatus.PAUSED,
        ),
        comeFromCreatingItinerary = false;

  @override
  String toString() {
    return 'ControllerPageBoardObject{trail: $trail, comeFromCreatingItinerary: $comeFromCreatingItinerary}';
  }
}
