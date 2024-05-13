// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/model/admin/DoctorModel.dart';
import 'package:doctor_appointment_app/model/patient/patientmodel.dart';
import 'package:doctor_appointment_app/screens/admin/adminHome.dart';
import 'package:doctor_appointment_app/staticdata.dart';
import 'package:doctor_appointment_app/widgets/navbar_roots.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();
  String errorMessage = "";
  TextEditingController email = TextEditingController();
  int index = 0;
  updateindex(int a) {
    index = a;
    update();
  }

  TextEditingController password = TextEditingController();
  bool passToggle = true;
  login(context) {
    if (email.text == "1234@gmail.com" && password.text == "1234@") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminNavBarRoots(),
          ));
      print('data: ');
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavBarRoots(),
          ));
    }
  }

  void signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential myuser =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      User user = myuser.user!;
      if (user != null) {
        String id = user.uid;
        StaticData.doctor = id;

        DocumentSnapshot snapshot = await StaticData.firebase
            .collection("doctor")
            .doc(StaticData.doctor)
            .get();
        if (snapshot.exists) {
          DoctorModel model =
              DoctorModel.fromMap(snapshot.data() as Map<String, dynamic>);
          StaticData.doctorModel = model;
          StaticData.doctor = model.id;
          update();
          StaticData.firebase
              .collection("doctor")
              .doc(StaticData.doctor)
              .update({"token": StaticData.token});
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminNavBarRoots(),
              ));
          SharedPreferences prefs = await SharedPreferences.getInstance();
          StaticData.cleardata(context).then((value) {
            prefs.setString("doctor", StaticData.doctor);
            clearForm();
          });
        } else {
          Fluttertoast.showToast(
              msg: "User Not Found !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        update();
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Invalid Email!";
          break;
        case "wrong-password":
          errorMessage = "Wrong Password";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          break;
        case "":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void signInWithEmailAndPassword1(BuildContext context) async {
    try {
      UserCredential myuser = await StaticData.auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      User user = myuser.user!;
      if (user != null) {
        Fluttertoast.showToast(
            msg: "Login Succesfull",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
        String id = user.uid;
        StaticData.patient = id;
        DocumentSnapshot snapshot = await StaticData.firebase
            .collection("patient")
            .doc(StaticData.patient)
            .get();
        if (snapshot.exists) {
          PatientModel model =
              PatientModel.fromMap(snapshot.data() as Map<String, dynamic>);
          StaticData.patientmodel = model;
          update();
          StaticData.firebase
              .collection("patient")
              .doc(StaticData.patient)
              .update({"token": StaticData.token});
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NavBarRoots(),
              ));
          SharedPreferences prefs = await SharedPreferences.getInstance();
          StaticData.cleardata(context).then((value) {
            prefs.setString("patient", id);
            clearForm();
          });
        }
      } else {
        update();
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Invalid Email!";
          break;
        case "wrong-password":
          errorMessage = "Wrong Password";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          break;
        case "":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  clearForm() {
    email.clear();
    password.clear();
    update();
  }
}
