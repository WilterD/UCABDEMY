import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class JitsiMeetJoin extends StatefulWidget {

  const JitsiMeetJoin({Key? key,required this.nameRoom}) : super(key: key);
  final String nameRoom;
  @override
  _JitsiMeetJoinState createState() => _JitsiMeetJoinState();
}

class _JitsiMeetJoinState extends State<JitsiMeetJoin>{

  String nameRooms = '';

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future initialData() async{
    nameRooms = widget.nameRoom;
    setState(() {});
    meet();

  }

  @override
  void dispose() {
    super.dispose();
  }

  Future meet() async {
    _joinMeeting();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: const Scaffold(
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future _joinMeeting() async {
    try{
      String? serverUrl = 'https://meet.jit.si/';
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE: false,
        FeatureFlagEnum.ADD_PEOPLE_ENABLED: false,
        FeatureFlagEnum.CALL_INTEGRATION_ENABLED: false,
        FeatureFlagEnum.RECORDING_ENABLED: false,
        FeatureFlagEnum.INVITE_ENABLED: false,
      };
      featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      var options = JitsiMeetingOptions(room: widget.nameRoom)
        ..serverURL = serverUrl
        ..subject = 'nameRooms'
        ..userDisplayName = 'nameRooms'
        ..audioOnly = false
        ..videoMuted = true
        ..audioMuted = true
        ..featureFlags.addAll(featureFlags);

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(
            onError: (message) {
              debugPrint('JITSI : Error con el mensaje: $message');
              debugPrint("${options.room} Error con el mensaje: $message");
            },
            onConferenceJoined: (message) {
              debugPrint('JITSI : unido con mensaje: $message');
              debugPrint("${options.room} unido con mensaje: $message");
            },
            onConferenceWillJoin: (message) {
              debugPrint('JITSI : se unirá con el mensaje: $message');
              debugPrint("${options.room} se unirá con el mensaje: $message");
              setState(() {});
            },
            onConferenceTerminated: (message) async {
              debugPrint('JITSI : terminado con mensaje: $message');
              debugPrint("${options.room} terminado con mensaje: $message");
            },
            genericListeners: [
              JitsiGenericListener(
                  eventName: 'readyToClose',
                  callback: (dynamic message) {
                    debugPrint('JITSI : readyToClose callback');
                    debugPrint("readyToClose callback");
                  }),
            ]),
      );
    }catch(e){
      debugPrint('_joinMeeting: ${e.toString()}');
    }
  }
}
