import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ucabdemy/provider/auth_provider.dart';
import 'package:ucabdemy/views/admin/admin_home_page.dart';
import 'package:ucabdemy/views/home/home_page.dart';
import 'package:ucabdemy/views/login/login_page.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);

    if ( authProvider.authStatus == AuthStatus.splash ) {
      return const BasicSplash();
    }
    if( authProvider.authStatus == AuthStatus.login ) {
      return const LoginPage();
    }
    if( authProvider.authStatus == AuthStatus.home ) {
      return const HomePage();
    }
    if( authProvider.authStatus == AuthStatus.admin ) {
      return const AdminHomePage();
    }
    return const BasicSplash();
  }
}

class BasicSplash extends StatelessWidget {
  const BasicSplash({Key? key}) : super(key: key);

  Future<bool> exit() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;
    return WillPopScope(
        child: Scaffold(
          body: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.03,),
        ),
        onWillPop: exit
    );
  }
}
