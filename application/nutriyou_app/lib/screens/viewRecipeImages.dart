import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:nutriyou_app/const.dart';
import 'package:nutriyou_app/routing_constants.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImgKeyValue {
    String fn;
    String encoded;
    
    ImgKeyValue({this.fn, this.encoded});
    
    Map<String, String> toJson() => <String, String> {
    	'fn': fn,
        'encoded': encoded,
    };
}

class IKVList {
    List<ImgKeyValue> imgKeyValues;
    
    IKVList(this.imgKeyValues);
    
    Map<String, dynamic> toJson() => <String, dynamic> {
    	'imgKeyValues': imgKeyValues,
    };
}

class ImgUpload extends StatefulWidget {
  @override
  _imgUpload createState() => _imgUpload();
}

class _imgUpload extends State<ImgUpload> {
  ImagePicker _picker = ImagePicker();
  List<XFile> _imageFileList;

  void _xFilesToFiles(List<XFile> imageFileList) {
    imageFileList.forEach((element) {
      fileList.add(File(element.path));
    });
  }

  List<Widget> fileListThumb;
  List<File> fileList = [];

  Future _pickFiles() async {
    List<Widget> thumbs = [];
    final pickedFileList = await _picker.pickMultiImage();
    setState(() {
      _imageFileList = pickedFileList;
    });
    _xFilesToFiles(_imageFileList);
    if (fileList != null && fileList.length > 0) {
      fileList.forEach((element) {
        thumbs.add(
            Padding(padding: EdgeInsets.all(1), child: Image.file(element)));
      });
      setState(() {
        fileListThumb = thumbs;
      });
    }
  }

  IKVList toBase64(List<File> fileList) {
    List<ImgKeyValue> imgKeyValues = [];

    if (fileList.length > 0) {
      fileList.forEach((element) {
        ImgKeyValue _imgKeyValue = ImgKeyValue(fn: basename(element.path), encoded: base64Encode(element.readAsBytesSync()));
        imgKeyValues.add(_imgKeyValue);
      });
    }

    IKVList ikvList = IKVList(imgKeyValues);

    return ikvList;
  }

  _uploadImages(IKVList ikvList) {
    UploadController().uploadImages(ikvList);
  }

  @override
  Widget build(BuildContext context) {
    if (fileListThumb == null){
      fileListThumb = [
        InkWell(
          onTap: _pickFiles,
          child: Container(
            child: Icon(
              Icons.add, 
              size: 50, 
              color: Colors.white,
            ),
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.teal.shade400,
              borderRadius: BorderRadius.circular(100)
            ),
          ),
        )
      ];
    }
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
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    children: fileListThumb,
                  ),
                )
              ),
              fileListThumb.length >= 1 ? SizedBox(
                height: 80,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal.shade300), 
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    padding: MaterialStateProperty.all(EdgeInsets.all(12))),
                    onPressed: () async {
                      IKVList _ikvList = toBase64(fileList);
                      _uploadImages(_ikvList);
                      Navigator.popUntil(context, ModalRoute.withName(MealsDetailsRoute));
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Text(
                              'Concluir', 
                              style: TextStyle(
                                color: Colors.white
                              )
                            ),
                            Icon(
                              Icons.playlist_add_check_rounded,
                              color: Colors.white,
                            )
                          ]
                        ),

                      ],
                    ),
                  ),
                ),
              ):Container(
                child: Text(
                  "Esta receita não tem nenhum passo ainda. Adicione!", 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class UploadController {

  Future<bool> uploadImages(IKVList ikvList) async {
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var receitaId = prefs.getInt('receita_id');

    final _ikvList = json.encoder.convert(ikvList);
    var data = {'receita_id': receitaId, 'ikvList' : ikvList};
    print(data);
    var response = await  http.post(Uri.parse(link("recipe/add_images.php")), body: json.encode(data));
    
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
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