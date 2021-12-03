import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

var constUrl = '192.168.1.124';

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
  var percentage = consumed/config;
  if(percentage >=1){
    return 1.0;
  }else{
    return percentage;
  }
 
}

transformToNoDecimal(String valor){
  var value = double.parse(valor).toStringAsFixed(0);
  return value;
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