import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:onetwotrail/l10n/app_localizations.dart';
import 'package:onetwotrail/repositories/enums/enum_filter_type.dart';
import 'package:onetwotrail/repositories/models/api_filter.dart';
import 'package:onetwotrail/repositories/models/api_filters_values.dart';
import 'package:onetwotrail/repositories/models/base_response.dart';
import 'package:onetwotrail/repositories/viewModels/main_filter_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:onetwotrail/ui/widgets/own_check_box/ownCheckBox.dart';
import 'package:provider/provider.dart';

const String LOADING = 'LOADING';
const String ERROR = 'ERROR';
const String SUCCESS = 'SUCCESS';

class MainFilterView extends StatelessWidget {
  final String query;

  const MainFilterView(this.query, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainFilterModel>(
      builder: (context, model, _) {
        Size mediaQuery = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SizedBox(
                width: mediaQuery.width,
                height: mediaQuery.height,
                child: StreamBuilder(
                  stream: model.filtersStream,
                  builder: (BuildContext ctxt, AsyncSnapshot<BaseResponse<List<ApiFilters>>> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.data!.responseStatus == LOADING && snapshot.data!.data.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.data!.responseStatus == ERROR && snapshot.data!.data.isEmpty) {
                      return Container(
                        height: 200,
                        padding: EdgeInsets.symmetric(vertical: 110, horizontal: 16),
                        alignment: Alignment.topLeft,
                        child: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              text: AppLocalizations.of(context)?.somethingWentWrongRequestText ?? "Something went wrong",
                              children: [
                                TextSpan(text: ". "),
                                TextSpan(
                                  text: AppLocalizations.of(context)?.tryAgain ?? "Try again",
                                  style: TextStyle(decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()..onTap = () => model.clearFilters(),
                                )
                              ]),
                        ),
                      );
                    } else if (snapshot.data!.responseStatus == SUCCESS && snapshot.data!.data.isEmpty) {
                      return Center(child: Text('No Filters Found'));
                    } else {
                      return Column(children: [
                        UIHelper.verticalSpace(100),
                        Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data!.data.length + 1,
                              itemBuilder: (BuildContext contx, int index) {
                                return index == snapshot.data!.data.length
                                    ? ApplyFilterButton()
                                    : RenderWidgetFromFiltersValue(
                                        snapshot.data!.data[index], snapshot.data!.data[index].filterType);
                              }),
                        ),
                      ]);
                    }
                  },
                ),
              ),
              AppBarFilterContainer(),
            ],
          ),
        );
      },
    );
  }
}

class AppBarFilterContainer extends StatelessWidget {
  const AppBarFilterContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Consumer<MainFilterModel>(
      builder: (context, model, _) {
        return Container(
          height: 100,
          width: mediaQuery.width,
          child: Stack(
            children: [
              Container(
                  height: 100,
                  width: mediaQuery.width,
                  child: Image.asset(
                    'assets/main_filter/appbar_background_image.png',
                    fit: BoxFit.fill,
                  )),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 50,
                  width: mediaQuery.width / 2,
                  child: Row(
                    children: [
                      UIHelper.horizontalSpace(mediaQuery.width * 0.053),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(bottom: mediaQuery.height * 0.01),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      UIHelper.horizontalSpace(mediaQuery.width * 0.053),
                      Container(
                        padding: EdgeInsets.only(bottom: mediaQuery.height * 0.01),
                        alignment: Alignment.centerRight,
                        child: Text(
                          AppLocalizations.of(context)?.filterText.toUpperCase() ?? "FILTER",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class RenderWidgetFromFiltersValue extends StatelessWidget {
  final ApiFilters apiFilter;
  final FilterType type;

  const RenderWidgetFromFiltersValue(this.apiFilter, this.type, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Container(
        width: mediaQuery.width,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.05, vertical: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              apiFilter.label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
            ),
          ),
          ContainerOfFilterValue(apiFilter),
        ]));
  }
}

class ContainerOfFilterValue extends StatelessWidget {
  final ApiFilters apiFilter;

  const ContainerOfFilterValue(this.apiFilter, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Consumer<MainFilterModel>(
      builder: (context, model, _) {
        return Container(
          width: mediaQuery.width,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: 1,
            shrinkWrap: true,
            itemBuilder: (context, int index) {
              return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                UIHelper.verticalSpace(10),
                apiFilter.filterType == FilterType.CHECK_BOX
                    ? FilterTypeCheckBox(apiFilter.apiFiltersValues, apiFilter.id)
                    : apiFilter.filterType == FilterType.VALUES_RANGE
                        ? FilterTypeValueRange(apiFilter.apiFiltersValues, apiFilter, index)
                        : apiFilter.filterType == FilterType.OPTIONS_RANGE
                            ? FilterTypeOptionRange(apiFilter, index)
                            : Container(),
              ]);
            },
          ),
        );
      },
    );
  }
}

class FilterTypeOptionRange extends StatelessWidget {
  final ApiFilters apiFilter;
  final int index;

  const FilterTypeOptionRange(this.apiFilter, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Consumer<MainFilterModel>(builder: (context, model, _) {
      List<Widget> list = [];
      for (int i = 0; i <= apiFilter.apiFiltersValues.length - 1; i++) {
        final double value = i / (apiFilter.apiFiltersValues.length - 1);
        final constraints = BoxConstraints(
          maxWidth: mediaQuery.width,
          minHeight: 0.0,
          minWidth: 0.0,
        );
        RenderParagraph renderParagraph = RenderParagraph(
          TextSpan(
            text: apiFilter.apiFiltersValues[i].label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        );
        renderParagraph.layout(constraints);
        double textLength = renderParagraph.getMinIntrinsicWidth(12).ceilToDouble();
        final double dx = 24 + value * (mediaQuery.width - 48) + 4 - (textLength + 12) / 2;
        list.add(Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: i == 0
                ? 24
                : i == apiFilter.apiFiltersValues.length - 1
                    ? mediaQuery.width - 24 - textLength
                    : dx,
          ),
          child: Text(
            apiFilter.apiFiltersValues[i].label,
            textAlign: TextAlign.start,
          ),
        ));
      }

      if (model.sliderSelectedValue[apiFilter.id] == null) {
        model.setOptionsRangeTypeValue(apiFilter.id, apiFilter.apiFiltersValues[0].value);
      }

      return Container(
          height: mediaQuery.height * 0.10,
          width: mediaQuery.width,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
              child: Stack(
                children: list,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                    showValueIndicator: ShowValueIndicator.never,
                    activeTickMarkColor: Colors.transparent,
                    inactiveTickMarkColor: Colors.transparent,
                    disabledActiveTickMarkColor: Colors.transparent,
                    disabledInactiveTickMarkColor: Colors.transparent,
                    tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 0.0)),
                child: Slider(
                  min: 0,
                  max: apiFilter.apiFiltersValues.length.toDouble() - 1 > 0
                      ? apiFilter.apiFiltersValues.length.toDouble() - 1
                      : 1,
                  divisions: apiFilter.apiFiltersValues.length - 1,
                  activeColor: tealish,
                  inactiveColor: tealish40,
                  value: model.sliderSelectedValue[apiFilter.id] ?? 0,
                  onChanged: (newRating) {
                    model.setSelectedSliderValue(apiFilter.id, newRating);
                    model.setOptionsRangeTypeValue(
                        apiFilter.id, apiFilter.apiFiltersValues[newRating.toInt()].value);
                  },
                ),
              ),
            ),
          ]));
    });
  }
}

class FilterTypeValueRange extends StatelessWidget {
  final List<ApiFiltersValues> apiFiltersValues;
  final ApiFilters apiFilter;
  final int indexApiFilters;

  const FilterTypeValueRange(this.apiFiltersValues, this.apiFilter, this.indexApiFilters, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainFilterModel>(builder: (context, model, _) {
      Size mediaQuery = MediaQuery.of(context).size;
      TimeOfDay start = apiFilter.apiFiltersValues[0].time;
      TimeOfDay end = apiFilter.apiFiltersValues[apiFilter.apiFiltersValues.length - 1].time;
      List<String> labels = model.getRangedLabels(start, end, context);
      RangeValues values = model.rangeSliderValues[apiFilter.id] ?? RangeValues(0, labels.length.toDouble() - 1);

      if (model.sliderSelectedValue[apiFilter.id] == null) {
        model.setTimeRangeTypeValue(apiFilter.id, values.start.round(), values.end.round());
      }
      return Container(
          height: mediaQuery.height * 0.10,
          child: Column(children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: mediaQuery.height * 0.025),
                child: Row(
                  children: [
                    Text(
                        '${labels[values.start.round()]} - '
                        '${labels[values.end.round()]}',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black))
                  ],
                )),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                    showValueIndicator: ShowValueIndicator.never,
                    activeTickMarkColor: Colors.transparent,
                    inactiveTickMarkColor: Colors.transparent),
                child: RangeSlider(
                  min: 0,
                  max: (labels.length - 1).toDouble(),
                  values: values,
                  divisions: labels.length - 1,
                  labels: RangeLabels(labels[values.start.round()], labels[values.end.round()]),
                  onChanged: (value) {
                    if (value.start != values.start || value.end != values.end) {
                      model.setRangeSliderValue(apiFilter.id, value);
                      model.setTimeRangeTypeValue(apiFilter.id, value.start.round(), value.end.round());
                    }
                  },
                  onChangeEnd: (value) {},
                ),
              ),
            )
          ]));
    });
  }
}

class FilterTypeCheckBox extends StatelessWidget {
  final List<ApiFiltersValues> apiFilter;
  final String id;

  const FilterTypeCheckBox(this.apiFilter, this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Consumer<MainFilterModel>(builder: (context, model, _) {
      return Container(
          width: mediaQuery.width,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: apiFilter.length,
            itemBuilder: (ctxt, int index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.05),
                height: mediaQuery.height * 0.07,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    apiFilter[index].label.isNotEmpty
                                        ? apiFilter[index].label
                                        : "${apiFilter[index].value ?? 'ss'}",
                                    style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400))),
                          ),
                          Expanded(
                            child: Container(
                                alignment: Alignment.centerRight,
                                child: OwnCheckBox((bool selected) {
                                  model.setCheckBoxTypeValue(id, apiFilter[index].value, selected);
                                }, model.getStatus(id, apiFilter[index].value)

                                    // model.checkboxCheckedValues[id] ?? false
                                    )),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ));
    });
  }
}

class ApplyFilterButton extends StatelessWidget {
  const ApplyFilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    return Consumer<MainFilterModel>(
      builder: (context, model, _) {
        return Column(
          children: [
            UIHelper.verticalSpace(mediaQuery.height * 0.075),
            Container(
              height: 50,
              child: Row(
                children: [
                  Flexible(
                    flex: 25,
                    child: Container(),
                  ),
                  Flexible(
                    flex: 50,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: viridian,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      child: Container(
                        width: mediaQuery.width * 0.523,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Flexible(
                              flex: 75,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalizations.of(context)?.applyFiltersText ?? "Apply Filters",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, model.selectedFiltersValues);
                      },
                    ),
                  ),
                  Flexible(
                    flex: 25,
                    child: Container(),
                  )
                ],
              ),
            ),
            UIHelper.verticalSpace(mediaQuery.height * 0.075),
          ],
        );
      },
    );
  }
}
