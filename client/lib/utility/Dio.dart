import 'package:dio/dio.dart';
import 'package:speanmeas/Environment.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: API_HOST, //
    connectTimeout: Duration(seconds: 10), //
    sendTimeout: Duration(seconds: 10), //
    receiveTimeout: Duration(seconds: 10), //
  ),
);
