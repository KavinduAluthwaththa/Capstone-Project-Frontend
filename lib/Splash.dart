
import 'package:capsfront/accounts/register.dart';
import 'package:capsfront/main.dart';
import 'package:flutter/material.dart';
import 'package:capsfront/Home.dart';
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
    // Navigate to SecondPage after a delay of 3 seconds
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
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
                  colors: [ Colors.green.shade900, Colors.white10],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        
        
            children: [
              Icon1(),
              SizedBox(height: 20,),
              Text("Crop planning",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),),
              //ElevatedButton1(),
              SizedBox(height: 20,),
              Expanded(child: Loading1(),)

        
        
            ],
        
          ),
        
        ),
      ),
    );
  }

  Icon1() {
    return Container(


      margin: EdgeInsets.only(top: 100, bottom: 10),


      child: Icon(Icons.account_tree, size: 90,),);
  }

// ElevatedButton1() {
//   return Container(
//       margin: EdgeInsets.only(top: 300),
//       child: ElevatedButton(
//           onPressed: () {},
//           child: Text('Next', style: TextStyle(
//               fontWeight: FontWeight.bold, color: Colors.black)),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green.shade700,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//
//           )
//
//       )
//   )
//   ;
}

Loading1() {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 50),

    child: Lottie.network('https://lottie.host/9f1a777d-fa08-4d3b-8c88-9e510ee525be/r1E9fn5G5E.json'),
  );
}



