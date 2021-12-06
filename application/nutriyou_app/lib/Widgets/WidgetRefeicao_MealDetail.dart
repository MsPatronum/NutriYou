import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:nutriyou_app/app_colors.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/screens/recipe_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetReceicao_MealDetails extends StatefulWidget {
  final String nomeReceita;
  final int codReceita;
  final int udmId;
  final int codRefeicao;
  final bool delBtn;
  final String tipoAlimento;
  final String dieta;
  final String kCal;
  const WidgetReceicao_MealDetails({ 
  this.nomeReceita, 
  this.codReceita, 
  this.udmId,
  this.codRefeicao, 
  this.delBtn, 
  this.tipoAlimento, 
  this.dieta, 
  this.kCal });

  @override
  _WidgetReceicao_MealDetailsState createState() => _WidgetReceicao_MealDetailsState();
}



  Future removeOfMeal(int refeicaoId, int codReceita, int udmId) async {
    var url_removereceita = link('day/remove_recipeofmeal.php');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    String datem = DateFormat("yyyy-MM-dd").format(DateTime.now().toUtc());


    // Navigator.pop(context);

    var data = {'user_id' : userId, 'refeicao_id' : refeicaoId, 'udmId': udmId, 'cod_receita': codReceita, 'data': datem};
    print(data);

    var response = await http.post(Uri.parse(url_removereceita), body: json.encode(data));
    print(response.body);

    return _returnFlutterToast();

  }

class _WidgetReceicao_MealDetailsState extends State<WidgetReceicao_MealDetails> {

  @override
  Widget build(BuildContext context) {

    return Positioned(
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 0),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 20,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15))
                  ),
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    margin: EdgeInsets.only(left: 20),
                    child: Stack(
                      children: [
                        Container(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                  text: widget.nomeReceita),
                            )
                        ),
                        Spacer(),
                        Container(
                            margin: EdgeInsets.only(top: 55),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    color: Colors.grey.shade200,
                                    height: 25,
                                    padding: EdgeInsets.all(2),
                                    child: Center(
                                      child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.w700
                                            ),
                                            text: widget.dieta,
                                          )
                                      ),
                                    ),
                                  ),
                                ),
                                Container(width: 5,),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    color: Colors.grey.shade300,
                                    height: 25,
                                    child: Center(
                                      child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.w700
                                            ),
                                            text: transformToNoDecimal(widget.kCal.toString())+"kcal",
                                          )
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        )
                      ],
                    )
                ),
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.only(right: 3),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                    color: AppColors.bntFundoVerde
                ),
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(Icons.remove_red_eye_rounded),
                  color: AppColors.bntTextoVerde,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  RecipeView(idRefeicao: widget.codReceita,)));
                    },
                ),
              ),
              Visibility(
                visible: widget.delBtn,
                child: Container(
                  transformAlignment: Alignment.center,
                  margin: EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                      color: AppColors.lightPink
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.delete_rounded),
                    color: Colors.pink,
                    onPressed: (){
                        setState(() {
                            removeOfMeal(widget.codRefeicao, widget.codReceita, widget.udmId);
                          }
                        );
                      },
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}

Future _returnFlutterToast() {
  return Fluttertoast.showToast(
      msg: "Receita removida da sua refeição com sucesso!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.teal.shade50,
      textColor: Colors.teal
  );
}