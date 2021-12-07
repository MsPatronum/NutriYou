import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/routing_constants.dart';
import 'package:nutriyou_app/screens/meal_details.dart';

class WidgetRefeicao extends StatefulWidget {
  final Color corFundoIcon;
  final String imagem;
  final int userId;
  final DateTime date;
  final String nomeRefeicao;
  final String itensRefeicao;
  final String qtdeCaloriasRefeicao;
  final int idRefeicao;

  WidgetRefeicao({@required this.corFundoIcon,
    @required this.nomeRefeicao,
    this.idRefeicao,
    @required this.userId,
    @required this.date,
    @required this.imagem,
    this.itensRefeicao,
    this.qtdeCaloriasRefeicao});

  @override
  _WidgetRefeicaoState createState() => _WidgetRefeicaoState();
}

class _WidgetRefeicaoState extends State<WidgetRefeicao> {
  @override
  Widget build(BuildContext context) {
    return Container(
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    color: widget.corFundoIcon,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: widget.corFundoIcon, width: 5.0)),
                child: Image(
                  image: AssetImage("images/" + widget.imagem),
                  color: Colors.white,
                  width: 60,
                  height: 60,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                  constraints: BoxConstraints(minWidth: 100, maxWidth: 180),
                  margin: EdgeInsets.only(left: 15),
                  child: Stack(
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 15),
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                                text: widget.nomeRefeicao),
                          )),
                      Spacer(),
                      Flexible(
                          child: Container(
                            margin: EdgeInsets.only(top: 40),
                            padding: EdgeInsets.only(right: 10),
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              strutStyle: StrutStyle(fontSize: 12.0),
                              text: TextSpan(
                                  style: TextStyle(color: Colors.black),
                                  text: widget.itensRefeicao),
                            ),
                          ))
                    ],
                  )),
              Spacer(),
              new Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      margin: EdgeInsets.only(top: 20, left: 10),
                      height: 65,
                      width: 75,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.tealAccent.shade700
                        ),
                          onPressed: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(name: MealsDetailsRoute),
                                  builder: (BuildContext context) {
                                    return new MealDetail(
                                      nomeRefeicao: widget.nomeRefeicao,
                                      imagem: widget.imagem,
                                      idRefeicao: widget.idRefeicao,
                                      userId: widget.userId,
                                      data: widget.date,
                                      corFundoIcon: widget.corFundoIcon,
                                    );
                                  },
                                ),
                              );/*
                              Navigator.push(context, MaterialPageRoute(builder: (context) => new MealDetail(
                                nomeRefeicao: widget.nomeRefeicao,
                                imagem: widget.imagem,
                                idRefeicao: widget.idRefeicao,
                                userId: widget.userId,
                                data: widget.date,
                                corFundoIcon: widget.corFundoIcon,
                              )));*/
                            });
                          },
                          child: Text(
                            widget.qtdeCaloriasRefeicao.isEmpty ? "0 kCal" :  transformToNoDecimal(widget.qtdeCaloriasRefeicao) + " kCal",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        )
                      )
                    )
            ],
          ),
        );
  }
  void _stateUpdate(){
    setState((){});
    print("refresh done");
  }
}



