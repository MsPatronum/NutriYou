import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nutriyou_app/models/calendarModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../const.dart';

class ViewDashboardDetails extends StatefulWidget {
  const ViewDashboardDetails({Key key, this.dateFilter}) : super(key: key);
  final DateTime dateFilter;
  @override
  _ViewDashboardDetailsState createState() => _ViewDashboardDetailsState();
  
}

class _ViewDashboardDetailsState extends State<ViewDashboardDetails> {
  Future<CalendarModel> fetchEvents(DateTime date) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var usuario_id = prefs.getInt('id');

    var url = link("dashboard/listcalendar.php");

    var data = {'usuario_id': usuario_id};

    var response = await  http.post(Uri.parse(url), body: json.encode(data));
    print(data);
    if(response.statusCode == 200){
      final message = calendarModelFromJson(response.body);
      return message;
    }else{
      throw Exception('Falha ao carregar');
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot){
        return Container(
        );
      }
    );
  }
}