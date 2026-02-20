import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/widgets/images_carrousel_widget.dart';
import 'package:provider/provider.dart';

class Manage extends ChangeNotifier {
  int imagesLoadErrorCount = 0;
}

class CarouselExperiencesImages extends StatefulWidget {
  const CarouselExperiencesImages(this.experience, {Key? key})
      : super(key: key);

  final Experience experience;

  @override
  _CarouselExperiencesImagesState createState() =>
      _CarouselExperiencesImagesState();
}

class _CarouselExperiencesImagesState extends State<CarouselExperiencesImages> {
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
      if (!mounted || widget.experience.imageUrls.isEmpty) return;
      final next = (_pageController.page?.round() ?? _currentPage) + 1;
      final target = next % widget.experience.imageUrls.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          target,
          duration: _animationDuration,
          curve: Curves.easeInOut,
        );
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
    if (mounted) {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.experience.imageUrls.isEmpty) return Container();

    return ChangeNotifierProvider(
      create: (_) => Manage(),
      child: Consumer2<Manage, BaseWidgetModel>(
        builder: (context, manage, baseWidgetModel, __) {
          manage.imagesLoadErrorCount = 0;
          return Stack(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.experience.imageUrls.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      Map<String, Object> value = {
                        'experience': widget.experience,
                        'index': index
                      };
                      return OpenContainer(
                        openElevation: 0,
                        closedElevation: 0,
                        closedColor: Colors.transparent,
                        closedShape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        openBuilder: (context, _) =>
                            Provider<Map<String, Object>>.value(
                          key: ValueKey(widget.experience.imageUrls[index]),
                          value: value,
                          child: ImagesCarrouselWidget(),
                        ),
                        closedBuilder: (context, openContainer) => Container(
                          decoration: BoxDecoration(
                            color: grey125Color,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            child: InkWell(
                              onTap: openContainer,
                              child: Image.network(
                                widget.experience.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  manage.imagesLoadErrorCount += 1;
                                  return Container(color: Colors.grey[300]);
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (widget.experience.imageUrls.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _createIndicatorBars(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _createIndicatorBars() {
    const double inactiveWidth = 8.0;
    const double activeWidth = 24.0;
    const double height = 4.0;

    List<Widget> widgets = [];
    for (int i = 0; i < widget.experience.imageUrls.length; i++) {
      if (i != 0) widgets.add(SizedBox(width: 6));

      final bool isActive = i == _currentPage;
      widgets.add(AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        width: isActive ? activeWidth : inactiveWidth,
        height: height,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      ));
    }
    return widgets;
  }
}
