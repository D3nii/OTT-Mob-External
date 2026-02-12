import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetwotrail/repositories/viewModels/register_page_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:provider/provider.dart';

class RoundedTextfield extends StatelessWidget {
  const RoundedTextfield(
    this.hintText,
    this.assetImage,
    this.textController,
    this.focusNode,
    this.onChanged, {
    Key? key,
    this.obscured = false,
    this.isEmpty = false,
    this.isEmail = false,
  }) : super(key: key);

  final String hintText;
  final AssetImage assetImage;
  final TextEditingController textController;
  final FocusNode focusNode;
  final Function() onChanged;
  final bool obscured;
  final bool isEmpty;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterPageModel>(
      builder: (context, model, _) {
        return Material(
          elevation: 0,
          shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            color: Colors.transparent,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  keyboardType: () {
                    if (isEmail) {
                      return TextInputType.emailAddress;
                    }
                    return TextInputType.text;
                  }(),
                  focusNode: focusNode,
                  obscureText: obscured,
                  controller: textController,
                  inputFormatters: () {
                    if (isEmail) {
                      return [
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9@.+-]")),
                      ];
                    }
                    return <TextInputFormatter>[];
                  }(),
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
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
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
                      color: isEmpty ? pinkishGrey : tealish,
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
