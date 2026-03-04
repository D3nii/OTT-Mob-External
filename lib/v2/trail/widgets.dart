// v2/trail/widgets.dart
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
    // Convert the duration to a human-readable text for the badge.
    var durationText = fromDurationToText(context, trail.itineraryEstimatedTime);

    // The footer will repeat the trail name as the title and show
    // the listing description in the body.
    var footerTitle = trail.name;
    var footerBody = trail.listingDescription;

    return TitleThreeSquares(
      titleText: trail.name,
      durationText: durationText,
      headerDescription: trail.description,
      summaryTitleText: footerTitle,
      summaryBodyText: footerBody,
      images: trail.imageProviders,
      mainAction: (BuildContext context) => Provider.value(value: trail, child: TrailPreviewView()),
      padding: EdgeInsets.only(left: 16, right: 16),
    );
  }
}
