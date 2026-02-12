import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/topic.dart';
import 'package:onetwotrail/repositories/viewModels/discover_model.dart';
import 'package:onetwotrail/ui/views/discover/discover_topic_carousel.dart';
import 'package:onetwotrail/v2/widget/banner.dart';

class TopicWidgetFactory {
  static Widget createWidgetFromDisplay(
      BuildContext context, String display, Topic topic, DiscoverModel discoverModel) {
    switch (display) {
      case 'banner':
        return createPageBanner(topic);
      case 'carousel':
        return createDiscoverTopicCarousel(context, topic, discoverModel);
      default:
        throw Exception('Unknown display type: $display');
    }
  }

  static PageBanner createPageBanner(Topic topic) {
    final pages = topic.experiences.map((Experience experience) {
      return PageBannerPage(
          primaryText: experience.name,
          secondaryText: experience.destinationName,
          image: NetworkImage(experience.imageUrls.first),
          onTap: (BuildContext context) {
            // Navigate to '/experience' named route.
            // Pass the experience as argument.
            Navigator.pushNamed(context, '/experience', arguments: experience);
          });
    }).toList();
    return PageBanner(pages: pages);
  }

  static DiscoverTopicCarousel createDiscoverTopicCarousel(
      BuildContext context, Topic topic, DiscoverModel discoverModel) {
    return DiscoverTopicCarousel(topic: topic);
  }
}
