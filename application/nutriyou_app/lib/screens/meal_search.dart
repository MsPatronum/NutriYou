import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/Widgets/WidgetRefeicao_MealDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealSearch extends StatefulWidget {
  final int idRefeicao;
  final int idUsuario;
  final Future<ReturnMealSearch> mealSearch;
  MealSearch({Key key, this.mealSearch, this.idRefeicao, this.idUsuario}) : super(key: key);

  @override
  _MealSearchState createState() => new _MealSearchState();
}
class ReturnMealSearch{
  ReturnMealSearch({
    this.receitaId,
    this.receitaNome,
    this.receitaDescricao,
    this.receitaKcal,
    this.receitaNivel,
    this.receitaTempoPrep,
    this.receitaImageUrl,
  });
  int receitaId;
  String receitaNome;
  String receitaDescricao;
  String receitaTempoPrep;
  String receitaNivel;
  double receitaKcal;
  String receitaImageUrl;

  factory ReturnMealSearch.fromJson(Map<String, dynamic> json){
    return ReturnMealSearch(
        receitaId: json["receita_id"] == null ? "0" : json["receita_id"],
        receitaNome: json["receita_nome"] == null ? "0" : json["receita_nome"],
        receitaDescricao: json["receita_desc"] == null ? "0" : json["receita_desc"],
        receitaTempoPrep: json["receita_tempo_preparo"] == null ? "0" : json["receita_tempo_preparo"],
        receitaNivel : json["rn_nivel"] == null ? "0" : json["rn_nivel"],
        receitaKcal: json["energy_kcal"] == null ? "0" : json["energy_kcal"],
        receitaImageUrl: json["receita_imagemurl"] == null ? "0" : json["receita_imagemurl"]
    );}}

class _MealSearchState extends State<MealSearch> {

  String selectedTerm;

  var url_mealsearch = link('search_meals.php');

  Future searchMeals(searchQuery) async {

    var data = {'search_query' : searchQuery};
    print(data.toString());

    var response = await http.post(Uri.parse(url_mealsearch), body: json.encode(data));

    if (response.statusCode == 200){
      if(response.body.contains("No Results Found")){
      }else{
        var jsonData = json.decode(response.body).cast<Map<String, dynamic>>();
        print(response.body);
        List<ReturnMealSearch> MealSearch = jsonData.map<ReturnMealSearch>((json) {
          return new ReturnMealSearch.fromJson(json);
        }).toList();
        return MealSearch;

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
            child:FutureBuilder(
              future: searchMeals(selectedTerm),
              builder: (context, snapshotMealSearch){
                if(!snapshotMealSearch.hasData){
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
                }else if(snapshotMealSearch.hasData){print(snapshotMealSearch.data.first.receitaKcal.toString());
                  if(snapshotMealSearch.data.first.receitaNome == null){
                      
                  }else{
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                            itemCount: snapshotMealSearch.data.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    addToMeal(widget.idUsuario, widget.idRefeicao, snapshotMealSearch.data[index].receitaId);
                                  });

                                },
                                child: Container(child: WidgetRefeicao_MealDetails(
                                  NomeRefeicao: snapshotMealSearch.data[index].receitaNome.toString(),
                                  TipoAlimento: "Tempo " + snapshotMealSearch.data[index].receitaTempoPrep.toString(),
                                  CodRefeicao: snapshotMealSearch.data[index].receitaId.toInt(),
                                  kCal:  snapshotMealSearch.data[index].receitaKcal.toString(),
                                  Dieta: snapshotMealSearch.data[index].receitaNivel,
                                  DelBtn: false,
                                )),
                              );
                            }
                        )
                    );
                  }
                }else if(snapshotMealSearch.hasError){
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
                print(snapshotMealSearch.connectionState.toString());
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
              searchMeals(selectedTerm);
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