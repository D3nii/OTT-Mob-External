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

class CarouselExperiencesImages extends StatelessWidget {
  const CarouselExperiencesImages(this.experience, {Key? key}) : super(key: key);

  final Experience experience;

  @override
  Widget build(BuildContext _context) {
    return experience.imageUrls.length > 0
        ? ChangeNotifierProvider(
            create: (_) => Manage(),
            child: Consumer2<Manage, BaseWidgetModel>(
              builder: (_, manage, baseWidgetModel, __) {
                manage.imagesLoadErrorCount = 0;
                return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: experience.imageUrls.length,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => Container(
                          width: 7,
                          height: 1,
                        ),
                    itemBuilder: (BuildContext ctxt, int index) {
                      Map<String, Object> value = {'experience': experience, 'index': index};
                      return OpenContainer(
                        openElevation: 0,
                        closedElevation: 0,
                        closedColor: Colors.transparent,
                        closedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        openBuilder: (context, _) => Provider<Map<String, Object>>.value(
                          key: ValueKey(experience.imageUrls[index]),
                          value: value,
                          child: ImagesCarrouselWidget(),
                        ),
                        closedBuilder: (context, openContainer) => Container(
                          decoration: BoxDecoration(
                              color: grey125Color,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              )),
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: InkWell(
                              child: Image.network(
                                experience.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  manage.imagesLoadErrorCount += 1;
                                  return Container();
                                },
                              ),
                              onTap: () {
                                openContainer();
                              },
                            ),
                          ),
                        ),
                      );
                    });
              },
            ))
        : Container();
  }
}
