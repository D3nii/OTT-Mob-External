import 'package:flutter/cupertino.dart';
import 'package:onetwotrail/repositories/models/experience.dart';

class ExperienceFeature {
  late bool Function(Experience) getValue;
  late String label;
  late Image image;
}

class ExperienceDetailsHelper {
  static final List<ExperienceFeature> _features = [
    ExperienceFeature()
      ..getValue = ((experience) => experience.accommodation == true)
      ..label = 'Lodging'
      ..image = Image.asset('assets/experience-features/accommodation.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.adultsOnly == true)
      ..label = 'Adults Only'
      ..image = Image.asset('assets/experience-features/adults-only.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.allTerrainVehicleOnly == true)
      ..label = 'All Terrain Vehicles Only'
      ..image = Image.asset('assets/experience-features/all-terrain-vehicles-only.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.birdWatching == true)
      ..label = 'Bird Watching'
      ..image = Image.asset('assets/experience-features/bird-watching.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.camping == true)
      ..label = 'Camping'
      ..image = Image.asset('assets/experience-features/camping.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.carbonNeutral == true)
      ..label = 'Carbon Neutral'
      ..image = Image.asset('assets/experience-features/carbon-neutral.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.evCharger == true)
      ..label = 'EV Charger'
      ..image = Image.asset('assets/experience-features/ev-charger.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.foodDrinks == true)
      ..label = 'Food & Drink'
      ..image = Image.asset('assets/experience-features/food-drink.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.internet == true)
      ..label = 'Internet'
      ..image = Image.asset('assets/experience-features/internet.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.parking == true)
      ..label = 'Parking'
      ..image = Image.asset('assets/experience-features/parking.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.parking == false)
      ..label = 'No Parking'
      ..image = Image.asset('assets/experience-features/no-parking.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.petFriendly == true)
      ..label = 'Pet Friendly'
      ..image = Image.asset('assets/experience-features/pet-friendly.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.petFriendly == false)
      ..label = 'Not Pet Friendly'
      ..image = Image.asset('assets/experience-features/not-pet-friendly.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.publicTransport == true)
      ..label = 'Public Transport'
      ..image = Image.asset('assets/experience-features/public-transport.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.securityLockers == true)
      ..label = 'Security Lockers'
      ..image = Image.asset('assets/experience-features/security-lockers.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.showers == true)
      ..label = 'Showers'
      ..image = Image.asset('assets/experience-features/showers.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.smokingArea == true)
      ..label = 'Smoking Area'
      ..image = Image.asset('assets/experience-features/smoking-area.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.toilets == true)
      ..label = 'Toilets'
      ..image = Image.asset('assets/experience-features/toilets.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.wheelchairAccessible == true)
      ..label = 'Wheelchair Accessible'
      ..image = Image.asset('assets/experience-features/wheelchair-accessible.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.wheelchairAccessible == false)
      ..label = 'Not Wheelchair Accessible'
      ..image = Image.asset('assets/experience-features/not-wheelchair-accessible.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.stayTime < Duration(hours: 2))
      ..label = '1 to 2 hours'
      ..image = Image.asset('assets/experience-features/stay-time.png'),
    ExperienceFeature()
      ..getValue =
          ((experience) => experience.stayTime > Duration(hours: 3) && experience.stayTime < Duration(hours: 6))
      ..label = '3 to 6 hours'
      ..image = Image.asset('assets/experience-features/stay-time.png'),
    ExperienceFeature()
      ..getValue = ((experience) => experience.stayTime > Duration(hours: 6))
      ..label = 'All Day'
      ..image = Image.asset('assets/experience-features/stay-time.png'),
  ];

  static List<ExperienceFeature> getExperienceFeatures(Experience experience) {
    return _features.where((feature) => feature.getValue(experience)).toList();
  }
}
