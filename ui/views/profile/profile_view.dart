import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/models/response.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/repositories/models/user.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/repositories/viewModels/profile_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/views/my_trail_board_and_itinerary/controller_page_board.dart';
import 'package:onetwotrail/ui/widgets/circular_progress_bar.dart';
import 'package:onetwotrail/ui/widgets/dialog.dart';
import 'package:onetwotrail/ui/widgets/inside_show_modal_bottom_sheet.dart';
import 'package:onetwotrail/ui/widgets/pagination_indicator.dart';
import 'package:onetwotrail/ui/widgets/profile_shimmer.dart';
import 'package:onetwotrail/ui/widgets/show_dialog_component_delete_trail.dart';
import 'package:onetwotrail/ui/widgets/trails_grid_shimmer.dart';
import 'package:onetwotrail/utils/hide_bottom_tabBar.dart';
import 'package:onetwotrail/utils/my_trail_sub_menu_more_helper.dart';
import 'package:onetwotrail/v2/util/duration.dart';
import 'package:onetwotrail/v2/util/string.dart';
import 'package:onetwotrail/v2/widget/three_squares.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (BuildContext context) {
        return ProfileViewModel(context);
      },
      child: Consumer2<HomeModel, ProfileViewModel>(
        builder: (context, homeModel, profileViewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: _BodyContainer(),
          );
        },
      ),
    );
  }
}

class _BodyContainer extends StatelessWidget {
  const _BodyContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeModel, ProfileViewModel>(
      builder: (context, homeModel, model, _) {
        return Column(
          children: <Widget>[
            _ContainerOfTitle(),
            Expanded(
              child: StreamBuilder<List<Trail>>(
                stream: model.trailStream.stream,
                builder: (context, AsyncSnapshot<List<Trail>> snapshot) {
                  if (model.isInitialLoadingTrails) {
                    return ProfileShimmer();
                  }
                  return NestedScrollView(
                    controller: homeModel.profileScrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: _ContainerOfUserData(),
                        ),
                        SliverToBoxAdapter(
                          child: _myTrailsHeader(context),
                        ),
                      ];
                    },
                    body: RefreshIndicator(
                      onRefresh: model.refresh,
                      child: CustomScrollView(
                        slivers: [
                          if ((snapshot.data?.isEmpty ?? true) && (model.isLoadingMoreTrails || model.trailService.isLoadingTrails))
                            SliverToBoxAdapter(
                              child: TrailsGridShimmer(),
                            )
                          else
                            _buildTrailsGrid(context, snapshot, model),
                          if ((snapshot.data?.isNotEmpty ?? false) && model.isLoadingMoreTrails)
                            SliverToBoxAdapter(
                              child: TrailsGridShimmer(),
                            ),
                          if (model.hasPaginationError)
                            SliverToBoxAdapter(
                              child: PaginationIndicator(
                                isLoadingMore: false,
                                hasError: true,
                                onRetry: model.retryPagination,
                                buttonColor: viridian,
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: SizedBox(height: 120),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}

class _ContainerOfTitle extends StatelessWidget {
  const _ContainerOfTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Container(
      height: mediaQuery.height * 0.15,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/my_trails/app_bar_background.png',
            fit: BoxFit.fill,
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)?.profileText.toUpperCase() ?? "PROFILE",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    TextSpan(text: "\n"),
                    TextSpan(
                      text: AppLocalizations.of(context)?.profileHeadline ?? "Your profile information",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ContainerOfUserData extends StatelessWidget {
  const _ContainerOfUserData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeModel, ProfileViewModel>(builder: (context, homeModel, model, _) {
      return StreamBuilder<BaseResponse<User>>(
          stream: model.profile,
          builder: (context, snapshot) {
            return Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _getAvatarImage(snapshot),
                    backgroundColor: whiteTwo,
                  ),
                  UIHelper.horizontalSpace(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                _getUserFullName(snapshot),
                                maxLines: 1,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                _getCountryName(snapshot),
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<BaseResponse<User>>(
                      stream: model.profile,
                      builder: (context, snapshot) {
                        return CircleAvatar(
                          backgroundColor: pigPinkTwo,
                          radius: 20,
                          child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: ImageIcon(
                                AssetImage("assets/icons/edit_profile.png"),
                                size: 20,
                                color: Colors.white,
                              ),
                              color: Colors.white,
                              onPressed: snapshot.data != null && snapshot.data!.responseStatus == SUCCESS
                                  ? () {
                                      Navigator.pushNamed(context, '/profile-user-information-view');
                                    }
                                  : null),
                        );
                      }),
                ],
              ),
            );
          });
    });
  }
}

Widget _myTrailsHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.trailsText ?? "Trails",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 16),
        CircleAvatar(
          backgroundColor: viridian,
          radius: 16,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: ImageIcon(
              AssetImage("assets/icons/icon_plus.png"),
              size: 8,
              color: Colors.white,
            ),
            color: Colors.white,
            onPressed: () {
              showCreateNewTrailDialog(context);
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildTrailsGrid(BuildContext context, AsyncSnapshot<List<Trail>> snapshot, ProfileViewModel model) {
  if (!snapshot.hasData || snapshot.data?.length == 0) {
    return SliverToBoxAdapter(child: Container(height: 0));
  }
  
  return SliverPadding(
    padding: const EdgeInsets.only(left: 16, right: 16),
    sliver: SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _createTrailWidget(context, snapshot.data![index]);
        },
        childCount: snapshot.data?.length ?? 0,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
    ),
  );
}

Widget _createTrailWidget(BuildContext context, Trail trail) {
  return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
    var experiencesText = _getExperiencesText(context, trail);
    return GestureDetector(
      onLongPress: () {
        MyTrailSubMenuMoreHelper().deployShowDialog(trail, context, delete: () {
          var hideBottomTabBar = Provider.of<HideBottomTabBar>(context, listen: false);
          hideBottomTabBar.changeVisibility(false);
          var trailService = Provider.of<TrailService>(context, listen: false);
          var baseWidgetModel = Provider.of<BaseWidgetModel>(context, listen: false);
          baseWidgetModel.showOverlayWidget(
              true,
              Provider.value(
                value: trail,
                child: ShowDialogComponentDelete(
                  close: () {
                    baseWidgetModel.showOverlayWidget(false, Container());
                  },
                  showCircularProgresIndicator: () {
                    baseWidgetModel.showOverlayWidget(true, CircularProgressBar());
                  },
                  closeCircularProgressIndicator: () {
                    baseWidgetModel.showOverlayWidget(false, Container());
                  },
                  showErrorDialog: () async {
                    baseWidgetModel.showOverlayWidget(false, Container());
                    baseWidgetModel.showOverlayWidget(true, CircularProgressBar());
                    ApplicationApiResponse result = await trailService.deleteTrail(trail);
                    if (result.result) {
                      baseWidgetModel.showOverlayWidget(false, Container());
                      result.statusCode = 702;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)?.trailRemovedText ?? "Trail removed"),
                          backgroundColor: tomato,
                          behavior: SnackBarBehavior.fixed,
                        ),
                      );
                    } else {
                      baseWidgetModel.showOverlayWidget(false, Container());
                      Dialogs.showApiErrorDialog(context, result);
                    }
                    hideBottomTabBar.changeVisibility(true);
                  },
                ),
              ));
        }, trailResult: (result) {
          if (result.result) {
            Trail temp = result.responseObject as Trail;
            trail.name = temp.name;
            trail.description = temp.description;
            trail.collaborators = temp.collaborators;
          }
        });
      },
      child: Container(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Column(
            children: [
              ThreeSquares(
                mainImage: trail.imageProviders[0],
                secondaryTopImage: trail.imageProviders[1],
                secondaryBottomImage: trail.imageProviders[2],
                mainAction: (BuildContext context) => Provider.value(value: trail, child: TrailView()),
                height: constraints.maxHeight - 48 - 8,
              ),
              // Add a vertical space between the images and the text.
              SizedBox(height: 8),
              // Make the row respect the width of the parent.
              // Add a text that contains the name of the trail.
              Row(
                children: [
                  Container(
                    width: constraints.maxWidth,
                    child: Text(
                      trail.name,
                      textAlign: TextAlign.left,
                      // Allow only one line of text.
                      maxLines: 1,
                      // Truncate remaining text with an ellipsis.
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        // Make the font bold.
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              // Add row with two texts A and B.
              // A is to the left of B.
              // A contains the number of experiences in the trail.
              // A is brighter than B.
              // B contains the duration of the trail in hours.
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    experiencesText,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    fromDurationToText(context, trail.itineraryEstimatedTime),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  });
}

ImageProvider _getAvatarImage(AsyncSnapshot<BaseResponse<User>> snapshot) {
  if (!snapshot.hasData) {
    return AssetImage('assets/icons/user.png');
  }

  final avatar = snapshot.data!.data.avatar;
  if (avatar.isEmpty) {
    return AssetImage('assets/icons/user.png');
  }

  if (avatar.startsWith("data:")) {
    return MemoryImage(
      base64Decode(
        avatar.replaceFirst("data:image/png;base64,", ""),
      ),
    );
  }

  return NetworkImage(avatar + ".png");
}

String _getCountryName(AsyncSnapshot<BaseResponse<User>> snapshot) {
  if (!snapshot.hasData) {
    return "";
  }

  // Use the User model's countryName property
  return snapshot.data!.data.countryName;
}

String _getUserFullName(AsyncSnapshot<BaseResponse<User>> snapshot) {
  if (!snapshot.hasData) {
    return "";
  }

  final firstName = snapshot.data!.data.firstName;
  final lastName = snapshot.data!.data.lastName;
  return "$firstName $lastName";
}

String _getExperiencesText(BuildContext context, Trail trail) {
  final count = trail.experiences.length;
  final localizations = AppLocalizations.of(context);
  if (localizations == null) {
    return "0 Experiences";
  }

  final singularText = localizations.experience;
  final pluralText = localizations.experiences;

  return fromCountToText(count, singularText, pluralText);
}

