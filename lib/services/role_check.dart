import 'package:capsfront/accounts/login.dart';
import 'package:capsfront/constraints/token_handler.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class RoleCheck{
  void checkAdminRole(BuildContext context){
    final decodedToken = JwtDecoder.decode(TokenHandler().getToken());
    String role = decodedToken['token'];

    if(role != "admin" || role.isEmpty){
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginPage()), 
        (Route<dynamic> route) => false,);
    }
  }

  void checkUserRole(BuildContext context){
    final decodedToken = JwtDecoder.decode(TokenHandler().getToken());
    String role = decodedToken['token'];

    if(role != "user" || role.isEmpty){
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginPage()), 
        (Route<dynamic> route) => false,);
    }
  }

}