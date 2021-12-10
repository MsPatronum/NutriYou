import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/models/loginModel.dart';
import 'package:nutriyou_app/screens/homepage.dart';
import 'package:nutriyou_app/screens/myappbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutriyou_app/routing_constants.dart';
import 'package:nutriyou_app/screens/FormValidator.dart';
import 'package:nutriyou_app/screens/LoginRequestData.dart';

class LoginUser extends StatefulWidget {
  final Future<LoginMessage> loginMessage;

  const LoginUser({Key key, this.loginMessage}) : super(key: key);

 
LoginUserState createState() => LoginUserState();
 
}
 
class LoginUserState extends State {
  GlobalKey<FormState> _key = new GlobalKey();
  LoginRequestData _loginData = LoginRequestData();
  bool _obscureText = true;
 
  // For CircularProgressIndicator.
  bool visible = false ;
 
  // Getting value from TextField widget.
  var emailController;
  var passwordController;
 
// ignore: missing_return
Future<LoginMessage> userLogin() async{
 
  // Showing CircularProgressIndicator.
  setState(() {
  visible = true ; 
  });
 
  // Getting value from Controller
  String email = _loginData.email;
  String password = _loginData.password;
 
  // SERVER LOGIN API URL
  var url = link('login.php');
 
  // Store all data with Param Name.
  var data = {'email': email, 'senha' : password};
 
  // Starting Web API Call.
  var response = await http.post(url, body: json.encode(data));
 print(response.body);
  // If the Response Message is Matched.
  
  if(response.statusCode == 200){
    final message = LoginMessage.fromJson(json.decode(response.body));
    if(message.error == false)
    {   
      // Hiding the CircularProgressIndicator.
      setState(() {
        visible = false; 
      });

      //set shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('id', message.data.id);
      prefs.setString('email', message.data.email);
      prefs.setString('token', message.data.token);
      prefs.setString('nome', message.data.nome);
  
      // Navigate to Profile Screen & Sending Email to Next Screen.
      
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: HomeViewRoute),
          builder: (BuildContext context) {
            return new MyAppBar();
          },
        ),
      );
    }else{
  
      // If Email or Password did not Matched.
      // Hiding the CircularProgressIndicator.
      setState(() {
        visible = false; 
        });
  
      // Showing Alert Dialog with Response JSON Message.
      return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(message.message),
          actions: <Widget>[
            ElevatedButton(
              child: new Text("OK"),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal.shade700)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
      );
      }
      }else{
       throw Exception('Falha ao carregar');
      }
 
}
 
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SafeArea(
        child:Center(
          child: new SingleChildScrollView(
            child: new Container(
              margin: new EdgeInsets.all(20.0),
              child: Center(
                child: new Form(
                  key: _key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: _getFormUI(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _getFormUI() {
    return new Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Image(image: AssetImage('images/logo.png'), fit: BoxFit.fitWidth,),
        ),
        new SizedBox(height: 50.0),
        new TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Email',
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
          validator: FormValidator().validateEmail,
          onSaved: (String value) {
            _loginData.email = value;
          },
        ),
        new SizedBox(height: 20.0),
        new TextFormField(
            autofocus: false,
            obscureText: _obscureText,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Senha',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  semanticLabel:
                      _obscureText ? 'show password' : 'hide password',
                      color: Colors.teal.shade300,
                ),
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
            validator: FormValidator().validatePassword,
            onSaved: (String value) {
              _loginData.password = value;
            }),
        new SizedBox(height: 15.0),
        new SizedBox(
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
                  userLogin();
                } else {
                    ///validation error
                }
              },
              child: Text('Entrar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        new TextButton(
          child: Text(
            'Esqueceu a senha?',
            style: TextStyle(color: Colors.black54),
          ),
          onPressed: _showForgotPasswordDialog,
        ),
        new TextButton(
          onPressed: (){
            
            Navigator.pushNamed(context, RegisterViewRoute);
          },
          child: Text('Novo aqui? Crie uma conta',
              style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
 
  Future<Null> _showForgotPasswordDialog() async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: const Text('Por favor insira o seu e-mail'),
            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
            content: new TextField(
              decoration: new InputDecoration(hintText: "Email"),
              onChanged: (String value) {
                _loginData.email = value;
              },
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Ok"),
                onPressed: () async {
                  _loginData.email = "";
                  Navigator.pop(context);
                },
              ),
              new TextButton(
                child: new Text("Cancelar", style: TextStyle(color: Colors.red),),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }
}