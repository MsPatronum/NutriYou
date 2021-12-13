import 'package:flutter/material.dart';
import 'package:nutriyou_app/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeView extends StatefulWidget {
  //const MeView({ Key? key }) : super(key: key);

  @override
  _MeViewState createState() => _MeViewState();
}

class _MeViewState extends State<MeView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: FutureBuilder(
            builder: (context, snapshot){
              return Column(
              children: [
                /*SizedBox(
                  height: 115,
                  width: 115,
                  child: Stack(
                    fit: StackFit.expand,
                    overflow: Overflow.visible,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage("images/person.png"),
                      ),
                      Positioned(
                        right: -16,
                        bottom: 0,
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                alignment: Alignment.center,
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    side: BorderSide(color: Colors.white),
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all(Colors.grey.shade100)
                            ),
                            onPressed: () {},
                            child: Icon(Icons.camera, size: 20, color: Colors.teal,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),*/
                SizedBox(height: 10),
                Text(getNome().toString()),
                Text("nicoleeguido@gmail.com"),
                Text("ID: 8B0OLBCT6Y"),
                SizedBox(height: 20),
                ProfileMenu(
                  text: "Adicionar Pacientes",
                  icon: Icons.person_add,
                  press: () {},
                  visivel: false,
                ),
                ProfileMenu(
                  text: "Configurações",
                  icon: Icons.settings,
                  press: () {},
                  visivel: true,
                ),
                ProfileMenu(
                  text: "Log Out",
                  icon: Icons.exit_to_app_rounded,
                  press: () {},
                  visivel: true,
                ),
              ],
            );
            },
            
          ),
        ));
  }
}

class ProfileMenu extends StatelessWidget {
  ProfileMenu({
    Key key,
    @required this.text,
    @required this.icon,
    @required this.visivel,
    this.press,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final VoidCallback press;
  bool visivel;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: visivel,
        child:Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(2),
              padding: MaterialStateProperty.all(EdgeInsets.all(20)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),),
              backgroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: press,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.teal,
                  size: 22,
                ),
                SizedBox(width: 20),
                Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade800),)),
                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade800,),
              ],
            ),
          ),)
    );
  }
}