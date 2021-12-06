import 'package:flutter/material.dart';
import 'package:nutriyou_app/app_colors.dart';

class AddRecipe extends StatefulWidget {
  //const AddRecipe({ Key? key }) : super(key: key);

  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
 
  var _recipeNameController = TextEditingController();
  var _recipeDescController = TextEditingController();
  int _nivel = 0;

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
              return (
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    customTextFormField("Nome da receita", "Adicione o nome da receita", TextInputType.text, _recipeNameController),
                    customTextFormField("Descrição da receita", "Breve descrição da receita", TextInputType.text, _recipeDescController),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.teal.shade700),
                          labelText: 'Qual o seu sexo?',
                          enabledBorder: InputBorder.none
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:[
                            _customRadioButton(1, _nivel, "Fácil"),
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
                  ],
                )
              );
            }
        ),),
      ),
    );
  }

  Row _customRadioButton(r_value, _controller, String descricao) {
    return Row(
      children: [
        SizedBox(
          width: 10,
          child: Radio(
            value: r_value,
            groupValue: _controller,
            activeColor: Colors.teal,
            onChanged: (value) {
              //value may be true or false
              setState(() {_controller = value;});
            },
          ),
        ),
        SizedBox(width: 10.0),
        Text(descricao),
      ],
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
    autofocus: false,
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.teal.shade700,fontSize: 15),
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