import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:nutriyou_app/const.dart';

class ViewImages extends StatefulWidget {
  final type;

  const ViewImages({Key key, this.type}) : super(key: key);

  @override
  _ViewImagesState createState() => _ViewImagesState();
}
  
class _ViewImagesState extends State<ViewImages> {
  
 
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];

  Future addImages() async {

    final Map<String,List> someMap = {};

    for (int i=0; i<imageFileList.length;i++){
      List<int> imageBytes = File(imageFileList[i].path).readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      someMap[baseimage] = imageBytes;
    }

    var response = await http.post(Uri.parse(link('recipes/add_images.php')), body: {'image': someMap, });
    
  }

  

  void selectImages() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList.addAll(selectedImages);
    }
    print("Image List Length:" + imageFileList.length.toString());
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildTitle("Adicione as fotos"),
        backgroundColor: Colors.transparent,
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                selectImages();
              },
              child: Text('Select Images'),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: imageFileList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      return Image.file(File(imageFileList[index].path), fit: BoxFit.cover,);
                    }),
              ),
            ),
            SizedBox(
              height: 80,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal.shade300), 
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                  padding: MaterialStateProperty.all(EdgeInsets.all(12))),
                  onPressed: () {
                    addImages();
                    /*Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(name: '/view_ingredients'),
                        builder: (BuildContext context) {
                          return new ViewIngredients();
                        },
                      ),
                    );*/
                    //Navigator.of(context).popUntil(ModalRoute.withName(HomeViewRoute));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Text(
                        'Próximo', 
                        style: TextStyle(
                          color: Colors.white
                        )
                      ),
                      Icon(
                        Icons.arrow_forward_outlined, 
                        color: Colors.white,
                      )
                    ]
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}

buildTitle(String text){
  return Padding(
    padding: EdgeInsets.all(8),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.black,
        fontSize: 22,
      ),
    ),
  );
}
buildTitleText(String text){
  return Container(
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
      ),
    ),
  );
}