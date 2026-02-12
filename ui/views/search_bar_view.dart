import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:onetwotrail/repositories/models/experience.dart';
import 'package:onetwotrail/repositories/services/application_api.dart';
import 'package:onetwotrail/repositories/services/search_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_widget_model.dart';
import 'package:onetwotrail/repositories/viewModels/search_bar_result_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/widgets/base_widget.dart';
import 'package:onetwotrail/ui/widgets/experience_horizontal_list.dart';
import 'package:onetwotrail/v2/event/event.dart';
import 'package:onetwotrail/v2/event/event_client.dart';
import 'package:onetwotrail/v2/event/event_name.dart';
import 'package:onetwotrail/v2/event/event_source_view.dart';
import 'package:onetwotrail/v2/event/event_tag.dart';
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

class SearchBarView extends BaseWidget {
  @override
  Widget getChild(BuildContext context, BaseWidgetModel baseWidgetModel) {
    var applicationApi = Provider.of<ApplicationApi>(context, listen: false);
    var searchService = Provider.of<SearchService>(context, listen: false);
    return ChangeNotifierProvider<SearchBarResultModel>(
        create: (_) => SearchBarResultModel(applicationApi, searchService)..initSearch(),
        child: Consumer2<SearchBarResultModel, BaseWidgetModel>(builder: (context, resultModel, widgetModel, _) {
          Size mediaQuery = MediaQuery.of(context).size;
          return Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: true,
              body: Column(children: [
                Stack(children: [
                  Container(
                    width: mediaQuery.width,
                    height: mediaQuery.height * .15,
                    child: Image.asset(
                      'assets/background_images/brand_bg_header.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(32)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      spreadRadius: 0,
                                      blurRadius: 10,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      splashColor: Colors.transparent,
                                      iconSize: 20.0,
                                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: resultModel.searchController,
                                        onTap: () => resultModel.changeSearchableState(true),
                                        onSubmitted: (value) {
                                          resultModel.submitSearch(value);
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
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    resultModel.showClearTextButton
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.cancel,
                                              color: Colors.grey,
                                            ),
                                            splashColor: Colors.transparent,
                                            iconSize: 20.0,
                                            onPressed: () {
                                              resultModel.clearSearch();
                                            },
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ]),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      resultModel.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : resultModel.showSearch
                              ? searchResults(context, resultModel)
                              : searchResultsPlaceholder(context),
                      resultModel.searchable ? _AutofillWidget() : Container(),
                    ],
                  ),
                ),
              ]));
        }));
  }

  Container searchResultsPlaceholder(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15, vertical: 24),
            child: Image.asset(
              'assets/background_images/empty_search.png',
            ),
          ),
          Text(
            AppLocalizations.of(context)?.emptySearchText ?? "Empty Search",
            style: TextStyle(
              color: Colors.grey,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }

  Widget searchResults(BuildContext context, SearchBarResultModel resultModel) {
    Size mediaQuery = MediaQuery.of(context).size;
    final int messageCount = resultModel.searchResults.length;
    if (messageCount == 0 && !resultModel.isLoading) {
      return Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.topLeft,
        child: Text(AppLocalizations.of(context)?.noSearchResultText ?? "No Search Result",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            )),
      );
    }
    return MasonryGridView.count(
      controller: resultModel.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 120
      ),
      crossAxisCount: 2,
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      itemCount: resultModel.searchResults.length,
      itemBuilder: (context, index) {
        final Experience experience = resultModel.searchResults[index];
        var width = mediaQuery.width * 0.5 - 8;
        var seed = experience.experienceId.hashCode;
        var random = Random(seed);
        var height = width * (1.0 + random.nextDouble());

        return experienceItem(
          context: context,
          experience: experience,
          onLongPress: () {},
          experienceNameFontSize: 14,
          experienceDestinationFontSize: 12,
          width: width,
          height: height,
          onTap: () {
            Provider.of<EventClient>(context, listen: false).createEvent(
              Event(EventName.experience_profile_viewed, EventSourceView.search_experience, {
                EventTag.experience_id: experience.experienceId.toString(),
                EventTag.experience_name: experience.name,
                EventTag.search_query: resultModel.searchController.text,
              })
            );
            return {};
          }
        );
      },
    );
  }
}

class _AutofillWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchBarResultModel>(builder: (context, model, _) {
      return Container(
        padding: EdgeInsets.only(top: 5, left: 10, right: 10),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: StreamBuilder<List<String>>(
            stream: model.autocompleteData,
            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              if (snapshot.data!.isEmpty) {
                if (model.recentSearchesTerms.isNotEmpty && model.searchController.text.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          "Recent Searches",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: model.recentSearchesTerms.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  model.submitSearch(model.recentSearchesTerms[index]);
                                },
                                dense: true,
                                leading: Icon(
                                  Icons.history,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  model.recentSearchesTerms[index],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    model.deleteRecentSearch(model.recentSearchesTerms[index]);
                                  },
                                ),
                              );
                            }),
                      ),
                    ],
                  );
                }
                return Container();
              }

              return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data?.length ?? 0,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        model.submitSearch(snapshot.data![index]);
                      },
                      dense: true,
                      leading: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      title: SubstringHighlight(
                        text: snapshot.data![index],
                        term: model.prevSearchTerm,
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                        textStyleHighlight: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    );
                  });
            }),
        ),
      );
    });
  }
}
