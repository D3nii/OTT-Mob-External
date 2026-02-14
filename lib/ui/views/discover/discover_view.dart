import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as json;
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/topic.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/discovery_service.dart';
import 'package:onetwotrail/repositories/viewModels/discover_model.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/discover/discover_topic_carousel.dart';
import 'package:onetwotrail/ui/widgets/experience_horizontal_list.dart';
import 'package:onetwotrail/v2/topic/widgets.dart';
import 'package:onetwotrail/v2/trail/widgets.dart';
import 'package:onetwotrail/v2/widget/three_squares.dart';
import 'package:provider/provider.dart';

const String ERROR = 'ERROR';
const String LOADING = 'LOADING';

class DiscoverView extends StatelessWidget {
  final ScrollController? scrollController;

  const DiscoverView({Key? key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer4<ApplicationApi, DiscoveryService, User, HomeModel>(
      builder:
          (context, applicationApi, discoveryService, user, homeModel, child) {
        return ChangeNotifierProvider<DiscoverModel>(create: (_) {
          var model = DiscoverModel(discoveryService)
            ..user = user
            ..homeModel = homeModel
            ..setSelectedTopicName(Uri.base.queryParameters['q'])
            ..initState();
          return model;
        }, child: Consumer2<HomeModel, DiscoverModel>(
          builder: (context, homeModel, model, _) {
            return PopScope(
              canPop: model.filters.isEmpty,
              onPopInvokedWithResult: (didPop, dynamic result) {
                if (!didPop) {
                  model.applyFilters({});
                }
              },
              child: Focus(
                focusNode: model.focusNode,
                child: GestureDetector(
                    onLongPress: () {
                      model.focusNode.requestFocus();
                    },
                    onTap: () {
                      model.focusNode.requestFocus();
                    },
                    child: Column(
                      children: [
                        _AppBarWithSearchBarContainer(),
                        Builder(builder: (context) {
                          return Expanded(
                            child: StreamBuilder<
                                    BaseResponse<Map<String, dynamic>>>(
                                initialData: model.lastServiceResponse,
                                stream: model.discoverDataResponse,
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                            BaseResponse<Map<String, dynamic>>>
                                        snapshot) {
                                  var response = snapshot.data;
                                  if (response == null ||
                                      response.responseStatus == 'START') {
                                    return Container();
                                  }
                                  model.lastServiceResponse = response;
                                  return Provider.value(
                                      value: response,
                                      child: const _ListViewBodyContainer());
                                }),
                          );
                        }),
                      ],
                    )),
              ),
            );
          },
        ));
      },
    );
  }
}

class _ListViewBodyContainer extends StatelessWidget {
  const _ListViewBodyContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeModel, DiscoverModel,
            BaseResponse<Map<String, dynamic>>>(
        builder: (context, homeModel, discoverModel, discoverResponse, _) {
      if (discoverResponse.responseStatus == ERROR) {
        return _SomethingWentWrongContainer();
      }
      if (discoverResponse.responseStatus == LOADING) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const _TopicsCarousel(),
            TitleThreeSquares.getShimmer(
                padding: EdgeInsets.only(left: 20, right: 20)),
            DiscoverTopicCarousel(
                topic: Topic.fromJson(
                    {'id': 0, 'name': 'Loading...', 'experiences': []}),
                showShimmer: true),
          ],
        );
      }
      String? selectedTopicName = discoverModel.selectedTopicName;
      // When a specific topic is selected, show its experiences from the search API.
      if (selectedTopicName != null && selectedTopicName.isNotEmpty) {
        return _TopicSearchResults(topicName: selectedTopicName);
      }

      var items = discoverResponse.data['items'] as List<dynamic>? ?? [];
      List<dynamic> visibleItems = items;
      int itemCount = visibleItems.length;
      return RefreshIndicator(
        onRefresh: () async {
          discoverModel.initState();
        },
        child: ListView.separated(
          itemCount: itemCount + 1,
          padding: EdgeInsets.all(0),
          controller: homeModel.discoverScrollController,
          separatorBuilder: (context, index) {
            // Do not add a separator above the topics carousel.
            if (index == 0) {
              return SizedBox.shrink();
            }
            return UIHelper.verticalSpace(20);
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              // Topics carousel at the top of the list.
              return const _TopicsCarousel();
            }

            var item = visibleItems[index - 1];
            Widget itemWidget;
            if (item == null) {
              itemWidget = Container();
            } else {
              switch (item['@type']) {
                case 'topic':
                  itemWidget = TopicWidgetFactory.createWidgetFromDisplay(
                      context,
                      item['@display'],
                      Topic.fromJson(item),
                      discoverModel);
                  break;
                case 'trail':
                  itemWidget = TrailWidgetFactory.createWidgetFromDisplay(
                      context, item['@display'], Trail.fromJson(item));
                  break;
                default:
                  itemWidget = Container();
              }
            }
            var children = [
              itemWidget,
            ];
            if (index == itemCount) {
              children.add(UIHelper.verticalSpace(120));
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            );
          },
        ),
      );
    });
  }
}

class _AppBarWithSearchBarContainer extends StatelessWidget {
  const _AppBarWithSearchBarContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoverModel>(builder: (context, model, _) {
      Size mediaQuery = MediaQuery.of(context).size;
      return Container(
        height: mediaQuery.height * 0.15,
        child: Stack(
          children: [
            Container(
              width: mediaQuery.width,
              height: mediaQuery.height * 0.15,
              child: Image.asset(
                'assets/background_images/brand_bg_header.png',
                fit: BoxFit.fill,
              ),
            ),
            SafeArea(
                bottom: false,
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)
                                  ?.discoverText
                                  .toUpperCase() ??
                              "DISCOVER",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        TextSpan(text: "\n"),
                        TextSpan(
                          text:
                              AppLocalizations.of(context)?.discoverHeadline ??
                                  "Discover headline",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      );
    });
  }
}

class _TopicsCarousel extends StatefulWidget {
  const _TopicsCarousel({Key? key}) : super(key: key);

  @override
  State<_TopicsCarousel> createState() => _TopicsCarouselState();
}

class _TopicsCarouselState extends State<_TopicsCarousel> {
  List<String> _topics = const ['All'];
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  static const Duration _smoothScrollDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
    _loadTopics();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollState);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollState() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final bool canLeft = offset > 0;
    final bool canRight = offset < maxExtent;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  Future<void> _scrollByCards(int direction, double cardWidth) async {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    final delta = direction * cardWidth * 2; // two cards per click
    final target = (current + delta).clamp(0.0, maxExtent);
    await _scrollController.animateTo(
      target,
      duration: _smoothScrollDuration,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadTopics() async {
    try {
      final applicationApi =
          Provider.of<ApplicationApi>(context, listen: false);
      // Request enough topics to cover the full list (24+).
      final topics = await applicationApi.getTopics(
        resultsPerPage: 30,
        token: applicationApi.context.token,
      );
      if (!mounted) return;
      setState(() {
        _topics = ['All', ...topics.map((t) => t.name)];
      });
    } catch (_) {
      // If the request fails, keep the default "All" topic.
    }
  }

  @override
  Widget build(BuildContext context) {
    final discoverModel = Provider.of<DiscoverModel>(context);
    final String? activeTopic = discoverModel.selectedTopicName;
    final Color selectedColor = Theme.of(context).primaryColor;
    final Color unselectedColor = Colors.black.withOpacity(0.6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        int visibleCards;
        if (width > 1440) {
          visibleCards = 9;
        } else if (width > 1024) {
          visibleCards = 7;
        } else if (width > 768) {
          visibleCards = 4;
        } else {
          visibleCards = 3;
        }
        // Leave a small gap between cards; actual width is based on visibleCards.
        final double cardWidth = width / visibleCards;

        return MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Container(
            height: width <= 768 ? 44 : 56,
            color: Colors.grey[100],
            // Slightly reduce horizontal padding so topics sit closer together.
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Focus(
              autofocus: false,
              onKey: (FocusNode node, RawKeyEvent event) {
                if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  _scrollByCards(-1, cardWidth);
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  _scrollByCards(1, cardWidth);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Row(
                children: [
                  // Left arrow (always visible, enabled only when it can scroll left)
                  _ArrowButton(
                    icon: Icons.arrow_back_ios_new,
                    enabled: _canScrollLeft,
                    onTap: () => _scrollByCards(-1, cardWidth),
                  ),
                  Expanded(
                    child: Listener(
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          // Translate vertical scrolling into horizontal motion.
                          final delta = pointerSignal.scrollDelta.dy;
                          final target =
                              (_scrollController.offset + delta).clamp(
                            0.0,
                            _scrollController.position.maxScrollExtent,
                          );
                          _scrollController.jumpTo(target);
                        }
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _topics.length,
                        // Fixed gap between topic labels so spacing is uniform.
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final String label = _topics[index];
                          final bool isSelected = (index == 0 &&
                                  (activeTopic == null ||
                                      activeTopic.isEmpty)) ||
                              label == activeTopic;
                          return GestureDetector(
                            onTap: () {
                              final String? selectedName =
                                  index == 0 ? null : label;
                              discoverModel.setSelectedTopicName(selectedName);
                            },
                            child: Container(
                              // Small horizontal padding so the visual gap is controlled by the separator.
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.0,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? selectedColor
                                          : unselectedColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 2,
                                    width: isSelected ? 24 : 0,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? selectedColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Right arrow (always visible, enabled only when it can scroll right)
                  _ArrowButton(
                    icon: Icons.arrow_forward_ios,
                    enabled: _canScrollRight,
                    onTap: () => _scrollByCards(1, cardWidth),
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

class _ArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  final bool enabled;

  const _ArrowButton(
      {Key? key,
      required this.icon,
      required this.onTap,
      required this.enabled})
      : super(key: key);

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.enabled) {
          setState(() => _hovering = true);
        }
      },
      onExit: (_) {
        if (widget.enabled) {
          setState(() => _hovering = false);
        }
      },
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: widget.enabled ? (_hovering ? 1.0 : 0.8) : 0.3,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: widget.enabled && _hovering ? 1.1 : 1.0,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                size: 18,
                color: widget.enabled ? Colors.black87 : Colors.black26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicSearchResults extends StatefulWidget {
  final String topicName;

  const _TopicSearchResults({Key? key, required this.topicName})
      : super(key: key);

  @override
  State<_TopicSearchResults> createState() => _TopicSearchResultsState();
}

class _TopicSearchResultsState extends State<_TopicSearchResults> {
  late Future<List<Experience>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _TopicSearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicName != widget.topicName) {
      _future = _load();
    }
  }

  Future<List<Experience>> _load() async {
    final applicationApi = Provider.of<ApplicationApi>(context, listen: false);
    final response = await applicationApi.search(widget.topicName, {}, 1, 20);
    if (response.statusCode != 200) {
      return [];
    }
    final Map<String, dynamic> parsed =
        json.jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> entries = parsed['entries'] as List<dynamic>? ?? [];
    final experiences = <Experience>[];
    for (final entry in entries) {
      try {
        experiences.add(Experience.fromJson(entry as Map<String, dynamic>));
      } catch (_) {}
    }
    return experiences;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Experience>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView(
            padding: EdgeInsets.zero,
            children: const [
              _TopicsCarousel(),
              SizedBox(height: 16),
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 120),
            ],
          );
        }

        final experiences = snapshot.data ?? [];
        if (experiences.isEmpty) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const _TopicsCarousel(),
              UIHelper.verticalSpace(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No results for "${widget.topicName}".',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              UIHelper.verticalSpace(120),
            ],
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            const _TopicsCarousel(),
            UIHelper.verticalSpace(8),
            experienceHorizontalList(
              context: context,
              experiences: experiences,
              experienceNameFontSize: 14,
              experienceDestinationFontSize: 12,
              // Match app-wide card sizing so topic results use the same card dimensions.
              experienceWidthRatio: 0.4,
              onTap: (ctx, experience) {
                Navigator.pushNamed(ctx, '/experience', arguments: experience);
              },
              paddingLeft: 16,
              paddingRight: 16,
              spaceBetweenExperiences: 8,
              title: widget.topicName,
              titleFontSize: 20,
            ),
            UIHelper.verticalSpace(120),
          ],
        );
      },
    );
  }
}

class _SomethingWentWrongContainer extends StatelessWidget {
  const _SomethingWentWrongContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoverModel>(
      builder: (context, model, _) {
        return Container(
          height: 200,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          alignment: Alignment.topLeft,
          child: RichText(
            text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                text: AppLocalizations.of(context)
                        ?.somethingWentWrongRequestText ??
                    "Something went wrong",
                children: [
                  TextSpan(text: ". "),
                  TextSpan(
                    text: AppLocalizations.of(context)?.tryAgain ?? "Try again",
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => model.initState(),
                  )
                ]),
          ),
        );
      },
    );
  }
}
