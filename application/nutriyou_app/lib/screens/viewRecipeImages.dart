import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ViewImages extends StatefulWidget {
  final type;

  const ViewImages({Key key, this.type}) : super(key: key);

  @override
  _ViewImagesState createState() => _ViewImagesState();
}

class _ViewImagesState extends State<ViewImages> {
  var _image;
  var imagePicker;
  var type;

  @override
  void initState() {
    super.initState();
    imagePicker = new ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 52,
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    var source = ImageSource.gallery;
                    XFile image = await imagePicker.pickImage(
                        source: source, imageQuality: 50, preferredCameraDevice: CameraDevice.front);
                    setState(() {
                      _image = File(image.path);
                    });
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        color: Colors.red[200]),
                    child: _image != null
                        ? Image.file(
                              _image,
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.fitHeight,
                            )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.red[200]),
                            width: 200,
                            height: 200,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}