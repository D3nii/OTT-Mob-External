import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/topic.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/widgets/add_toggle_button.dart';

typedef PickedTopicCallback = Function(int id);

class TopicCard extends StatelessWidget {
  const TopicCard(this.pickedTopicCallback, {Key? key, required this.topic}) : super(key: key);

  final PickedTopicCallback pickedTopicCallback;
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: () {
      pickedTopicCallback(topic.id);
    },
    child: Container(
      decoration: BoxDecoration(
        color: greyColor,
        image: DecorationImage(
            image: CachedNetworkImageProvider(
              topic.imageUrl,
            ),
            fit: BoxFit.cover),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          color: topic.selected ? Colors.black38 : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Column(
            children: <Widget>[
              Text(
                topic.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              ImageIcon(
                AssetImage("assets/icons/icon_checkmark.png"),
                size: 32,
                color: topic.selected ? Colors.white : Colors.transparent,
              ),
              Spacer(),
              Row(
                children: <Widget>[
                  Spacer(),
                  AddToggleButton(topic.selected, () {
                    pickedTopicCallback(topic.id);
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
  }
}
