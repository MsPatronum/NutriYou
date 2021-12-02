import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
//import 'package:nutri_app/Widgets/WidgetStarRating.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  bool like = false;
  bool dislike = false;
  @override

  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
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
        actions: [
          Container(
            margin: EdgeInsets.only(right: 15),
            child: IconButton(
              icon: Icon(
                like ? (){dislike = false; return Icons.thumb_up;}() : Icons.thumb_up_outlined,
                size: 30,
                color: Colors.teal,
              ),
              onPressed: (){
                setState(() {
                  like = !like;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 15),
            child: IconButton(
              icon: Icon(
                dislike ? (){like = false; return Icons.thumb_down;}() : Icons.thumb_down_outlined,
                size: 30,
                color: Colors.teal,
              ),
              onPressed: (){
                setState(() {
                  dislike = !dislike;
                });
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text("Título da receita")),
                  Center(child: Text("Subtitulo da Receita", ),),
                  SizedBox(
                    height: 16,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Rendimento",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                              ),
                            ),
                            Text("10 porções"),
                          ],
                        ),
                        VerticalDivider(
                          color: Colors.teal,
                          thickness: 2,
                        ),
                        Column(
                          children: [
                          Text(
                          "Tempo de Preparo",
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                        ),
                            Text("50 minutos"),
                          ],
                        ),
                        VerticalDivider(
                          color: Colors.teal,
                          thickness: 2,
                        ),
                        Column(
                          children: [
                          Text(
                          "Avaliação",
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                        ),
                            /*StarDisplayWidget(
                              value: 4,
                              filledStar: Icon(Icons.star_rounded, color: AppColors.defaultGreen, size: 20,),
                              unfilledStar: Icon(Icons.star_border_rounded, color: AppColors.defaultGreen, size: 20,),
                            )*/
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            SizedBox(
              height: 26,
            ),

            Container(
              height: 350,
              padding: EdgeInsets.only(left: 16),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Info. Nutricional'),
                      buildNutrition(240, "Calorias", "Kcal"),
                      SizedBox(
                        height: 16,
                      ),
                      buildNutrition(11, "Carbs", "g"),
                      SizedBox(
                        height: 16,
                      ),
                      buildNutrition(10, "Proteina", "g"),
                      SizedBox(
                        height: 16,
                      ),
                      buildNutrition(10, "Gordura", "g"),
                    ],
                  ),

                  Positioned(
                    right: 0,
                    child: Hero(
                      tag: "assets/comida/frango.jpg",
                      child: Container(
                        height: 350,
                        width: 220,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20), topLeft: Radius.circular(20)),
                          child: Image(
                            image: AssetImage("assets/comida/linguica_ovo.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 80, top: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text('Ingredientes',),

                  buildTextIngredient("2", "copo", "pecã cortada"),
                  buildTextIngredient("1", "colher de sopa", "manteiga sem sal derretida"),
                  buildTextIngredient("1/4",  "colher de chá", "sal, plus "),
                  buildTextIngredient("3",  "colher de sopa", "suco de limão fresco"),
                  buildTextIngredient("2",  "colher de sopa", "azeite"),
                  buildTextIngredient("1/2",  "colher de chá", "mel"),

                  SizedBox(height: 16,),

                  Text('Modo de Preparo', ),

                  buildTextStep("PASSO 1"),
                  Text("In a medium bowl, mix all the marinade ingredients with some seasoning. Chop the chicken into bite-sized pieces and toss with the marinade. Cover and chill in the fridge for 1 hr or overnight.", ),

                  buildTextStep("PASSO 2"),
                  Text("In a large, heavy saucepan, heat the oil. Add the onion, garlic, green chilli, ginger and some seasoning. Fry on a medium heat for 10 mins or until soft.", ),

                  buildTextStep("PASSO 3"),
                  Text("Add the spices with the tomato purée, cook for a further 2 mins until fragrant, then add the stock and marinated chicken. Cook for 15 mins, then add any remaining marinade left in the bowl. Simmer for 5 mins, then sprinkle with the toasted almonds. Serve with rice, naan bread, chutney, coriander and lime wedges, if you like.", ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildNutrition(int value, String title, String subTitle){
    return Container(
      height: 60,
      width: 150,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        boxShadow: [BoxShadow(
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
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 0),
              )],
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(
            width: 20,
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                subTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

}

buildTextStep(String text){
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: IntrinsicWidth(
      child: Container(
          height: 35,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.teal,
            borderRadius: BorderRadius.circular(7)
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          )
      ),
    )
  );
}

buildTextIngredient(String qtd, String medida, String nome){
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 45,
          height: 30,
          decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(7)
          ),
          child: Center(
            child: Text(
              qtd,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          margin: EdgeInsets.only(right: 15),
        ),
        Text(
          medida + " ",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          nome,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    )
  );
}

buildTextSubTitleVariation2(String text){
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[400],
      ),
    ),
  );
}

buildRecipeTitle(String text){
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

buildRecipeSubTitle(String text){
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade400,
      ),
    ),
  );
}

buildCalories(String text){
  return Text(
    text,
    style: TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  );
}



