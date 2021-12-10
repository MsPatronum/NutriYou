import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/routing_constants.dart';

import 'FormValidator.dart';

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  int _profissional = 0;
  String _email = "";
  String _password = "";
  // ignore: unused_field
  String _confirmPassword = "";
  String _genero = "";
  int _ativo = 0;
  var _nomeController = TextEditingController();
  var _sobrenomeController = TextEditingController();
  var _pesoController = TextEditingController();
  var _alturaController = TextEditingController();
  var _dataNascController = TextEditingController();
  // For CircularProgressIndicator.
  bool visible = false ;
  
  GlobalKey<FormState> _key = new GlobalKey();


  Future userRegister() async{
 
  // Showing CircularProgressIndicator.
  setState(() {
  visible = true ; 
  });
 
  // Getting value from Controller
  String email = _email;
  String password = _password;
  String nome = _nomeController.text;
  String sobrenome = _sobrenomeController.text;
  int tipo = _profissional;
  String altura = _alturaController.text;
  String peso = _pesoController.text;
  String sexo = _genero;
  String dataNasc = _dataNascController.text;
  int ativo = _ativo;

 
  // SERVER LOGIN API URL
  var url = link('register_user.php');
 
  // Store all data with Param Name.
  var data = {'nome':nome, 'sobrenome':sobrenome, 'email':email, 'senha':password, 'tipo':tipo, 'peso':peso, 'sexo':sexo, 'data_nasc':dataNasc, 'is_active':ativo, 'altura':altura};
 
   print (data);
  // Starting Web API Call.
  var response = await http.post(Uri.parse(url), body: json.encode(data));

  print(response.toString());
 
  // Getting Server response into variable.
  Map<String, dynamic> message = new Map<String, dynamic>.from(json.decode(response.body));
 
  // If the Response Message is Matched.
  if(message['error'] == false)
  {
 
    // Hiding the CircularProgressIndicator.
      setState(() {
      visible = false; 
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(message['message']),
            actions: <Widget>[
              ElevatedButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pushNamed(LoginViewRoute);
                },
              ),
            ],
          );
        },
      );
      
  }else{
 
    // If Email or Password did not Matched.
    // Hiding the CircularProgressIndicator.
    setState(() {
      visible = false; 
      });
 
    // Showing Alert Dialog with Response JSON Message.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(message['message']),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal)),
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
                Navigator.of(context).pushNamed(LoginViewRoute);
              },
            ),
          ],
        );
      },
    );
  }
 
}


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SafeArea(
        child: new SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: new Container(
            margin: new EdgeInsets.all(20.0),
            child: Center(
              child: new Form(
                key: _key,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Image(image: AssetImage('images/logo.png'), fit: BoxFit.fitWidth,),
                          ),
                          Text(
                            "REGISTRO",
                            style: TextStyle(
                              fontSize: 30, 
                              color: Colors.teal.shade700
                            ), 
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top:50)),
                    customTextFormField("Nome", "", TextInputType.name, _nomeController),
                    SizedBox(height: 10,),
                    customTextFormField("Sobrenome","", TextInputType.name,_sobrenomeController),
                    SizedBox(height: 10,),
                    customTextFormField("Data de Nascimento", "DD/MM/AAAA", TextInputType.datetime,_dataNascController),
                    SizedBox(height: 10,),
                    Divider(thickness: 2,),
                    SizedBox(height: 10,),

                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      autovalidateMode: AutovalidateMode.always,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        labelText: "E-mail",
                        labelStyle: TextStyle(color: Colors.teal.shade700),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border:
                          OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0)
                          ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Colors.teal.shade700,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      validator: (String value) {
                        _email = value;
                        return (FormValidator().validateEmail(value));
                      },
                    ),
                    SizedBox(height: 10,),
                    new TextFormField(
                      autofocus: false,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Colors.teal.shade700,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      validator: (String value) {
                        String patttern = r'(^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$)';
                        RegExp regExp = new RegExp(patttern);
                        if (value.isEmpty) {
                          return "Necessário inserir sua senha";
                        } else if (value.length < 8) {
                          return "Mínimo de 8 caracteres";
                        } else if (!regExp.hasMatch(value)) {
                          return "A senha precisa de pelo menos uma letra maiúscula, \numa minúscula e um número";
                        }
                        _password = value;
                        return null;
                      },
                      onSaved: (String value) {
                        _password = value;
                      }
                    ),
                    SizedBox(height: 10,),
                    new TextFormField(
                      autofocus: false,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Confirme sua senha',
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Colors.teal.shade700,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      validator: (value){
                        if(value.isEmpty){
                          return "Confirme sua senha";
                        }else if (value != _password){
                          return "Senhas não conferem";
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        _confirmPassword = value;
                      }
                    ),

                    SizedBox(height: 10,),
                    Divider(thickness: 2,),
                    SizedBox(height: 10,),
                    Container(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.teal.shade700),
                          labelText: 'Qual o seu sexo?',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:[
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                  child: Radio(
                                  value: "M",
                                  groupValue: _genero,
                                  activeColor: Colors.teal,
                                  onChanged: (value) {
                                    print( value);
                                    //value may be true or false
                                    setState(() {_genero = value;});
                                  },
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text("Masculino"),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                  child: Radio(
                                  value: "F",
                                  groupValue: _genero,
                                  activeColor: Colors.teal,
                                  onChanged: (value) {
                                    print( value);
                                    //value may be true or false
                                    setState(() {_genero = value;});
                                  },
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text("Feminino"),
                              ],
                            ),
                          ]
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.teal.shade700),
                          labelText: 'É um profissional de saúde?',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Colors.teal.shade700,
                            ),
                          ),
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
                                  groupValue: _profissional,
                                  activeColor: Colors.teal,
                                  onChanged: (value) {
                                    print( value);
                                    //value may be true or false
                                    setState(() {_profissional = value;});
                                  },
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text("Sim"),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                  child: Radio(
                                  value: 0,
                                  groupValue: _profissional,
                                  activeColor: Colors.teal,
                                  onChanged: (value) {
                                    print( value);
                                    //value may be true or false
                                    setState(() {_profissional = value;});
                                  },
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text("Não"),
                              ],
                            ),
                          ]
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.teal.shade700),
                          labelText: 'Faz exercícios regularmente?',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Colors.teal.shade700,
                            ),
                          ),
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
                                  groupValue: _ativo,
                                  activeColor: Colors.teal,
                                  onChanged: (value) {
                                    print( value);
                                    //value may be true or false
                                    setState(() {_ativo = value;});
                                  },
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text("Sim"),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                  child: Radio(
                                  value: 0,
                                  groupValue: _ativo,
                                  activeColor: Colors.teal,
                                  onChanged: (value) {
                                    print( value);
                                    //value may be true or false
                                    setState(() {_ativo = value;});
                                  },
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text("Não"),
                              ],
                            ),
                          ]
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Divider(thickness: 2,),
                    SizedBox(height: 10,),
                    customTextFormField("Peso em kg", "", TextInputType.number, _pesoController),
                    SizedBox(height: 10,),
                    customTextFormField("Altura em centímetros", "", TextInputType.number, _alturaController),
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
                            if (_key.currentState.validate()) {
                              /// No any error in validation
                              _key.currentState.save();
                              userRegister();
                            } else {
                                ///validation error
                            }
                          },
                          child: Text('Registrar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget customTextFormField(label, hint, inputtype, controller){
  return TextFormField(

    keyboardType: inputtype,
    autofocus: false,
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.teal.shade700),
      hintText: hint,
      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      border:
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0)
        ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(
          color: Colors.teal.shade700,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(
          color: Colors.teal,
        ),
      ),
    ),
  );
}