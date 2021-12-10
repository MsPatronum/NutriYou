import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/recipeAddModel.dart';
import 'package:nutriyou_app/screens/view_ingredients.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddRecipe extends StatefulWidget {
  //const AddRecipe({ Key? key }) : super(key: key);
final CheckBoxModel item;

  const AddRecipe({Key key, this.item}) : super(key: key);
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final List<CheckBoxModel> dieta = [
    CheckBoxModel(cod: 1, texto: "Sem açúcar"), 
    CheckBoxModel(cod: 2, texto: "Vegano"), 
    CheckBoxModel(cod: 3, texto: "Sem lactose"), 
    CheckBoxModel(cod: 4, texto: "Sem glúten"), 
    CheckBoxModel(cod: 5, texto: "Vegetariano"), 
    CheckBoxModel(cod: 6, texto: "Sem ovos"), 
    CheckBoxModel(cod: 7, texto: "Sem gordura trans"), 
  ];

  final List<CheckBoxModel> refeicao = [
    CheckBoxModel(cod: 1,	texto: "Café da Manhã"),
    CheckBoxModel(cod: 2,	texto: "Lanche da Manhã"),
    CheckBoxModel(cod: 3,	texto: "Almoço"),
    CheckBoxModel(cod: 4,	texto: "Lanche da Tarde"),
    CheckBoxModel(cod: 5,	texto: "Jantar"),
    CheckBoxModel(cod: 6,	texto: "Lanche da Noite"),
  ];
  
  final _formKey = GlobalKey<FormState>();
  var _recipeNameController = TextEditingController();
  var _recipeDescController = TextEditingController();
  int _nivel = 0;
  var _recipeHourController = TextEditingController();
  var _recipeMinController = TextEditingController();
  var _recipePortionController = TextEditingController();
  int _privacidade;

  Future<RecipeAdd> addRecipe() async {
    
    setState(() {
      //visible = true ; 
    });
    
    String recipeName = _recipeNameController.text;
    String recipeDesc = _recipeDescController.text;
    int nivel = _nivel;
    String recipeHour = _recipeHourController.text;
    String recipeMin = _recipeMinController.text;
    String recipePortion =_recipePortionController.text;
    int privacidade = _privacidade;

    NumberFormat formatter = NumberFormat("00");
    print(recipeHour + "recipe hour");
    var tempoPreparo = formatter.format(int.parse(recipeHour))+":"+formatter.format(int.parse(recipeMin))+":"+"00";
    var l_dieta = List.from(dieta.where((item) => item.checked));
    var l_refeicao = List.from(refeicao.where((item) => item.checked));

    List dietaMarcados = l_dieta.map((value) => value.cod).toList();
    List refeicaoMarcados = l_refeicao.map((value) => value.cod).toList();

    var url = link("recipe/new_recipe.php");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    var data = {
      'usuario_id': userId, 
      'nivel_receita_id': nivel, 
      'receita_tempo_preparo': tempoPreparo,
      'receita_porcoes': recipePortion,
      'receita_nome': recipeName,
      'receita_desc': recipeDesc,
      'receita_modo': privacidade,
      'receita_status': '0',
      'dieta': dietaMarcados,
      'momento': refeicaoMarcados
      };

    var response = await  http.post(Uri.parse(url), body: json.encode(data));
    
    var message = recipeAddFromJson(response.body);
    print(response.body);
    prefs.setInt('receita_id', message.data.receitaId);

  }

  Future<RecipeAdd> remRecipe() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var receita_id = prefs.getInt('receita_id');

    if(receita_id != null){
      var url = link('recipe/remove_recipe.php');
      var data = {'receita_id': receita_id};
      var response = await  http.post(Uri.parse(url), body: json.encode(data));
      prefs.remove('receita_id');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle("Adicione sua receita"),
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
          child: FutureBuilder(
            builder: (context, snapshot){
              return Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: (
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      customTextFormField("Nome da receita", "Adicione o nome da receita", TextInputType.text, _recipeNameController, 40),
                      customTextFormField("Descrição da receita", "Breve descrição da receita", TextInputType.text, _recipeDescController, 100),
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 19),
                            labelText: 'Dificuldade',
                            enabledBorder: InputBorder.none
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:[
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                    child: Radio(
                                    value: 1,
                                    groupValue: _nivel,
                                    activeColor: Colors.teal,
                                    onChanged: (value) {
                                      //value may be true or false
                                      setState(() {_nivel = value;});
                                    },
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Text("Fácil"),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                    child: Radio(
                                    value: 2,
                                    groupValue: _nivel,
                                    activeColor: Colors.teal,
                                    onChanged: (value) {
                                      //value may be true or false
                                      setState(() {_nivel = value;});
                                    },
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Text("Médio"),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                    child: Radio(
                                    value: 3,
                                    groupValue: _nivel,
                                    activeColor: Colors.teal,
                                    onChanged: (value) {
                                      //value may be true or false
                                      setState(() {_nivel = value;});
                                    },
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Text("Difícil"),
                                ],
                              ),
                            ]
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 0.0),
                        child: Text(
                          "Tempo de preparo", 
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:[
                          SizedBox(
                            width: MediaQuery.of(context).size.width *0.40,
                            child: customTextFormField("Horas", "", TextInputType.number, _recipeHourController, 2),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width *0.40,
                            child: customTextFormField("Minutos", "", TextInputType.number, _recipeMinController, 2),
                          ),
                        ]
                      ),

                      customTextFormField("Porções", "", TextInputType.number, _recipePortionController, 2),

                      Container(
                        margin: EdgeInsets.only(top: 15),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 19),
                            labelText: 'Privacidade',
                            enabledBorder: InputBorder.none
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:[
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                    child: Radio(
                                    value: 0,
                                    groupValue: _privacidade,
                                    activeColor: Colors.teal,
                                    onChanged: (value) {
                                      //value may be true or false
                                      setState(() {_privacidade = value;});
                                    },
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Text("Receita privada"),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                    child: Radio(
                                    value: 1,
                                    groupValue: _privacidade,
                                    activeColor: Colors.teal,
                                    onChanged: (value) {
                                      //value may be true or false
                                      setState(() {_privacidade = value;});
                                    },
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Text("Receita pública"),
                                ],
                              ),
                            ]
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                                labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 19),
                                labelText: 'Tipo de alimento',
                                enabledBorder: InputBorder.none
                              ),
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: dieta.length,
                                itemBuilder: (_, int index){
                                  return CheckboxListTile(
                                    activeColor: Colors.teal.shade400,
                                    title: Text(dieta[index].texto),
                                    value: dieta[index].checked,
                                    onChanged: (bool value){
                                      setState((){
                                        dieta[index].checked = value;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),
                                labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 19),
                                labelText: 'Refeições indicadas',
                                enabledBorder: InputBorder.none
                              ),
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: refeicao.length,
                                itemBuilder: (_, int index){
                                  return CheckboxListTile(
                                    activeColor: Colors.teal.shade400,
                                    title: Text(refeicao[index].texto),
                                    value: refeicao[index].checked,
                                    onChanged: (bool value){
                                      setState((){
                                        refeicao[index].checked = value;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
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
                              addRecipe();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(name: '/view_ingredients'),
                                  builder: (BuildContext context) {
                                    return new ViewIngredients();
                                  },
                                ),
                              );
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
                  )
                ),
              );
            }
        ),),
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

class CheckBoxModel{
  
  CheckBoxModel({this.cod, this.texto, this.checked = false});
  
  String texto;
  int cod;
  bool checked;
}