// v2/widget/three_squares.dart
import 'dart:math' as math;
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/v2/util/string.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class ThreeSquares extends StatelessWidget {
  final ImageProvider? mainImage;
  final ImageProvider? secondaryTopImage;
  final ImageProvider? secondaryBottomImage;
  final List<ImageProvider>? images;
  final Function(BuildContext context) mainAction;
  final double? height;

  ThreeSquares({
    this.mainImage,
    this.secondaryTopImage,
    this.secondaryBottomImage,
    required this.mainAction,
    this.height,
    this.images,
  });

  @override
  Widget build(BuildContext context) {
    final empty = AssetImage('assets/help/empty_image.png');
    return OpenContainer<bool>(
      transitionDuration: Duration(milliseconds: 500),
      closedElevation: 0,
      openBuilder: (context, _) => mainAction(context),
      closedBuilder: (context, openContainer) {
        return Container(
          height: height ?? 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: InkWell(
              onTap: () => openContainer(),
              child: LayoutBuilder(
                builder: (context, constraints) => _OverlappingImageStack(
                  images: images ??
                      [
                        mainImage ?? empty,
                        secondaryTopImage ?? empty,
                        secondaryBottomImage ?? empty,
                      ],
                  cardHeight: height ?? 200,
                  maxWidth: constraints.maxWidth,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverlappingImageStack extends StatefulWidget {
  final List<ImageProvider> images;
  final double cardHeight;
  final double maxWidth;

  const _OverlappingImageStack({
    required this.images,
    required this.cardHeight,
    required this.maxWidth,
    Key? key,
  }) : super(key: key);

  @override
  _OverlappingImageStackState createState() => _OverlappingImageStackState();
}

class _OverlappingImageStackState extends State<_OverlappingImageStack> {
  int? _hoveredIndex;

  List<ImageProvider> get _images => [...widget.images];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double availableWidth = widget.maxWidth.isFinite
          ? widget.maxWidth
          : constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 360.0;
      final int count = _images.length;
      if (count == 0) return SizedBox.shrink();

      // Defaults similar to original behaviour
      const double defaultCardWidth = 280.0;
      const double desiredOverlap = 80.0;
      const int maxAllowed = 4;

      final int visible = math.min(count, maxAllowed);

      double cardWidth = defaultCardWidth;
      double overlap = desiredOverlap;

      if (defaultCardWidth + desiredOverlap * (visible - 1) > availableWidth) {
        final double minOverlap = 20.0;
        final double computedOverlap =
            (availableWidth - defaultCardWidth) / (visible - 1);
        if (computedOverlap >= minOverlap) {
          overlap = computedOverlap;
        } else {
          overlap = minOverlap;
          final double computedCard = availableWidth - overlap * (visible - 1);
          cardWidth = computedCard > 80.0 ? computedCard : 80.0;
        }
      }

      List<Widget> children = [];
      for (int i = 0; i < visible; i++) {
        final double w = cardWidth;
        Widget card = _HoverableImageCard(
          image: _images[i],
          width: w,
          height: widget.cardHeight,
          hovered: _hoveredIndex == i,
          onHoverChanged: (hovering) {
            setState(() {
              _hoveredIndex = hovering ? i : null;
            });
          },
        );
        children.add(Positioned(left: i * overlap, child: card));
      }

      // Render leftmost image on top by reversing order so index 0 is last
      List<Widget> finalChildren = children.reversed.toList();

      // If hovered, bring hovered card to top
      if (_hoveredIndex != null) {
        int removeAtIndex = (children.length - 1) - _hoveredIndex!;
        if (removeAtIndex >= 0 && removeAtIndex < finalChildren.length) {
          Widget hovered = finalChildren.removeAt(removeAtIndex);
          finalChildren.add(hovered);
        }
      }

      return Stack(
        clipBehavior: Clip.none,
        children: finalChildren,
      );
    });
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
        transform:
            hovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
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
  final String? headlineText;
  final String? headerDescription;
  final String titleText;
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
    List<ImageProvider>? images,
    double? height,
    required Function(BuildContext context) mainAction,
  }) : super(
          mainImage: images != null && images.isNotEmpty
              ? images[0]
              : AssetImage('assets/help/empty_image.png'),
          secondaryTopImage: images != null && images.length > 1
              ? images[1]
              : AssetImage('assets/help/empty_image.png'),
          secondaryBottomImage: images != null && images.length > 2
              ? images[2]
              : AssetImage('assets/help/empty_image.png'),
          images: images,
          height: height,
          mainAction: mainAction,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => mainAction(context)),
              );
            },
            child: Row(
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
                      if (headerDescription != null &&
                          headerDescription!.trim().isNotEmpty) ...[
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
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tomato,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      durationText!,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ]
              ],
            ),
          ),
          UIHelper.verticalSpace(8),
          super.build(context),
          UIHelper.verticalSpace(8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => mainAction(context)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (summaryTitleText.trim().isNotEmpty &&
                    summaryTitleText.trim() != titleText.trim())
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
            images: [emptyImage, emptyImage, emptyImage],
            mainAction: (context) => Container(),
            padding: padding,
          ),
        ));
  }
}
