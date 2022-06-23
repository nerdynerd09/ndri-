import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File? image;
  String? imagePath;
  String? imageName;
  String? urlDownload;
  // var _image;

  // Uploading to Firebase
  Future uploadFile() async{
    File? imagePathUpload = image;
    String? imageNameUpload = imageName;
    UploadTask? uploadTask;

    // final firebasePath  = 'files/$imageNameUpload';
    final firebasePath  = '$imageNameUpload';
    final firebaseFile = imagePathUpload;

    final ref = FirebaseStorage.instance.ref().child(firebasePath);
    uploadTask = ref.putFile(imagePathUpload!);

    final snapshot = await uploadTask.whenComplete((){});

    urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');
    print("Path from Upload: $imagePathUpload");
    print("Name from Upload: $imageNameUpload");

    makeRequest();
  }

  // Making request to our server
  makeRequest() async{
    var url = Uri.parse("http://10.0.2.2:5000/?url=$imageName");
    var response = await http.get(url);
    print("Response from server: ${response.body}");

  }


  // Selecting Image
  Future pickImage(ImageSource source) async{
    try{
      final image = await ImagePicker().pickImage(source: source);
    if(image==null) return;

    final imageTemporary = File(image.path);
    // final imageTemporary = File(image);
    setState(() {
      // this.image=File(image.path);
      this.image=imageTemporary;
      imagePath = (image.path);
      imageName = image.name;
      print("ImagePath: $imagePath");
      print("ImageName: $imageName");
    });
    }on PlatformException catch (e){
      print('Failed to pick images $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gopal Sarathi'),
          leading: const Icon(Icons.dehaze_outlined),
        ),
        body: Column(
            children: [
              SizedBox(height: 25,),
              
              image!=null?Image.file(image!,height: 240,width: 440,fit: BoxFit.fill):
              Container(
                margin: EdgeInsets.all(15),
                height: 240,
                width: 440,
                decoration:BoxDecoration(color: Colors.red,image: DecorationImage(fit: BoxFit.fill,image: AssetImage('assets/cow.jpeg'))),
                // child: _image!=null?Image.file(_image,width: 340,height: 240,fit: BoxFit.fill,):Image.network('https://artprojectsforkids.org/wp-content/uploads/2021/01/Cow.jpeg'),
                // child: Text("hellooo"),
              ),
              
              SizedBox(height:30),
              ElevatedButton(onPressed: () {pickImage(ImageSource.camera);}, child: Text('Camera')),
              ElevatedButton(onPressed: () {pickImage(ImageSource.gallery);}, child: Text('Gallery')),
              ElevatedButton(onPressed: () {uploadFile();}, child: Text('Proceed')),
              
              ]),
      ),
    );
  }


 
}

