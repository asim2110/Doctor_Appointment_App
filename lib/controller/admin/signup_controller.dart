// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/model/admin/DoctorModel.dart';
import 'package:doctor_appointment_app/model/admin/DoctorSlot.dart';
import 'package:doctor_appointment_app/model/patient/patientmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:doctor_appointment_app/screens/login_screen.dart';
import 'package:doctor_appointment_app/staticdata.dart';
import 'package:intl/intl.dart';

class SignupController extends GetxController {
  static SignupController get to => Get.find();
  TextEditingController fullname = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController specilest = TextEditingController();
  TextEditingController about = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController bio = TextEditingController();
  TextEditingController fee = TextEditingController();
  String? startTime;
  String? endTime;
  bool passToggle = true;

  int? maxAppointmentDuration;

  int? index = 1;
  List<String> time = ["10", "20", "30"];
  int select = 0;
  int? duration;
  updateindex(int a) {
    index = a;
    update();
  }

  updateduration(int a) {
    duration = a;
    maxAppointmentDuration = int.tryParse(time[a]);
    update();
  }

  void register(context) async {
    if (startTime != null &&
        endTime != null &&
        maxAppointmentDuration != null) {
      try {
        UserCredential myuser =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );
        User user = myuser.user!;
        String id = user.uid;

        DoctorModel model = DoctorModel(
          fee: double.tryParse(fee.text) ?? 0.0,
          ratingperson: 0,
          patientList: [],
          totalrating: 0.0,
          address: address.text,
          email: email.text,
          fullname: fullname.text,
          token: StaticData.token,
          password: password.text,
          id: id,
          image: 'https://cdn-icons-png.flaticon.com/512/194/194915.png',
          status: 'Offline',
          audiocallStatus: false,
          about: about.text,
          bio: bio.text,
          specialty: specilest.text,
          callStatus: false,
          roomId: '',
          type: '',
          phonenumber: phonenumber.text,
          endtime: endTime.toString(),
          maxAppointmentDuration: maxAppointmentDuration!,
          starttime: startTime.toString(),
        );
        print("time startTime.toString()${startTime.toString()}");
        print("time endTime.toString()${endTime.toString()}");
        await StaticData.firebase
            .collection("doctor")
            .doc(id)
            .set(model.toMap());

        print("object123");
        List<DoctorSlot> slots = await generateDoctorSlots(
            startTime!, endTime!, maxAppointmentDuration!, id, fullname.text);
        print("object12345");

        for (var e in slots) {
          StaticData.firebase
              .collection("slots")
              .doc(id)
              .collection("slots")
              .doc(e.id.toString())
              .set(e.toMap());
        }
        print("object1235678");

        clearForm();

        var time = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 12, 0);
        Duration timeUntilScheduled = time.difference(DateTime.now());

        Timer(timeUntilScheduled, () async {
          print('Task executed at ${DateTime.now()}');
          DocumentSnapshot snapshot =
              await StaticData.firebase.collection("doctor").doc(id).get();
          DoctorModel doctormodel = await DoctorModel.fromMap(
              snapshot.data() as Map<String, dynamic>);
          print("Executing daily task at 12:00 AM");
          List<DoctorSlot> slots1 = await create(
              doctormodel.starttime,
              doctormodel.endtime,
              doctormodel.maxAppointmentDuration,
              doctormodel.id,
              doctormodel.fullname);
          print('Initial doctor slots generated at ${DateTime.now()}');

          print("object12345");

          QuerySnapshot subcollectionSnapshot = await StaticData.firebase
              .collection("slots")
              .doc(doctormodel.id)
              .collection("slots")
              .get();
          subcollectionSnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
          for (var e in slots1) {
            StaticData.firebase
                .collection("slots")
                .doc(id)
                .collection("slots")
                .doc(e.id.toString())
                .set(e.toMap());
          }
        });

        // Timer(initialDelay, () {
        //   generateDoctorSlots(
        //       doctormodel.starttime,
        //       doctormodel.endtime,
        //       doctormodel.maxAppointmentDuration,
        //       doctormodel.id,
        //       doctormodel.fullname);
        //   print('Initial doctor slots generated at ${DateTime.now()}');
        // });
        print("object123787990");

        Fluttertoast.showToast(
          msg: "Signup Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ));
      } catch (e) {
        print("eror${e.toString()}");
        Fluttertoast.showToast(
          msg: "Check internet connecti...or try another email${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "First select Time & Duration !",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        fontSize: 17,
        timeInSecForIosWeb: 1,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void register1(context) async {
    try {
      UserCredential myuser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      User user = myuser.user!;

      String id = user.uid;
      PatientModel model = PatientModel(
        email: email.text,
        doctorList: [],
        fullname: fullname.text,
        token: StaticData.token,
        password: password.text,
        id: id,
        image:
            'https://firebasestorage.googleapis.com/v0/b/doctor-appointment-app-a9ca9.appspot.com/o/patient_logo1-removebg-preview.png?alt=media&token=ea96884a-5544-48d6-8d42-8e53affa042b',
        status: 'Offline',
        audiocallStatus: false,
        callStatus: false,
        roomId: '',
        type: '',
        phonenumber: phonenumber.text,
      );
      await StaticData.firebase
          .collection("patient")
          .doc(id)
          .set(model.toMap());
      clearForm();
      Fluttertoast.showToast(
        msg: "Signup Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ));
    } catch (e) {
      print("eror${e.toString()}");
      Fluttertoast.showToast(
        msg: "Check internet connecti...or try another email${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  clearForm() {
    fullname.clear();
    phonenumber.clear();
    email.clear();
    password.clear();
    specilest.clear();
    about.clear();
    address.clear();
    bio.clear();
    fee.clear();
    startTime = null;
    endTime = null;
    select = -1;

    update();
  }

  Future<List<DoctorSlot>> generateDoctorSlots(String startTime, String endTime,
      int maxAppointmentDuration, String doctorid, String doctorname) async {
    List<DoctorSlot> doctorSlots = [];
    // try {
    QuerySnapshot querySnapshot = await StaticData.firebase
        .collection("slots")
        .doc(doctorid)
        .collection("slots")
        .get();
    int slotId = querySnapshot.docs.length;
    DateTime? currentStartTime;
    DateFormat format = DateFormat("h:mm a", 'en_US');

    try {
      print("11111111");
      print("startTime: $startTime");
      currentStartTime = parseTime(startTime);
      print("2222222");
    } catch (e) {
      print('Error parsing time: $e');
    }

    while (currentStartTime!.isBefore(parseTime(endTime))) {
      DateTime currentEndTime =
          currentStartTime.add(Duration(minutes: maxAppointmentDuration));
      var uuid = const Uuid();
      var id = uuid.v4();
      doctorSlots.add(DoctorSlot(
        
        index: slotId++,
        date: currentStartTime.microsecondsSinceEpoch,
        doctorid: doctorid,
        doctorname: doctorname,
        id: id.toString(),
        startTime: format.format(currentStartTime),
        endTime: format.format(currentEndTime),
        isAvailable: true,
      ));

      currentStartTime = currentEndTime;
    }
    print("33333333");

    return doctorSlots;
  }

  Future<List<DoctorSlot>> create(String startTime, String endTime,
      int maxAppointmentDuration, String doctorid, String doctorname) async {
    List<DoctorSlot> doctorSlots = [];
    // try {
    QuerySnapshot querySnapshot = await StaticData.firebase
        .collection("slots")
        .doc(doctorid)
        .collection("slots")
        .get();
    int slotId = querySnapshot.docs.length;
    DateTime? currentStartTime;
    DateFormat format = DateFormat("h:mm a", 'en_US');

    try {
      print("11111111");
      print("startTime: $startTime");
      currentStartTime = parseTime(startTime);
      print("2222222");
    } catch (e) {
      print('Error parsing time: $e');
    }

    while (currentStartTime!.isBefore(parseTime(endTime))) {
      DateTime currentEndTime =
          currentStartTime.add(Duration(minutes: maxAppointmentDuration));
      var uuid = const Uuid();
      var id = uuid.v4();
      doctorSlots.add(DoctorSlot(
        index: slotId++,
        date: currentStartTime.microsecondsSinceEpoch,
        doctorid: doctorid,
        doctorname: doctorname,
        id: id.toString(),
        startTime: format.format(currentStartTime),
        endTime: format.format(currentEndTime),
        isAvailable: true,
      ));

      currentStartTime = currentEndTime;
    }
    print("33333333");
    currentStartTime = null;

    return doctorSlots;
  }

  String addMinutes(String time, int minutes) {
    RegExp regExp = RegExp(r'(\d+):(\d+)(\w+)');

    try {
      RegExpMatch? match = regExp.firstMatch(time);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        String period = match.group(3)!;

        DateTime dateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          period == 'PM' ? hour + 12 : hour,
          minute,
        );

        dateTime = dateTime.add(Duration(minutes: minutes));
        return DateFormat("h:mm a").format(dateTime);
      } else {
        throw FormatException('Invalid time format');
      }
    } catch (e) {
      print('Error parsing time: $e');
      return time;
    }
  }

  DateTime parseTime(String time) {
    try {
      time = time.trim();

      time = time.replaceAll(RegExp(r'[^a-zA-Z0-9 :]'), '');

      DateFormat format = DateFormat("h:mm a");
      return format.parse(time);
    } catch (e) {
      print('Error parsing time: $e');
      throw e;
    }
  }
}
