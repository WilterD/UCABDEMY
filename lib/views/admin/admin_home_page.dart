import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/services/authenticate_firebase.dart';
import 'package:ucabdemy/services/shared_preferences_local.dart';
import 'package:ucabdemy/views/admin/subjects/subjects.dart';
import 'package:ucabdemy/views/admin/teacher/teachers.dart';
import 'package:ucabdemy/views/login/login_page.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<AdminHomePage> {

  double sizeH = 0;
  double sizeW = 0;

  @override
  Widget build(BuildContext context) {

    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: appBarWidget(
        sizeH: sizeH,
        title: 'UCABDEMY ADMIN',
        elevationActive: false,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app,color: Colors.white,size: sizeH * 0.03),
            onPressed: () async {
              try{
                await AuthenticateFirebaseUser().signOutFirebase();
                showAlert(text: 'Desconectando',color: Colors.redAccent);
                SharedPreferencesLocal.prefs.setInt('pleksusLogin',0);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context2) => const LoginPage()));
              }catch(_){}
            },
          )
        ]
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: sizeH * 0.02),
              child: ButtonGeneral(
                backgroundColor: UcabdemyColors.primary,
                radius: 10,
                title: 'PROFESORES',
                height: sizeH * .06,
                width: sizeW * .8,
                borderColor: UcabdemyColors.primary,
                textStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.bold,color: Colors.white),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>const Teachers(),),);
                },
              ),
            ),
          ),

          const SizedBox(height: 20),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: sizeH * 0.02),
              child: ButtonGeneral(
                backgroundColor: UcabdemyColors.primary,
                radius: 10,
                title: 'MATERIAS',
                height: sizeH * .06,
                width: sizeW * .8,
                borderColor: UcabdemyColors.primary,
                textStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.bold,color: Colors.white),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>const Subjects(),),);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
