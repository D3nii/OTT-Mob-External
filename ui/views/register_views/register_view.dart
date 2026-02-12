import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:onetwotrail/repositories/enums/view_state.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/viewModels/register_page_model.dart';
import 'package:onetwotrail/ui/views/register_views/register_step_one_view.dart';
import 'package:onetwotrail/ui/views/register_views/register_step_two_view.dart';
import 'package:onetwotrail/ui/views/register_views/verify_email_view.dart';
import 'package:onetwotrail/ui/widgets/circular_progress_bar.dart';
import 'package:provider/provider.dart';



class RegisterView extends StatelessWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  final authService = Provider.of<AuthenticationService>(context, listen: false);
  return ChangeNotifierProvider<RegisterPageModel>(
    create: (_) => RegisterPageModel(authenticationService: authService),
    child: Consumer<RegisterPageModel>(
    builder: (context, model, _) {
      return Stack(
        children: [
          PageView(
            allowImplicitScrolling: false,
            scrollDirection: Axis.horizontal,
            controller: model.pageController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              RegisterStepOneView(),
              RegisterStepTwoView(),
              VerifyEmailView(),
            ],
          ),
          model.state == ViewState.Busy ? CircularProgressBar() : Container(),
        ],
      );
    },
  ));
}
}
