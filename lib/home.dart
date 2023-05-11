import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_upload_firestorage/user.dart';
import "package:flutter/material.dart";

class Home1 extends StatefulWidget {
  const Home1({super.key});

  @override
  State<Home1> createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  List<Users> listUser = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home1"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error initializing Firebase');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16.0),
            itemBuilder: (context, index) {
              var userData = snapshot.data!.docs[index].data();
              var docId = snapshot.data!.docs[index].id;
              var getUser = Users(
                  userId: docId,
                  userName: userData['name'],
                  userPhoto: userData['photo'],
                  userAge: userData['age'],
                  userSalary: userData['salary']);

              var name = getUser.userName;
              String photo = getUser.userPhoto;
              var salary = getUser.userSalary;
              var age = getUser.userAge;
              debugPrint("Images..... : $photo");
              listUser.add(getUser);

              return Card(
                elevation: 5.0,
                child: ListTile(
                  title: Text(name),
                  leading: Image.network(
                    photo,
                    height: 50,
                    width: 50,
                  ),
                  subtitle: Text("salary : $salary"),
                  trailing: Text("Age : $age"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
