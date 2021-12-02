import 'package:flutter/material.dart';
import 'package:nutriyou_app/router.dart' as router;
import 'package:nutriyou_app/routing_constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Named Routing',
        onGenerateRoute: router.generateRoute,
      initialRoute: LoginViewRoute,
    );
  }
}
