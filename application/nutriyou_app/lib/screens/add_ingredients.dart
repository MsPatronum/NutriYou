import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/Widgets/WidgetRefeicao_MealDetail.dart';
import 'package:nutriyou_app/models/searchIngredientsModel.dart';
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

  var url_mealsearch = link('recipe/fetch_ingredients.php');

  Future<List<IngredienteModel>> searchIngredients(searchQuery) async {

    

    var data = {'search_query' : searchQuery};
    
    var response = await http.post(Uri.parse(url_mealsearch), body: json.encode(data));
    

    if (response.statusCode == 200){
      if(response.body.contains("No Results Found")){
      }else{
        final List ingredienteModel = List<IngredienteModel>.from(json.decode(response.body).map((x) => IngredienteModel.fromJson(x)));
        
        print(ingredienteModel.first.ingredientesDesc.toString() + "teste");
        int  _maxItems = ingredienteModel.length;
        int  _numItemsPage = 10;


        return ingredienteModel;

      }
    }
  }

  var url_addreceitaarefeicao = link('day/add_recipeonmeal.php');

  Future addToMeal(int userId, int refeicaoId, int codReceita) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    String datem = DateFormat("yyyy-MM-dd").format(DateTime.now().toUtc());


    // Navigator.pop(context);

    var data = {'user_id' : userId, 'refeicao_id' : refeicaoId, 'cod_receita': codReceita, 'data': datem};
    print(data);

    var response = await http.post(Uri.parse(url_addreceitaarefeicao), body: json.encode(data));
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
                  print(snapshot.data.first.ingredientesDesc.toString());
                  if(snapshot.data.first.ingredientesDesc == null){
                      
                  }else{
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                            itemCount: snapshot.data.length,
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    //addToMeal(widget.idUsuario, widget.idRefeicao, snapshot.data[index].receitaId);
                                  });

                                },
                                child: 
                                Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.75,
                                        child: Text(data[index].ingredientesDesc)),
                                      Spacer(),
                                      Text(data[index].ingredientesBaseQtd.toString() + data[index].ingredientesBaseUnity)
                                    ],
                                  )
                                ),
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
                Navigator.of(context).pop();
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