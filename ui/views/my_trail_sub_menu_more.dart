import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/constants.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/my_trail_sub_menu_more_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/edit_trail_dialog_form.dart';
import 'package:provider/provider.dart';

class MyTrailSubMenuMore extends StatelessWidget {
  const MyTrailSubMenuMore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var padding = UIHelper.defaultHorizontalPadding(context);
    return ChangeNotifierProxyProvider3<Trail, TrailService, ProfileService, MyTrailSubMenuMoreModel>(
      create: (_) => MyTrailSubMenuMoreModel(),
      update: (_, trail, trailService, profileService, model) => model!
        ..trail = trail
        ..trailService = trailService
        ..profileService = profileService
        ..init(),
      child: Consumer<MyTrailSubMenuMoreModel>(
        builder: (context, model, _) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: padding),
              children: <Widget>[
                UIHelper.verticalSpace(91),
                ImageAndButtons(
                  model.trail,
                ),
                UIHelper.verticalSpace(86)
              ],
            ),
          );
        },
      ),
    );
  }
}

class ImageAndButtons extends StatelessWidget {
  final Trail trail;

  const ImageAndButtons(this.trail, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Consumer<MyTrailSubMenuMoreModel>(
      builder: (context, model, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TrailImage(model.getTrailImagesFromExperiences()),
            Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        trail.name,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
                      )),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      trail.description,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            UIHelper.verticalSpace(mediaQuery.height * 0.05),
            Container(
              child: ActionsButtonsTrail(
                model.trail,
              ),
            )
          ],
        );
      },
    );
  }
}

class TrailImage extends StatelessWidget {
  final List<String> images;

  const TrailImage(this.images, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width * 0.37,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              flex: 96,
              child: /*First Image to the left*/ Container(
                decoration: BoxDecoration(
                    color: Colors.black26,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: images.isEmpty
                          ? AssetImage('assets/help/empty_image.png') as ImageProvider
                          : NetworkImage(images.first),
                    )),
                height: double.infinity,
                width: double.infinity,
                padding: EdgeInsets.all(12),
              ),
            ),
            /*Second Image Top Right*/
            Expanded(
              flex: 71,
              child: Container(
                color: Colors.black12,
                child: Column(
                  children: <Widget>[
                    /*Second image, topRight*/ Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: images.length < 2
                                ? AssetImage('assets/help/empty_image.png') as ImageProvider
                                : NetworkImage(images[1]),
                          ),
                        ),
                      ),
                    ),
                    /*Third image bottom right*/ Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(top: 8),
                        alignment: Alignment.topCenter,
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: images.length < 3
                                ? AssetImage('assets/help/empty_image.png') as ImageProvider
                                : NetworkImage(images[2]),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ActionsButtonsTrail extends StatelessWidget {
  final Trail trail;

  const ActionsButtonsTrail(this.trail, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Consumer<MyTrailSubMenuMoreModel>(builder: (context, model, _) {
      return Column(
        children: <Widget>[
          Container(
            child: InkWell(
              onTap: () {
                Navigator.pop(context, Constants.SHOW_EDIT_FORM);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 50,
                    child: /*Icon*/ Container(
                        child: Stack(alignment: Alignment.center, children: <Widget>[
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tealish,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ImageIcon(
                          AssetImage('assets/icons/edit.png'),
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ])),
                  ),
                  Flexible(
                    flex: 50,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.editDetailsTrailText,
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(mediaQuery.height * 0.03),
          // todo: restore after share reimplementation
          // Container(
          //   child: InkWell(
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: <Widget>[
          //         Flexible(
          //           flex: 50,
          //           child: /*Icon*/ Container(
          //               child: Stack(alignment: Alignment.center, children: <Widget>[
          //             Container(
          //               height: 40,
          //               width: 40,
          //               decoration: BoxDecoration(
          //                 shape: BoxShape.circle,
          //                 color: tealish,
          //               ),
          //             ),
          //             Align(
          //               alignment: Alignment.center,
          //               child: Image.asset(
          //                 "assets/icons/send_icon.png",
          //                 color: Colors.white,
          //                 height: 25,
          //                 width: 25,
          //               ),
          //             ),
          //           ])),
          //         ),
          //         Flexible(
          //           flex: 50,
          //           child: Container(
          //             alignment: Alignment.centerLeft,
          //             child: Text(
          //               AppLocalizations.of(context).shareText,
          //               style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14),
          //             ),
          //           ),
          //         )
          //       ],
          //     ),
          //     onTap: () {},
          //   ),
          // ),
          // UIHelper.verticalSpace(mediaQuery.height * 0.03),
          InkWell(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 50,
                    child: /*Icon*/ Container(
                        child: Stack(alignment: Alignment.center, children: <Widget>[
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: tomato),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          child: ImageIcon(
                            AssetImage('assets/icons/trash.png'),
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ])),
                  ),
                  Flexible(
                    flex: 50,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.deleteTrailText,
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
            ),
            onTap: () {
              Navigator.pop(context, Constants.SHOW_DELETE_DIALOG);
            },
          ),
          UIHelper.verticalSpace(mediaQuery.height * 0.10),
          Center(
            child: InkWell(
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tomato, width: 2),
                ),
                child: Center(
                  child: Container(
                    height: 18,
                    width: 18,
                    child: Image.asset(
                      'assets/icons/close.png',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      );
    });
  }
}

class ShowDialogEditContent extends StatelessWidget {
  final Trail trailToEdit;
  final VoidCallback close;
  final Function(ApplicationApiResponse) trailResult;

  const ShowDialogEditContent(this.trailToEdit, this.close, this.trailResult, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: trailToEdit,
      key: ValueKey(trailToEdit.id),
      child: EditTrailDialogForm(close, trailResult),
    );
  }
}

void showDialogComponentAbandon(BuildContext context, Trail trail) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(0),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Consumer<MyTrailSubMenuMoreModel>(
            builder: (context, model, _) {
              return Container(
                height: 337,
                width: 296,
                child: Padding(
                    padding: const EdgeInsets.only(top: 33, left: 35, right: 35, bottom: 42),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.abandonTrailText}?",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: tomato),
                          ),
                        ),
                        UIHelper.verticalSpace(16),
                        Container(
                          child: Text(
                            AppLocalizations.of(context)!.thisTrailWillBeReset,
                            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black),
                          ),
                        ),
                        UIHelper.verticalSpace(26),
                        Container(
                          height: 50,
                          width: 196,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35.0), side: BorderSide(color: Colors.red)),
                              backgroundColor: tomato,
                              padding: EdgeInsets.all(8.0),
                            ),
                            onPressed: () {
                              model.abandonTrail(trail);
                            },
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)!.abandonText,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(10),
                                      child: Image.asset(
                                        'assets/icons/00AtomsBtnArrow.png',
                                        color: Colors.white,
                                      ))
                                ]),
                          ),
                        ),
                        UIHelper.verticalSpace(16),
                        InkWell(
                          child: Container(
                            child: Text(
                              AppLocalizations.of(context)!.cancelText,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )),
              );
            },
          ),
        );
      });
}
