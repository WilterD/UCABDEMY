import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:ucabdemy/views/home/videos/save_video.dart';
import 'package:ucabdemy/views/home/videos/view_video.dart';
import 'package:ucabdemy/widgets_utils/button_general.dart';
import 'package:ucabdemy/widgets_utils/dialog_alert.dart';

import '../../widgets_utils/circular_progress_colors.dart';

class HomeVideo extends StatefulWidget {
  const HomeVideo({Key? key}) : super(key: key);

  @override
  State<HomeVideo> createState() => _HomeVideoState();
}

class _HomeVideoState extends State<HomeVideo> {

  double sizeH = 0;
  double sizeW = 0;
  late UserProvider? userProvider;
  final CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');
  final CollectionReference subjectsCollection = FirebaseFirestore.instance.collection('subjects');
  final CollectionReference teachersCollection = FirebaseFirestore.instance.collection('teachers');
  List<QueryDocumentSnapshot> listSubjects = [];

  final PageController _controller = PageController( initialPage: 0 );

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

    bool isTeacher = userProvider?.isTeacher ?? false;


    return Scaffold(
      backgroundColor: UcabdemyColors.primary_4,
      body: isTeacher ? containerHomeVideosTeacher() : containerHomeVideos(),
      floatingActionButton: isTeacher ? floatingActionButton() : Container(),
    );
  }

  Widget containerHomeVideosTeacher(){
    return StreamBuilder<QuerySnapshot>(
      stream: teachersCollection.where('uid',isEqualTo: userProvider!.userFirebase!.uid).snapshots(),
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
              child: Text('Videos por materias',style: UcademyStyles().stylePrimary(size: sizeH * 0.02)),
            ),
            Expanded(
              child: viewSubjects(dataUser['subjects']),
            ),
          ],
        );
      },
    );
  }

  Widget containerHomeVideos(){
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
              child: Text('Videos por materias',style: UcademyStyles().stylePrimary(size: sizeH * 0.02)),
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

        List listStorage = [];
        if(dataListSubjects.containsKey('listStorage')){
          try{
            listStorage = dataListSubjects['listStorage'];
            if(listStorage.isNotEmpty){
              listStorage.add(
                SizedBox(height: sizeH * 0.08,)
              );

            }
          }catch(_){}
        }

        listW.add(
            InkWell(
              onTap: (){

              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10,left: 10,right: 10, bottom: 10),
                        width: 40,height: 40,
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: listStorage.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context,index){

                        if((listStorage.length - 1) == index){
                          return listStorage[index];
                        }

                        String name = '';
                        String description = '';
                        String url = '';
                        try{
                          name = listStorage[index]['title'];
                          description = listStorage[index]['description'];
                          url = listStorage[index]['url'];
                        }catch(_){}

                        return Card(
                          margin: EdgeInsets.only(left: sizeW * 0.04, right: sizeW * 0.04,top: sizeH * 0.02),
                          elevation: 10,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.02,vertical: sizeH * 0.02),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: sizeW * 0.02),
                                    Expanded(
                                      child: Text(name,style: UcademyStyles().stylePrimary(
                                        size: sizeH * 0.025,color: UcabdemyColors.primary
                                      )),
                                    ),
                                    Container(
                                      child: ButtonGeneral(
                                        backgroundColor: UcabdemyColors.primary,
                                        radius: 10,
                                        title: 'Ver',
                                        height: sizeH * .06,
                                        width: sizeW * 0.1,
                                        borderColor: UcabdemyColors.primary,
                                        textStyle: UcademyStyles().stylePrimary(size: sizeH * 0.023,fontWeight: FontWeight.bold,color: Colors.white),
                                        onPressed: (){
                                          if(url.isNotEmpty){
                                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
                                                ViewVideo(pathVideo: url,title: name,elementList: elementListSubjects, indexPos: index),),);
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                description.isEmpty ? Container() : Container(
                                  margin: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
                                  width: sizeW,
                                  child: Text(description,style: UcademyStyles().stylePrimary(
                                      size: sizeH * 0.02,color: UcabdemyColors.primary
                                  ),),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
        );
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: sizeH * 0.02),
      child: PageView(
        controller: _controller,
        children: listW,
      ),
    );
  }

  Widget floatingActionButton(){
    return FloatingActionButton(
      backgroundColor: UcabdemyColors.primary,
      onPressed: () => recordVideo(),
      child: Center(child: Icon(Icons.add,color: Colors.white,size: sizeH * 0.03),),
    );
  }

  Future recordVideo() async{
    if(userProvider!.userFirebase != null){
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SaveVideo(idUser: userProvider!.userFirebase!.uid),),);
    }
  }
}

// Widget containerHomeVideos(){
//   return SizedBox(
//     width: sizeW,
//     child: ListView.builder(
//       itemCount: userProvider!.listVideos!.length,
//       itemBuilder: (context,index){
//
//         List data = userProvider!.listVideos![index].toString().split('|');
//
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: Card(
//                 margin: EdgeInsets.only(top: sizeH * 0.02,left: sizeW * 0.02),
//                 child: InkWell(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: sizeH * 0.01, horizontal: sizeH * 0.03),
//                     child: Center(
//                       child: Column(
//                         children: [
//                           SizedBox(
//                             width: sizeW,
//                             child: Text(data[0],style: UcademyStyles().stylePrimary(size: sizeH * 0.02,fontWeight: FontWeight.bold),textAlign: TextAlign.left),
//                           ),
//                           SizedBox(height: sizeH * 0.01),
//                           SizedBox(
//                             width: sizeW,
//                             child: Text(data[1],style: UcademyStyles().stylePrimary(size: sizeH * 0.018),textAlign: TextAlign.left),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   onTap: (){
//                     String pathVideo = data[2];
//                     Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ViewVideo(pathVideo: pathVideo,title: data[0]),),);
//                   },
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () async {
//                 try{
//                   bool res = await alertDeleteVideo(context);
//                   if(res){
//                     userProvider!.deleteVideo(index: index);
//                   }
//                 }catch(_){}
//
//               },
//               iconSize: sizeH * 0.035,
//               icon: const Icon(Icons.delete,color: Colors.red),
//             ),
//           ],
//         );
//       },
//     ),
//   );
// }