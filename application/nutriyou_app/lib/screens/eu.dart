import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/routing_constants.dart';
import 'package:nutriyou_app/screens/login.dart';
import 'package:nutriyou_app/screens/view_pacientes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeView extends StatefulWidget {
  //const MeView({ Key? key }) : super(key: key);

  @override
  _MeViewState createState() => _MeViewState();
}

class _MeViewState extends State<MeView> {

  getKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final prefsMap = Map<String, dynamic>();
    for(String key in keys) {
      prefsMap[key] = prefs.get(key);
    }

    return prefsMap;
  }

  logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

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
            future: getKeys(),
            builder: (context, snapshot){
              if(snapshot.hasData){
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
                      Text(snapshot.data['nome']),
                      Text(snapshot.data['email']),
                      Text("ID: "+snapshot.data['token']),
                      SizedBox(height: 20),
                      ProfileMenu(
                        text: "Meus Pacientes",
                        icon: Icons.person_search_rounded,
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: '/view_patients'),
                              builder: (BuildContext context){
                                return ViewPatient();
                              }
                            )
                          );
                        },
                        visivel: snapshot.data['tipo'] == 1? true : false,
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
                        press: () {
                          logout();
                          print(ModalRoute.of(context).settings.name);
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context, 
                            MaterialPageRoute(
                              settings: RouteSettings(name: '/login'),
                              builder: (BuildContext context) {
                                return LoginUser();
                              },
                            ),
                          );
                        },
                        visivel: true,
                      ),
                    ],
                  );
              }else{
                return CircularProgressIndicator();
              }
              
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