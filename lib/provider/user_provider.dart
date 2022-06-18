import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_teacher.dart';
import 'package:ucabdemy/services/shared_preferences_local.dart';

class UserProvider extends ChangeNotifier {

  User? userFirebase;
  bool loadDataUser = true;
  bool isTeacher = false;
  int selectedBottomHome = 1;
  List<String>? listVideos = [];

  UserProvider() {
    userActive();
    getListVideos();
  }

  Future userActive() async {
    FirebaseAuth.instance.authStateChanges().listen((event) async {
      userFirebase = event;
      if(userFirebase != null){
        List<QueryDocumentSnapshot> listTeacher = await FirebaseConnectionTeachers().getTeachers(id: userFirebase!.uid);
        isTeacher = listTeacher.isNotEmpty;
      }
      loadDataUser = false;
      notifyListeners();
    });
  }

  void changeSelectedBottomHome({required int type}){
    selectedBottomHome = type;
    notifyListeners();
  }

  void getListVideos(){
    try{
      listVideos = SharedPreferencesLocal.prefs.getStringList('UcabdemyVideos') ?? [];
      notifyListeners();
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future updateListVideos({required String pathNew}) async{
    listVideos!.add(pathNew);
    SharedPreferencesLocal.prefs.setStringList('UcabdemyVideos', listVideos!);
    notifyListeners();
  }

  void deleteVideo({required int index}){
    listVideos!.removeAt(index);
    SharedPreferencesLocal.prefs.setStringList('UcabdemyVideos', listVideos!);
    notifyListeners();
  }
}
