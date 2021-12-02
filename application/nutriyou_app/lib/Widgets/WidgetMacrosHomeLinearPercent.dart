import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class WidgetMacros extends StatelessWidget {
  final String imagem;
  final String tipoMacro;
  final double porcentagem;
  final String restante;
  final bool ml;
  const WidgetMacros({
    @required this.tipoMacro,
    this.imagem,
    this.porcentagem,
    this.restante,
    this.ml
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Image.asset("assets/Icons/"+ Imagem, color: AppColors.normalGreen, scale: 1,),
              Padding(padding: EdgeInsets.all(3)),
              Text(
                tipoMacro,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700
                ),
              ),
            ],
          ),
          Container(height: 4,),
          Container(
            child: LinearPercentIndicator(
              lineHeight: 10,
              percent: porcentagem,
              backgroundColor: Colors.teal.shade300,
              progressColor: Colors.teal.shade900,
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(top: 3),
            child: Text(
              // ignore: unrelated_type_equality_checks
              ml == true ? restante + "ml" : restante + "g" + " restantes",
              style: TextStyle(
                fontSize: 14, 
                color: Colors.grey.shade700, 
                fontWeight: FontWeight.w500
              ),
            )
          ),
        ]
      )
    );
  }
}