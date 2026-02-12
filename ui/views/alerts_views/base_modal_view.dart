import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/services/base_view_service.dart';
import 'package:onetwotrail/repositories/viewModels/base_modal_model.dart';
import 'package:onetwotrail/ui/widgets/draggable_searchable_list_view.dart';
import 'package:onetwotrail/utils/base_view_provider.dart';
import 'package:provider/provider.dart';

class BaseModal extends StatelessWidget {
  final Widget principalView;
  final Widget alertView;

  const BaseModal(this.principalView, this.alertView, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var alert = Provider.of<BaseView>(context);
    alert.visible = false;
    alert.loading = false;
    alert.pushNotification = false;
    alert.showBottomSheet = false;
    return ChangeNotifierProxyProvider<BaseViewService, BaseModalModel>(
        create: (_) => BaseModalModel(),
        update: (_, baseViewService, model) {
          if (model == null) {
            return BaseModalModel()..baseViewService = baseViewService;
          }
          return model..baseViewService = baseViewService;
        },
        child: Consumer<BaseModalModel>(builder: (context, model, _) {
          return Stack(
            children: <Widget>[
              principalView,
              alert.visible
                  ? alert.loading
                      ? Container(
                          color: Colors.black45,
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ))
                      : alert.pushNotification
                          ? Container()
                          : alert.showBottomSheet
                              ? const DraggableSearchableListView(key: Key('searchable_list'))
                              : alertView
                  : Container()
            ],
          );
        }));
  }
}
