import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

var constUrl = '172.18.160.1';

link(String page){
  return ('http://'+ constUrl +'/NutriYou/API/'+page);
}

getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('id');
  return userId;
}

Future getNome() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('nome'); 
}

calculatePercentage(double config, double consumed){
  return consumed/config;
}

subtraction(double bnumber, double snumber){
  var a = bnumber-snumber;
  var resultado = a.toStringAsFixed(0);
  return resultado;
}

class BodyText extends StatelessWidget {
  final String texto;
  final double tamFonte;

  const BodyText({
    @required this.texto,
    @required this.tamFonte,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      texto, 
      style: TextStyle(
        fontSize: tamFonte,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w700
      ),
    );
  }
}