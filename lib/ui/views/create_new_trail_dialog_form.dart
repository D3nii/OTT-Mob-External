import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/create_new_trail_dialog_form_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:provider/provider.dart';

class CreateNewTrailDialogForm extends StatelessWidget {
  final VoidCallback? close;
  final VoidCallback? circularProgress;

  const CreateNewTrailDialogForm({Key? key, this.close, this.circularProgress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Read the experience from the context if available.
    Experience? experience = Provider.of<Experience?>(context, listen: false);
    return ChangeNotifierProxyProvider<TrailService, CreateNewTrailDialogFormModel>(
      create: (_) => CreateNewTrailDialogFormModel(),
      update: (_, trailService, model) {
        if (model == null) {
          return CreateNewTrailDialogFormModel()
            ..trailService = trailService
            ..experience = experience;
        }
        return model
          ..trailService = trailService
          ..experience = experience;
      },
      child: Consumer<CreateNewTrailDialogFormModel>(
        builder: (context, model, _) {
          Size mediaQuery = MediaQuery.of(context).size;
          return Center(
            child: Container(
              width: mediaQuery.width * 0.96,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(20.0),
              //   color: pinkishGrey,
              // ),
              child: ListView(
                shrinkWrap: true,
                controller: model.viewController,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mediaQuery.width * 0.085,
                    ),
                    child: Container(
                      child: Text(
                        AppLocalizations.of(context)?.createNewTrailText ?? "Create New Trail",
                        style: TextStyle(
                          color: tealish,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mediaQuery.width * 0.085,
                    ),
                    child: Container(
                      child: Text(
                        AppLocalizations.of(context)?.tellUsSomeDetailsText ?? "Tell us some details",
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(mediaQuery.height * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mediaQuery.width * 0.085,
                    ),
                    child: DialogRoundedTextField(
                        AppLocalizations.of(context)?.addNameText ?? "Add Name",
                        AssetImage("assets/icons/location.png"),
                        pinkishGrey,
                        model.addNameController,
                        model.addNameFocusNode, () {
                      model.nameAndEmailsCheck(context);
                    }),
                  ),
                  model.errorInName != ""
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: mediaQuery.width * 0.085,
                          ),
                          child: Container(
                            child: Text(
                              model.errorMessage,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
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
                  UIHelper.verticalSpace(mediaQuery.height * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mediaQuery.width * 0.085,
                    ),
                    child: DialogAddEmail(),
                  ),
                  model.errorMessage != ""
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: mediaQuery.width * 0.085,
                          ),
                          child: Container(
                            child: Text(
                              model.errorMessage,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
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
                  UIHelper.verticalSpace(mediaQuery.height * 0.009),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mediaQuery.width * 0.085,
                    ),
                    child: StreamBuilder(
                      stream: model.streamControllerOfCollaborators.stream,
                      builder: (BuildContext context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            color: tomato,
                            width: 0,
                            height: 0,
                          );
                        } else {
                          List<String> data = snapshot.data as List<String>;
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                String item = data[index];
                                return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: (item.length * 4.0) + 100 + (item.length * 1.9),
                                        height: 10.0 * 4,
                                        decoration: BoxDecoration(
                                            color: tealish, borderRadius: BorderRadius.all(Radius.circular(30))),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            UIHelper.horizontalSpace(5),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                data[index],
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
                                                ),
                                                onPressed: () {
                                                  model.removeCollaboratorOfTheList(data[index]);
                                                })
                                          ],
                                        ),
                                      ),
                                      UIHelper.verticalSpace(5)
                                    ]);
                              });
                        }
                      },
                    ),
                  ),
                  UIHelper.verticalSpace(mediaQuery.height * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mediaQuery.width * 0.085,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          controller: model.addSmallDescriptionController,
                          focusNode: model.addSmallDescriptionFocusNode,
                          maxLines: 5,
                          decoration:
                              InputDecoration.collapsed(hintText: AppLocalizations.of(context)?.addSmallDescriptionText ?? "Add small description"),
                          onChanged: (_) {
                            model.nameAndEmailsCheck(context);
                          },
                        ),
                      ),
                    ),
                  ),
                  model.errorInDescription != ""
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: mediaQuery.width * 0.085,
                          ),
                          child: Container(
                            child: Text(
                              model.errorInDescription,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
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
                  UIHelper.verticalSpace(mediaQuery.height * 0.02),
                  UIHelper.verticalSpace(mediaQuery.height * 0.048),
                  model.show
                      ? Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.20),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                              backgroundColor: tomato,
                            ),
                            child: !model.showCircular
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 50,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            AppLocalizations.of(context)?.addText ?? "Add",
                                            style:
                                                TextStyle(color: pinkishGrey, fontSize: 16, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                            onPressed: () async {
                              if (!model.showCircular) {
                                model.showCircular = !model.showCircular;
                                bool result = await model.saveTrail();
                                if (result) {
                                  model.showCircular = !model.showCircular;
                                  Navigator.pop(context, true);
                                } else {
                                  model.showCircular = !model.showCircular;
                                  Dialogs.showSomethingWentWrongDialog(context);
                                }
                              }
                            },
                          ),
                        )
                      : Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.20),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              side: BorderSide(color: tomato, width: 2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 50,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      AppLocalizations.of(context)?.addText ?? "Add",
                                      style: TextStyle(color: tomato, fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {},
                          ),
                        ),
                  UIHelper.verticalSpace(mediaQuery.height * 0.015),
                  Center(
                    child: TextButton(
                      child: Text(
                        AppLocalizations.of(context)?.backText ?? "Back",
                        style: TextStyle(
                            letterSpacing: 0.5,
                            fontFamily: 'Poppins-Medium',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black),
                      ),
                      onPressed: () {
                        // close();
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DialogRoundedTextField extends StatelessWidget {
  final String hintText;
  final AssetImage assetImage;
  final Color iconColor;
  final TextEditingController textController;
  final FocusNode focusNode;
  final Function() onChanged;
  final bool obscured;

  const DialogRoundedTextField(
      this.hintText, this.assetImage, this.iconColor, this.textController, this.focusNode, this.onChanged,
      {Key? key, this.obscured = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateNewTrailDialogFormModel>(
      builder: (context, model, _) {
        return Material(
          elevation: 3,
          shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  focusNode: focusNode,
                  obscureText: obscured,
                  controller: textController,
                  onChanged: (_) {
                    onChanged();
                  },
                  onSubmitted: (_) {
                    model.unfocusAllTextFields();
                  },
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    prefixIcon: ImageIcon(
                      assetImage,
                      size: 25,
                      color: iconColor,
                    ),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(125, 125, 125, 1),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
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

class DialogAddEmail extends StatelessWidget {
  const DialogAddEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateNewTrailDialogFormModel>(
      builder: (context, model, _) {
        Size mediaQuery = MediaQuery.of(context).size;
        return Container(
          width: mediaQuery.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        controller: model.addCollaboratorEmailController,
                        focusNode: model.addCollaboratorEmailFocusNode,
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
