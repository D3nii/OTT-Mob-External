import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/models/trail.dart';
import 'package:onetwotrail/restart.dart';
import 'package:onetwotrail/ui/views/discover/discover_view.dart';
import 'package:onetwotrail/ui/views/experience_info.dart';
import 'package:onetwotrail/ui/views/generate_itinerary_from_board.dart';
import 'package:onetwotrail/ui/views/home_view.dart';
import 'package:onetwotrail/ui/views/main_filter_view.dart';
import 'package:onetwotrail/ui/views/my_trail_board_and_itinerary/board_view.dart';
import 'package:onetwotrail/ui/views/my_trail_board_and_itinerary/controller_page_board.dart';
import 'package:onetwotrail/ui/views/on_board_views/controller_page_view.dart';
import 'package:onetwotrail/ui/views/profile/profile_user_information_view.dart';
import 'package:onetwotrail/ui/views/profile/update_password_view.dart';
import 'package:onetwotrail/ui/views/register_views/register_view.dart';
import 'package:onetwotrail/ui/views/report_issue_view.dart';
import 'package:onetwotrail/ui/views/reset_password_send_email.dart';
import 'package:onetwotrail/ui/views/reset_password_view_two.dart';
import 'package:onetwotrail/ui/views/sign_in_view.dart';
import 'package:onetwotrail/ui/views/sign_up_or_sign_in_view.dart';
import 'package:onetwotrail/ui/views/splash_view.dart';
import 'package:onetwotrail/ui/views/trail_preview/trail_preview_view.dart';
import 'package:onetwotrail/ui/views/debug/debug_view.dart';
import 'package:onetwotrail/utils/CupertinoPageRouteMoreTime.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static Route<dynamic> generateRouter(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return CupertinoPageRouteMoreTime(
          title: 'Home',
          builder: (context) {
          RestartWidget.context = context;
          return AnimatedCrossFade(
            firstCurve: Curves.easeIn,
            secondCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 1000),
            firstChild: SplashView(image: Image.asset("assets/splash/background_image.png", gaplessPlayback: true)),
            secondChild: HomeView(),
            crossFadeState: CrossFadeState.showSecond,
          );
        });
      case '/login':
        return CupertinoPageRouteMoreTime(
            title: 'Login',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: SignInView(),
                ));
      case '/register-view':
        return CupertinoPageRouteMoreTime(
            title: 'Register',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: RegisterView(),
                ));
      case '/onBoard':
        return CupertinoPageRouteMoreTime(
            title: 'Onboarding',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: ControllerPageView(),
                ));
      case '/experienceInfo':
        Experience experiences = settings.arguments as Experience;
        return CupertinoPageRouteMoreTime(
            title: 'Experience Info',
            builder: (_) => Provider.value(
                  value: experiences,
                  child: ExperienceInfo(),
                ));
      case '/reset-password':
        return CupertinoPageRouteMoreTime(
            title: 'Reset Password',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: ResetPasswordSendEmail(),
                ));
      case '/reset_password_view_two':
        String uri = settings.arguments as String;
        return CupertinoPageRouteMoreTime(
            title: 'Reset Password',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: ResetPasswordViewTwo(
                    // uri: uri.isNotEmpty ? uri : "",
                    url: uri.isNotEmpty ? uri : "",
                  ),
                ));
      case '/reportIssue':
        Experience experience = settings.arguments as Experience;
        return CupertinoPageRouteMoreTime(
            title: 'Report Issue',
            builder: (_) => Provider.value(
                  value: experience,
                  child: ReportIssueView(),
                ));
      case '/main_filters':
        String query = settings.arguments as String;
        return CupertinoPageRouteMoreTime(
            title: 'Filters',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: MainFilterView(query),
                ));
      case '/trail-main-view':
        int trailId = settings.arguments as int;
        return CupertinoPageRouteMoreTime(
            title: 'Trail',
            builder: (_) => Provider.value(
                  value: trailId,
                  child: BoardView(),
                ));
      case '/landing':
        return CupertinoPageRouteMoreTime(
            title: 'Landing',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: SignUpOrSignInView(),
                ));
      case '/trail-preview-view':
        Trail trail = settings.arguments as Trail;
        return CupertinoPageRouteMoreTime(
            title: 'Trail Preview',
            builder: (_) => Provider.value(
                  value: trail,
                  child: TrailPreviewView(),
                ));
      case '/generate-itinerary-from-board':
        Trail trail = settings.arguments as Trail;
        return CupertinoPageRouteMoreTime(
            title: 'Generate Itinerary',
            builder: (_) => Provider.value(
                  value: trail,
                  child: GenerateItineraryFromBoard(),
                ));
      case '/profile-user-information-view':
        return CupertinoPageRouteMoreTime(
            title: 'Profile',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: ProfileUserInformationView(),
                ));
      case '/update-password-view':
        return CupertinoPageRouteMoreTime(
            title: 'Update Password',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: UpdatePasswordView(),
                ));
      case '/discover-view':
        return CupertinoPageRouteMoreTime(
            title: 'Discover',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: DiscoverView(),
                ));
      case '/home-view':
        return CupertinoPageRouteMoreTime(
            title: 'Home',
            builder: (_) => Provider.value(
                  value: settings.arguments,
                  child: HomeView(),
                ));
      case '/experience':
        return CupertinoPageRouteMoreTime(
            title: 'Experience',
            builder: (_) => Provider<Experience>.value(
                  value: settings.arguments as Experience,
                  child: ExperienceInfo(),
                ));
      case '/private-trail':
        return CupertinoPageRouteMoreTime(
            title: 'Trail',
            builder: (_) => Provider<Trail>.value(
                  value: settings.arguments as Trail,
                  child: TrailView(),
                ));
      case '/public-trail':
        return CupertinoPageRouteMoreTime(
            title: 'Public Trail',
            builder: (_) => Provider<Trail>.value(
                  value: settings.arguments as Trail,
                  child: TrailPreviewView(),
                ));
      case '/debug':
        return CupertinoPageRouteMoreTime(
            title: 'Debug Tools',
            builder: (_) => DebugView(),
        );
      default:
        return CupertinoPageRouteMoreTime(
            title: 'Not Found',
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('Route not found: ${settings.name}'),
                  ),
                ));
    }
  }
}
