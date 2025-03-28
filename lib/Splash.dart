import 'package:capsfront/accounts/login.dart';
import 'package:capsfront/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


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

        MaterialPageRoute(builder: (context) => LoginPage()),

      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        height: 900,
        width: double.infinity,

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Colors.white10],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Container(
        height: 900,
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
            Text(
              "Crop planning",
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            //ElevatedButton1(),
            Loading(),

          ],

        ),

      ),
    ));
  }

  Icon1() {
    return Container(

      margin: EdgeInsets.only(top: 100, bottom: 10),

        child: Icon(Icons.account_tree, size: 90),
      );
  }

}

Loading() {
  return Container(
    margin: EdgeInsets.only(top: 200),

    child: Lottie.network('https://lottie.host/430eaba1-0722-4d09-893d-80fc747c75e5/mvvEzovt6M.json'),
  );
}

