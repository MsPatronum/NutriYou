import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/recipeAddModel.dart';
import 'package:nutriyou_app/models/recipeIngredientsModel.dart';
import 'package:nutriyou_app/routing_constants.dart';
import 'package:nutriyou_app/screens/add_ingredients.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewIngredients extends StatefulWidget {
  //const AddRecipe({ Key? key }) : super(key: key);

  @override
  _ViewIngredientsState createState() => _ViewIngredientsState();
}

class _ViewIngredientsState extends State<ViewIngredients> {
  final _formKey = GlobalKey<FormState>();
  var _recipeNameController = TextEditingController();
  var _recipeDescController = TextEditingController();
  int _nivel = 0;
  var _recipeHourController = TextEditingController();
  var _recipeMinController = TextEditingController();
  var _recipePortionController = TextEditingController();
  int _privacidade;

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle("Adicione os ingredientes"),
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
                              //print(ModalRoute.of(context).settings.name);
                              //addRecipe();
                            
                              //Navigator.of(context).popUntil(ModalRoute.withName(HomeViewRoute));
                            },
                            child: Row(
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