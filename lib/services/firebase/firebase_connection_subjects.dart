import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseConnectionSubjects{

  final CollectionReference subjectsCollection = FirebaseFirestore.instance.collection('subjects');

  Future<bool> createSubjects(Map<String,dynamic> data) async {
    bool res = false;
    try{
      await subjectsCollection.add(data);
      res = true;
    }catch(ex){
      debugPrint(ex.toString());
    }
    return res;
  }

  Future<List<QueryDocumentSnapshot>> getAllSubjects() async{
    List<QueryDocumentSnapshot> listAll = [];
    try{
      var result =  await subjectsCollection.get();
      listAll = result.docs.map((QueryDocumentSnapshot e) => e).toList();
    }catch(ex){
      debugPrint(ex.toString());
    }
    return listAll;
  }

  Future<bool> editSubjects({required Map<String, dynamic> data,required String id}) async {
    bool res = false;
    try{
      await subjectsCollection.doc(id).update(data);
      res = true;
    }catch(ex){
      debugPrint(ex.toString());
    }
    return res;
  }

}

