import 'package:flutter/material.dart';
import 'package:nutriyou_app/routing_constants.dart';
import 'package:nutriyou_app/screens/eu.dart';
import 'package:nutriyou_app/screens/meal_search.dart';
import 'package:nutriyou_app/screens/myappbar.dart';
import 'package:nutriyou_app/screens/login.dart';
import 'package:nutriyou_app/screens/register.dart';
import 'package:nutriyou_app/undefined_view.dart';

Route<dynamic> generateRoute(RouteSettings settings){
  switch (settings.name){
    case LoginViewRoute:
      //var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => LoginUser());
    case RegisterViewRoute:
      //var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => RegisterUser());
    case HomeViewRoute:
      return MaterialPageRoute(builder: (context) => MyAppBar());
    case MeViewRoute:
      return MaterialPageRoute(builder: (context) => MeView());
    case MealSearchRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => MealSearch(idRefeicao: argument,));
    case MealsDetailsRoute:
      return MaterialPageRoute(builder: (context) => MealSearch());
    default:
      return MaterialPageRoute(builder: (context) => UndefinedView(name: settings.name,));

  }
}