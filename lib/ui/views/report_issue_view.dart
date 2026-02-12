import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/viewModels/report_issue_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/own_check_box/ownCheckBox.dart';
import 'package:provider/provider.dart';

class ReportIssueView extends StatelessWidget {
  const ReportIssueView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider2<Experience, ApplicationApi, ReportIssueModel>(
      create: (_) => ReportIssueModel(),
      update: (_, experience, applicationApi, model) {
        if (model != null) {
          model.applicationApi = applicationApi;
          model.experience = experience;
          model.init(context);
          return model;
        }
        return ReportIssueModel();
      },
      child: Consumer<ReportIssueModel>(
        builder: (context, model, _) {
          Size mediaQuery = MediaQuery.of(context).size;
          return GestureDetector(
            onTap: () {
              model.addCommentFocusNode.unfocus();
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.058),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 43),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)?.reportIssueText ?? "These reports will help us to take action and inform the providers so this does not happen again.",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.038),
                    Container(
                      padding: EdgeInsets.only(left: 42),
                      child: Text(
                        AppLocalizations.of(context)?.typeOfIssueText ?? "Type of issue",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black),
                      ),
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.022),
                    SizedBox(
                      height: 235,
                      child: const _ContainerOfCheckBoxes(),
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.0221),
                    Container(
                      padding: EdgeInsets.only(left: 42),
                      width: double.infinity,
                      child: Text(
                        AppLocalizations.of(context)?.howBadlyText ?? "How severe is the issue?",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black),
                      ),
                    ),
                    UIHelper.verticalSpace(mediaQuery.height * 0.022),
                    const _DraggableSelector(),
                    UIHelper.verticalSpace(mediaQuery.height * 0.0426),
                    const _AddCommentArea(),
                    UIHelper.verticalSpace(mediaQuery.height * 0.038),
                    const _ReportIssueButton(),
                    UIHelper.verticalSpace(mediaQuery.height * 0.038),
                  ],
                ),
                const _AppBarContainer(),
              ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DraggableSelector extends StatelessWidget {
  const _DraggableSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportIssueModel>(builder: (context, model, _) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Flexible(
                  flex: 33,
                  child: Container(
                    child: Image.asset(
                      'assets/report_issue/neutral_face.png',
                      color: darkishPink50,
                    ),
                  )),
                Flexible(
                  flex: 33,
                  child: Container(
                    child: Image.asset(
                      'assets/report_issue/upset_face.png',
                      color: darkishPink50,
                    ),
                  )),
                Flexible(
                  flex: 33,
                  child: Container(
                    child: Image.asset(
                      'assets/report_issue/angry_face.png',
                      color: darkishPink50,
                    ),
                  )),
              ],
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Slider(
                inactiveColor: Color(0x6632bcad),
                activeColor: Color(0xff32bcad),
                value: model.faceSelection,
                onChanged: (value) {
                  model.faceSelection = value;
                },
                divisions: 2,
                min: 0,
                max: 1.0,
              ),
            )
          ],
        ),
      );
    });
  }
}

class _AppBarContainer extends StatelessWidget {
  const _AppBarContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportIssueModel>(builder: (context, model, _) {
      Size mediaQuery = MediaQuery.of(context).size;
      MediaQueryData data = MediaQuery.of(context);
      return /*AppBar*/ Container(
        height: mediaQuery.height * 0.1 + data.padding.top,
        width: double.infinity,
        child: Container(
          height: mediaQuery.height * 0.1 + data.padding.top,
          child: Stack(
            children: <Widget>[
              /*AppBar image*/ Container(
                width: double.infinity,
                height: mediaQuery.height * 0.1 + data.padding.top,
                child: Image.asset(
                  'assets/report_issue/02C.png',
                  fit: BoxFit.fill,
                ),
              ),
              /*AppBar content*/ Column(children: [
                Container(
                  height: data.padding.top,
                ),
                Container(
                  height: mediaQuery.height * 0.1,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      UIHelper.horizontalSpace(mediaQuery.width * 0.053),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)?.reportIssuesText ?? "Report issues",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ])
            ],
          ),
        ),
      );
    });
  }
}

class _AddCommentArea extends StatelessWidget {
  const _AddCommentArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportIssueModel>(
      builder: (context, model, _) {
        return /*Add Comment Area*/ Container(
            color: Color(0xfff9f9f9),
            padding: EdgeInsets.only(top: 5),
            height: MediaQuery.of(context).size.height * 0.227,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)?.addCommentText ?? "Add a comment",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black),
                  ),
                ),
                UIHelper.verticalSpace(MediaQuery.of(context).size.height * 0.03),
                /*Add Comment*/ Container(
                    height: MediaQuery.of(context).size.height * 0.14,
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      focusNode: model.addCommentFocusNode,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                      controller: model.addCommentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: model.addCommentFocusNode.hasFocus
                              ? ''
                              : AppLocalizations.of(context)?.addSmallDescriptionText ?? "Add a small description",
                          hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 14)),
                    )),
              ],
            ));
      },
    );
  }
}

class _ReportIssueButton extends StatelessWidget {
  const _ReportIssueButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportIssueModel>(
      builder: (context, model, _) {
        return Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.23),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tomato,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            onPressed: () async {
              if (!model.atLeastOneTypeOfIssueSelected()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)?.reportIssuesSelectAtLeastOneTypeOfIssueText ?? "Select at least one issue."),
                  ),
                );
                return;
              }
              if (model.addCommentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)?.youCantLeaveCommentEmptyText ?? "You can't leave the comment empty"),
                  ),
                );
                return;
              }
              ApplicationApiResponse result = await model.reportIssue(context);
              if (result.result) {
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)?.reportSubmittedText ?? "Report submitted"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                // Wait for the snackbar to be visible before navigating back
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.pop(context);
                });
              } else {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)?.somethingWentWrongText ?? "Something went wrong"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: model.showLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      flex: 70,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context)?.sendReportText ?? "Send report",
                          style: TextStyle(color: Colors.white),
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

class _ContainerOfCheckBoxes extends StatelessWidget {
  const _ContainerOfCheckBoxes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportIssueModel>(
      builder: (context, model, _) {
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: model.list.length,
          itemBuilder: (context, int index) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 42, right: 60),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 50,
                        child: Text(
                          model.list[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 50,
                        child: Container(
                          child: OwnCheckBox((selected) {
                            model.setSelection(model.list[index]);
                          }, model.getValueKey(model.list[index])),
                        ),
                      ),
                    ],
                  ),
                ),
                UIHelper.verticalSpace(12),
              ],
            );
          });
      },
    );
  }
}
