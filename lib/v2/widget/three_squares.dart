// v2/widget/three_squares.dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/v2/util/string.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
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
        // overlapping stack of three images inside a fixed-height container
        return Container(
          height: height ?? 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: InkWell(
              onTap: () => openContainer(),
              child: _OverlappingImageStack(
                mainImage: mainImage,
                secondaryTopImage: secondaryTopImage,
                secondaryBottomImage: secondaryBottomImage,
                cardHeight: height ?? 200,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Internal widget that displays the three images as a horizontal overlapping stack
/// and handles hover/scale interaction. The leftmost card is rendered on top by
/// ordering children such that index 0 is last.
class _OverlappingImageStack extends StatefulWidget {
  final ImageProvider mainImage;
  final ImageProvider secondaryTopImage;
  final ImageProvider secondaryBottomImage;
  final double cardHeight;

  const _OverlappingImageStack({
    required this.mainImage,
    required this.secondaryTopImage,
    required this.secondaryBottomImage,
    required this.cardHeight,
    Key? key,
  }) : super(key: key);

  @override
  _OverlappingImageStackState createState() => _OverlappingImageStackState();
}

class _OverlappingImageStackState extends State<_OverlappingImageStack> {
  int? _hoveredIndex;

  List<ImageProvider> get _images => [
        widget.mainImage,
        widget.secondaryTopImage,
        widget.secondaryBottomImage,
      ];

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 280.0;
    const double overlapOffset = 80.0; // cardWidth - 200px overlap shift

    List<Widget> children = [];
    for (int i = 0; i < _images.length; i++) {
      Widget card = _HoverableImageCard(
        image: _images[i],
        width: cardWidth,
        height: widget.cardHeight,
        hovered: _hoveredIndex == i,
        onHoverChanged: (hovering) {
          setState(() {
            _hoveredIndex = hovering ? i : null;
          });
        },
      );
      children.add(Positioned(left: i * overlapOffset, child: card));
    }

    // bring hovered card to the top of the stack (last child)
    if (_hoveredIndex != null) {
      Widget hovered = children.removeAt(_hoveredIndex!);
      children.add(hovered);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: children,
    );
  }
}

class _HoverableImageCard extends StatelessWidget {
  final ImageProvider image;
  final double width;
  final double height;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;

  const _HoverableImageCard({
    required this.image,
    required this.width,
    required this.height,
    required this.hovered,
    required this.onHoverChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: AnimatedContainer(
      duration: Duration(milliseconds: 200),
      transform: hovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: image, fit: BoxFit.cover),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
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
  // kept for compatibility but not rendered by default
  final String? headlineText;

  /// Optional description shown under the header title
  final String? headerDescription;

  final String titleText;

  /// New badge text that appears to the right of the trail name in the header
  final String? durationText;

  final String summaryTitleText;
  final String summaryBodyText;

  final EdgeInsetsGeometry padding;

  final Color textBackgroundColor;

  TitleThreeSquares({
    required this.titleText,
    this.headlineText,
    this.durationText,
    this.headerDescription,
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
          // header row with name and optional duration badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleText,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
                        color: viridian,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (headerDescription != null && headerDescription!.trim().isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        headerDescription!,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
              if (durationText != null) ...[
                UIHelper.horizontalSpace(8),
                Container(
                  // push down slightly so it lines up more with the
                  // middle of the title text rather than the top edge
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tomato,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    durationText!,
                    // smaller font to de‑emphasize
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ]
            ],
          ),
          UIHelper.verticalSpace(8),
          super.build(context),
          UIHelper.verticalSpace(8),
          // footer title (only show if it's not the same as the header title)
          if (summaryTitleText.trim().isNotEmpty && summaryTitleText.trim() != titleText.trim())
            Text(
              summaryTitleText,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
                backgroundColor: textBackgroundColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          // description under images
          Text(
            summaryBodyText,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w300,
              fontSize: 14,
              color: Color(0xFF666666),
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
            titleText: createRandomText(8),
            durationText: createRandomText(4),
            summaryTitleText: createRandomText(8),
            summaryBodyText: createRandomText(80),
            mainImage: emptyImage,
            secondaryTopImage: emptyImage,
            secondaryBottomImage: emptyImage,
            mainAction: (context) => Container(),
            padding: padding,
          ),
        ));
  }
}
