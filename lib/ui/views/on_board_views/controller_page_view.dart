import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/discovery_service.dart';
import 'package:onetwotrail/repositories/viewModels/controller_page_model.dart';
import 'package:onetwotrail/ui/views/on_board_views/on_board_view_one.dart';
import 'package:onetwotrail/ui/views/on_board_views/on_board_view_three.dart';
import 'package:onetwotrail/ui/views/on_board_views/on_board_view_two.dart';
import 'package:provider/provider.dart';

class ControllerPageView extends StatelessWidget {
  const ControllerPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ProxyProvider<ApplicationApi, DiscoveryService>(
              update: (_, api, previous) => (previous ?? DiscoveryService(api))),
          ChangeNotifierProxyProvider<DiscoveryService, ControllerPageModel>(
              create: (_) => ControllerPageModel(),
              update: (_, discoverApi, previous) => (previous ?? ControllerPageModel())..discoveryService = discoverApi)
        ],
        child: Consumer<ControllerPageModel>(
          builder: (context, model, _) {
            return PageView(
              allowImplicitScrolling: false,
              scrollDirection: Axis.horizontal,
              controller: model.pageController,
              children: <Widget>[
                OnBoardViewOne(),
                OnBoardViewTwo(),
                OnBoardViewThree(),
              ],
            );
          },
        ));
  }
}
