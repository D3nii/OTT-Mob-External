import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/widgets/dots_item_experience.dart';
import 'package:provider/provider.dart';

class ItineraryExperienceItem extends StatelessWidget {
  final double height;
  final double width;
  final VoidCallback onGoNowTap;
  final VoidCallback onMoreTap;

  static final Logger _logger = Logger('ItineraryExperienceItem');

  ItineraryExperienceItem({required this.onGoNowTap, required this.onMoreTap, this.height = 115, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    Experience experience = Provider.of<Experience>(context, listen: false);
    Size mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Stack(
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        flex: 60,
                        child: _createImage(
                            experience.visited, experience.imageUrls.isNotEmpty ? experience.imageUrls[0] : null)),
                    Flexible(
                      flex: 40,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              flex: 50,
                              child: _createImage(
                                  experience.visited,
                                  experience.imageUrls.length > 1
                                      ? experience.imageUrls[1]
                                      : null)),
                          Flexible(
                            flex: 50,
                            child: Stack(
                              children: [
                                _createImage(
                                    experience.visited,
                                    experience.imageUrls.length > 2
                                        ? experience.imageUrls[2]
                                        : null),
                                ...[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                      padding: EdgeInsets.only(right: 5),
                                      height: mediaQuery.height * 0.05,
                                      width: mediaQuery.width * 0.3,
                                      child: new TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: tealish,
                                          shape: new RoundedRectangleBorder(
                                              borderRadius: new BorderRadius.circular(30.0)),
                                        ),
                                        child: new Text(
                                          AppLocalizations.of(context)?.goNowText ?? 'Go Now',
                                          style: TextStyle(
                                              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                                        ),
                                        onPressed: onGoNowTap,
                                      )),
                                )
                              ]
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withAlpha(204), Colors.transparent])),
              ),
              ...[
              Positioned(
                top: 0,
                right: 4,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.white24,
                    highlightColor: Colors.white10,
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => onMoreTap(),
                    child: Container(
                      height: 48,
                      width: 48,
                      padding: EdgeInsets.all(12),
                      child: DotsItemExperience(),
                    ),
                  ),
                ),
              )
            ]
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: experience.visited
              ? Text(
                  experience.name,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                )
              : Text(
                  experience.name,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 13),
                ),
        ),
      ],
    );
  }

  Widget _createImage(bool visited, [String? imageUrl]) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: visited ? ColorFilter.mode(Colors.grey, BlendMode.color) : null,
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            _logger.warning(
              'Error loading image: $imageUrl - ${exception.toString()}',
              exception,
              stackTrace
            );
          },
        ),
      ),
    );
  }
}
