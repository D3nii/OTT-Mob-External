import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:onetwotrail/repositories/models/topic.dart';
import 'package:onetwotrail/ui/widgets/topic_card.dart';



class RegisterTopicsGridView extends StatelessWidget {
  final ScrollController scrollController;
  final List<Topic> topicsList;
  final PickedTopicCallback pickedTopicCallback;

  const RegisterTopicsGridView(this.scrollController, this.topicsList, this.pickedTopicCallback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
    margin: const EdgeInsets.all(0),
    width: double.maxFinite,
    height: 276,
    child: GridView.builder(
      itemCount: topicsList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 4 / 5,
        crossAxisSpacing: 7.0,
        mainAxisSpacing: 3.5,
      ),
      itemBuilder: (ctx, index) => TopicCard(pickedTopicCallback, topic: topicsList[index]),
      controller: scrollController,
    ),
  );
}
}
