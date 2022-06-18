import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ucabdemy/config/ucabdemy_colors.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:ucabdemy/views/home/home_students.dart';
import 'package:ucabdemy/views/home/home_teacher.dart';
import 'package:ucabdemy/widgets_utils/appbar_widgets.dart';
import 'package:ucabdemy/widgets_utils/circular_progress_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  double sizeH = 0;
  double sizeW = 0;
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {

    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;
    userProvider = Provider.of<UserProvider>(context);

    return userProvider.loadDataUser ?
    Scaffold(
      backgroundColor: UcabdemyColors.primary_4,
      appBar: appBarWidget(
        sizeH: sizeH,
        title: 'UCABDEMY',
        elevationActive: false,
      ),
      body: Center(child: circularProgressColors(widthContainer2: sizeH * 0.04,widthContainer1: sizeW),),
    )
        :
    Scaffold(
      body: userProvider.isTeacher ? const HomeTeacher() : const HomeStudents(),
    );
  }
}
