import 'dart:async';
import 'package:newfeautre/APi.dart';

class Repository {
  final apiProvider = ApiProvider();

  Future<List> getLocation(String userid) => apiProvider.getLocation(userid);
  Future addloc(Map<dynamic,dynamic> data) => apiProvider.addloc(data);

}

