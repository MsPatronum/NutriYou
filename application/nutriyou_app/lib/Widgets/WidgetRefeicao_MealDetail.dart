import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/screens/recipe_view.dart';

class WidgetRefeicao_MealDetails extends StatelessWidget {
  final String NomeRefeicao;
  final int CodRefeicao;
  final bool DelBtn;
  final String TipoAlimento;
  final String Dieta;
  final String kCal;

  WidgetRefeicao_MealDetails({
    @required this.CodRefeicao,
    @required this.NomeRefeicao,
    @required this.DelBtn,
    @required this.TipoAlimento,
    @required this.Dieta,
    @required this.kCal,
    });

  @override
  Widget build(BuildContext context) {

    return Positioned(
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 0),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          topLeft: Radius.circular(15)
                      ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        topLeft: Radius.circular(15)
                    ),
                    child: Image(
                      image: AssetImage("images/cafemanha.png"),
                      width: 80,
                      height: 100,
                      fit: BoxFit.fitHeight,
                    ),
                  )
              ),
              Expanded(
                flex: 20,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15))
                  ),
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    margin: EdgeInsets.only(left: 10),
                    child: Stack(
                      children: [
                        Container(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                  text: NomeRefeicao),
                            )
                        ),
                        Spacer(),
                        Container(
                            margin: EdgeInsets.only(top: 55),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    color: Colors.grey.shade200,
                                    height: 25,
                                    padding: EdgeInsets.all(2),
                                    child: Center(
                                      child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.w700
                                            ),
                                            text: Dieta,
                                          )
                                      ),
                                    ),
                                  ),
                                ),
                                Container(width: 5,),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    color: Colors.grey.shade300,
                                    height: 25,
                                    child: Center(
                                      child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.w700
                                            ),
                                            text: transformToNoDecimal(kCal.toString())+"kcal",
                                          )
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        )
                      ],
                    )
                ),
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.only(right: 3),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                    color: Colors.teal
                ),
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(Icons.remove_red_eye_rounded),
                  color: Colors.grey.shade700,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  RecipeView()));
                    },
                ),
              ),
              Visibility(
                visible: DelBtn,
                child: Container(
                  transformAlignment: Alignment.center,
                  margin: EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                      color: Colors.pinkAccent
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.delete_rounded),
                    color: Colors.pink.shade100,
                    onPressed: () {},
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
