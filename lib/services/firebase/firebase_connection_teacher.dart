import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseConnectionTeachers{

  final CollectionReference teacherCollection = FirebaseFirestore.instance.collection('teachers');

  Future<bool> createTeacher(Map<String,dynamic> data) async {
    bool res = false;
    try{
      await teacherCollection.add(data);
      res = true;
    }catch(ex){
      debugPrint(ex.toString());
    }
    return res;
  }

  Future<List<QueryDocumentSnapshot>> getAllTeachers() async{
    List<QueryDocumentSnapshot> listAll = [];
    try{
      var result =  await teacherCollection.get();
      listAll = result.docs.map((QueryDocumentSnapshot e) => e).toList();
    }catch(ex){
      debugPrint(ex.toString());
    }
    return listAll;
  }

  Future<List<QueryDocumentSnapshot>> getTeachers({required String id}) async{
    List<QueryDocumentSnapshot> listAll = [];
    try{
      var result =  await teacherCollection.where('uid',isEqualTo: id).get();
      listAll = result.docs.map((QueryDocumentSnapshot e) => e).toList();
    }catch(ex){
      debugPrint(ex.toString());
    }
    return listAll;
  }

  Future<bool> editTeacher({required Map<String, dynamic> data,required String id}) async {
    bool res = false;
    try{
      await teacherCollection.doc(id).update(data);
      res = true;
    }catch(ex){
      debugPrint(ex.toString());
    }
    return res;
  }

}

