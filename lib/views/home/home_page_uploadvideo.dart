// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ucabdemy/main.dart';
// import 'package:ucabdemy/services/http_connection.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//
//   String text = 'AGREGAR VIDEO';
//   int viewPos = 0;
//   XFile? video;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: viewPos == 0 ? view1() : view2(),
//     );
//   }
//
//   Widget view1(){
//     return Center(
//       child: InkWell(
//         child: Container(
//           height: 100,
//           width: 300,
//           color: Colors.blue,
//           child:Center(child: Text('AGREGAR VIDEO')),
//         ),
//         onTap: ()=> recordVideo(),
//       ),
//     );
//   }
//
//   Future recordVideo() async{
//     ImagePicker _picker = ImagePicker();
//     video = await _picker.pickVideo(source: ImageSource.gallery);
//     Uint8List? uploadfile = await video!.readAsBytes();
//     try{
//       Response response = await uploadVideo(pathVideo: video!.path);
//       var value = jsonDecode(response.body);
//       print('');
//     }catch(e){
//       print(e.toString());
//     }
//
//     // if(video != null){
//     //   viewPos = 1;
//     // }else{
//     //   viewPos = 0;
//     // }
//     // setState(() {});
//   }
//
//   Widget view2(){
//     return Center(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           InkWell(
//             child: Container(
//               height: 100,
//               width: 300,
//               color: Colors.blue,
//               child:Center(child: Text('SUBIR AL SERVER')),
//             ),
//             onTap: ()=> sendVideo(),
//           ),
//           SizedBox(height: 20,),
//           InkWell(
//             child: Container(
//               height: 100,
//               width: 300,
//               color: Colors.blue,
//               child:Center(child: Text('REGRESAR')),
//             ),
//             onTap: (){
//               viewPos = 0;
//               setState(() {});
//             },
//           )
//         ],
//       ),
//     );
//   }
//
//   Future sendVideo() async{
//     try{
//       // final file = getFile('');
//       // bool isFile = await File(video!.path).exists();
//       // print('');
//       Response response = await uploadVideo(pathVideo: video!.path);
//       var value = jsonDecode(response.body);
//       print('');
//     }catch(e){
//       print(e.toString());
//     }
//   }
//
//   File getFile(String filename) {
//     String appDocPath = appDocDi25!.path;
//     return File("$appDocPath/$filename");
//   }
// }
