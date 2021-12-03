import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:nutriyou_app/Widgets/WidgetMacrosHomeLinearPercent.dart';
import 'package:nutriyou_app/Widgets/WidgetRefeicaoHome.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/macrosModel.dart';
import 'package:nutriyou_app/models/mealsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {

  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {


  var urlFetchday = link('day/fetch_day.php');
  var urlFetchMealsDay = link('day/fetch_meals_day.php');
  
Future<MacrosMessage> fetchMacros() async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('id');
  
  String datem = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var data = {'user_id': userId, 'date' : datem};
  var response = await http.post(urlFetchday, body: json.encode(data));

    if (response.statusCode == 200) {

      final message = MacrosMessage.fromJson(json.decode(response.body));

      return message;
    }
    else {
      throw Exception('Failed to load data from Server.');
    }
}

Future<ItensRefeicaoMessage> fetchMeals(int idrefeicao) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('id');
  
  String datem = DateFormat("yyyy-MM-dd").format(DateTime.now());

  var data = {'user_id': userId, 'date' : datem, 'refeicao_cod': idrefeicao};
  var response = await http.post(urlFetchMealsDay, body: json.encode(data));

    if (response.statusCode == 200) {
      
      final message = ItensRefeicaoMessage.fromJson(json.decode(response.body));
      print(message.error);
      return message;
    }
    else {
      throw Exception('Failed to load data from Server.');
    }
  
}
_refreshAction() {
  setState(() {
  });
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: new Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 15),
                height: MediaQuery.of(context).size.height/3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:[
                        FutureBuilder(
                          future: getNome(), 
                          builder: (context, snapshot){
                            if(snapshot.hasData){
                              return BodyText(texto: 'Bem vindo(a),  ${snapshot.data}', tamFonte: 20,);
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0), 
                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          ),
                          child: Icon(Icons.replay_outlined,color: Colors.teal,size: 35,),
                          onPressed: _refreshAction,
                        )
                      ],
                    ),
                    
                    FutureBuilder<MacrosMessage>(
                      future: fetchMacros(), 
                      builder: (context, macrossnapshot){
                        if(macrossnapshot.hasData){
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        height: 60,
                                        width: MediaQuery.of(context).size.width*0.40,
                                        child: WidgetMacros(
                                          tipoMacro: "Carboidratos",
                                          imagem: "",
                                          ml: false,
                                          porcentagem: calculatePercentage(macrossnapshot.data.data.configCarbsdia, macrossnapshot.data.data.userDiaCarbs),
                                          restante: subtraction(macrossnapshot.data.data.configCarbsdia, macrossnapshot.data.data.userDiaCarbs).toString(),
                                        ),
                                      ),
                                    ]
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children:[  
                                      Container(
                                        height: 60,
                                        width: MediaQuery.of(context).size.width*0.40,
                                        child: WidgetMacros(
                                          tipoMacro: "Proteínas",
                                          imagem: "",
                                          ml: false,
                                          porcentagem: calculatePercentage(
                                            macrossnapshot.data.data.configProtdia, 
                                            macrossnapshot.data.data.userDiaProt),
                                          restante: subtraction(macrossnapshot.data.data.configProtdia, macrossnapshot.data.data.userDiaProt).toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        height: 60,
                                        width: MediaQuery.of(context).size.width*0.40,
                                        child: WidgetMacros(
                                          tipoMacro: "Gorduras",
                                          imagem: "",
                                          ml: false,
                                          porcentagem: calculatePercentage(
                                            macrossnapshot.data.data.configGorddia,
                                            macrossnapshot.data.data.userDiaGord),
                                          restante: subtraction(
                                            macrossnapshot.data.data.configGorddia, 
                                            macrossnapshot.data.data.userDiaGord).toString()
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    child: BodyText(texto: "Você consumiu", tamFonte: 16,),
                                  ),
                                  Container(
                                    child: BodyText(texto: macrossnapshot.data.data.userDiaKcal.toStringAsFixed(0), tamFonte: 26,)
                                  ),
                                  Container(
                                    child: BodyText(texto: "de", tamFonte: 16,),
                                  ),
                                  Container(
                                    child: BodyText(texto: macrossnapshot.data.data.configKcaldia.toStringAsFixed(0), tamFonte: 26,)
                                  ),
                                  Container(
                                    child: BodyText(texto: "calorias hoje", tamFonte: 16,),
                                  ),
                                ],
                              )
                            ],
                          );
                        }
                        return CircularProgressIndicator();
                      } 
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Column(
                  children: [
                    FutureBuilder(
                      future: fetchMeals(1),
                      builder: (context, mealsnapshot){
                        if(mealsnapshot.hasData){
                          var receitas = mealsnapshot.data.data.receitasNome == null ? "Não há nada aqui." : mealsnapshot.data.data.receitasNome;
                          var kcal = mealsnapshot.data.data == null ? "0" : mealsnapshot.data.data.refeicaokcal ;
                          return WidgetRefeicao(
                            idRefeicao: 1,
                            corFundoIcon: Colors.teal.shade200,
                            imagem: "cafemanha.png",
                            nomeRefeicao: "Café da Manhã",
                            date: DateTime.now(),
                            userId: 1,
                            itensRefeicao: receitas.toString(),
                            qtdeCaloriasRefeicao: kcal.toString()
                          );
                        }
                        return CircularProgressIndicator();
                      }
                    ),
                    FutureBuilder(
                      future: fetchMeals(2),
                      builder: (context, mealsnapshot){
                        if(mealsnapshot.hasData){
                          var receitas = mealsnapshot.data.data.receitasNome == null ? "Não há nada aqui." : mealsnapshot.data.data.receitasNome;
                          var kcal = mealsnapshot.data.data == null ? "0" : mealsnapshot.data.data.refeicaokcal;
                          return WidgetRefeicao(
                            idRefeicao: 2,
                            corFundoIcon: Colors.teal.shade200,
                            imagem: "lanchemanha.png",
                            nomeRefeicao: "Lanche da Manhã",
                            date: DateTime.now(),
                            userId: 1,
                            itensRefeicao: receitas,
                            qtdeCaloriasRefeicao: kcal.toString()
                          );
                        }
                        return CircularProgressIndicator();
                      }
                    ),
                    FutureBuilder(
                      future: fetchMeals(3),
                      builder: (context, mealsnapshot){
                        if(mealsnapshot.hasData){
                          print(mealsnapshot.hasData);
                          var receitas = mealsnapshot.data.data.receitasNome == null ? "Não há nada aqui." : mealsnapshot.data.data.receitasNome;
                          var kcal = mealsnapshot.data.data == null ? "0" : mealsnapshot.data.data.refeicaokcal;
                          return WidgetRefeicao(
                            idRefeicao: 3,
                            corFundoIcon: Colors.teal.shade200,
                            imagem: "almoco.png",
                            nomeRefeicao: "Almoço",
                            date: DateTime.now(),
                            userId: 1,
                            itensRefeicao: receitas.toString(),
                            qtdeCaloriasRefeicao: kcal.toString()
                          );
                        }
                        return CircularProgressIndicator();
                      }
                    ),
                    FutureBuilder(
                      future: fetchMeals(4),
                      builder: (context, mealsnapshot){
                        if(mealsnapshot.hasData){
                          var receitas = mealsnapshot.data.data.receitasNome == null ? "Não há nada aqui." : mealsnapshot.data.data.receitasNome;
                          var kcal = mealsnapshot.data.data == null ? "0" : mealsnapshot.data.data.refeicaokcal;
                          return WidgetRefeicao(
                            idRefeicao: 4,
                            corFundoIcon: Colors.teal.shade200,
                            imagem: "lanchetarde.png",
                            nomeRefeicao: "Café da Tarde",
                            date: DateTime.now(),
                            userId: 1,
                            itensRefeicao: receitas.toString(),
                            qtdeCaloriasRefeicao: kcal.toString()
                          );
                        }
                        return CircularProgressIndicator();
                      }
                    ),
                    FutureBuilder(
                      future: fetchMeals(5),
                      builder: (context, mealsnapshot){
                        if(mealsnapshot.hasData){
                          var receitas = mealsnapshot.data.data.receitasNome == null ? "Não há nada aqui." : mealsnapshot.data.data.receitasNome;
                          var kcal = mealsnapshot.data.data == null ? "0" : mealsnapshot.data.data.refeicaokcal;
                          return WidgetRefeicao(
                            idRefeicao: 5,
                            corFundoIcon: Colors.teal.shade200,
                            imagem: "jantar.png",
                            nomeRefeicao: "Jantar",
                            date: DateTime.now(),
                            userId: 1,
                            itensRefeicao: receitas.toString(),
                            qtdeCaloriasRefeicao: kcal.toString()
                          );
                        }
                        return CircularProgressIndicator();
                      }
                    ),
                    FutureBuilder(
                      future: fetchMeals(6),
                      builder: (context, mealsnapshot){
                        if(mealsnapshot.hasData){
                          var receitas = mealsnapshot.data.data.receitasNome == null ? "Não há nada aqui." : mealsnapshot.data.data.receitasNome;
                          var kcal = mealsnapshot.data.data == null ? "0" : mealsnapshot.data.data.refeicaokcal;
                          return WidgetRefeicao(
                            idRefeicao: 6,
                            corFundoIcon: Colors.teal.shade200,
                            imagem: "lanchenoite.png",
                            nomeRefeicao: "Lanche da Noite",
                            date: DateTime.now(),
                            userId: 1,
                            itensRefeicao: receitas.toString(),
                            qtdeCaloriasRefeicao: kcal.toString()
                          );
                        }
                        return CircularProgressIndicator();
                      }
                    ),
                  ],
                )
              )
            ],
          )
        ) 
      );
  }
}