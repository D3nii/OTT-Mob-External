import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/topic.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/discovery_service.dart';
import 'package:onetwotrail/repositories/viewModels/discover_model.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/discover/discover_topic_carousel.dart';
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
      builder: (context, applicationApi, discoveryService, user, homeModel, child) {
        return ChangeNotifierProvider<DiscoverModel>(create: (_) {
          var model = DiscoverModel(discoveryService)
            ..user = user
            ..homeModel = homeModel
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
                            child: StreamBuilder<BaseResponse<Map<String, dynamic>>>(
                                initialData: model.lastServiceResponse,
                                stream: model.discoverDataResponse,
                                builder:
                                    (BuildContext context, AsyncSnapshot<BaseResponse<Map<String, dynamic>>> snapshot) {
                                  var response = snapshot.data;
                                  if (response == null || response.responseStatus == 'START') {
                                    return Container();
                                  }
                                  model.lastServiceResponse = response;
                                  return Provider.value(value: response, child: const _ListViewBodyContainer());
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
    return Consumer3<HomeModel, DiscoverModel, BaseResponse<Map<String, dynamic>>>(
        builder: (context, homeModel, discoverModel, discoverResponse, _) {
      if (discoverResponse.responseStatus == ERROR) {
        return _SomethingWentWrongContainer();
      }
      if (discoverResponse.responseStatus == LOADING) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            TitleThreeSquares.getShimmer(padding: EdgeInsets.only(left: 20, right: 20)),
            DiscoverTopicCarousel(topic: Topic.fromJson({'id': 0, 'name': 'Loading...', 'experiences': []}), showShimmer: true),
          ],
        );
      }
      int itemCount = discoverResponse.data['items']?.length ?? 0;
      return RefreshIndicator(
        onRefresh: () async {
          discoverModel.initState();
        },
        child: ListView.separated(
          itemCount: itemCount,
          padding: EdgeInsets.all(0),
          controller: homeModel.discoverScrollController,
          separatorBuilder: (context, index) {
            return UIHelper.verticalSpace(20);
          },
          itemBuilder: (context, index) {
            var item = discoverResponse.data['items']?[index];
            Widget itemWidget;
            if (item == null) {
              itemWidget = Container();
            } else {
              switch (item['@type']) {
                case 'topic':
                  itemWidget = TopicWidgetFactory.createWidgetFromDisplay(
                      context, item['@display'], Topic.fromJson(item), discoverModel);
                  break;
                case 'trail':
                  itemWidget = TrailWidgetFactory.createWidgetFromDisplay(context, item['@display'], Trail.fromJson(item));
                  break;
                default:
                  itemWidget = Container();
            }
            }
            var children = [
              itemWidget,
            ];
            if (index == itemCount - 1) {
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
                          text: AppLocalizations.of(context)?.discoverText.toUpperCase() ?? "DISCOVER",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        TextSpan(text: "\n"),
                        TextSpan(
                          text: AppLocalizations.of(context)?.discoverHeadline ?? "Discover headline",
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
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
                text: AppLocalizations.of(context)?.somethingWentWrongRequestText ?? "Something went wrong",
                children: [
                  TextSpan(text: ". "),
                  TextSpan(
                    text: AppLocalizations.of(context)?.tryAgain ?? "Try again",
                    style: TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () => model.initState(),
                  )
                ]),
          ),
        );
      },
    );
  }
}
