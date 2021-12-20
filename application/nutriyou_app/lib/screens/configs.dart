import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/calendarModel.dart';
import 'package:nutriyou_app/models/daysCalendarModel.dart';
import 'package:nutriyou_app/models/getConfigs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewConfigs extends StatefulWidget {
  @override
  _ViewConfigsState createState() => _ViewConfigsState();
}

class _ViewConfigsState extends State<ViewConfigs> {

  Future<ConfigModel> configs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var usuarioId = prefs.getInt('id');

    var url = link("configs/getconfigs.php");

    var data = {'usuario_id': usuarioId };

    var response = await  http.post(Uri.parse(url), body: json.encode(data));
    if(response.statusCode == 200){
      final calendarModel = configModelFromJson(response.body);
      return calendarModel;
    }else{
      throw Exception('Falha ao carregar');
    }
  }
  Future<ConfigModel> setConfig(perm) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var usuarioId = prefs.getInt('id');

    var url = link("configs/setconfigs.php");

    var data = {'usuario_id': usuarioId, 'perm': perm};

    var response = await  http.post(Uri.parse(url), body: json.encode(data));
    print(response.body);
    if(response.statusCode == 200){
      final calendarModel = configModelFromJson(response.body);
      return calendarModel;
    }else{
      throw Exception('Falha ao carregar');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle("Configurações"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:  GestureDetector(
            onTap: () {
                Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.black,
                size: 30,
              ),
            )

        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              FutureBuilder<ConfigModel>(
                future: configs(),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    bool isSwitched = snapshot.data.data.usuarioPermitProfissional == 1? true : false;
                    return Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text("Permitir que profissionais de saúde me adicionem em sua lista de pacientes", softWrap: true,),
                        ),
                        Switch(
                          value: isSwitched,
                          onChanged: (value) {
                            setConfig(value == true? 1: 0);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(name: '/view_configs'),
                                builder: (BuildContext context){
                                  return ViewConfigs();
                                }
                              ),
                            );
                          },
                          activeTrackColor: Colors.teal,
                          activeColor: Colors.teal.shade800,
                        ),
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

buildTitle(String text){
  return Padding(
    padding: EdgeInsets.all(8),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.black,
        fontSize: 22,
      ),
    ),
  );
}