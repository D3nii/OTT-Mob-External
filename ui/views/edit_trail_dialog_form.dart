import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/edit_trail_dialog_form_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:onetwotrail/ui/widgets/labeled_toggle.dart';
import 'package:onetwotrail/repositories/services/anonymous.dart';
import 'package:provider/provider.dart';

class EditTrailDialogForm extends StatelessWidget {
  final VoidCallback close;
  final Function(ApplicationApiResponse) trailResult;

  const EditTrailDialogForm(this.close, this.trailResult, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider3<ProfileService, Trail, TrailService, EditTrailDialogFormModel>(
      create: (_) => EditTrailDialogFormModel(),
      update: (_, profileService, trail, trailService, model) {
        if (model == null) {
          return EditTrailDialogFormModel()
            ..profileService = profileService
            ..trail = trail
            ..trailService = trailService
            ..addNameController.text = trail.name
            ..addSmallDescriptionController.text = trail.description
            ..init();
        }
        return model
          ..profileService = profileService
          ..trail = trail
          ..trailService = trailService
          ..addNameController.text = trail.name
          ..addSmallDescriptionController.text = trail.description
          ..init();
      },
      child: Consumer<EditTrailDialogFormModel>(
        builder: (context, model, _) {
          Size mediaQuery = MediaQuery.of(context).size;
          return StreamBuilder<BaseResponse<User>>(
              stream: model.userProfile,
              builder: (context, profileSnapshot) {
                return GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      Center(
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shrinkWrap: true,
                          children: <Widget>[
                            UIHelper.verticalSpace(25),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context)?.editDetailsTrailText ?? "Edit Details Trail",
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: tealish),
                              ),
                            ),
                            UIHelper.verticalSpace(7),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context)?.editTheDetailsFromYourTrailText ?? "Edit the details from your trail",
                                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
                              ),
                            ),
                            UIHelper.verticalSpace(20),
                            NameForTrailTextField(),
                            UIHelper.verticalSpace(10),
                            _DialogAddEmail(),
                            model.errorMessage != ""
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: mediaQuery.width * 0.085,
                                    ),
                                    child: Container(
                                      child: Text(
                                        model.errorMessage,
                                        style: TextStyle(
                                            color: tomato,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 0,
                                    width: 0,
                                  ),
                            StreamBuilder(
                              stream: model.streamControllerOfCollaborators.stream,
                              builder: (BuildContext context, snapshot) {
                                int length = 0;
                                if (snapshot.hasData) {
                                  List<String> data = snapshot.data as List<String>;
                                  length = data.length;
                                }
                                return Container(
                                  height: 60,
                                  child: ListView.builder(
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      itemCount: length,
                                      controller: model.controller,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (BuildContext context, int index) {
                                        List<String> data = snapshot.data as List<String>;
                                        String email = data[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: _TrailCollaboratorChip(email),
                                        );
                                      }),
                                );
                              },
                            ),
                            TextAreaEditTrail(),
                             UIHelper.verticalSpace(16),
                             if (isAdminUser(context))
                               Consumer<EditTrailDialogFormModel>(
                                 builder: (context, model, _) {
                                   return LabeledToggle(
                                     label: AppLocalizations.of(context)?.trailIsPublicText ?? 'Public',
                                     value: model.isPublic,
                                     enabled: !model.publishingVisibility,
                                     onChanged: (isPublic) async {
                                       final response = await model.setPublic(isPublic);
                                       if (response.result) {
                                         final message = isPublic
                                             ? (AppLocalizations.of(context)?.trailPublishedText ?? 'Trail published')
                                             : (AppLocalizations.of(context)?.trailUnpublishedText ?? 'Trail unpublished');
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(message, style: const TextStyle(color: Colors.white)),
                                              backgroundColor: tealish,
                                              behavior: SnackBarBehavior.fixed,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                       } else {
                                         ScaffoldMessenger.of(context).showSnackBar(
                                           SnackBar(
                                             content: Text(
                                               AppLocalizations.of(context)?.somethingWentWrongRequestText ?? 'Something went wrong with your request',
                                               style: const TextStyle(color: Colors.white),
                                             ),
                                             backgroundColor: tomato,
                                             behavior: SnackBarBehavior.fixed,
                                             duration: const Duration(seconds: 2),
                                           ),
                                         );
                                       }
                                     },
                                   );
                                 },
                               ),
                            UIHelper.verticalSpace(mediaQuery.width * 0.04),
                            _SaveButton(close, trailResult),
                            UIHelper.verticalSpace(mediaQuery.width * 0.041),
                            InkWell(
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalizations.of(context)?.cancelText ?? "Cancel",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              onTap: () {
                                //close();
                                Navigator.pop(context);
                              },
                            ),
                            UIHelper.verticalSpace(40),
                          ],
                        ),
                      ),
                      !profileSnapshot.hasData || !model.trailRefreshed
                          ? Container(
                              color: pinkishGrey,
                              child: Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              ),
                            )
                          : (profileSnapshot.hasData && profileSnapshot.data?.data == null) || !model.trailRefreshed
                              ? Container(
                                  color: pinkishGrey,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                  ),
                                )
                              : Container()
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback close;
  final Function(ApplicationApiResponse) trailResult;

  const _SaveButton(this.close, this.trailResult, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EditTrailDialogFormModel>(builder: (context, model, _) {
      Size mediaQuery = MediaQuery.of(context).size;
      return Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.10),
        child: !model.saveChanges
            ? TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: model.publishingVisibility ? tomato : null,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: tomato, width: 2, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(35)),
                ),
                onPressed: () async {},
                child: model.publishingVisibility
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        Expanded(
                          flex: 60,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(AppLocalizations.of(context)?.saveText ?? "Save", style: TextStyle(color: tomato)),
                          ),
                        ),
                      ]),
              )
            : TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: tomato,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: tomato, width: 2, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(35)),
                ),
                onPressed: () async {
                  ApplicationApiResponse result = await model.saveChangesInApi();
                  if (result.result) {
                    trailResult(result);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)?.changesSavedText ?? "Changes saved",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: tealish,
                        behavior: SnackBarBehavior.fixed,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (result.statusCode == 422) {
                    Dialogs.showBodyMessageDialog(
                      context,
                      tomato,
                      AppLocalizations.of(context)?.invalidCollaborators ?? "Invalid collaborators",
                      "${AppLocalizations.of(context)?.invalidCollaboratorsLegend ?? "Invalid collaborators legend"}\n${result.responseBody}",
                      () {},
                    );
                  } else {
                    Dialogs.showMessageDialog(
                      context,
                      AppLocalizations.of(context)?.somethingWentWrongRequestText ?? "Something went wrong",
                      () {},
                    );
                  }
                },
                child: model.saving
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            Expanded(
                              flex: 60,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(AppLocalizations.of(context)?.saveText ?? "Save", style: TextStyle(color: Colors.white)),
                              ),
                            )
                          ]),
              ),
      );
    });
  }
}

class NameForTrailTextField extends StatelessWidget {
  const NameForTrailTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EditTrailDialogFormModel>(
      builder: (context, model, _) {
        return Container(
          width: double.infinity,
          height: 60,
          child: Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: !model.nameValid
                      ? Icon(
                          Icons.place,
                          color: pinkishGrey,
                        )
                      : Icon(
                          Icons.place,
                          color: tealish,
                        ),
                ),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.start,
                    controller: model.addNameController,
                    focusNode: model.addNameFocusNode,
                    onChanged: (_) {
                      model.validateChanges();
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: AppLocalizations.of(context)?.nameForTrailText ?? "Name for trail",
                        hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[400])),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TextAreaEditTrail extends StatelessWidget {
  const TextAreaEditTrail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EditTrailDialogFormModel>(builder: (context, model, _) {
      return Column(
        children: <Widget>[
          Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: model.addSmallDescriptionController,
                  maxLines: 8,
                  onChanged: (_) {
                    model.validateChanges();
                  },
                  decoration: InputDecoration.collapsed(
                      hintText: AppLocalizations.of(context)?.itsAnSmallDescriptionText ?? "It's a small description",
                      hintStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey[400])),
                ),
              ))
        ],
      );
    });
  }
}

class _DialogAddEmail extends StatelessWidget {
  const _DialogAddEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EditTrailDialogFormModel>(
      builder: (context, model, _) {
        Size mediaQuery = MediaQuery.of(context).size;
        return Container(
          width: mediaQuery.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      flex: 10,
                      child: ImageIcon(
                        AssetImage('assets/icons/user.png'),
                        color: tealish,
                      )),
                  Expanded(
                    flex: 80,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        textAlign: TextAlign.left,
                        controller: model.addEmailController,
                        focusNode: model.addEmailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        onChanged: (text) {
                          model.errorMessage = "";
                        },
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)?.addCollaboratorEmailText ?? "Add collaborator email",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      icon: Icon(
                        Icons.add_circle,
                        color: tealish,
                      ),
                      onPressed: () {
                        model.addToCollaboratorList(context);
                      },
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}

class _TrailCollaboratorChip extends StatelessWidget {
  final String email;

  const _TrailCollaboratorChip(this.email, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EditTrailDialogFormModel>(builder: (context, model, _) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 10.0 * 4,
            decoration: BoxDecoration(
                color: tealish, borderRadius: BorderRadius.all(Radius.circular(30))),
            padding: EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UIHelper.horizontalSpace(5),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      model.removeCollaboratorOfTheList(email);
                    })
              ],
            ),
          ),
        ],
      );
    });
  }
}

