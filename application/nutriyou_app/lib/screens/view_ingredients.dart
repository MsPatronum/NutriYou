import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/recipeIngredientViewModel.dart';
import 'package:nutriyou_app/models/recipeIngredientsModel.dart';
import 'package:nutriyou_app/screens/add_ingredients.dart';
import 'package:nutriyou_app/screens/detail_ingredient.dart';
import 'package:nutriyou_app/screens/view_steps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewIngredients extends StatefulWidget {
  //const AddRecipe({ Key? key }) : super(key: key);

  @override
  _ViewIngredientsState createState() => _ViewIngredientsState();
}

class _ViewIngredientsState extends State<ViewIngredients> {

  Future<IngredienteReceitaModel> fetchIngredients() async {
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id');
    var receitaId = prefs.getInt('receita_id');

    var url = link("recipe/fetch_recipe_ingredients.php");

    var data = {'usuario_id': userId, 'receita_id': receitaId};

    var response = await  http.post(url, body: json.encode(data));
    print(data);
    if(response.statusCode == 200){
      var message = ingredienteReceitaModelFromJson(response.body);
      return message;
    }else{
      throw Exception('Falha ao carregar');
    }
    
    
  }

  Future <IngredienteRecipeViewModel> viewIngredients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var receitaId = prefs.getInt('receita_id');

    var url = link("recipe/fetch_list_ingredients_recipe.php");

    var data = {'receita_id': receitaId};

    var response = await  http.post(url, body: json.encode(data));

    print(data);
    if(response.statusCode == 200){
     final ingredienteRecipeViewModel = ingredienteRecipeViewModelFromJson(response.body);
      return ingredienteRecipeViewModel;
    }else{
      throw Exception('Falha ao carregar');
    }

  }

  Future removefromRecipe(int ingrediente_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var receitaId = prefs.getInt('receita_id');

    var url = link("recipe/remove_ingredient.php");

    var data = {'receita_id': receitaId, 'ingrediente_id': ingrediente_id};

    var response = await  http.post(url, body: json.encode(data));
  }

  Future removeRecipeId(int recipeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('receita_id');

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle("Adicione os ingredientes"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
            onTap: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
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
        child: 
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          physics: BouncingScrollPhysics(),
          child: FutureBuilder<IngredienteReceitaModel>(
            future: fetchIngredients(),
            builder: (context, snapshot){
              if(snapshot.hasData){
                var nulo = snapshot.data.data == null ? 0 :  snapshot.data.data;
                if(nulo != 0){
                    return Column(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            FutureBuilder<IngredienteRecipeViewModel>(
                              future: viewIngredients(),
                              builder: (context, snapshoting){
                                if(snapshoting.hasData){
                                  // ignore: unrelated_type_equality_checks
                                  if(snapshoting.data.message == 'Ingrediente retornado com sucesso.'){
                                    
                                    return Container(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        itemCount: snapshoting.data.data.length,
                                        itemBuilder: (BuildContext context, int index){
                                          var data = snapshoting.data.data;
                                          return Column(
                                            children: [
                                              Container(
                                                height: 50,
                                                margin: EdgeInsets.only(bottom: 15),
                                                padding: EdgeInsets.symmetric(horizontal: 15),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(15),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 0),
                                                    )
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: (){
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            settings: RouteSettings(name: '/ingredient_detail'),
                                                            builder: (BuildContext context) {
                                                              return new DetailIngredient(idIngrediente: data[index].ingredientesId,);
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.45,
                                                            child: Text(data[index].ingredientesDesc)
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.13,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text("Porção"),
                                                                Text(data[index].ingredientesBaseQtd.toString() + data[index].ingredientesBaseUnity)
                                                              ],
                                                            ),
                                                          ),
                                                          //VerticalDivider(thickness: 1,),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.12,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(data[index].energyKcal.toStringAsFixed(0)),
                                                                Text("Kcal"),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 0.09,
                                                      child: IconButton(
                                                        onPressed: (){
                                                          removefromRecipe(data[index].ingredientesId);
                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              settings: RouteSettings(name: '/view_ingredients'),
                                                              builder: (BuildContext context) {
                                                                return ViewIngredients();
                                                              },
                                                            ),
                                                          );
                                                        }, 
                                                        icon: Icon(Icons.delete_rounded), 
                                                        color: Colors.pink,
                                                      )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      ),
                                    );
                                  }else{
                                    return Container(
                                      child: Text(
                                        "Esta receita não tem nenhum ingrediente ainda. Adicione!", 
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18, 
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    );
                                  }
                                }
                                return CircularProgressIndicator();
                              }
                            ),
                          ],
                        )
                      ),
                      SizedBox(
                        height: 80,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.teal.shade300), 
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                )
                              ),
                              padding: MaterialStateProperty.all(EdgeInsets.all(12))
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(name: '/add_ingredients'),
                                  builder: (BuildContext context) {
                                    return IngredientAdd();
                                  },
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                Text(
                                  'Adicionar mais ingredientes', 
                                  style: TextStyle(
                                    color: Colors.white
                                  )
                                ),
                                Icon(
                                  Icons.add_rounded, 
                                  color: Colors.white,
                                )
                              ]
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal.shade300), 
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                            padding: MaterialStateProperty.all(EdgeInsets.all(12))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(name: '/view_steps'),
                                  builder: (BuildContext context) {
                                    return ViewSteps();
                                  },
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Text(
                                      'Próximo', 
                                      style: TextStyle(
                                        color: Colors.white
                                      )
                                    ),
                                    Icon(
                                      Icons.arrow_forward_outlined, 
                                      color: Colors.white,
                                    )
                                  ]
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }else{
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "Esta receita não tem nenhum ingrediente ainda. Adicione!", 
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 80,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.teal.shade300), 
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                )
                              ),
                              padding: MaterialStateProperty.all(EdgeInsets.all(12))
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(name: '/add_ingredients'),
                                  builder: (BuildContext context) {
                                    return new IngredientAdd();
                                  },
                                ),
                              );
                              //print(ModalRoute.of(context).settings.name);
                              //addRecipe();
                            
                              //Navigator.of(context).popUntil(ModalRoute.withName(HomeViewRoute));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                Text(
                                  'Adicionar', 
                                  style: TextStyle(
                                    color: Colors.white
                                  )
                                ),
                                Icon(
                                  Icons.add_rounded, 
                                  color: Colors.white,
                                )
                              ]
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
              return CircularProgressIndicator();
            }
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
buildTitleText(String text){
  return Container(
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
      ),
    ),
  );
}

Widget customTextFormField(label, hint, inputtype, controller, maxlength){
  return TextFormField(
    keyboardType: inputtype,
    autofocus: false,
    controller: controller,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (String value){
      if(value.isEmpty){
        return "Insira dados";
      }
        return null;
    },
    maxLength: maxlength,
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600,fontSize: 15),
      hintText: hint,
      contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
      border: UnderlineInputBorder(),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.teal.shade700,
          width: 2.0,
        ),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.teal,
        ),
      ),
    ),
  );
}