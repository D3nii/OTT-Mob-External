import 'dart:async';
import 'package:flutter/material.dart';

/// A descriptor that specifies the content of a [PageBanner].
class PageBannerPage {
  /// The primary text of the item.
  final String primaryText;

  /// The secondary text of the item.
  final String secondaryText;

  /// The image of the item.
  final ImageProvider image;

  /// The action to execute when tapping the item. It receives a BuildContext.
  final Function(BuildContext) onTap;

  /// Creates a [PageBannerPage].
  ///
  /// The [primaryText] and [secondaryText] must not be null.
  const PageBannerPage({
    required this.primaryText,
    required this.secondaryText,
    required this.image,
    required this.onTap,
  });
}

/// A widget that displays a collection of pages of banners.
///
/// The background of each banner is the [PageBannerPage.image].
///
/// Over the background image, in the center, it displays the [PageBannerPage.primaryText] in bold. And below it,
/// the [PageBannerPage.secondaryText] in normal text.
///
/// To traverse the pages, the user can swipe left and right each item.
///
/// The background image of each carousel item is darkened based on [PageBanner.backgroundColorRatio] to allow the
/// primary and secondary text to be visible.
///
/// At the bottom, the widget contains a page indicator using small circles.
class PageBanner extends StatefulWidget {
  /// The pages of the banner.
  final List<PageBannerPage> pages;

  /// The ratio of the background color of each page.
  ///
  /// The background color is the [PageBannerPage.image] darkened by this ratio.
  final double backgroundColorRatio;

  /// Creates a [PageBanner].
  ///
  /// The [pages] must not be null.
  PageBanner({
    required this.pages,
    this.backgroundColorRatio = 0.5,
  });

  @override
  _PageBannerState createState() {
    return _PageBannerState();
  }
}

class _PageBannerState extends State<PageBanner> {
  int _currentPage = 0;
  PageController _pageController = PageController();
  Timer? _autoRotateTimer;
  final Duration _autoRotateInterval = Duration(seconds: 4);
  final Duration _animationDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_handlePageChange);

    // start auto-rotate
    _autoRotateTimer = Timer.periodic(_autoRotateInterval, (_) {
      if (!mounted || widget.pages.isEmpty) return;
      final next = (_pageController.page?.round() ?? _currentPage) + 1;
      final target = next % widget.pages.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(target,
            duration: _animationDuration, curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _autoRotateTimer?.cancel();
    _pageController.removeListener(_handlePageChange);
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange() {
    setState(() {
      _currentPage = _pageController.page?.round() ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .4,
      child: Stack(
        children: [
          // PageView (fills area)
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final item = widget.pages[index];
                return GestureDetector(
                  onTap: () => item.onTap(context),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: item.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(
                              (widget.backgroundColorRatio * 255).toInt()),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(
                                item.primaryText,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              item.secondaryText,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Indicators: small bars centered at bottom (bottom: 20px)
          if (widget.pages.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _createIndicatorBars(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _createIndicatorBars() {
    const double inactiveWidth = 8.0;
    const double activeWidth = 24.0;
    const double height = 8.0;

    List<Widget> widgets = [];
    for (int i = 0; i < widget.pages.length; i++) {
      if (i != 0) widgets.add(SizedBox(width: 8));

      final bool isActive = i == _currentPage;
      widgets.add(AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        width: isActive ? activeWidth : inactiveWidth,
        height: height,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white54,
          borderRadius: BorderRadius.circular(4),
        ),
      ));
    }
    return widgets;
  }
}
