import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/config/value_validators.dart';
import 'package:ucabdemy/services/authenticate_firebase.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/textfield_general.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  double sizeH = 0;
  double sizeW = 0;
  bool loadSave = false;

  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  TextEditingController controllerPassConfirm = TextEditingController();

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
          title: 'Registro',
          onTap: () => Navigator.of(context).pop(),
        ),
        backgroundColor: UcabdemyColors.primary_4,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: sizeH * 0.04,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
                child: TextFieldGeneral(
                  sizeH: sizeH,
                  sizeW: sizeW,
                  hintText: 'Correo',
                  labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500,color: Colors.grey),
                  textEditingController: controllerEmail,
                  initialValue: null,
                  textCapitalization: TextCapitalization.none,
                  textInputType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: sizeH * 0.03,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
                child: TextFieldGeneral(
                  sizeH: sizeH,
                  sizeW: sizeW,
                  hintText: 'Nombre Completo',
                  labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500,color: Colors.grey),
                  textEditingController: controllerName,
                  initialValue: null,
                  textInputType: TextInputType.name,
                ),
              ),
              SizedBox(height: sizeH * 0.03,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
                child: TextFieldGeneral(
                  sizeH: sizeH,
                  sizeW: sizeW,
                  hintText: 'Contraseña',
                  labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500,color: Colors.grey),
                  textEditingController: controllerPass,
                  initialValue: null,
                  textInputType: TextInputType.visiblePassword,
                  obscure: true,
                ),
              ),
              SizedBox(height: sizeH * 0.03,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
                child: TextFieldGeneral(
                  sizeH: sizeH,
                  sizeW: sizeW,
                  textInputType: TextInputType.visiblePassword,
                  hintText: 'Confirmar contraseña',
                  labelStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.w500,color: Colors.grey),
                  textEditingController: controllerPassConfirm,
                  initialValue: null,
                  obscure: true,
                ),
              ),
              SizedBox(height: sizeH * 0.04,),
              loadSave ?
              circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04)
               :
              ButtonGeneral(
                backgroundColor: UcabdemyColors.primary,
                radius: 10,
                title: 'Crear cuenta',
                height: sizeH * .06,
                width: sizeW * .8,
                borderColor: UcabdemyColors.primary,
                textStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.bold,color: Colors.white),
                onPressed: () => saveUser(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveUser() async{

    loadSave = true;
    setState(() {});

    FocusScope.of(context).requestFocus(FocusNode());

    String errorText = '';
    if(errorText.isEmpty && controllerEmail.text.isEmpty){
      errorText = 'Correo no puede estar vacio';
    }
    if(errorText.isEmpty && !validateEmailAddress(email: controllerEmail.text,context: context)['valid']){
      errorText = validateEmailAddress(email: controllerEmail.text,context: context)['sms'];
    }
    if(errorText.isEmpty && controllerName.text.isEmpty){
      errorText = 'Nombre no puede estar vacio';
    }
    if(errorText.isEmpty && controllerPass.text.isEmpty){
      errorText = 'Contraseña no puede estar vacia';
    }
    if(errorText.isEmpty && controllerPass.text.length < 8){
      errorText = 'Contraseña debe contener al menos 8 caracteres';
    }
    if(errorText.isEmpty && controllerPass.text != controllerPassConfirm.text){
      errorText = 'Contraseñas deben coincidir';
    }

    if(errorText.isEmpty){
      try{
        Map<String,dynamic> data = await AuthenticateFirebaseUser().registerFirebase(
            email: controllerEmail.text, password: controllerPass.text,alias: controllerName.text);
        if(data.containsKey('user')){
          showAlert(text: 'Bienvenido',color: Colors.green);
          Navigator.of(context).pop(true);
        }else{
          String error = data.containsKey('error') ? data['error'] : 'Problmas de conexión con el servidor';
          showAlert(text: error,color: Colors.redAccent);
        }

      }catch(e){
        showAlert(text: 'Error de conexión con el servidor',color: Colors.redAccent);
      }
    }else{
      showAlert(text: errorText,color: Colors.redAccent);
    }
    loadSave = false;
    setState(() {});
  }
}
