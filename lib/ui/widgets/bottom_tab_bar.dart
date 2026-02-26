import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetwotrail/repositories/viewModels/home_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/utils/app_environment.dart';
import 'package:provider/provider.dart';

/// Pinterest-style bottom navigation bar: icons only, minimalist black outline design.
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

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).clearSnackBars();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushNamed(context, '/debug');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 300),
      top: MediaQuery.of(context).size.height - (visible ? _barHeight(context) : 0),
      child: Container(
        height: _barHeight(context),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _NavIcon(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                onLongPress: () => _onDiscoverLongPress(context),
              ),
              _NavIcon(
                icon: Icons.search,
                activeIcon: Icons.search,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavIcon(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                isActive: currentIndex == 2,
                onTap: () {
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
    );
  }

  double _barHeight(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return 56 + padding.bottom;
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 56,
        child: Center(
          child: Icon(
            isActive ? activeIcon : icon,
            size: 28,
            color: isActive ? Colors.black : Colors.black.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
