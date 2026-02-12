import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/services/search_service.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/widgets/search_bar/model/search_bar_item_model.dart';
import 'package:provider/provider.dart';

class SearchBarItem extends StatelessWidget {
  const SearchBarItem(
    this.filtersButtonClicked,
    this.focus, {
    Key? key,
    this.showBackArrow = false,
  }) : super(key: key);

  final Function() filtersButtonClicked;
  final Function() focus;
  final bool showBackArrow;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<SearchService, SearchBarItemModel>(
      create: (_) => SearchBarItemModel()..initSearch(),
      update: (_, searchService, model) {
        if (model != null) {
          model.searchService = searchService;
        }
        return model!;
      },
      child: Consumer<SearchBarItemModel>(
        builder: (context, model, _) {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  !showBackArrow
                      ? model.searchFocusNode.hasFocus == true
                          ? IconButton(
                              icon: Icon(
                                Icons.search,
                                color: tealish,
                              ),
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              iconSize: 20.0,
                              onPressed: () {},
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              iconSize: 20.0,
                              onPressed: () {},
                            )
                      : IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: tealish,
                          ),
                          splashColor: Colors.transparent,
                          iconSize: 20.0,
                          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        ),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      controller: model.searchController,
                      focusNode: model.searchFocusNode,
                      onTap: () async {
                        // model.searchFocusNode.requestFocus();
                        focus();
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: '${AppLocalizations.of(context)?.searchTitle ?? 'Search'}',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffb7b7b6),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(
                  //       right: MediaQuery.of(context).size.width * 0.024),
                  //   child: Stack(
                  //     alignment: Alignment.center,
                  //     children: [
                  //       Container(
                  //         height: 30,
                  //         width: 30,
                  //         decoration: BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: tealish,
                  //         ),
                  //       ),
                  //       InkWell(
                  //         child: Container(
                  //           height: 25,
                  //           width: 25,
                  //           child: Image.asset(
                  //             'assets/icons/filter.png',
                  //           ),
                  //         ),
                  //         highlightColor: Colors.transparent,
                  //         splashColor: Colors.transparent,
                  //         onTap: () => filtersButtonClicked(),
                  //       )
                  //     ],
                  //   ),
                  // ),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}
