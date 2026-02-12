import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/v2/util/string.dart';
import 'package:shimmer/shimmer.dart';

class ThreeSquares extends StatelessWidget {
  final ImageProvider mainImage;
  final ImageProvider secondaryTopImage;
  final ImageProvider secondaryBottomImage;
  final Function(BuildContext context) mainAction;
  final double? height;

  ThreeSquares({
      required this.mainImage,
      required this.secondaryTopImage,
      required this.secondaryBottomImage,
      required this.mainAction,
      this.height})
      : super();

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionDuration: Duration(milliseconds: 500),
      closedElevation: 0,
      openBuilder: (context, _) => mainAction(context),
      closedBuilder: (context, openContainer) {
        return Container(
          height: height ?? MediaQuery.of(context).size.width * .5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: InkWell(
              onTap: () => openContainer(),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 50,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: mainImage,
                          ),
                          color: Colors.black12),
                      margin: EdgeInsets.only(right: 4),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Container(
                      color: Colors.black12,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: secondaryTopImage,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              child: Container(
                                margin: EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: secondaryBottomImage,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SlidableThreeSquares extends ThreeSquares {
  final String titleText;
  final List<Widget> secondaryActions;
  final Function(BuildContext context) subMenuAction;

  SlidableThreeSquares({
    required this.titleText,
    required this.secondaryActions,
    required this.subMenuAction,
    required ImageProvider mainImage,
    required ImageProvider secondaryTopImage,
    required ImageProvider secondaryBottomImage,
    required Function(BuildContext context) mainAction,
  }) : super(
          mainImage: mainImage,
          secondaryTopImage: secondaryTopImage,
          secondaryBottomImage: secondaryBottomImage,
          mainAction: mainAction,
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
          closeOnScroll: false,
          // Updated for Flutter 3 compatibility
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: secondaryActions,
          ),
          child: super.build(context),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titleText,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            Container(
              height: 24,
              width: 60,
              child: TextButton(
                child: Image.asset(
                  'assets/icons/elipsis.png',
                  color: Colors.black,
                ),
                onPressed: () => subMenuAction(context),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class TitleThreeSquares extends ThreeSquares {
  final String headlineText;

  final String titleText;

  final String summaryTitleText;
  final String summaryBodyText;

  final EdgeInsetsGeometry padding;

  final Color textBackgroundColor;

  TitleThreeSquares({
    required this.titleText,
    required this.headlineText,
    required this.summaryTitleText,
    required this.summaryBodyText,
    required this.padding,
    this.textBackgroundColor = Colors.transparent,
    required ImageProvider mainImage,
    required ImageProvider secondaryTopImage,
    required ImageProvider secondaryBottomImage,
    required Function(BuildContext context) mainAction,
  }) : super(
          mainImage: mainImage,
          secondaryTopImage: secondaryTopImage,
          secondaryBottomImage: secondaryBottomImage,
          mainAction: mainAction,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Add one line of text with the heading text.
          // Capitalize all the text and make it a bit smaller.
          Text(
            headlineText.toUpperCase(),
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.grey,
              backgroundColor: textBackgroundColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            titleText,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.black,
              backgroundColor: textBackgroundColor,
            ),
          ),
          // Add a 4 pixel vertical margin between the sections.
          UIHelper.verticalSpace(8),
          super.build(context),
          // Add a 4 pixel vertical margin between the sections.
          UIHelper.verticalSpace(8),
          // Add a text to serve as the title of the summary section.
          // It is bold and 2 points bigger than the body text.
          // It only has one line.
          Text(
            summaryTitleText,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.black,
              backgroundColor: textBackgroundColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Add text under the three squares.
          // It contains the summary text.
          // If it is longer than two lines, truncate it using an ellipsis.
          Text(
            summaryBodyText,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.black,
              backgroundColor: textBackgroundColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static Shimmer getShimmer({EdgeInsetsGeometry padding = EdgeInsets.zero}) {
    var emptyImage = AssetImage('assets/help/empty_image.png');
    return Shimmer.fromColors(
        baseColor: Colors.grey[400] ?? Colors.grey,
        highlightColor: Colors.grey[200] ?? Colors.grey.shade300,
        enabled: true,
        child: IgnorePointer(
          child: TitleThreeSquares(
            textBackgroundColor: Colors.black,
            headlineText: createRandomText(80),
            titleText: createRandomText(8),
            summaryTitleText: createRandomText(80),
            summaryBodyText: createRandomText(160),
            mainImage: emptyImage,
            secondaryTopImage: emptyImage,
            secondaryBottomImage: emptyImage,
            mainAction: (context) => Container(),
            padding: padding,
          ),
        ));
  }
}
