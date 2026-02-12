import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/widgets/tab_bar_button.dart';
import 'package:onetwotrail/utils/app_environment.dart';
import 'package:provider/provider.dart';

class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    Key? key,
    required this.onTap,
    required this.currentIndex,
    required this.visible,
  }) : super(key: key);

  final ValueChanged<int> onTap;
  final int currentIndex;
  final bool visible;

  void _onDiscoverLongPress(BuildContext context) {
    if (!AppEnvironment.isDebugEnvironment()) {
      return;
    }

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Clear any existing snackbars first to prevent Hero conflicts
    ScaffoldMessenger.of(context).clearSnackBars();

    // Use a post-frame callback to ensure the clear operation completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show brief visual feedback with SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🛠️ Debug mode activated!'),
          backgroundColor: tealish,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 100, left: 20, right: 20),
        ),
      );
    });

    // Navigate to debug view after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushNamed(context, '/debug');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 300),
      top: MediaQuery.of(context).size.height - (visible ? 100 : 0),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
        height: 81,
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: Colors.white),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 6, 0, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TabBarButton(
                  AppLocalizations.of(context)?.discoverText ?? 'Discover',
                  AssetImage("assets/icons/discover_active.png"),
                  AssetImage("assets/icons/discover_inactive.png"),
                  currentIndex == 0,
                  () {
                    onTap(0);
                  },
                  onLongPress: () {
                    _onDiscoverLongPress(context);
                  },
                ),
                TabBarButton(
                  AppLocalizations.of(context)?.search ?? 'Search',
                  AssetImage("assets/icons/search_active.png"),
                  AssetImage("assets/icons/search_inactive.png"),
                  currentIndex == 1,
                  () {
                    onTap(1);
                  }
                ),
                TabBarButton(
                  AppLocalizations.of(context)?.profileText ?? 'Profile',
                  AssetImage("assets/icons/profile_active.png"),
                  AssetImage("assets/icons/profile_inactive.png"),
                  currentIndex == 2,
                  () {
                    if (currentIndex == 2) {
                      final homeModel = Provider.of<HomeModel>(context, listen: false);
                      homeModel.scrollProfileToTop();
                    } else {
                      onTap(2);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
