import 'dart:ui';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutriyou_app/app_colors.dart';

class AddRecipe extends StatefulWidget {
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  List<TagRecipe> _tagRecipe;
  List<MomRecipe> _momRecipe;
  List<String> _filters;
  var nameTECs = <TextEditingController>[];
  var nameSteps = <TextEditingController>[];
  var ingredients = <Container>[];
  var steps = <Container>[];
  String _time = "Não selecionado";
  String _confirmTime = "";
  int _servings = 0;
  int _add_ingr = 0;

  Container createContainerIngredient() {
    var ingredientController = TextEditingController();
    nameTECs.add(ingredientController);
    return Container(
        child:
        TextField(
          controller: ingredientController,
          decoration: InputDecoration(labelText: 'nome do ingrediente',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.bntTextoVerde),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.darkGreen, width: 2),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.bntTextoVerde),
            ),
            focusColor: AppColors.bntTextoVerde,
          ),)

    );
  }
  Container createContainerStep() {
    var stepController = TextEditingController();
    nameSteps.add(stepController);
    return Container(
        child: TextField(
          controller: stepController,
          maxLines: null,
          minLines: 4,
          decoration: InputDecoration(
            labelText: 'Descreva esse passo',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.bntTextoVerde),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.darkGreen, width: 2),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.bntTextoVerde),
            ),
            focusColor: AppColors.bntTextoVerde,
          ),
        )
    );
  }
  void add_servings() {
    setState(() {
      _servings++;
    });
  }
  void add_ingr() {
    setState(() {
      _add_ingr++;
    });
  }
  void minus_servings() {
    setState(() {
      if (_servings != 0)
        _servings--;
    });
  }
  void minus_ingr() {
    setState(() {
      if (_add_ingr != 0)
        _add_ingr--;
    });
  }

  @override

  void initState(){
    super.initState();
    ingredients.add(createContainerIngredient());
    steps.add(createContainerStep());
    _filters = <String>[];
    _tagRecipe = <TagRecipe>[
      TagRecipe('Vegano'),
      TagRecipe('Sem açúcar'),
      TagRecipe('Sem Lactose'),
      TagRecipe('Sem Glúten'),
      TagRecipe('Vegetariano'),
      TagRecipe('Sem leite'),
      TagRecipe('Sem Gordura Trans'),
    ];
    _momRecipe = <MomRecipe>[
      MomRecipe('Café da Manhã'),
      MomRecipe('Lanche da Manhã'),
      MomRecipe('Almoço'),
      MomRecipe('Lanche da tarde'),
      MomRecipe('Janta'),
      MomRecipe('Lanche da Noite'),
    ];
  }
  _onDone() {
    List<IngredientEntry> ingr_entries = [];
    for (int i = 0; i < ingredients.length; i++) {
      var name = nameTECs[i].text;
      ingr_entries.add(IngredientEntry(name));
    }
    Navigator.pop(context, ingr_entries);
    List<StepsEntry> steps_entries = [];
    for (int i = 0; i < steps.length; i++) {
      var name_steps = nameSteps[i].text;
      steps_entries.add(StepsEntry(name_steps));
    }
    Navigator.pop(context, steps_entries);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.grey.shade200,
        title: Text(
          "Adicione sua receita",
          style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w700,
              fontSize: 25
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          iconSize: 35,
          color: Colors.grey.shade800,
          onPressed: (){
            setState(() {
              Navigator.pop(context);
            });
          },
        ),
      ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(height: 35,),
                        Text("Nome da receita"),
                        Container(
                          margin: EdgeInsets.only(bottom: 35),
                          child: TextField(
                            cursorColor: AppColors.bntTextoVerde,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.bntTextoVerde),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkGreen, width: 2),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.bntTextoVerde),
                              ),
                              focusColor: AppColors.bntTextoVerde,
                            ),
                            maxLines: null,
                          ),
                        ),
                        Text("Breve descrição da receita"),
                        Container(
                          margin: EdgeInsets.only(bottom: 35),
                          child: TextField(
                            cursorColor: AppColors.bntTextoVerde,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.bntTextoVerde),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkGreen, width: 2),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.bntTextoVerde),
                              ),
                              focusColor: AppColors.bntTextoVerde,
                            ),
                            maxLines: null,
                          ),
                        ),
                        Container(child: Text("Selecione as tags dessa receita"),),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 5,
                            children: tagRecipe.toList(),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 25),
                          child: Text("Selecione os momentos dessa receita",),
                        ),
                        Center(
                          child: Wrap(
                            spacing: 5,
                            children: momRecipe.toList(),
                          ),
                        ),
                        Container(
                          margin:EdgeInsets.only(top: 35),
                          child: Text("Selecione os ingredientes dessa receita",),
                          ),
                        Container(
                          child:ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: ingredients.length,
                            itemBuilder: (BuildContext context, int index) {
                              print('$_add_ingr');
                              return
                                Column(
                                    children: [
                                      Row(
                                        children: [
                                          new IconButton(
                                            icon: Icon(
                                              Icons.add_circle,
                                              size: 30,
                                              color: AppColors.defaultGreen,
                                            ),
                                            onPressed: (){
                                              setState(() {
                                                if (_add_ingr != 0)
                                                  _add_ingr++;
                                              });
                                            }
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('$_add_ingr', style: TextStyle(fontSize: 20,),),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Icon(Icons.remove_circle, size: 30,
                                              color: AppColors.normalPink,),
                                          ),
                                          Expanded(child: ingredients[index],),
                                        ],
                                      ),
                                    ]
                                );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 35),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(AppColors.bntFundoVerde),
                            ),
                            child: Text('Adicionar novo ingrediente',
                              style: TextStyle(color: AppColors.bntTextoVerde),),
                            onPressed: () => setState(() => ingredients.add(createContainerIngredient())),
                          ),
                        ),
                        Container(child: Text("Adicione os passos dessa receita", ),),
                        Container(
                          child:ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: steps.length,
                            itemBuilder: (BuildContext context, int index) {
                              int teste = 0;
                              return
                                Column(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(teste.toString(), style: TextStyle(fontSize: 20,),),
                                          ),
                                          Expanded(child: steps[index],),
                                        ],
                                      ),
                                    ]
                                );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 35),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(AppColors.bntFundoVerde),
                            ),
                            child: Text('Adicionar novo passo',
                              style: TextStyle(color: AppColors.bntTextoVerde),),
                            onPressed: () => setState(() => steps.add(createContainerStep())),
                          ),
                        ),
                        Divider(color: AppColors.defaultGreen,height: 3, thickness: 1,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Tempo de preparo",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    )
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7.0))),
                                    elevation: MaterialStateProperty.all(0),
                                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                  ),
                                  onPressed: () {
                                    /*DatePicker.showTimePicker(context,
                                        theme: DatePickerTheme(
                                          containerHeight: MediaQuery.of(context).size.height * 0.25,
                                        ),
                                        showSecondsColumn: false,
                                        showTitleActions: true,
                                        onConfirm: (time) {
                                          print('confirm $time');
                                          _time = '${time.hour}h : ${time.minute}m ';
                                          _confirmTime = "Mudar";
                                          setState(() {});
                                        },
                                        currentTime: DateTime.parse("0000-00-00 00:00:00Z"),
                                        locale: LocaleType.pt);
                                    setState(() {});*/
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 50.0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    "$_time",
                                                    style: TextStyle(
                                                        color: AppColors.bntTextoVerde,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14.0),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.fromLTRB(15, 5, 0, 5),
                                          child: Text(
                                            "$_confirmTime",
                                            style: TextStyle(
                                                color: AppColors.darkPink,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Porções",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  )
                              ),
                              Row(children: <Widget>[
                                IconButton(
                                  onPressed: add_servings,
                                  icon: Icon(Icons.add_circle,
                                    size: 30,
                                    color: AppColors.defaultGreen,),
                                  color: AppColors.bntFundoVerde,
                                  iconSize: 15,

                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Text('$_servings',
                                      style: new TextStyle(fontSize: 20.0)),
                                ),
                                IconButton(
                                  onPressed: minus_servings,
                                  icon: Icon(Icons.remove_circle,
                                    size: 30,
                                    color: AppColors.normalPink,),
                                  color: AppColors.bntFundoVerde,
                                  iconSize: 15,

                                ),
                              ],)
                            ],
                          ),
                        ),
                        Container(height: 100,color: Colors.transparent,)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  Iterable<Widget> get tagRecipe sync* {
    for (TagRecipe _tag in _tagRecipe) {
      yield Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: FilterChip(
          backgroundColor: AppColors.bntFundoVerde,
          avatar: CircleAvatar(
            backgroundColor: AppColors.defaultGreen,
            child: Text(_tag.name[0].toUpperCase(),style: TextStyle(color: Colors.white),),
          ),
          label: Text(_tag.name,),
          selected: _filters.contains(_tag.name),selectedColor: AppColors.defaultGreen,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _filters.add(_tag.name);
              } else {
                _filters.removeWhere((String name) {
                  return name == _tag.name;
                });
              }
            });
          },
        ),
      );
    }
  }
  Iterable<Widget> get momRecipe sync* {
    for (MomRecipe _tag in _momRecipe) {
      yield Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: FilterChip(
          backgroundColor: AppColors.bntFundoVerde,
          avatar: CircleAvatar(
            backgroundColor: AppColors.defaultGreen,
            child: Text(_tag.name[0].toUpperCase(),style: TextStyle(color: Colors.white),),
          ),
          label: Text(_tag.name,),
          selected: _filters.contains(_tag.name),selectedColor: AppColors.defaultGreen,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _filters.add(_tag.name);
              } else {
                _filters.removeWhere((String name) {
                  return name == _tag.name;
                });
              }
            });
          },
        ),
      );
    }
  }

}

class TagRecipe {
  const TagRecipe(this.name);
  final String name;
}
class MomRecipe{
  const MomRecipe(this.name);
  final String name;
}

class IngredientEntry {
  final String name;

  IngredientEntry(this.name);
  @override
  String toString() {
    return 'Ingredient: name= $name';
  }
}

class StepsEntry {
  final String name;

  StepsEntry(this.name);
  @override
  String toString() {
    return 'Steps: name= $name';
  }
}

class BezierClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size){
    Path path = new Path();
    path.lineTo(0, size.height*0.8); //vertical line
    path.quadraticBezierTo(size.width/2, size.height, size.width, size.height*0.8); //quadratic curve
    path.lineTo(size.width, 0); //vertical line
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
class BoxShadowPainter extends CustomPainter {
  @override
  Path paint(Canvas canvas, Size size) {
    Path path = new Path();
    path.lineTo(0, size.height * 0.8); //vertical line
    path.quadraticBezierTo(size.width / 2, size.height, size.width,
        size.height * 0.8); //quadratic curve
    path.lineTo(size.width, 0); //vertical line

    canvas.drawShadow(path, Colors.black54, 8, false);
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}