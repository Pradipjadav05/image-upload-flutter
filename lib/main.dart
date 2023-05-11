// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_upload_firestorage/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Something went wrong...!!");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Flutter Firestore CRUD',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            debugShowCheckedModeBanner: false,
            home: const Home(),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? image;
  final picker = ImagePicker();
  String? downloadUrl;
  Future imagePicker() async {
    try {
      final pick = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pick != null) {
          image = File(pick.path);
        } else {
          debugPrint("No image selected...");
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String> uploadImage(File image) async {
    String url;
    String imgId = DateTime.now().microsecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child("images").child("users$imgId");
    await reference.putFile(image);
    url = await reference.getDownloadURL();
    return url;
  }

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addWorker() async {
    final imageUrl = await uploadImage(image!);
    return await users
        .add({"name": "Pradip", "salary": 50000, "age": 21, "photo": imageUrl})
        .then((value) => print("User Added"))
        .whenComplete(() => print("Worker added to the firestore"))
        .catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Upload"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
                // ignore: unnecessary_null_comparison
                child: image == null
                    ? const Text("no image selected")
                    : Image.file(
                        image!,
                        height: 150,
                      )),
          ),
          ElevatedButton(
            child: const Text("select image"),
            onPressed: () {
              imagePicker();
              // imagePicker().whenComplete(() {
              //   uploadImage(image!);
              // });
            },
          ),
          ElevatedButton(
            child: const Text("Add User"),
            onPressed: () {
              addWorker();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home1(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
