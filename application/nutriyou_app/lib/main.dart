import 'package:flutter/material.dart';
import 'package:nutriyou_app/router.dart' as router;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:nutriyou_app/routing_constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
        supportedLocales: [const Locale('pt', 'BR')],
        title: 'Named Routing',
        onGenerateRoute: router.generateRoute,
      initialRoute: LoginViewRoute,
    );
  }
}
