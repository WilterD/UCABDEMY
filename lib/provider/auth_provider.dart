import 'package:flutter/material.dart';
import 'package:ucabdemy/services/shared_preferences_local.dart';

enum AuthStatus { splash,login,home,admin}

class AuthProvider extends ChangeNotifier {

  AuthStatus authStatus = AuthStatus.splash;

  AuthProvider() {
    isAuthenticated();
  }

  Future isAuthenticated() async {
    int isLogin = SharedPreferencesLocal.prefs.getInt('pleksusLogin') ?? 0;
    if(isLogin == 0){
      authStatus = AuthStatus.login;
    }
    if(isLogin == 1){
      authStatus = AuthStatus.home;
    }
    if(isLogin == 2){
      authStatus = AuthStatus.admin;
    }
    notifyListeners();
  }
}
