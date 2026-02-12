import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/viewModels/register_page_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/countryPickerDialog.dart';
import 'package:provider/provider.dart';

class RoundedCountryPicker extends StatelessWidget {
  const RoundedCountryPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterPageModel>(
      builder: (context, model, _) {
        return Material(
          elevation: 3,
          shadowColor: Color.fromRGBO(0, 0, 0, 0.0),
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            height: 60,
            width: double.infinity,
            child: Material(
              elevation: 0,
              shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
              borderRadius: BorderRadius.circular(10.0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 24, 0),
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
                  ),
                  onPressed: () {
                    model.unfocusAllTextFields();
                    showModal(context: context, builder: (BuildContext context) => CountryPickerDialog(model));
                  },
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: ImageIcon(
                          AssetImage("assets/icons/world.png"),
                          size: 25,
                          color: model.selectedCountry == null ? pinkishGrey : tealish,
                        ),
                      ),
                      UIHelper.horizontalSpace(12),
                      Expanded(
                        child: Text(
                          model.selectedCountry == null
                              ? AppLocalizations.of(context)?.countryText ?? 'Country'
                              : model.selectedCountry?.name ?? 'Country',
                          textAlign: TextAlign.left,
                          textWidthBasis: TextWidthBasis.longestLine,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                            fontWeight: model.selectedCountry == null ? FontWeight.w300 : FontWeight.w500,
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
