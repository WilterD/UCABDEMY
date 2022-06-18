import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/config/ucabdemy_style.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:ucabdemy/views/home/videos/save_video.dart';
import 'package:ucabdemy/views/home/videos/view_video.dart';
import 'package:ucabdemy/widgets_utils/dialog_alert.dart';

class HomeVideo extends StatefulWidget {
  const HomeVideo({Key? key}) : super(key: key);

  @override
  State<HomeVideo> createState() => _HomeVideoState();
}

class _HomeVideoState extends State<HomeVideo> {

  double sizeH = 0;
  double sizeW = 0;
  late UserProvider? userProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;
    userProvider = Provider.of<UserProvider>(context);


    return Scaffold(
      backgroundColor: UcabdemyColors.primary_4,
      body: containerHomeVideos(),
      floatingActionButton: floatingActionButton(),
    );
  }

  Widget containerHomeVideos(){
    return SizedBox(
      width: sizeW,
      child: ListView.builder(
        itemCount: userProvider!.listVideos!.length,
        itemBuilder: (context,index){

          List data = userProvider!.listVideos![index].toString().split('|');

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Card(
                  margin: EdgeInsets.only(top: sizeH * 0.02,left: sizeW * 0.02),
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: sizeH * 0.01, horizontal: sizeH * 0.03),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: sizeW,
                              child: Text(data[0],style: UcademyStyles().stylePrimary(size: sizeH * 0.02,fontWeight: FontWeight.bold),textAlign: TextAlign.left),
                            ),
                            SizedBox(height: sizeH * 0.01),
                            SizedBox(
                              width: sizeW,
                              child: Text(data[1],style: UcademyStyles().stylePrimary(size: sizeH * 0.018),textAlign: TextAlign.left),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: (){
                      String pathVideo = data[2];
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ViewVideo(pathVideo: pathVideo,title: data[0]),),);
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  try{
                    bool res = await alertDeleteVideo(context);
                    if(res){
                      userProvider!.deleteVideo(index: index);
                    }
                  }catch(_){}

                },
                iconSize: sizeH * 0.035,
                icon: const Icon(Icons.delete,color: Colors.red),
              ),
            ],
          );
        },
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
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const SaveVideo(),),);
  }
}