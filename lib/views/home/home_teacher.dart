import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:ucabdemy/services/authenticate_firebase.dart';
import 'package:ucabdemy/services/firebase/firebase_connection_subjects.dart';
import 'package:ucabdemy/services/shared_preferences_local.dart';
import 'package:ucabdemy/views/call/jitsi_meet_page.dart';
import 'package:ucabdemy/views/home/home_video.dart';
import 'package:ucabdemy/views/login/login_page.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';

class HomeTeacher extends StatefulWidget {
  const HomeTeacher({Key? key}) : super(key: key);

  @override
  State<HomeTeacher> createState() => _HomeTeacherState();
}

class _HomeTeacherState extends State<HomeTeacher> {

  double sizeH = 0;
  double sizeW = 0;
  final CollectionReference teachersCollection = FirebaseFirestore.instance.collection('teachers');
  List<QueryDocumentSnapshot> listSubjects = [];
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future initialData() async{
    listSubjects = await FirebaseConnectionSubjects().getAllSubjects();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: UcabdemyColors.primary_4,
      appBar: appBarWidget(
          sizeH: sizeH,
          title: 'UCABDEMY PROFESOR',
          elevationActive: true,
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
            ),
          ],

        leadingW: Container(
          margin: EdgeInsets.only(left: sizeW * 0.02),
          width: sizeH * 0.08,
          child: Container(
            height: sizeH * 0.0025,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: Image.asset('assets/image/logo_app.png').image,
                    fit: BoxFit.fitWidth
                )
            ),
          ),
        ),
      ),
      body: userProvider.userFirebase == null ? Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
          child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
        ),
      ) : userProvider.selectedBottomHome == 1 ? streamBody() : const HomeVideo(),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  Widget streamBody(){
    return StreamBuilder<QuerySnapshot>(
      stream: teachersCollection.where('uid',isEqualTo: userProvider.userFirebase!.uid).snapshots(),
      builder: (context,snapshot){
        if (snapshot.data == null){
          return Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
              child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
            ),
          );
        }

        Map<String,dynamic> data = snapshot.data!.docs[0].data() as Map<String,dynamic>;

        return Column(
          children: [
            Container(
              width: sizeW,
              margin: const EdgeInsets.only(top: 10,left: 10),
              child: Text(userProvider.userFirebase!.displayName!,style: UcademyStyles().stylePrimary(size: sizeH * 0.03)),
            ),
            Expanded(
              child: viewSubjects(data['subjects']),
            ),
          ],
        );
      },
    );
  }

  Widget viewSubjects(List listSubjectsTeacher){

    List<Widget> listW = [];
    for(int x = 0; x < listSubjects.length; x++){

      QueryDocumentSnapshot elementListSubjects = listSubjects[x];
      Map<String,dynamic> dataListSubjects = elementListSubjects.data() as Map<String,dynamic>;

      if(listSubjectsTeacher.contains(elementListSubjects.id)){
        listW.add(
            InkWell(
              onTap: () => goToConference(elementListSubjects: elementListSubjects),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10,left: 10,right: 10),
                    width: 120,height: 120,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                          image: Image.asset('assets/image/${dataListSubjects['posImage']}.png').image,
                          fit: BoxFit.contain
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                  SizedBox(
                    width: sizeW * 0.3,
                    child: Text(dataListSubjects['name'],textAlign: TextAlign.center,style: UcademyStyles().stylePrimary(size: sizeH * 0.02,fontWeight: FontWeight.w400,)),
                  )
                ],
              ),
            )
        );
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: sizeH * 0.02),
      child: Container(
        width: sizeW,
        height: sizeH * 0.4,
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: EdgeInsets.symmetric(horizontal: sizeW * 0.05),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: listW,
          ),
        ),
      ),
    );
  }

  Future goToConference({required QueryDocumentSnapshot elementListSubjects}) async {
    Map<String,dynamic> dataListSubjects = elementListSubjects.data() as Map<String,dynamic>;

    //NOTIFICAR QUE SE INICIO UNA CONFERENCIA
    dataListSubjects['inConference'] = true;
    await FirebaseConnectionSubjects().editSubjects(data: dataListSubjects, id: elementListSubjects.id);
    //ABRIR CONFERENCIA
    await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
        JitsiMeetVideo(
          nameRoom: elementListSubjects.id,
          videoMuted: false,
        ),),);
    //CERRAR CONFERENCIA
    dataListSubjects['inConference'] = false;
    await FirebaseConnectionSubjects().editSubjects(data: dataListSubjects, id: elementListSubjects.id);
  }

  Widget bottomNavigationBar(){
    return Container(
      width: sizeW,
      height: sizeH * 0.1,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0)
        ),
      ),
      child: Row(
        children: [
          Expanded( child: buttonBottom(type: 1)),
          Expanded( child: buttonBottom(type: 2)),
        ],
      ),
    );
  }

  Widget buttonBottom({required int type}){
    IconData icon = Icons.menu_book;
    String title = 'Materias';
    if(type == 2){
      icon = Icons.photo_camera_front;
      title = 'Videos';
    }

    return InkWell(
      onTap: (){
        userProvider.changeSelectedBottomHome(type: type);
      },
      child: Opacity(
        opacity: userProvider.selectedBottomHome == type ? 1 : 0.5,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,size: sizeH * 0.03,color: UcabdemyColors.primary,),
              Text(title,style: UcademyStyles().stylePrimary(size: sizeH * 0.02,color: UcabdemyColors.primary),)
            ],
          ),
        ),
      ),
    );
  }
}
