import 'package:onetwotrail/repositories/models/experience.dart';

class Topic {
  final int id;
  final String name;
  final String imageUrl;
  bool selected = false;
  List<Experience> experiences = [];
  String description = "";
  String nextPageToken = "";
  int resultsPerPage = 0;

  Topic({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.experiences,
    required this.description,
    required this.nextPageToken,
    required this.resultsPerPage,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    int topicId = json['topic_id'] ?? 0;
    String name = json['name'] ?? "";
    String nextPageToken = json['next_page_token'] ?? "";
    var experienceJsons = json['experiences'] ?? [];
    List<Experience> experiences = [];
    for (var expJson in experienceJsons as List) {
      experiences.add(Experience.fromJson(expJson as Map<String, dynamic>));
    }
    return Topic(
      id: topicId,
      name: name,
      description: "",
      imageUrl: "",
      experiences: experiences,
      nextPageToken: nextPageToken,
      resultsPerPage: json['results_per_page'] ?? 0,
    );
  }

  static void addPage(Map<String, dynamic> page, Topic topic) {
    var experiencePage = page['experiences'] as List?;
    if (experiencePage != null) {
      for (var json in experiencePage) {
        topic.experiences.add(Experience.fromJson(json as Map<String, dynamic>));
      }
    }
    if (page.containsKey('next_page_token')) {
      topic.nextPageToken = page['next_page_token'] as String? ?? "";
    } else {
      topic.nextPageToken = "";
    }
  }
}
