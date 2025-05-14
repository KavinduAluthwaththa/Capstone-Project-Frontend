import 'package:capsfront/Inspector_area/addDeseace.dart';
import 'package:capsfront/accounts/login.dart';
import 'package:capsfront/farmer_area/MarketPrice.dart';
import 'package:capsfront/main.dart';
import 'package:capsfront/shared/Chat.dart';
import 'package:capsfront/shared/Chatbot.dart';
import 'package:capsfront/shared/crop_disease_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../farmer_area/notifications.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key, required BottomNavigationBarExample child});

  @override
  State<Splashscreen> createState() => _State();
}

class _State extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (context) => MarketPriceScreen()),

      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(


          width: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.white10],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),



          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon1(),
              SizedBox(height: 20,),
              Text(
                "Crop planning",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20,),
              //ElevatedButton1(),
              Expanded(child: Loading(),)

            ],

          ),

        ),
            ),
      );
  }

  Icon1() {
    return Container(

      margin: EdgeInsets.only(top: 200, bottom: 10),

        child: Icon(Icons.account_tree, size: 90),
      );
  }

}

Loading() {
  return Container(

    margin: EdgeInsets.symmetric(vertical: 50),

    // child: Lottie.network('https://lottie.host/430eaba1-0722-4d09-893d-80fc747c75e5/mvvEzovt6M.json'),
    child: Lottie.network('https://lottie.host/9f1a777d-fa08-4d3b-8c88-9e510ee525be/r1E9fn5G5E.json'),
  );
}

