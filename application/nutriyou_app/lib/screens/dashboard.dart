import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/calendarModel.dart';
import 'package:nutriyou_app/models/daysCalendarModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Dashboard extends StatefulWidget {

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var _selectedDay = DateTime.now();
  var _focusedDay = DateTime.now();

  Future<CalendarModel> fetchEvents() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var usuario_id = prefs.getInt('id');

    var url = link("dashboard/fetchcalendar.php");

    var data = {'usuario_id': usuario_id};

    var response = await  http.post(Uri.parse(url), body: json.encode(data));
    if(response.statusCode == 200){
      final calendarModel = calendarModelFromJson(response.body);
      return calendarModel;
    }else{
      throw Exception('Falha ao carregar');
    }
  }

   Future<DaysCalendarModel> fetchDays() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var usuario_id = prefs.getInt('id');

    var url = link("dashboard/listdays.php");

    var data = {'usuario_id': usuario_id};

    var response = await  http.post(Uri.parse(url), body: json.encode(data));
    print(data);
    if(response.statusCode == 200){
      final message = daysCalendarModelFromJson(response.body);
      return message;
    }else{
      throw Exception('Falha ao carregar');
    }
  }

  filterDatas(DateTime dtpfiltrar){


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<CalendarModel>(
                future: fetchEvents(),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    var data = snapshot.data.data;
                    var lista = data.detalhes.map((e) => e.data).toList();
                    var indexofselectedday = data.detalhes.indexWhere((element) => element.data.day == _selectedDay.day);
                    return Column(
                      children: [
                        TableCalendar(
                          locale: 'pt_BR',
                          eventLoader: (day) => lista.where((event) => isSameDay(event,day)).toList(), //THIS IS IMPORTANT
                          firstDay: DateTime(2021),
                          lastDay: DateTime(2050),
                          calendarFormat: CalendarFormat.month,
                          calendarBuilders: CalendarBuilders(
                            singleMarkerBuilder: (context, date, event){
                              var comp = data.detalhes.indexWhere((element) => element.data.day == date.day);
                              var cor = data.detalhes;
                              if(cor[comp].classcolor == 'green'){
                                return Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                );
                              }else if (cor[comp].classcolor == 'red'){
                                return Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                );
                              }
                              return Container(
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              );
                            }
                          ),
                          availableCalendarFormats: const{
                            CalendarFormat.month: "Mês"
                          },
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay; // update `_focusedDay` here as well
                            });
                          },
                          calendarStyle: CalendarStyle(
                            selectedTextStyle: const TextStyle(color: Colors.white),
                            isTodayHighlighted: true,
                            selectedDecoration: BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle
                            )
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 25),
                          child: 
                            _selectedDay == _focusedDay 
                              && 
                             indexofselectedday  != -1
                            ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Limite de\ncalorias"),
                              Text(data.detalhes[indexofselectedday].udcKcal.toString()),
                              Text("Calorias \ningeridas"),
                              Text(data.detalhes[indexofselectedday].udmKcal.toStringAsFixed(0)),
                            ]
                          ):null
                        )
                      ],
                    );
                  }
                  return CircularProgressIndicator();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}