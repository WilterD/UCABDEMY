import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseConnectionStudents{

  final CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');

  Future<QueryDocumentSnapshot?> createStudent(Map<String,dynamic> data) async {
    QueryDocumentSnapshot? res;
    try{
      var ref = await studentsCollection.add(data);
      data['ref'] = ref.id;
      await editStudent(id: ref.id, data: data);
    }catch(ex){
      debugPrint(ex.toString());
    }
    return res;
  }

  Future<List<QueryDocumentSnapshot>> getAllStudents() async{
    List<QueryDocumentSnapshot> listAll = [];
    try{
      var result =  await studentsCollection.get();
      listAll = result.docs.map((QueryDocumentSnapshot e) => e).toList();
    }catch(ex){
      debugPrint(ex.toString());
    }
    return listAll;
  }

  Future<List<QueryDocumentSnapshot>> getStudent({required String id}) async{
    List<QueryDocumentSnapshot> listAll = [];
    try{
      var result =  await studentsCollection.where('uid',isEqualTo: id).get();
      listAll = result.docs.map((QueryDocumentSnapshot e) => e).toList();
    }catch(ex){
      debugPrint(ex.toString());
    }
    return listAll;
  }

  Future<bool> editStudent({required Map<String, dynamic> data,required String id}) async {
    bool res = false;
    try{
      await studentsCollection.doc(id).update(data);
      res = true;
    }catch(ex){
      debugPrint(ex.toString());
    }
    return res;
  }

}

