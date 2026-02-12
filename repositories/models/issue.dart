import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/enums/trail_status.dart';

import 'experience.dart';

class Issue {
  int idExperience;
  String nameExperience;
  List<String> reportType;
  Experience experience;
  Trail trail;

  String comment;

  Issue.init()
      : idExperience = 0,
        nameExperience = "",
        reportType = [],
        comment = "",
        experience = Experience(
          experienceId: 0,
          experienceInTrailId: 0,
          accommodation: false,
          active: false,
          adultsOnly: false,
          allTerrainVehicleOnly: false,
          approved: false,
          birdWatching: false,
          camping: false,
          carbonNeutral: false,
          description: '',
          destinationName: '',
          draftId: '',
          email: '',
          evCharger: false,
          facebook: '',
          foodDrinks: false,
          imageUrls: [],
          instagram: '',
          internet: false,
          latitude: 0.0,
          likes: 0,
          longitude: 0.0,
          name: '',
          nearBy: [],
          parking: false,
          paymentMethods: [],
          petFriendly: false,
          phone: '',
          publicTransport: false,
          recommendations: '',
          related: [],
          securityLockers: false,
          showers: false,
          smokingArea: false,
          stayTime: Duration.zero,
          title: '',
          toilets: false,
          topics: [],
          visitEndTime: DateTime.now(),
          visitStartTime: DateTime.now(),
          visited: false,
          website: '',
          whatsApp: '',
          wheelchairAccessible: false,
        ),
        trail = Trail(
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
        );

  Issue(this.idExperience, this.nameExperience, this.reportType, this.comment, {required this.experience, required this.trail});
}
