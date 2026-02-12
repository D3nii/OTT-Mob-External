import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/topic.dart';
import 'package:onetwotrail/repositories/services/discovery_service.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/experience_horizontal_list.dart';
import 'package:onetwotrail/v2/event/event.dart';
import 'package:onetwotrail/v2/event/event_client.dart';
import 'package:onetwotrail/v2/event/event_name.dart';
import 'package:onetwotrail/v2/event/event_source_view.dart';
import 'package:onetwotrail/v2/event/event_tag.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DiscoverTopicCarousel extends StatelessWidget {
  const DiscoverTopicCarousel({Key? key, required this.topic, this.showShimmer = false}) : super(key: key);

  final Topic topic;

  final bool showShimmer;

  @override
  Widget build(BuildContext _context) {
    return showShimmer
        ? Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[200]!,
            enabled: true,
            child: const _ShimmerContent())
        : _Content(topic: topic);
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key, required this.topic}) : super(key: key);

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<DiscoveryService, Handler>(
        create: (_) => Handler(topic.id),
        update: (_, apiDiscoverOneTwoTrail, handler) =>
            (handler ?? Handler(topic.id))..apiDiscoverOneTwoTrail = apiDiscoverOneTwoTrail,
        child: Consumer<Handler>(
          builder: (_, handler, __) => Container(
            child: experienceHorizontalList(
              context: context,
              experiences: topic.experiences,
              experienceNameFontSize: 14,
              experienceDestinationFontSize: 12,
              experienceWidthRatio: 0.4,
              onTap: (context, experience) {
                Provider.of<EventClient>(context, listen: false)
                    .createEvent(Event(EventName.experience_profile_viewed, EventSourceView.discovery_topic, {
                  EventTag.experience_id: experience.experienceId.toString(),
                  EventTag.experience_name: experience.name,
                  EventTag.topic_id: topic.id.toString(),
                  EventTag.topic_name: topic.name,
                }));
              },
              paddingLeft: 16,
              paddingRight: 16,
              spaceBetweenExperiences: 8,
              title: topic.name,
              titleFontSize: 24,
            ),
          ),
        ));
  }
}

class _ShimmerContent extends StatelessWidget {
  const _ShimmerContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 22, 0, 0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'Mountain',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black,
                    backgroundColor: Colors.black),
              ),
            ),
          ),
          UIHelper.verticalSpace(8),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'Get to know the most peaceful places in this country.',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black,
                    backgroundColor: Colors.black),
              ),
            ),
          ),
          UIHelper.verticalSpace(10),
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            height: 250,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Container(
                  width: 120,
                  child: Column(
                    children: [
                      Container(
                        height: 163,
                        decoration: BoxDecoration(
                          color: greyColor,
                          image: DecorationImage(image: AssetImage('assets/help/empty_image.png'), fit: BoxFit.cover),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Container(
                          decoration:
                              BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 2, 8, 10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Spacer(),
                                    Container(
                                      height: 27,
                                      width: 28,
                                      child: ImageIcon(
                                        AssetImage("assets/icons/elipsis.png"),
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Row(
                                  children: <Widget>[
                                    Spacer(),
                                    Container(
                                      height: 27,
                                      width: 27,
                                      child: CircleAvatar(
                                        backgroundColor: viridian,
                                        child: ImageIcon(
                                          AssetImage("assets/icons/icon_plus.png"),
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      UIHelper.verticalSpace(5),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          child: AutoSizeText(
                            'Jaulares Viewport',
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            minFontSize: 10,
                            maxFontSize: 12,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.black,
                                backgroundColor: Colors.black),
                          ),
                        ),
                      ),
                      UIHelper.verticalSpace(5),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          child: Text(
                            '',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Handler extends ChangeNotifier {
  late DiscoveryService _apiDiscoverOneTwoTrail;
  late ScrollController _scrollController;
  bool start = true;
  late int _topicId;
  bool _gettingPage = false;

  ScrollController get scrollController => _scrollController;

  set apiDiscoverOneTwoTrail(DiscoveryService value) {
    _apiDiscoverOneTwoTrail = value;
  }

  Handler(int topicId) {
    _topicId = topicId;
    _scrollController = ScrollController()
      ..addListener(() async {
        if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.33 && !_gettingPage) {
          _gettingPage = true;
          await _apiDiscoverOneTwoTrail.getTopicPage(_topicId);
          _gettingPage = false;
          notifyListeners();
        }
      });
  }
}
