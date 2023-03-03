import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: must_be_immutable
//
class loc extends Equatable {
  late String? location_key;
  String userid;
  String longi;
  String lat;
  late String? time;


  loc(
      {
        this.location_key,
        required this.userid,
        required this.longi,
        required this.lat,
        this.time,
      });

  factory loc.fromJson(Map<String, dynamic> parsedJson) {
    return loc(
      location_key: parsedJson['location_key'],
      userid: parsedJson['userid'],
      longi: parsedJson['longi'],
      lat: parsedJson['lat'],
      time: DateFormat.jm().format(DateTime.parse(parsedJson['time'])),
    );
  }

  Map<dynamic, dynamic> toMap(){
    var map = new Map<String, dynamic>();
    map['userid']=this.userid;
    map['longi'] = this.longi;
    map['lat'] = this.lat;
    return map;
  }

  @override
  List<Object> get props => [location_key!];

  @override
  String toString() {
    return "location Key: $location_key";
  }
}