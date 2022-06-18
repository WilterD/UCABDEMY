import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticateFirebaseUser{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<Map<String,dynamic>> registerFirebase({required String email, required String password, required String alias})async{
    Map<String,dynamic> data = {};
    try{
      final UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      await userCredential.user!.updateDisplayName(alias);
      data['user'] = userCredential.user;
    } on FirebaseAuthException catch (e){
      debugPrint(e.toString());
      data['error'] = e.code;
    }
    return data;
  }

  Future<Map<String,dynamic>> signInFirebase({required String email, required String password})async{
    Map<String,dynamic> data = {};
    try{
      final UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      data['user'] = userCredential.user;
    } on FirebaseAuthException catch (e){
      debugPrint(e.toString());
      data['error'] = e.code;
    }
    return data;
  }

  Future<Map<String,dynamic>> signOutFirebase()async{
    Map<String,dynamic> data = {};
    try{
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e){
      debugPrint(e.toString());
      data['error'] = e.code;
    }
    return data;
  }

  Future<Map<String,dynamic>> sendPasswordResetEmailFirebase({required String email})async{
    Map<String,dynamic> data = {};
    try{
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e){
      debugPrint(e.toString());
      data['error'] = e.code;
    }
    return data;
  }

  Future<Map<String,dynamic>> confirmPasswordResetFirebase({required String newPass, required String code})async{
    Map<String,dynamic> data = {};
    try{
      await firebaseAuth.confirmPasswordReset(newPassword: newPass,code: code);
    } on FirebaseAuthException catch (e){
      debugPrint(e.toString());
      data['error'] = e.code;
    }
    return data;
  }

}