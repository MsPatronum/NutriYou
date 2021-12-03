import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:nutri_app/Pages/meal_search.dart';
import 'package:nutriyou_app/Widgets/WidgetRefeicao_MealDetail.dart';
import 'package:http/http.dart' as http;
import 'package:nutriyou_app/app_colors.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/itensRefeicao.dart';
import 'package:nutriyou_app/models/mealListModel.dart';
import 'package:nutriyou_app/models/mealsModel.dart';
import 'package:nutriyou_app/screens/add_recipe.dart';
import 'package:nutriyou_app/screens/meal_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routing_constants.dart';

class MealDetail extends StatefulWidget {
  @override
  _MealDetailState createState() => _MealDetailState();


  const MealDetail({Key key,
    this.userId,
    this.nomeRefeicao,
    this.data,
    this.imagem,
    this.corFundoIcon,
    this.idRefeicao,
    this.meallist,
  }) : super(key: key);
  final int userId;
  final String nomeRefeicao;
  final DateTime data;
  final String imagem;
  final Color corFundoIcon;
  final int idRefeicao;
  final Future<List<ItensRefeicao>> meallist;
}
class _MealDetailState extends State<MealDetail> {

  String datem = DateFormat("yyyy-MM-dd").format(DateTime.now().toUtc());

  var urlbuscadetalhesrefeicao = link('day/fetch_meals_meal.php');

  Future fetchMealList(int refeicaoCod, DateTime date) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    String datem = DateFormat("yyyy-MM-dd").format(date);
    var data = {'user_id': userId, 'date' : datem, 'refeicao_cod': widget.idRefeicao};

    var response = await http.post(Uri.parse(urlbuscadetalhesrefeicao), body: json.encode(data));
    if (response.statusCode == 200) {
        final message = ItensRefeicao.fromJson(json.decode(response.body));
            List itensRefeicao = message?.data?.toList();
            print(itensRefeicao);
            return itensRefeicao;
          
         // return (itensRefeicao as Map);
      }
    else {
      throw Exception('Failed to load data from Server.');
    }
  }
  Future fetchMealDetails(int refeicaoCod, DateTime date) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    String datem = DateFormat("yyyy-MM-dd").format(date);
    var data = {'user_id': userId, 'date' : datem, 'refeicao_cod': widget.idRefeicao};

    var response = await http.post(Uri.parse(urlbuscadetalhesrefeicao), body: json.encode(data));
    if (response.statusCode == 200) {
        final message = ItensRefeicao.fromJson(json.decode(response.body));
        return message;
         // return (itensRefeicao as Map);
      }
    else {
      throw Exception('Failed to load data from Server.');
    }
  }
  _refreshAction() {
    setState(() {
    });
  }
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.post_add),
          label: Text(
            "Sua receita",
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => new AddRecipe())
            );
          },
          backgroundColor: AppColors.defaultGreen,
        ),
        body: SafeArea( 
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
          child: Stack(
            children: [
              CustomPaint(
                painter: BoxShadowPainter(),
                child: ClipPath(
                  clipper: BezierClipper(),
                  child: Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15,bottom: 10),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_rounded, size: 30,),
                            color: Colors.grey.shade800,
                            onPressed: (){
                              setState(() {
                                Navigator.pop(context);
                              });
                            },

                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                              color: widget.corFundoIcon,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: widget.corFundoIcon, width: 5.0)),
                          child: Image(
                            image: AssetImage("images/" + widget.imagem),
                            color: Colors.white,
                            width: 80,
                            height: 80,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 15, bottom: 25, right: 20),
                            child: RichText(
                              overflow: TextOverflow.clip,
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                  text: widget.nomeRefeicao
                              ),
                            ),
                          ),
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
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 150),
                child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                            children:[
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      )
                                    ]
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                child: Column(
                                    children: [
                                      Text("Total de calorias da refeição:",),
                                      FutureBuilder(
                                        future: fetchMealDetails(widget.idRefeicao, widget.data),
                                        builder: (context, snapshotMealList){
                                          if(snapshotMealList.hasData){
                                            double soma = 0;
                                            // for (int i = 0; snapshotMealList.data.length > i; i++){
                                            //   //soma = soma + snapshotMealList.data[i].refeicaoKcal;
                                            // }
                                            return Text(
                                              soma.toStringAsFixed(0) + " kCal",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700,
                                              ),
                                            );
                                          }else if(snapshotMealList.hasError){
                                            return Text(
                                              "0" + " kCal",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700,
                                              ),
                                            );
                                          }
                                          print(snapshotMealList.connectionState.toString());
                                          return CircularProgressIndicator();
                                        },
                                      ),
                                    ]
                                ),
                              ),
                            ]
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                enableFeedback: true,
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                padding: MaterialStateProperty.all(EdgeInsets.zero),
                                shadowColor: MaterialStateProperty.all(Colors.transparent),
                              ),
                              onPressed: (){
                                Navigator.pushNamed(context, MealSearchRoute, arguments: widget.idRefeicao);
                              },
                              child: Container(
                                height: 50,
                                width: 140,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.bntFundoVerde,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  boxShadow: [BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: Offset(0, 0),
                                  )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 33,
                                      width: 33,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: Offset(0, 0),
                                        )],
                                      ),
                                      child: Center(
                                        child: Icon( Icons.add_circle, color: AppColors.defaultGreen,),
                                      ),
                                    ),

                                    SizedBox(
                                      width: 10,
                                    ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Adicionar",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800
                                          ),
                                        ),
                                        Text(
                                          "mais alimentos",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 230, left: 15, right: 15),
                child:
                    FutureBuilder(
                      future: fetchMealList(widget.idRefeicao, widget.data),
                      builder: (context, snapshotMealList){
                        if(snapshotMealList.hasData){
                          List<Data> data = snapshotMealList.data ?? [];
                          if(snapshotMealList.data.length > 0){
                            return Container(
                                height: 500,
                                child: ListView.builder(
                                    itemCount: data.length,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (BuildContext context, int index) {
                                      return WidgetRefeicao_MealDetails(
                                            NomeRefeicao: data[index].receitaNome,
                                            TipoAlimento: "",
                                            CodRefeicao: data[index].receitaId,
                                            kCal: data[index].receitaKcal.toStringAsPrecision(3),
                                            DelBtn: true, 
                                            Dieta: '',
                                      );
                                    }
                                )
                            );
                          }else{
                            return Center(
                              child: Container(
                                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                                child: Text(
                                  "Ainda não há nada aqui",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                )
                              )
                            );
                          }
                        }else if(snapshotMealList.hasError){
                          return Center(
                              child: Container(
                                  child: Text(
                                    "Ainda não há nada aqui",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  )
                              )
                          );
                        }else if(snapshotMealList.hasData == false){
                          return Center(
                              child: Container(
                                  child: Text(
                                    "Ainda não há nada aqui",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  )
                              )
                          );
                        }
                        print(snapshotMealList.connectionState.toString());
                        return CircularProgressIndicator();
                      },
                    ),


              )
            ],
          ),
        )
      )
    );
  }

  _verificaReceitas(){
    Future.delayed(Duration.zero, (){
          return Container(
            child: Text("Ainda não há nada aqui"),
          );
        },
        );
    }

}


class BezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0, size.height * 0.85); //vertical line
    path.quadraticBezierTo(size.width / 2, size.height, size.width,
        size.height * 0.85); //quadratic curve
    path.lineTo(size.width, 0); //vertical line
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class BoxShadowPainter extends CustomPainter {
  @override
  Path paint(Canvas canvas, Size size) {
    Path path = new Path();
    path.lineTo(0, size.height * 0.85); //vertical line
    path.quadraticBezierTo(size.width / 2, size.height, size.width,
        size.height * 0.85); //quadratic curve
    path.lineTo(size.width, 0); //vertical line

    canvas.drawShadow(path, Colors.black38, 6.0, false);
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
