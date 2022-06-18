import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/services/authenticate_firebase.dart';
import 'package:ucabdemy/services/shared_preferences_local.dart';
import 'package:ucabdemy/views/admin/admin_home_page.dart';
import 'package:ucabdemy/views/home/home_page.dart';
import 'package:ucabdemy/views/login/register_page.dart';
import 'package:ucabdemy/views/login/reset_email_page.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/textfield_general.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  double sizeH = 0;
  double sizeW = 0;
  bool loadLogin = false;
  bool viewPass = false;
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPass = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: appBarWidget(
          sizeH: sizeH,
          title: 'LOGIN',
          elevationActive: false
        ),
        backgroundColor: UcabdemyColors.primary_4,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: sizeH * 0.1,),
              iconApp(),
              // SizedBox(
              //   width: sizeW,
              //   child: Text('UCABDEMY',style: UcademyStyles().stylePrimary(size: 60,color: UcabdemyColors.primary,fontWeight: FontWeight.bold,),textAlign: TextAlign.center),
              // ),
              SizedBox(height: sizeH * 0.08,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
                child: TextFieldGeneral(
                  sizeH: sizeH,
                  sizeW: sizeW,
                  hintText: 'Correo',
                  labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500, color: Colors.grey),
                  textEditingController: controllerEmail,
                  initialValue: null,
                  textInputType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                ),
              ),
              SizedBox(height: sizeH * 0.025,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
                child: TextFieldGeneral(
                  sizeH: sizeH,
                  sizeW: sizeW,
                  hintText: 'Contraseña',
                  labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500, color: Colors.grey),
                  textEditingController: controllerPass,
                  initialValue: null,
                  textInputType: TextInputType.visiblePassword,
                  obscure: !viewPass,
                  suffixIcon: InkWell(
                    onTap: (){
                      setState(() {
                        viewPass = !viewPass;
                      });
                    },
                    child: Icon(viewPass ? Icons.remove_red_eye_outlined : Icons.remove_red_eye),
                  ),
                ),
              ),
              SizedBox(height: sizeH * 0.02,),
              SizedBox(
                width: sizeW,
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context2) => ResetPasswordEmail(email: controllerEmail.text,)));
                  },
                  child: Text('Olvidé la contraseña',style: UcademyStyles().stylePrimary(size: sizeH * 0.02,color: UcabdemyColors.primary_1,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                ),
              ),
              SizedBox(height: sizeH * 0.04,),
              loadLogin ?
              Container(
                margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
                child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
              )
                  :
              Container(
                margin: EdgeInsets.symmetric(vertical: sizeH * 0.02),
                child: ButtonGeneral(
                  backgroundColor: UcabdemyColors.primary,
                  radius: 10,
                  title: 'Entrar',
                  height: sizeH * .06,
                  width: sizeW * .8,
                  borderColor: UcabdemyColors.primary,
                  textStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.bold,color: Colors.white),
                  onPressed: ()=>loginUser(),
                ),
              ),
              SizedBox(
                width: sizeW,
                child: InkWell(
                  onTap: () async{
                    bool? res = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context2) => const RegisterPage()));
                    if(res != null &&  res){
                      SharedPreferencesLocal.prefs.setInt('pleksusLogin',1);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context2) => const HomePage()));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: sizeW * 0.06,),
                    child: Text('Registrarme',style: UcademyStyles().stylePrimary(size: sizeH * 0.025,color: UcabdemyColors.primary_1,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget iconApp(){
    return SizedBox(
      width: sizeW,
      child: Container(
        height: sizeH * 0.25,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.asset('assets/image/logo_app.png').image,
                fit: BoxFit.fitHeight
            )
        ),
      ),
    );
  }

  Future<void> loginUser() async{

    loadLogin = true;
    setState(() {});

    FocusScope.of(context).requestFocus(FocusNode());

    String errorText = '';
    if(errorText.isEmpty && controllerEmail.text.isEmpty){
      errorText = 'Correo no puede estar vacio';
    }

    if(errorText.isEmpty && controllerPass.text.isEmpty){
      errorText = 'Contraseña no puede estar vacio';
    }

    if(errorText.isEmpty){

      if(controllerEmail.text == 'admin@ucabdemy.com' && controllerPass.text == '123456'){
        SharedPreferencesLocal.prefs.setInt('pleksusLogin',2);
        showAlert(text: 'Bienvenido admin',color: Colors.green);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context2) => const AdminHomePage()));
      }else{
        try{
          Map<String,dynamic> data = await AuthenticateFirebaseUser().signInFirebase(email: controllerEmail.text, password: controllerPass.text);
          if(data.containsKey('user')){
            SharedPreferencesLocal.prefs.setInt('pleksusLogin',1);
            showAlert(text: 'Bienvenido',color: Colors.green);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context2) => const HomePage()));
          }else{
            String error = data.containsKey('error') ? data['error'] : 'Problmas de conexión con el servidor';
            showAlert(text: error,color: Colors.redAccent);
          }
        }catch(e){
          showAlert(text: 'Error: ${e.toString()}',color: Colors.redAccent);
        }
      }
    }else{
      showAlert(text: errorText,color: Colors.redAccent);
    }
    loadLogin = false;
    setState(() {});
  }
}
