import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:ucabdemy/services/authenticate_firebase.dart';
import 'package:ucabdemy/services/shared_preferences_local.dart';
import 'package:ucabdemy/views/call/jitsi_meet_join.dart';
import 'package:ucabdemy/views/home/home_video.dart';
import 'package:ucabdemy/views/home/students/add_subjects_for_students.dart';
import 'package:ucabdemy/views/login/login_page.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';
import 'package:ucabdemy/widgets_utils/dialog_alert.dart';
import 'package:ucabdemy/widgets_utils/toast_widget.dart';

class HomeStudents extends StatefulWidget {
  const HomeStudents({Key? key}) : super(key: key);

  @override
  State<HomeStudents> createState() => _HomeStudentsState();
}

class _HomeStudentsState extends State<HomeStudents> {

  double sizeH = 0;
  double sizeW = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  UserProvider? userProvider;
  final CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');
  final CollectionReference subjectsCollection = FirebaseFirestore.instance.collection('subjects');
  List<QueryDocumentSnapshot> listSubjects = [];

  @override
  void initState() {
    super.initState();

    subjectsCollection.snapshots().listen((event) {
      listSubjects = event.docs;
      setState(() {});
    });

  }

  @override
  Widget build(BuildContext context) {

    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: _drawerMenu(),
      backgroundColor: UcabdemyColors.primary_4,
      appBar: appBarWidget(
        sizeH: sizeH,
        title: 'UCABDEMY',
        elevationActive: true,
        leadingW: IconButton(
          icon: Icon(Icons.menu,color: Colors.white,size: sizeH * 0.04,),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: sizeW * 0.05),
            width: sizeH * 0.06,
            child: Container(
              height: sizeH * 0.0025,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image.asset('assets/image/logo_app.png').image,
                      fit: BoxFit.fitWidth
                  )
              ),
            ),
          )
        ]
      ),
      body: userProvider!.userFirebase == null ? Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
          child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
        ),
      ) : userProvider!.selectedBottomHome == 1 ? streamBody() : const HomeVideo(),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  Widget _drawerMenu(){

    Widget _divider = Container(
      width: sizeW,height: sizeH * 0.0015,
      margin: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
      color: Colors.white,
    );

    return Drawer(
      elevation: 20.0,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: UcabdemyColors.primary,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: sizeH * 0.1),
            SizedBox(
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
            ),
            Expanded(child: Container()),
            _textDrawer(
                text: 'Mis materias',
                iconData: Icons.book,
                onTap: () async {
                  if(userProvider != null && userProvider!.userFirebase != null){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context2) => AddSubjectsForStudent(idUser: userProvider!.userFirebase!.uid,)));
                  }
                }
            ),
            _divider,
            _textDrawer(
                text: 'Cerrar sesión',
                iconData: Icons.exit_to_app,
                onTap: () async {
                  try{
                    bool res = await alertClosetSession(context);
                    if(res){
                      await AuthenticateFirebaseUser().signOutFirebase();
                      showAlert(text: 'Desconectando',color: Colors.redAccent);
                      SharedPreferencesLocal.prefs.setInt('pleksusLogin',0);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context2) => const LoginPage()));
                    }
                  }catch(_){}
                }
            ),
            _divider,
            SizedBox(height: sizeH * 0.025,)
          ],
        ),
      ),
    );
  }
  Widget _textDrawer({required String text, required Function onTap, required IconData iconData}){
    return InkWell(
      onTap: (){
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        width: sizeW,
        margin: EdgeInsets.symmetric(horizontal: sizeW * 0.05, vertical: sizeW * 0.025),
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: UcademyStyles().stylePrimary(size: sizeH * 0.022, color: Colors.white),textAlign: TextAlign.left),
            ),
            const SizedBox(width: 10,),
            Icon(iconData,size: sizeH * 0.03,color: Colors.white,)
          ],
        ),
      ),
    );
  }

  Widget streamBody(){
    return StreamBuilder<QuerySnapshot>(
      stream: studentsCollection.where('uid',isEqualTo: userProvider!.userFirebase!.uid).snapshots(),
      builder: (context,snapshotStudents){
        if (snapshotStudents.data == null){
          return Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: sizeH * 0.026),
              child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04),
            ),
          );
        }

        if(snapshotStudents.data!.docs.isEmpty) return Container();
        Map<String,dynamic> dataUser = snapshotStudents.data!.docs[0].data() as Map<String,dynamic>;

        return Column(
          children: [
            Container(
              width: sizeW,
              margin: const EdgeInsets.only(top: 10,left: 10),
              child: Text(userProvider!.userFirebase!.displayName!,style: UcademyStyles().stylePrimary(size: sizeH * 0.03)),
            ),
            Expanded(
              child: viewSubjects(dataUser['listSubjects']),
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
              onTap: (){
                if(dataListSubjects['inConference']){
                  goToConference(idSubjects: elementListSubjects.id);
                }else{
                  showAlert(text: 'En estos momentos no se encuentra en conferencia.',color: Colors.redAccent);
                }
              },
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      dataListSubjects['inConference'] ? PulsingWidget(
                        child: Container(
                          margin: const EdgeInsets.only(top: 10,left: 10,right: 10),
                          width: 140,height: 140,
                          child: const CircleAvatar(
                            backgroundColor: Colors.blue,

                          ),
                        ),
                      ) : Container(
                        margin: const EdgeInsets.only(top: 10,left: 10,right: 10),
                        width: 140,height: 140,
                      ),
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
                    ],
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

  Future goToConference({required String idSubjects}) async {

    //ABRIR CONFERENCIA
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
      JitsiMeetJoin(
        nameRoom: idSubjects,
      ),),);

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
        userProvider!.changeSelectedBottomHome(type: type);
      },
      child: Opacity(
        opacity: userProvider!.selectedBottomHome == type ? 1 : 0.5,
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


class PulsingWidget extends StatefulWidget {
  final Tween<double>? tween;
  final Widget child;
  final Duration? duration;

  const PulsingWidget({Key? key,required this.child, this.duration, this.tween}) : super(key: key);

  //const PulsingWidget({required this.child, this.duration, this.tween}) : assert(child! != null);
  @override
  _PulsingWidget createState() => _PulsingWidget();
}

class _PulsingWidget extends State<PulsingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Duration _duration;
  late Tween<double> _tween;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _tween = widget.tween ?? Tween(begin: 0.25, end: 1.0);
    _duration = widget.duration ?? const Duration(milliseconds: 1500);
    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
    );
    final CurvedAnimation curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
    _animation = _tween.animate(curve);
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}