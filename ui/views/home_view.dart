import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/home_component_visibility_status.dart';
import 'package:onetwotrail/repositories/services/anonymous.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/trail_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/bottom_tab_bar.dart';
import 'package:onetwotrail/utils/dialog_to_show/dialog_to_show.dart';
import 'package:onetwotrail/utils/hide_bottom_tabBar.dart';
import 'package:provider/provider.dart';

class HomeView extends BaseWidget {
  @override
  Widget getChild(BuildContext context, BaseWidgetModel baseModel) {
    HomeComponentVisibilityStatus hideBottomTabBar = Provider.of<HomeComponentVisibilityStatus>(context);
    return MultiProvider(
      providers: [
        StreamProvider<Widget>(initialData: const SizedBox(), create: (_) {
          return Provider.of<HomeModel>(context).dialogsWidget;
        }),
      ],
      child: Consumer3<ApplicationApi, TrailService, HomeComponentVisibilityStatus>(
        builder: (context, applicationApi, trailService, homeComponentVisibilityStatus, child) {
          return ChangeNotifierProvider<HomeModel>(
            create: (context) {
              var model = HomeModel(applicationApi);
              var hideBottomTabBar = Provider.of<HideBottomTabBar>(context, listen: false);
              model.hideBottomTabBar = hideBottomTabBar;
              model.initState(context);
              return model;
            },
            child: Consumer<HomeModel>(
              builder: (context, model, _) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    body: model.tabs.length != 0
                        ? Stack(children: <Widget>[
                            IndexedStack(
                              children: model.tabs,
                              index: model.currentTab,
                            ),
                            StreamBuilder<bool>(
                                initialData: true,
                                stream: model.streamTabBarVisible,
                                builder: (context, snapshot) {
                                  return hideBottomTabBar.bottomTabBar
                                      ? BottomTabBar(
                                          onTap: (selectedIndex) async {
                                            var updateCurrentTab = () async => model.currentTab = selectedIndex;
                                            // if unregistered and presses profile, then display login view
                                            if (selectedIndex == 2) {
                                              return await runBasedOnUser(context,
                                                  onUnregistered: () => Navigator.pushNamed(context, "/landing"),
                                                  onRegistered: updateCurrentTab);
                                            }
                                            updateCurrentTab();
                                          },
                                          currentIndex: model.currentTab,
                                          visible: snapshot.data ?? true,
                                        )
                                      : Container();
                                }),
                            DialogToShow(),
                          ])
                        : Container(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
