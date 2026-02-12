import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/models/country.dart';
import 'package:onetwotrail/repositories/viewModels/register_page_model.dart';
import 'package:onetwotrail/ui/share/country_list.dart';
import 'package:provider/provider.dart';

class CountryPickerDialog extends StatelessWidget {
  const CountryPickerDialog(this.model, {Key? key}) : super(key: key);

  final RegisterPageModel model;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchHandler(),
      child: Consumer<SearchHandler>(
        builder: (_, handler, __) => Material(
          color: Color.fromRGBO(0, 0, 0, 0.3),
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
                            AppLocalizations.of(context)?.countryText ?? 'Country',
                            textAlign: TextAlign.left,
                            textWidthBasis: TextWidthBasis.longestLine,
                            style: TextStyle(
                              fontFamily: "Futura-Medium",
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      onChanged: (value) => handler.searchTextChanged(value),
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)?.searchByCountryName ?? 'Search by country name'),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: handler.filteredList.length,
                      itemBuilder: (context, index) => Material(
                        color: Colors.white,
                        child: ListTile(
                          onTap: () {
                            model.updateCountry(handler.filteredList[index]);
                            Navigator.pop(context);
                          },
                          selected: true,
                          title: Text(
                            handler.filteredList[index].name,
                            textAlign: TextAlign.left,
                            textWidthBasis: TextWidthBasis.longestLine,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(125, 125, 125, 1),
                            ),
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
        ),
      ),
    );
  }
}

class SearchHandler extends ChangeNotifier {
  List<Country> filteredList = CountryList.countryList;

  void searchTextChanged(String value) {
    if (value.isEmpty) {
      filteredList = CountryList.countryList;
    } else {
      filteredList =
          CountryList.countryList.where((country) => country.name.toUpperCase().contains(value.toUpperCase())).toList();
    }

    notifyListeners();
  }
}
