import 'package:flutter/material.dart';

class DraggableSearchableListView extends StatefulWidget {
  const DraggableSearchableListView({
    Key? key,
  }) : super(key: key);

  @override
  _DraggableSearchableListViewState createState() => _DraggableSearchableListViewState();
}

class _DraggableSearchableListViewState extends State<DraggableSearchableListView> {
  final TextEditingController searchTextController = TextEditingController();
  final ValueNotifier<bool> searchTextCloseButtonVisibility = ValueNotifier<bool>(false);
  final ValueNotifier<bool> searchFieldVisibility = ValueNotifier<bool>(false);

  @override
  void dispose() {
    searchTextController.dispose();
    searchTextCloseButtonVisibility.dispose();
    searchFieldVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent == 1.0) {
          searchFieldVisibility.value = true;
        } else {
          searchFieldVisibility.value = false;
        }
        return true;
      },
      child: DraggableScrollableActuator(
        child: Stack(
          children: <Widget>[
            DraggableScrollableSheet(
              initialChildSize: 0.30,
              minChildSize: 0.5,
              maxChildSize: 1.0,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.grey, offset: Offset(1.0, -2.0), blurRadius: 4.0, spreadRadius: 2.0)
                    ],
                  ),
                  child: ListView.builder(
                    controller: scrollController,

                    ///we have 25 rows plus one header row.  itemCount: 25 + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Container(
                          child: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 16.0,
                                    left: 24.0,
                                    right: 24.0,
                                  ),
                                  child: Container(
                                      child: Row(children: <Widget>[
                                    Flexible(flex: 25, child: Container()),
                                    Flexible(flex: 50, child: Container(child: Divider(thickness: 5))),
                                    Flexible(flex: 25, child: Container()),
                                  ])),
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Divider(color: Colors.grey),
                            ],
                          ),
                        );
                      }
                      return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0), child: ListTile(title: Text('Item $index')));
                    },
                  ),
                );
              },
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              child: ValueListenableBuilder<bool>(
                  valueListenable: searchFieldVisibility,
                  builder: (context, value, child) {
                    return value
                        ? PreferredSize(
                            preferredSize: Size.fromHeight(56.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                child: Container(
                                    child: Row(children: <Widget>[
                                  Flexible(flex: 25, child: Container()),
                                  Flexible(flex: 50, child: Container(child: Divider(thickness: 5))),
                                  Flexible(flex: 25, child: Container()),
                                ]))),
                          )
                        : Container();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController textEditingController;
  final ValueNotifier<bool> closeButtonVisibility;
  final ValueChanged<String> onSearchSubmit;
  final VoidCallback onClose;

  const SearchBar({
    Key? key,
    required this.textEditingController,
    required this.closeButtonVisibility,
    required this.onSearchSubmit,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 56.0,
              width: 56.0,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  child: Icon(
                    Icons.arrow_back,
                    color: theme.textTheme.bodySmall?.color ?? Colors.black54,
                  ),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    textEditingController.clear();
                    closeButtonVisibility.value = false;
                    onClose();
                  },
                ),
              ),
            ),
            SizedBox(
              width: 16.0,
            ),
            Expanded(
              child: TextFormField(
                onChanged: (value) {
                  if (value.length > 0) {
                    closeButtonVisibility.value = true;
                  } else {
                    closeButtonVisibility.value = false;
                  }
                },
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  onSearchSubmit(value);
                },
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.none,
                textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.left,
                maxLines: 1,
                controller: textEditingController,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: "Search here",
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
                valueListenable: closeButtonVisibility,
                builder: (context, value, child) {
                  return value
                      ? SizedBox(
                          width: 56.0,
                          height: 56.0,
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              child: Icon(
                                Icons.close,
                                color: theme.textTheme.bodySmall?.color ?? Colors.black54,
                              ),
                              onTap: () {
                                closeButtonVisibility.value = false;
                                textEditingController.clear();
                              },
                            ),
                          ),
                        )
                      : Container();
                })
          ],
        ),
      ),
    );
  }
}
