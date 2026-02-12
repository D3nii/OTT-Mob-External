import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Removed unnecessary import
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:onetwotrail/repositories/services/authentication_service.dart';
import 'package:onetwotrail/repositories/services/profile_service.dart';
import 'package:onetwotrail/repositories/viewModels/profile_edit_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/country_list.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:provider/provider.dart';

class ProfileUserInformationView extends StatelessWidget {
  const ProfileUserInformationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider2<AuthenticationService, ProfileService, ProfileEditViewModel>(
      update: (_, authenticationService, profileService, model) => model!
        ..profileService = profileService
        ..authenticationService = authenticationService
        ..init(),
      create: (_) => ProfileEditViewModel(),
      child: Consumer<ProfileEditViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              onTap: () {
                model.unfocusAllTextFields();
              },
              child: Container(
                child: Stack(
                  children: [
                    _ContainerOfBody(),
                    model.successToastVisible ? _ContainerOfToast() : Container(),
                    model.saveWarningVisible ? _ContainerOfWarningSave() : Container()
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ContainerOfBody extends StatelessWidget {
  const _ContainerOfBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(builder: (context, model, _) {
      return Column(
        children: [
          _ContainerOfAppBar(),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              color: pinkishGrey,
              child: ListView(
                children: [
                  _ContainerOfAvatarImageAndLogOutButton(),
                  UIHelper.verticalSpace(12),
                  RoundedProfileTextfield(
                    AppLocalizations.of(context)!.firstName,
                    AssetImage("assets/icons/user.png"),
                    model.firstNameTextController,
                    model.firstNameFocusNode,
                    () {
                      model.unsavedChanges = true;
                    },
                    isEmpty: model.firstNameTextController.text.isEmpty,
                    isEmail: false,
                  ),
                  UIHelper.verticalSpace(12),
                  RoundedProfileTextfield(
                    AppLocalizations.of(context)!.lastNameText,
                    AssetImage("assets/icons/user.png"),
                    model.lastNameTextController,
                    model.lastNameFocusNode,
                    () {
                      model.unsavedChanges = true;
                    },
                    isEmpty: model.lastNameTextController.text.isEmpty,
                    isEmail: false,
                  ),
                  UIHelper.verticalSpace(12),
                  RoundedProfileTextfield(
                    AppLocalizations.of(context)!.emailText,
                    AssetImage("assets/icons/email.png"),
                    model.emailTextController,
                    model.emailFocusNode,
                    () {
                      model.updateEmail();
                      model.unsavedChanges = true;
                    },
                    isEmpty: model.emailTextController.text.isEmpty,
                    isEmail: true,
                    enabled: false,
                  ),
                  UIHelper.verticalSpace(12),
                  RoundedProfileCountryPicker(),
                  UIHelper.verticalSpace(12),
                  _UpdatePasswordButton(),
                  UIHelper.verticalSpace(12),
                  _DeleteMyAccountButton(() async {await model.deleteAccount(context);}),
                  UIHelper.verticalSpace(12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: model.savingChanges
                                ? tealish
                                : (model.unsavedChanges || model.unsavedCountry)
                                    ? tealish
                                    : beige,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: tealish, width: 2, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                UIHelper.horizontalSpace(24),
                                Container(
                                  alignment: Alignment.center,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.saveChangesText,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: model.savingChanges
                                              ? tealish
                                              : (model.unsavedChanges || model.unsavedCountry)
                                                  ? Colors.white
                                                  : tealish,
                                        ),
                                      ),
                                      model.savingChanges
                                          ? Align(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                UIHelper.horizontalSpace(24),
                              ]),
                          onPressed: () => model.saveChanges(context),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(24),
                ],
              ),
            ),
          )
        ],
      );
    });
  }
}

class _ContainerOfAvatarImageAndLogOutButton extends StatelessWidget {
  const _ContainerOfAvatarImageAndLogOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(builder: (context, model, _) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ContainerOfCircleImage(),
          _ContainerOfLogOutButton(),
        ],
      );
    });
  }
}

class _ContainerOfLogOutButton extends StatelessWidget {
  const _ContainerOfLogOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(builder: (context, model, _) {
      Size mediaQuery = MediaQuery.of(context).size;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) => states.contains(WidgetState.disabled) ? Colors.black : Colors.black,
              ),
            ),
            child: Container(
              alignment: Alignment.centerRight,
              width: ((mediaQuery.width * 0.6) - 136),
              child: AutoSizeText(
                AppLocalizations.of(context)!.logOutText,
                maxLines: 1,
                minFontSize: 8,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black),
              ),
            ),
            onPressed: model.logout,
          ),
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: tomato,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: ImageIcon(
                  AssetImage("assets/icons/sign_out.png"),
                  size: 15,
                  color: Colors.white,
                ),
                color: Colors.white,
                onPressed: model.logout,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ContainerOfCircleImage extends StatelessWidget {
  const _ContainerOfCircleImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(builder: (context, model, _) {
      Size mediaQuery = MediaQuery.of(context).size;
      try {
        return Container(
          width: mediaQuery.width * 0.35,
          child: Center(
            child: Stack(children: [
              CircleAvatar(
                radius: mediaQuery.width * 0.35 / 2,
                backgroundImage: model.userAvatar.isNotEmpty
                    ? NetworkImage(
                        model.userAvatar,
                      ) as ImageProvider
                    : AssetImage("assets/icons/user.png") as ImageProvider,
                backgroundColor: grey125Color,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: viridian,
                  radius: 15,
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: ImageIcon(
                        AssetImage("assets/icons/edit_profile_picture.png"),
                        size: 12,
                        color: Colors.white,
                      ),
                      color: Colors.white,
                      onPressed: () async {
                        await model.pickImage(context);
                      }),
                ),
              )
            ]),
          ),
        );
      } catch (error) {
        return CircleAvatar(
          radius: mediaQuery.width * 0.35 / 2,
          backgroundImage: AssetImage("assets/icons/user.png") as ImageProvider,
          backgroundColor: grey125Color,
        );
      }
    });
  }
}

class _ContainerOfAppBar extends StatelessWidget {
  const _ContainerOfAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(builder: (context, model, _) {
      Size mediaQuery = MediaQuery.of(context).size;
      return Container(
        height: 104,
        width: mediaQuery.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 104,
              width: mediaQuery.width,
              child: Image.asset(
                'assets/main_filter/appbar_background_image.png',
                fit: BoxFit.fill,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16, left: 20),
                child: Row(children: [
                  Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => model.tryToLeave(context),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5),
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.editProfileText.toUpperCase(),
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
                    ),
                  )
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ContainerOfWarningSave extends StatelessWidget {
  const _ContainerOfWarningSave({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(builder: (context, model, _) {
      Size mediaQuery = MediaQuery.of(context).size;
      return Container(
        color: black85Transparent,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            width: mediaQuery.width * 0.85,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Color.fromRGBO(0, 0, 0, 0.7),
                ),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UIHelper.verticalSpace(24),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.leaveWithoutSavingText,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: tomato),
                  ),
                ),
                UIHelper.verticalSpace(12),
                Flexible(
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.changesWillBeLostText,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                UIHelper.verticalSpace(16),
                Container(
                  height: 50,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: tealish,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: tealish, width: 2, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          UIHelper.horizontalSpace(24),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)!.saveChangesText,
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          UIHelper.horizontalSpace(24),
                        ]),
                    onPressed: () async {
                      return await model.saveChanges(context, popView: true);
                    },
                  ),
                ),
                UIHelper.verticalSpace(4),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.transparent),
                    ),
                    onPressed: () => model.leaveView(context),
                    child: Text(
                      AppLocalizations.of(context)!.leaveText,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          color: Colors.black),
                    ),
                  ),
                ),
                UIHelper.verticalSpace(16),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _ContainerOfToast extends StatelessWidget {
  const _ContainerOfToast({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(
      builder: (context, model, _) {
        return Align(
          alignment: Alignment.center,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                  color: black70Transparent,
                  border: Border.all(
                    color: black70Transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UIHelper.horizontalSpace(24),
                  Text(
                    AppLocalizations.of(context)!.changesSavedText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  UIHelper.horizontalSpace(32),
                  ImageIcon(
                    AssetImage("assets/icons/check.png"),
                    color: Colors.white,
                  ),
                ],
              )),
        );
      },
    );
  }
}

class _UpdatePasswordButton extends StatelessWidget {
  const _UpdatePasswordButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container()),
        TextButton(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
          ),
          onPressed: () => Navigator.pushNamed(context, '/update-password-view'),
          child: Text(
            AppLocalizations.of(context)!.changeMyPasswordText,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: turquoise,
                color: turquoise),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}

class _DeleteMyAccountButton extends StatelessWidget {
  final void Function() onPressed;

  const _DeleteMyAccountButton(this.onPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container()),
        TextButton(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
          ),
          onPressed: onPressed,
          child: Text(
            AppLocalizations.of(context)!.deleteMyAccountText,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: Colors.red,
                color: Colors.red),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}

class RoundedProfileTextfield extends StatelessWidget {
  final String hintText;
  final AssetImage assetImage;
  final TextEditingController textController;
  final FocusNode focusNode;
  final Function() onChanged;
  final bool obscured;
  final bool isEmpty;
  final bool isEmail;
  final bool allowAllCharacters;
  final bool isPhone;
  final bool enabled;

  const RoundedProfileTextfield(
    this.hintText,
    this.assetImage,
    this.textController,
    this.focusNode,
    this.onChanged, {
    Key? key,
    this.obscured = false,
    this.isEmpty = false,
    this.isEmail = false,
    this.allowAllCharacters = false,
    this.isPhone = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(
      builder: (context, model, _) {
        return Material(
          elevation: 0,
          shadowColor: black30Transparent,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            color: Colors.transparent,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  enabled: enabled,
                  focusNode: focusNode,
                  obscureText: obscured,
                  keyboardType: () {
                    if (isPhone) {
                      return TextInputType.phone;
                    }
                    if (isEmail) {
                      return TextInputType.emailAddress;
                    }
                    return TextInputType.text;
                  }(),
                  controller: textController,
                  onChanged: (_) {
                    onChanged();
                  },
                  onSubmitted: (_) {
                    model.unfocusAllTextFields();
                  },
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.black : pinkishGrey,
                  ),
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
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
                      color: isEmpty || !enabled ? pinkishGrey : tealish,
                    ),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
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

class RoundedProfileCountryPicker extends StatelessWidget {
  const RoundedProfileCountryPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(
      builder: (context, model, _) {
        return Material(
          elevation: 0,
          shadowColor: Colors.black,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            height: 60,
            width: double.infinity,
            child: Material(
              elevation: 0,
              shadowColor: black30Transparent,
              borderRadius: BorderRadius.circular(10.0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 24, 0),
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => Colors.transparent),
                  ),
                  onPressed: () {
                    model.unfocusAllTextFields();
                    showDialog(context: context, builder: (BuildContext context) => CountryProfilePickerDialog(model));
                  },
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: ImageIcon(
                          AssetImage("assets/icons/world.png"),
                          size: 25,
                          color: tealish,
                        ),
                      ),
                      UIHelper.horizontalSpace(12),
                      Expanded(
                        child: Text(
                          // Use the User model's countryName property via the ProfileEditViewModel
                          model.getUserCountryName(),
                          textAlign: TextAlign.left,
                          textWidthBasis: TextWidthBasis.longestLine,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      UIHelper.horizontalSpace(12),
                      Container(
                        child: ImageIcon(
                          AssetImage("assets/icons/dropdown_carat.png"),
                          size: 16,
                          color: tealish,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CountryProfilePickerDialog extends StatelessWidget {
  final ProfileEditViewModel model;

  const CountryProfilePickerDialog(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: black30Transparent,
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 60,
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        AppLocalizations.of(context)!.countryText,
                        textAlign: TextAlign.left,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: CountryList.countryList.length,
                  itemBuilder: (context, index) => Material(
                    color: Colors.white,
                    child: ListTile(
                      onTap: () {
                        // Update the country using the Country object
                        model.updateCountry(CountryList.countryList[index]);
                        Navigator.pop(context);
                      },
                      selected: true,
                      title: Text(
                        CountryList.countryList[index].name,
                        textAlign: TextAlign.left,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: TextStyle(fontSize: 16, color: grey125Color),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 12,
              )
            ],
          ),
        ),
      ),
    );
  }
}


class RoundedPhoneTextfield extends StatelessWidget {
  final String hintText;
  final Widget widget;
  final TextEditingController textController;
  final FocusNode focusNode;
  final Function() onChanged;
  final bool obscured;
  final bool isEmpty;
  final bool isEmail;
  final bool allowAllCharacters;
  final bool isPhone;
  final bool enabled;

  const RoundedPhoneTextfield(
    this.hintText,
    this.widget,
    this.textController,
    this.focusNode,
    this.onChanged, {
    Key? key,
    this.obscured = false,
    this.isEmpty = false,
    this.isEmail = false,
    this.allowAllCharacters = false,
    this.isPhone = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(
      builder: (context, model, _) {
        return Material(
          elevation: 0,
          shadowColor: black30Transparent,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            color: Colors.transparent,
            height: 66,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: InternationalPhoneNumberInput(
                    isEnabled: true,
                    selectorConfig: SelectorConfig(selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
                    onInputChanged: (PhoneNumber number) {
                      model.phone = number.phoneNumber ?? '';
                      onChanged();
                    },
                    ignoreBlank: false,
                    selectorTextStyle: TextStyle(color: Colors.black),
                    initialValue: model.number,
                    textFieldController: textController,
                    inputDecoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      hintText: AppLocalizations.of(context)!.phoneText,
                      fillColor: Color.fromRGBO(255, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
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

