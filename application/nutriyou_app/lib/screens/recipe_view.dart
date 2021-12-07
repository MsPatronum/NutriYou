import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:nutriyou_app/app_colors.dart';
import 'package:nutriyou_app/const.dart';
import 'package:http/http.dart' as http;
import 'package:nutriyou_app/models/recipeViewModel.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RecipeView extends StatefulWidget {
  const RecipeView({Key key, this.idRefeicao, this.recipeView}) : super(key: key);

  @override
  _RecipeViewState createState() => _RecipeViewState();

  final int idRefeicao;
  final Future<RecipeView> recipeView;
}

class _RecipeViewState extends State<RecipeView> {
  bool like = false;
  bool dislike = false;

  var recipeviewlink = link('recipe/recipe_view.php');

  Future<RecipeViewModel> fetchRecipe(int receita_id) async {

    var data = {'receita_id': receita_id};

    var response = await http.post(Uri.parse(recipeviewlink), body: json.encode(data));
    if (response.statusCode == 200) {

        final recipeView = recipeViewModelFromJson(response.body);
        //print(response.body);
        return recipeView;
    }
    else {
      throw Exception('Failed to load data from Server.');
    }
  }

  /*Future likeDislikeHandler(String option, int receita_id) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    var data = {'receita_id': receita_id, 'option': option, 'userId': userId};

    var response = await http.post(Uri.parse(link('recipe/likeDislike.php')), body: json.encode(data));
    if (response.statusCode == 200) {


    }else {
      throw Exception('Failed to load data from Server.');
    }
    


  }*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        elevation: 0,
        leading: GestureDetector(
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
        /*actions: [
          FutureBuilder( future: likeDislikeHandler('like', 1),
          builder: (context, snapshot){
            return Container(
                margin: EdgeInsets.only(right: 15),
                child: IconButton(
                  icon: Icon(
                    like ? (){dislike = false; return Icons.thumb_up;}() : Icons.thumb_up_outlined,
                    size: 30,
                    color: Colors.teal,
                  ),
                  onPressed: (){
                    setState(() {
                      like = !like;
                      if (dislike == true){
                        dislike = !dislike;
                      }
                    });
                  },
                ),
              );

          }),
          Row( 
            children: [
              Container(
                margin: EdgeInsets.only(right: 15),
                child: IconButton(
                  icon: Icon(
                    like ? (){dislike = false; return Icons.thumb_up;}() : Icons.thumb_up_outlined,
                    size: 30,
                    color: Colors.teal,
                  ),
                  onPressed: (){
                    setState(() {
                      like = !like;
                      if (dislike == true){
                        dislike = !dislike;
                      }
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 15),
                child: IconButton(
                  icon: Icon(
                    dislike ? (){like = false; return Icons.thumb_down;}() : Icons.thumb_down_outlined,
                    size: 30,
                    color: Colors.teal,
                  ),
                  onPressed: (){
                    setState(() {
                      dislike = !dislike;
                      if (like == true){
                        like = !like;
                      }
                    });
                  },
                ),
              )
          ],)
        ],*/
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child:FutureBuilder<RecipeViewModel>(
          future: fetchRecipe(1),
            builder: (context, snapshot){
              if(snapshot.hasData){
                List<String> imageList = [linkImages('recipepics/rec1_pic1.jpg'), linkImages('recipepics/rec1_pic2.jpg')];
              var infoReceita = snapshot.data.infoReceita;
              var ingredientesReceita = snapshot.data.ingredientes;
              var passosReceita = snapshot.data.passos;
              var s = infoReceita.receitaTempoPreparo;
              var porcao = infoReceita.receitaPorcoes > 1 ? ' porções' : ' porção';
              TimeOfDay _startTime = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));
              print (_startTime);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [                
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: buildRecipeTitle(infoReceita.receitaNome)),
                        Center(child: buildRecipeSubTitle(infoReceita.receitaDesc ),),
                        SizedBox(
                          height: 16,
                        ),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Rendimento",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15
                                    ),
                                  ),
                                  Text(infoReceita.receitaPorcoes.toString() + porcao),
                                ],
                              ),
                              VerticalDivider(
                                color: Colors.teal,
                                thickness: 2,
                              ),
                              Column(
                                children: [
                                Text(
                                  "Tempo de Preparo",
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15
                                  ),
                                ),
                                Text(_startTime.hour.toString() + "h " + _startTime.minute.toString() + "m"),
                                ],
                              ),
                              /*VerticalDivider(
                                color: Colors.teal,
                                thickness: 2,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Avaliação",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15
                                    ),
                                  ),
                                  RatingBarIndicator(
                                    rating: infoReceita.aval,
                                    itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: AppColors.defaultGreen,
                                    ),
                                    itemCount: 5,
                                    itemSize: 18.0,
                                    direction: Axis.horizontal,
                                  ),
                                ],
                              )*/
                            ],
                          ),
                        )
                      ],
                    ),
                  ),                  
                  SizedBox(
                    height: 26,
                  ),
                  Container(
                    height: 350,
                    padding: EdgeInsets.only(left: 16),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildTitleText('Info. Nutricional'),
                              buildNutrition(
                                int.parse(infoReceita.energyKcal.toStringAsFixed(0)), 
                                "Calorias", 
                                "Kcal"
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              buildNutrition(
                                int.parse(infoReceita.carbohydrateQtd.toStringAsFixed(0)), 
                                "Carbs", 
                                infoReceita.carbohydrateUnit
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              buildNutrition(
                                int.parse(infoReceita.proteinQtd.toStringAsFixed(0)), 
                                "Proteina", 
                                infoReceita.proteinUnit
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              buildNutrition(
                                int.parse(infoReceita.lipidQtd.toStringAsFixed(0)),  
                                "Gordura", 
                                infoReceita.lipidUnit
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            child: Container(
                              height: 330,
                              width: MediaQuery.of(context).size.width*0.5,
                              margin: EdgeInsets.all(15),
                              child: CarouselSlider.builder(
                                itemCount: snapshot.data.imagens.length,
                                options: CarouselOptions(
                                  enlargeCenterPage: true,
                                  disableCenter: false,
                                  height: 350,
                                  autoPlay: false,
                                  reverse: false,
                                  aspectRatio: 5.0,
                                ),
                                itemBuilder: (context, i, id){
                                  List<Imagem> imagem = snapshot.data.imagens ?? [];
                                  print(imagem[i].receitaImagensPath);
                                  //for onTap to redirect to another screen
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      linkImages(imagem[i].receitaImagensPath),
                                    fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),                            
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 80, top: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTitleText('Ingredientes',),
                          ListView.builder(
                            itemCount: ingredientesReceita.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index){
                              List<Ingrediente> ingrediente = ingredientesReceita ?? [];
                              var qtd = ingredientesReceita.single.receitaIngredientesQtd * ingredientesReceita.single.ingredientesBaseQtd;
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                child: buildTextIngredient(
                                  qtd.toString(), 
                                  ingrediente[index].ingredientesBaseUnity, 
                                  ingrediente[index].ingredientesDesc
                                )
                              );
                            }
                          ),

                          SizedBox(height: 25,),

                          buildTitleText('Modo de Preparo', ),
                          
                          ListView.builder(
                            itemCount: passosReceita.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index){
                              List<Passo> passos = passosReceita ?? [];
                              return Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildTextStep("PASSO " + passos[index].rpNumero.toString()),
                                    Text(
                                      passos[index].rpDesc, 
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey.shade700, 
                                      ),
                                    ),
                                    SizedBox(height: 15,)
                                  ],
                                ),
                                  
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }else{
                return CircularProgressIndicator();
              }
            }
          ),
      ),
    );
  }

  Widget buildNutrition(int value, String title, String subTitle){
    return Container(
      height: 60,
      width: 150,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.all(
          Radius.circular(50),
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
            height: 44,
            width: 44,
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
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(
            width: 20,
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),

              Text(
                subTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade50,
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

}

buildTextStep(String text){
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: IntrinsicWidth(
      child: Container(
          height: 35,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.teal,
            borderRadius: BorderRadius.circular(7)
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          )
      ),
    )
  );
}

buildTextIngredient(String qtd, String medida, String nome){
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 45,
          height: 30,
          decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(7)
          ),
          child: Center(
            child: Text(
              qtd,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          margin: EdgeInsets.only(right: 15),
        ),
        Expanded(child: 
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.grey.shade700,
            ),
            children: [
              TextSpan(text: medida),
              TextSpan(text: ' de '),
              TextSpan(text: nome)
            ]
          )
          ),
        ),
      ],
    )
  );
}

buildTextSubTitleVariation2(String text){
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[400],
      ),
    ),
  );
}

buildRecipeTitle(String text){
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

buildTitleText(String text){
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

buildRecipeSubTitle(String text){
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
      ),
    ),
  );
}

buildCalories(String text){
  return Text(
    text,
    style: TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  );
}



