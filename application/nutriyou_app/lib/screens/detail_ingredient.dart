import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nutriyou_app/models/ingredientDetailModel.dart';
import 'package:nutriyou_app/screens/view_ingredients.dart';
import '../const.dart';

class DetailIngredient extends StatefulWidget {
  final int idIngrediente;
  final Future<IngredientDetailModel> ingredientDetailModel;

  const DetailIngredient({Key key, @required this.idIngrediente, this.ingredientDetailModel}) : super(key: key);

  @override
  _DetailIngredientState createState() => _DetailIngredientState();
}

class _DetailIngredientState extends State<DetailIngredient> {

  Future<IngredientDetailModel> fetchIngredient(ingredienteId) async {
    var url_mealsearch = link('recipe/fetch_ingredient.php');
    var data = {'ingrediente_id' : ingredienteId};
    
    var response = await http.post(Uri.parse(url_mealsearch), body: json.encode(data));
    

    if (response.statusCode == 200){
      if(response.body.contains("No Results Found")){
      }else{
        final ingredientDetailModel = ingredientDetailModelFromJson(response.body);
        return ingredientDetailModel;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle("Detalhes do ingrediente"),
        backgroundColor: Colors.transparent,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          physics: BouncingScrollPhysics(),
          child: FutureBuilder<IngredientDetailModel>(
            future: fetchIngredient(widget.idIngrediente),
            builder: (context, snapshot){
              if(snapshot.hasData){
                if(snapshot.data.message == "Ingrediente retornado com sucesso."){
                  var data = snapshot.data.data;
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 25),
                        child: Text(data.ingredientesDesc, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
                      Text("Porção de"),
                      Text(data.ingredientesBaseQtd.toString() + data.ingredientesBaseUnity),
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.23,
                              child: Column(
                                children: [
                                  Text("Calorias"),
                                  Text(data.energyKcal.toStringAsFixed(0))
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.23,
                              child: Column(
                                children: [
                                  Text("Carb"),
                                  Text(data.carbohydrateQtd.toStringAsFixed(0) + data.carbohydrateUnit)
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.23,
                              child: Column(
                                children: [
                                  Text("Gorduras"),
                                  Text(data.lipidQtd.toStringAsFixed(0) + data.lipidUnit)
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.23,
                              child: Column(
                                children: [
                                  Text("Proteínas"),
                                  Text(data.proteinQtd.toStringAsFixed(0) + data.proteinUnit)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }
              return CircularProgressIndicator();
            }
          )
        ),
      ),
    );
  }
}