import 'package:flutter/material.dart';

class CustomAppBar01 extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const CustomAppBar01({super.key})
      : preferredSize = const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 10.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          // colors: [
          //   Color.fromARGB(255, 25, 196, 33),
          //   Color.fromARGB(255, 58, 80, 226),
          //   Color.fromARGB(255, 7, 182, 236)
          // ], // Gradient colors
          colors: [
            Color.fromARGB(205, 14, 27, 206),
            Color.fromARGB(205, 14, 27, 206),
            Color.fromARGB(205, 14, 27, 206)
          ], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(10.0),
        ),


        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center all items horizontally
          children: [
            // Commented out image section, you can add it back if needed
            // Padding(
            //   padding: const EdgeInsets.all(4),
            //   child: Image.asset(
            //     'assets/logo.png', // Path to your image
            //     height: 70.0, // Adjust the height as needed
            //     width: 70.0, // Adjust the width as needed
            //   ),
            // ),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold, 
                    fontFamily: 'Roboto',
                  ),
                  children: [
                    TextSpan(
                      text: 'E Zone BIZ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
