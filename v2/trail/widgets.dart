import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/ui/views/trail_preview/trail_preview_view.dart';
import 'package:onetwotrail/v2/util/duration.dart';
import 'package:onetwotrail/v2/widget/banner.dart';
import 'package:onetwotrail/v2/widget/three_squares.dart';
import 'package:provider/provider.dart';

class TrailWidgetFactory {
  static Widget createWidgetFromDisplay(BuildContext context, String display, Trail trail) {
    switch (display) {
      case 'banner':
        return createPageBanner(trail);
      case 'three-squares':
        return createTitleThreeSquares(context, trail);
      default:
        throw Exception('Unknown display type: $display');
    }
  }

  static PageBanner createPageBanner(Trail trail) {
    var experienceCount = trail.experiences.length;
    var secondaryText = "$experienceCount Experience";
    if (experienceCount > 1) {
      secondaryText += "s";
    }
    List<PageBannerPage> pages = [
      PageBannerPage(
          primaryText: trail.name,
          secondaryText: secondaryText,
          image: trail.imageProviders.first,
          onTap: (BuildContext context) {
            // Navigate to the '/public-trail' named route. Pass the trail as argument.
            Navigator.pushNamed(context, '/public-trail', arguments: trail);
          }),
    ];
    return PageBanner(pages: pages);
  }

  static TitleThreeSquares createTitleThreeSquares(BuildContext context, Trail trail) {
    // Convert the duration to a human-readable text.
    var summaryTitleText = fromDurationToText(context, trail.itineraryEstimatedTime);
    // Join the names of the experiences with a comma and space.
    var summaryBodyText = trail.experiences.map((e) => e.name).join(', ');
    return TitleThreeSquares(
      titleText: trail.name,
      headlineText: trail.description,
      summaryTitleText: summaryTitleText,
      summaryBodyText: summaryBodyText,
      mainImage: trail.imageProviders[0],
      secondaryTopImage: trail.imageProviders[1],
      secondaryBottomImage: trail.imageProviders[2],
      mainAction: (BuildContext context) => Provider.value(value: trail, child: TrailPreviewView()),
      padding: EdgeInsets.only(left: 16, right: 16),
    );
  }
}
