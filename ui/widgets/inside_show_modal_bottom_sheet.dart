import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/constants.dart';
import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/inside_show_modal_bottom_sheet_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/create_new_trail_dialog_form.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'base_widget.dart';
import 'circular_progress_bar.dart';
import 'drag_handle.dart';
import 'pagination_indicator.dart';


class InsideShowModalBottomSheet extends StatelessWidget {
  const InsideShowModalBottomSheet(
    this.user,
    this.experience,
    this.close, {
    Key? key,
    this.addButton,
  }) : super(key: key);

  final User user;
  final Experience experience;
  final VoidCallback close;
  final VoidCallback? addButton;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InsideShowModalBottomSheetModel>(create: (context) {
      var trailService = Provider.of<TrailService>(context, listen: false);
      var model = InsideShowModalBottomSheetModel(experience, trailService);
      model.startListeningTrails();
      return model;
    }, child: Consumer<InsideShowModalBottomSheetModel>(
      builder: (context, model, _) {
        Size mediaQuery = MediaQuery.of(context).size;
        return !model.visible
            ? Container()
            : Material(
                child: CupertinoPageScaffold(
                  backgroundColor: Colors.white,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      width: mediaQuery.width,
                      height: mediaQuery.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(40), topLeft: Radius.circular(40)),
                        color: Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          DragHandle(),
                          Expanded(
                            child: _DraggableChild(experience, () {
                              model.visible = false;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    ));
  }
}

class _DraggableChild extends StatelessWidget {
  const _DraggableChild(this.experience, this.addButton, {Key? key}) : super(key: key);

  final Experience experience;
  final VoidCallback? addButton;

  @override
  Widget build(BuildContext context) {
    return Consumer<InsideShowModalBottomSheetModel>(
      builder: (context, model, _) {
        return Column(children: [
          FirstRow(experience, addButton),
          Expanded(
            child: ListView.builder(
                controller: model.trailScrollController,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.only(top: 0),
                itemCount: model.trails.length + (model.isLoadingMoreTrails ? Constants.TRAILS_PAGE_SIZE : (model.hasPaginationError ? 1 : 0)),
                itemBuilder: (BuildContext context, int index) {
                  if (index < model.trails.length) {
                    return Provider.value(value: model.trails[index], child: ChipOfTrails());
                  }
                  
                  if (model.isLoadingMoreTrails) {
                    return _TrailItemShimmer();
                  }
                  
                  if (model.hasPaginationError) {
                    return PaginationIndicator(
                      isLoadingMore: false,
                      hasError: true,
                      onRetry: model.retryPagination,
                      buttonColor: tealish,
                    );
                  }
                  
                  return SizedBox.shrink();
                }),
          ),
        ]);
      },
    );
  }
}

class ChipOfTrails extends BaseWidget {
  ChipOfTrails({Key key = const Key('chip_of_trails')}) : super(key: key);

  @override
  Widget getChild(BuildContext pareContext, BaseWidgetModel baseModel) {
    Trail trail = Provider.of<Trail>(pareContext);
    return Consumer<InsideShowModalBottomSheetModel>(
      builder: (context, model, _) {
        final experienceCount = trail.experiences.length;
        final isSelected = trail.experiences.any((element) => element.experienceId == model.experience.experienceId);
        
        return Container(
          height: 80,
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          child: Row(
            children: [
              _CompactThumbnail(trail: trail),
              UIHelper.horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      trail.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    UIHelper.verticalSpace(4),
                    Text(
                      experienceCount == 1 
                          ? '1 experience' 
                          : '$experienceCount experiences',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: brownishGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.horizontalSpace(12),
              _ToggleButton(
                isSelected: isSelected,
                baseModel: baseModel,
                trailId: trail.id,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompactThumbnail extends StatelessWidget {
  const _CompactThumbnail({required this.trail, Key? key}) : super(key: key);

  final Trail trail;

  @override
  Widget build(BuildContext context) {
    return Consumer<InsideShowModalBottomSheetModel>(
      builder: (context, model, _) {
        final images = model.getImagesFromExperiencesInTrail(trail);
        
        return Container(
          width: 60,
          height: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: images.isEmpty
                            ? const AssetImage('assets/help/empty_image.png')
                            : NetworkImage(images[0]) as ImageProvider,
                      ),
                    ),
                  ),
                ),
                Container(width: 1, color: Colors.white),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: images.length < 2
                                  ? const AssetImage('assets/help/empty_image.png')
                                  : NetworkImage(images[1]) as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                      Container(height: 1, color: Colors.white),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: images.length < 3
                                  ? const AssetImage('assets/help/empty_image.png')
                                  : NetworkImage(images[2]) as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.isSelected,
    required this.baseModel,
    required this.trailId,
    Key? key,
  }) : super(key: key);

  final bool isSelected;
  final BaseWidgetModel baseModel;
  final int trailId;

  @override
  Widget build(BuildContext context) {
    return Consumer<InsideShowModalBottomSheetModel>(
      builder: (context, model, _) {
        return InkWell(
          onTap: () async {
            if (model.updatingTrail == true) {
              return;
            }
            Future<bool> result = isSelected 
                ? model.setUnchecked(trailId)
                : model.setChecked(trailId);
            Navigator.of(context).pop();
            if (!await result) {
              _showOurDialogError(context);
            }
          },
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? tealish : Colors.transparent,
              border: Border.all(
                color: tealish,
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      },
    );
  }
}

void _showOurDialogError(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Expanded(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)?.oopsText ?? 'Oops',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: tomato),
                        ),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(16),
                  Container(
                    child: Expanded(
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            AppLocalizations.of(context)?.somethingWentWrongText ?? 'Something went wrong',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(16),
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.20),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: viridian,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      ),
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)?.okText ?? 'OK',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                      },
                    ),
                  ),
                  UIHelper.verticalSpace(15),
                ],
              ),
            ),
          ),
        );
      });
}


class FirstRow extends StatelessWidget {
  const FirstRow(this.experience, this.addButton, {Key? key}) : super(key: key);

  final Experience experience;
  final VoidCallback? addButton;

  @override
  Widget build(BuildContext context) {
    return Consumer<InsideShowModalBottomSheetModel>(
      builder: (context, model, _) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 30, right: 30, top: 16, bottom: 16),
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.addToTrailText ?? 'Add to trail',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: tealish),
                    ),
                  ),
                  if (addButton != null) ...[
                    UIHelper.horizontalSpace(12),
                    InkWell(
                      onTap: () {
                        addButton!();
                        Navigator.pop(context);
                        showCreateNewTrailDialog(context, experience: experience);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: viridian,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                  UIHelper.horizontalSpace(12),
                  InkWell(
                    onTap: () {
                      model.visible = false;
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tomato,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300],
            ),
          ],
        );
      },
    );
  }
}

class _TrailItemShimmer extends StatelessWidget {
  const _TrailItemShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300] ?? Colors.grey,
      highlightColor: Colors.grey[100] ?? Colors.grey.shade100,
      child: Container(
        height: 80,
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            UIHelper.horizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  UIHelper.verticalSpace(8),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            UIHelper.horizontalSpace(12),
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showCreateNewTrailDialog(BuildContext context, {Experience? experience}) async {
  Size mediaQuery = MediaQuery.of(context).size;
  bool? added = await showModal<bool>(
    configuration: FadeScaleTransitionConfiguration(
      barrierColor: Colors.black87,
      transitionDuration: Duration(milliseconds: 450),
    ),
    context: context,
    builder: (BuildContext context) {
      return Container(
        child: Dialog(
          insetPadding: EdgeInsets.all(0),
          backgroundColor: pinkishGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: mediaQuery.height * 0.7,
            width: mediaQuery.width * 0.95,
            child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 10, right: 10, bottom: 5),
                child: Provider.value(value: experience, child: CreateNewTrailDialogForm())),
          ),
        ),
      );
    },
  );

  return added ?? false;
}
