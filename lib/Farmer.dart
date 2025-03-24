import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';




class Farmer extends StatelessWidget {
  const Farmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
             Container(
               height: 200,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Now',style: GoogleFonts.poppins(fontSize: 20),),
                          SizedBox(height: 5),
                          Text('26°',style: GoogleFonts.poppins(fontSize: 30,fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Icon(Icons.cloud, color: Colors.white),

                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_pin, color: Colors.red),
                          Text('Anuradhapura',style: GoogleFonts.poppins(fontSize: 16) ),
                        ],
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [


                        Text('Hi <Farmer Name>!',style: GoogleFonts.poppins(fontSize: 20), ),
                      ],
                    ),
                  ),
                ],
              ),
            ), SizedBox(height: 50,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(

                  children: [
                    buildButton('Crops'),
                    SizedBox(height: 50,),
                    buildButton('Shop list'),
                    SizedBox(height: 50,),
                    buildButton('Market price'),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {},
          child: Text(text,style: GoogleFonts.poppins(fontSize: 20,color: Colors.green.shade900,fontWeight: FontWeight.bold), ),
        ),
      ),
    );
  }
}
