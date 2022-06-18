import 'package:flutter/material.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/services/authenticate_firebase.dart';
import 'package:ucabdemy/views/login/register_page.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/textfield_general.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';

class ResetPasswordEmail extends StatefulWidget {
  const ResetPasswordEmail({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  State<ResetPasswordEmail> createState() => _ResetPasswordEmailState();
}

class _ResetPasswordEmailState extends State<ResetPasswordEmail> {

  double sizeH = 0;
  double sizeW = 0;
  bool loadLogin = false;
  bool viewPass = false;
  TextEditingController controllerEmail = TextEditingController();

  bool viewSend = true;
  TextEditingController controllerCode = TextEditingController();
  TextEditingController controllerPass = TextEditingController();



  @override
  void initState() {
    controllerEmail.text = widget.email;
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
          title: 'RESTABLECER CONTRASEÑA',
          onTap: (){
            Navigator.of(context).pop();
          }
        ),
        backgroundColor: UcabdemyColors.primary_4,
        body: viewSend ? view1() : view2(),
      ),
    );
  }

  Widget view1(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sizeH * 0.3,),
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
              title: 'Enviar',
              height: sizeH * .06,
              width: sizeW * .8,
              borderColor: UcabdemyColors.primary,
              textStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.bold,color: Colors.white),
              onPressed: ()=>loginUser(),
            ),
          ),
        ],
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

    if(errorText.isEmpty){
      try{
        Map<String,dynamic> data = await AuthenticateFirebaseUser().sendPasswordResetEmailFirebase(email: controllerEmail.text);
        if(!data.containsKey('error')){
          showAlert(text: 'Código enviado',color: Colors.green);
        }else{
          String error = data.containsKey('error') ? data['error'] : 'Problmas de conexión con el servidor';
          showAlert(text: error,color: Colors.redAccent);
        }
      }catch(e){
        showAlert(text: 'Error: ${e.toString()}',color: Colors.redAccent);
      }
    }else{
      showAlert(text: errorText,color: Colors.redAccent);
    }
    loadLogin = false;
    setState(() {});
  }

  Widget view2(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sizeH * 0.15,),
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
                //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context2) => new RecoverPassword(blocData: widget.blocData,)));
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
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context2) => const RegisterPage()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: sizeW * 0.06,),
                child: Text('Registrarme',style: UcademyStyles().stylePrimary(size: sizeH * 0.025,color: UcabdemyColors.primary_1,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              ),
            ),
          )
        ],
      ),
    );
  }
}
