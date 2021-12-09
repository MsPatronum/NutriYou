import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/searchIngredientsModel.dart';
import 'package:nutriyou_app/screens/detail_ingredient.dart';
import 'package:nutriyou_app/screens/view_ingredients.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IngredientAdd extends StatefulWidget {
  final int idRefeicao;
  final int idUsuario;
  final Future<List<IngredienteModel>> ingredienteModel;
  IngredientAdd({Key key, this.ingredienteModel, this.idRefeicao, this.idUsuario}) : super(key: key);

  @override
  _IngredientAddState createState() => new _IngredientAddState();
}

class _IngredientAddState extends State<IngredientAdd> {

  String selectedTerm;
  var _quantidadeController = TextEditingController();
  

  Future<List<IngredienteModel>> searchIngredients(searchQuery) async {
    var url_mealsearch = link('recipe/fetch_list_ingredients.php');
    var data = {'search_query' : searchQuery};
    
    var response = await http.post(Uri.parse(url_mealsearch), body: json.encode(data));
    

    if (response.statusCode == 200){
      if(response.body.contains("No Results Found")){
      }else{
        final List ingredienteModel = List<IngredienteModel>.from(json.decode(response.body).map((x) => IngredienteModel.fromJson(x)));
        return ingredienteModel;
      }
    }
  }

  

  Future addToRecipe(int codIngrediente, double quantidade) async {

    var url_addToRecipe = link('recipe/add_ingredients.php');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final receitaId = prefs.getInt('receita_id');

    var data = {'receita_id' : receitaId, 'ingrediente_id' : codIngrediente, 'quantidade': quantidade};
    print(data);

    var response = await http.post(Uri.parse(url_addToRecipe), body: json.encode(data));
    print(response.body);

    return _returnFlutterToast();

  }


  FloatingSearchBarController controller;

  @override
  void initState() {
    super.initState();
    controller = FloatingSearchBarController();
    //filteredSearchHistory = filterSearchTerms(filter: null);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SafeArea(
        child: FloatingSearchBar(
          automaticallyImplyBackButton: false,
          controller: controller,
          body:Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            padding: EdgeInsets.only(top: 70),
            child:FutureBuilder<List<IngredienteModel>>(
              future: searchIngredients(selectedTerm),
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return Center(
                      child: Container(
                          child: Text(
                            "Nada por aqui.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          )
                      )
                  );
                }else if(snapshot.hasData){
                  var data = snapshot.data;
                  if(snapshot.data.first.ingredientesDesc == null){
                      
                  }else{
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                          itemCount: snapshot.data.length,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
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
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        settings: RouteSettings(name: '/ingredient_detail'),
                                        builder: (BuildContext context) {
                                          return new DetailIngredient(idIngrediente: data[index].ingredienteId,);
                                        },
                                      ),
                                    );
                                  },
                                  child: 
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.5,
                                        child: Text(
                                          data[index].ingredientesDesc
                                        ),
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
                                      //VerticalDivider(thickness: 1,),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.09,
                                  child: IconButton(
                                    onPressed: (){
                                      _quantidadeController = TextEditingController();
                                      return showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: new Text("Adicione a quantidade"),
                                            content: Form(
                                              child: customTextFormField("Quantidade em gramas", "", TextInputType.number, _quantidadeController),
                                            ),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal)),
                                                child: Column(
                                                  children: [
                                                    Text("Ok")
                                                  ],
                                                ),
                                                onPressed: () {
                                                 addToRecipe(data[index].ingredienteId, double.parse(_quantidadeController.text));
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
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }, 
                                    icon: Icon(Icons.add_rounded,), 
                                    color: Colors.teal.shade400,
                                  )
                                ),
                              ],
                            )
                          );
                        }
                      )
                    );
                  }
                }else if(snapshot.hasError){
                  return Center(
                      child: Container(
                          child: Text(
                            "Pesquise sua comida favorita",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          )
                      )
                  );
                }
                print(snapshot.connectionState.toString());
                return CircularProgressIndicator();
              },
            ),
          ),



          transition: CircularFloatingSearchBarTransition(),
          physics: BouncingScrollPhysics(),
          title: Text(
            selectedTerm ?? 'Pesquise...',
            style: Theme.of(context).textTheme.headline6,
          ),
          hint: 'Digite o termo desejado',
          leadingActions: [
            IconButton(icon: Icon(Icons.arrow_back_rounded), onPressed: (){
              setState(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: '/view_ingredients'),
                    builder: (BuildContext context) {
                      return new ViewIngredients();
                    },
                  ),
                );
                //Navigator.of(context).pushNamedAndRemoveUntil(MealsDetailsRoute, ModalRoute.withName('home'));
              });
            })
          ],
          actions: [
            FloatingSearchBarAction.searchToClear(),
          ],
          onSubmitted: (query) {
            setState(() {
              selectedTerm = query;
              searchIngredients(selectedTerm);
            });
            controller.close();
          },
          builder: (context, transition) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Material(
                color: Colors.white,
                elevation: 4,
                child: Builder(
                  builder: (context) {
                    if (controller.query.isEmpty) {
                      return Container(
                        height: 56,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          'Começe a Pesquisar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      );
                    } else {
                      return Text("");
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future _returnFlutterToast() {
  return Fluttertoast.showToast(
      msg: "Receita adicionada a sua refeição com sucesso!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.teal.shade50,
      textColor: Colors.teal
  );
}

Widget customTextFormField(label, hint, inputtype, controller){
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
