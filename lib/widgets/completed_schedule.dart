// ignore_for_file: override_on_non_overriding_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_appointment_app/model/admin/AppointmentModel.dart';
import 'package:doctor_appointment_app/staticdata.dart';
import 'package:doctor_appointment_app/util/appthem.dart';
import 'package:doctor_appointment_app/util/customwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CompletedSchedule extends StatefulWidget {
  const CompletedSchedule({super.key});

  @override
  State<CompletedSchedule> createState() => _CompletedScheduleState();
}

class _CompletedScheduleState extends State<CompletedSchedule> {
  double fullrating = 0;

  var height, width;
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height * 0.65,
      width: width,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: StreamBuilder(
            stream: StaticData.firebase
                .collection('appointment')
                .where("patientid", isEqualTo: StaticData.patientmodel!.id)
                .where("status", isEqualTo: 2)
                .snapshots(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print("Error: /${snapshot.error}");
                return Text('Error: /${snapshot.error}');
              }

              AppointmentModel? model;
              if (snapshot.data!.docs.length != 0)
                print(
                    'snapshot.data!.docs.length/${snapshot.data!.docs.length}');
              return snapshot.data!.docs.length == 0 &&
                      snapshot.data!.docs.isEmpty
                  ? Center(
                      child: CustomWidget.largeText('Data not found !'),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        model = AppointmentModel.fromMap(
                            snapshot.data!.docs[index].data());
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      "Dr.${model!.doctername}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text("${model!.bio}"),
                                    trailing:  model!.docImage==null?
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              AssetImage("images/doctor1.png"),
                                        ): CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              NetworkImage(model!.docImage),
                                        )
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      InkWell(
                                        onTap: model!.rating == null
                                            ? () {
                                                model =
                                                    AppointmentModel.fromMap(
                                                        snapshot
                                                            .data!.docs[index]
                                                            .data());
                                                fullrating = 0;
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return StatefulBuilder(
                                                          builder:
                                                              (context, set) {
                                                        return SizedBox(
                                                          height: 10,
                                                          child: AlertDialog(
                                                            actions: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "No",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: width *
                                                                    0.05,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  StaticData
                                                                      .firebase
                                                                      .collection(
                                                                          "appointment")
                                                                      .doc(model!
                                                                          .id)
                                                                      .update({
                                                                    "rating":
                                                                        fullrating
                                                                  });
                                                                  StaticData
                                                                      .firebase
                                                                      .collection(
                                                                          "doctor")
                                                                      .doc(model!
                                                                          .doctorid)
                                                                      .update({
                                                                    "totalrating":
                                                                        FieldValue.increment(
                                                                            fullrating),
                                                                    "ratingperson":
                                                                        FieldValue
                                                                            .increment(1),
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      color: Apptheme
                                                                          .primary),
                                                                ),
                                                              ),
                                                            ],
                                                            title: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                SizedBox(
                                                                  width: 20,
                                                                ),
                                                                Text(
                                                                  "Dotcor Rating",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Icon(
                                                                        Icons
                                                                            .cancel_outlined)),
                                                              ],
                                                            ),

                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)), //this right here
                                                            content: Container(
                                                              height: 60,
                                                              child: Column(
                                                                children: [
                                                                  RatingBar.builder(
                                                                      initialRating: 0,
                                                                      minRating: 1,
                                                                      unratedColor: Colors.grey,
                                                                      itemCount: 5,
                                                                      itemSize: 30,
                                                                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                                      updateOnDrag: true,
                                                                      itemBuilder: (context, index) => Icon(
                                                                            Icons.star,
                                                                            color:
                                                                                Color(0xFF7165D6),
                                                                          ),
                                                                      onRatingUpdate: (ratingvalue) {
                                                                        set(() {
                                                                          setState(
                                                                              () {
                                                                            fullrating =
                                                                                ratingvalue;
                                                                          });
                                                                        });
                                                                      }),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    "Rating : $fullrating",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                    });
                                              }
                                            : () {
                                                print(
                                                    " model!.rating${model!.rating}");
                                              },
                                        child: Text(
                                          "Rating : ${model!.rating ?? 0}",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Divider(
                                      thickness: 1,
                                      height: 20,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "${StaticData.formatMicrosecondsSinceEpoch(model!.createdtime)}",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Icon(
                                            Icons.access_time_filled,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "${model!.time}",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "Completed",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
            },
          )),
    );
  }
}
