import 'dart:math';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/viewModels/images_carrousel_widget_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:provider/provider.dart';

class ImagesCarrouselWidget extends StatelessWidget {
  const ImagesCarrouselWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, Object> experiencesAndPosition = Provider.of<Map<String, Object>>(context);
    Experience experiences = experiencesAndPosition['experience'] as Experience;
    int index = experiencesAndPosition['index'] as int;

    return ChangeNotifierProvider<ImagesCarrouselWidgetModel>(
        create: (_) => ImagesCarrouselWidgetModel()
          ..initialIndex = index
          ..pageCounter = index,
        child: Consumer<ImagesCarrouselWidgetModel>(
          builder: (context, model, _) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Scaffold(
                backgroundColor: Colors.black87,
                body: Column(
                  children: <Widget>[
                    const _AppBarContainerForImages(),
                  Flexible(
                    flex: 10,
                    child: Container(),
                  ),
                  Flexible(
                    flex: 60,
                    child: Container(
                      child: PageView.builder(
                        controller: model.pageController,
                        scrollDirection: Axis.horizontal,
                        itemCount: experiences.imageUrls.length,
                        onPageChanged: (index) {
                          model.pageCounter = index;
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            height: double.infinity,
                            child: Image.network(
                              experiences.imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 30,
                    child: Column(children: <Widget>[
                      Flexible(
                        flex: 35,
                        child: Container(),
                      ),
                      Flexible(
                        flex: 30,
                        child: Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  model.previousImage();
                                },
                              ),
                              UIHelper.horizontalSpace(10),
                              Text(
                                "${model.pageCounter + 1}/${experiences.imageUrls.length}",
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              UIHelper.horizontalSpace(10),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  model.nextImage();
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 35,
                        child: Container(),
                      )
                    ]),
                  )
                ],
              ),
            ),
          );
        },
      ));
}

}

class _AppBarContainerForImages extends StatelessWidget {
  const _AppBarContainerForImages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(left: mediaQuery.width * 0.115, top: mediaQuery.height * 0.07),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Row(
          children: [
            Container(
              child: Transform.rotate(
                  angle: pi,
                  child: Image.asset(
                    'assets/icons/00AtomsBtnArrow.png',
                    color: tealish,
                  )),
            ),
            UIHelper.horizontalSpace(7),
            Text(
              AppLocalizations.of(context)?.backText ?? 'Back',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
