import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:find_my_bus/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomePageConductor extends StatefulWidget {
  const HomePageConductor({Key? key}) : super(key: key);
  static String id = 'editprofile_screen';

  @override
  _HomePageConductor createState() => _HomePageConductor();
}

class _HomePageConductor extends State<HomePageConductor> {
  @override
  XFile? _image;
  _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  final ImagePicker _picker = ImagePicker();

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Future<void> _getUser() async {
    user = _auth.currentUser!;
  }

  String downloadURL = '';
  Future<void> download() async {
    downloadURL = await FirebaseStorage.instance
        .ref('${user!.email}/profile.png')
        .getDownloadURL();
  }

  String busid = '';
  String busnumber = '';
  String end = '';
  String start = '';
  Future<void> _getData() async {
    final DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection('buses').doc(busid).get();
    end = ds.get('end');
    start = ds.get('start');
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    download();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool usernameExists = false;
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF3383CD),
                  Color(0xFF11249F),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60.0),
                bottomRight: Radius.circular(60.0),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 180.0,
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                downloadURL,
                              ))),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            _showPicker(context);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 4,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              color: Colors.green,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 80.0,
              ),
              Container(
                height: 70.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Bus Id",
                      hintText: 'PB043892',
                      prefixIcon: Icon(
                        Icons.directions_bus,
                      ),
                    ),
                    onChanged: (value) {
                      busid = value;
                      print(busid);
                    },
                  ),
                ),
              ),
              Container(
                height: 70.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "BusNumber",
                      hintText: 'PB05CD8439',
                      prefixIcon: Icon(
                        Icons.featured_play_list,
                      ),
                    ),
                    onChanged: (value) {
                      busnumber = value;
                      print(busnumber);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 80.0,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 20.0),
                child: FlatButton(
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.email)
                          .update({
                        'busid': busid,
                        'busnumber': busnumber,
                      }).then((value) async {
                        print("User Added");
                        if (_image != null) {
                          try {
                            await FirebaseStorage.instance
                                .ref('${user!.email}/profile.png')
                                .putFile(File(_image!.path));
                          } on FirebaseException catch (err) {
                            print(err);
                          }
                        }
                      });
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        print('The password provided is too weak.');
                      } else if (e.code == 'email-already-in-use') {
                        print('The account already exists for that email.');
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  color: Colours.orangyish,
                  padding: EdgeInsetsDirectional.all(2.0),
                  minWidth: 120.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
