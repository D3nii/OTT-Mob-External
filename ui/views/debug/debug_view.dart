import 'package:flutter/material.dart';
import 'package:onetwotrail/repositories/viewModels/debug_view_model.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';
import 'package:provider/provider.dart';

class DebugView extends StatelessWidget {
  const DebugView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DebugViewModel>(
      create: (_) => DebugViewModel(),
      child: Consumer<DebugViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                ListView(
                  children: [
                    Container(height: MediaQuery.of(context).size.height * 0.12),
                    UIHelper.verticalSpace(20),
                    _buildInfoSection(context),
                    UIHelper.verticalSpace(30),
                    _buildDebugToolsSection(context, model),
                    UIHelper.verticalSpace(100),
                  ],
                ),
                _buildAppBar(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    Size mediaQuery = MediaQuery.of(context).size;
    MediaQueryData data = MediaQuery.of(context);
    
    return Container(
      height: mediaQuery.height * 0.12 + data.padding.top,
      width: double.infinity,
      child: Container(
        height: mediaQuery.height * 0.12 + data.padding.top,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: mediaQuery.height * 0.12 + data.padding.top,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tomato, Color(0xFFFF6B35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Column(
              children: [
                Container(height: data.padding.top),
                Container(
                  height: mediaQuery.height * 0.12,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      UIHelper.horizontalSpace(mediaQuery.width * 0.053),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DEBUG TOOLS",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Development & Staging",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFFFE69C)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Color(0xFF856404)),
                UIHelper.horizontalSpace(12),
                Expanded(
                  child: Text(
                    "This debug panel provides tools for testing various app integrations "
                    "and functionality. Only available in development and staging environments.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF856404),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugToolsSection(BuildContext context, DebugViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Error Reporting Tests",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          UIHelper.verticalSpace(16),
          _buildDebugButton(
            context,
            "Flutter Framework Error",
            "Triggers a widget build error",
            Icons.widgets,
            tomato,
            () => model.triggerFlutterError(),
          ),
          UIHelper.verticalSpace(12),
          _buildDebugButton(
            context,
            "Dart Runtime Error",
            "Triggers a null pointer exception",
            Icons.code,
            Color(0xFFE91E63),
            () => model.triggerRuntimeError(),
          ),
          UIHelper.verticalSpace(12),
          _buildDebugButton(
            context,
            "Manual Error Report",
            "Reports a custom error with context",
            Icons.bug_report,
            Color(0xFF9C27B0),
            () => model.triggerManualError(),
          ),

        ],
      ),
    );
  }

  Widget _buildDebugButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, size: 24),
            UIHelper.horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  UIHelper.verticalSpace(4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
