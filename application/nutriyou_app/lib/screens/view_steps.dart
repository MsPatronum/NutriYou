import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/StepListModel.dart';
import 'package:nutriyou_app/screens/viewRecipeImages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewSteps extends StatefulWidget {
  //const AddRecipe({ Key? key }) : super(key: key);

  @override
  _ViewStepsState createState() => _ViewStepsState();
}

class _ViewStepsState extends State<ViewSteps> {
  var _stepController = TextEditingController();


Future<StepListModel> fetchSteps() async {
    
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var receitaId = prefs.getInt('receita_id');

  var url = link("recipe/fetch_steps.php");

  var data = {'receita_id': receitaId};

  var response = await  http.post(Uri.parse(url), body: json.encode(data)); print(response.body);
  print(data);
  if(response.statusCode == 200){
    
    var stepListModel = stepListModelFromJson(response.body);
    return stepListModel;
  }else{
    throw Exception('Falha ao carregar');
  }
}

Future addSteps(step_desc, step_nr) async {
    
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var receitaId = prefs.getInt('receita_id');

  var url = link("recipe/add_steps.php");

  var data = {'receita_id': receitaId, 'rp_numero' : step_nr, 'rp_desc': step_desc} ;

  var response = await  http.post(Uri.parse(url), body: json.encode(data));

  if(response.statusCode == 200){
    
  }else{
    throw Exception('Falha ao carregar');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle("Adicione os passos"),
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
          child: FutureBuilder<StepListModel>(
            future: fetchSteps(),
            builder: (context, snapshot){
              if(snapshot.hasData){
                var nulo = snapshot.data.data == null ? 0 : snapshot.data.data;
                if(nulo != 0){
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: snapshot.data.data.length,
                        itemBuilder: (BuildContext context, int index){
                          var data = snapshot.data.data;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                                    Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.1,
                                          child: Text("Passo \n"+data[index].rpNumero.toString(), textAlign: TextAlign.center,)
                                        ),
                                        SizedBox(width: 5,),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.6,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(data[index].rpDesc)
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    /*Container(
                                      width: MediaQuery.of(context).size.width * 0.09,
                                      child: IconButton(
                                        onPressed: (){

                                        }, 
                                        icon: Icon(Icons.delete_rounded), 
                                        color: Colors.pink,
                                      )
                                    ),*/
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
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
                              _stepController = TextEditingController();
                              return showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: new Text("Adicione um passo"),
                                    content: Form(
                                      child: customTextFormField("Descreva o passo", "", TextInputType.multiline, _stepController),
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
                                          var calc = snapshot.data.data.length + 1;
                                          addSteps(_stepController.text, calc);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              settings: RouteSettings(name: '/view_steps'),
                                              builder: (BuildContext context) {
                                                return ViewSteps();
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
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Text(
                                      'Adicionar passos', 
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

                              ],
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
                                  settings: RouteSettings(name: '/add_images'),
                                  builder: (BuildContext context) {
                                    return new ViewImages();
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
                    children: [
                      Container(
                        child: Text(
                          "Esta receita não tem nenhum passo ainda. Adicione!", 
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
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal.shade300), 
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                            padding: MaterialStateProperty.all(EdgeInsets.all(12))),
                            onPressed: () {
                              _stepController = TextEditingController();
                              return showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: new Text("Adicione um passo"),
                                    content: Form(
                                      child: customTextFormField("Descreva o passo", "", TextInputType.multiline, _stepController),
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
                                          addSteps(_stepController.text, 1);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              settings: RouteSettings(name: '/view_steps'),
                                              builder: (BuildContext context) {
                                                return ViewSteps();
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
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Text(
                                      'Adicionar passos', 
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
                              ],
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
        )
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

Widget customTextFormField(label, hint, inputtype, controller){
  return TextFormField(
    keyboardType: inputtype,
    autofocus: true,
    maxLines: 5,
    minLines: 1,
    controller: controller,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (String value){
      if(value.isEmpty){
        return "Insira dados";
      }
        return null;
    },
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