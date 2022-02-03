import 'package:bc_assignment/screens/login_verification_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login_screen';
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    height: 40,
                    image: AssetImage("images/bclogo.png"),
                  ),
                  SizedBox(
                    height: 300.0,
                  ),
                  // Spacer(),
                  SizedBox(
                    height: 65,
                    width: 400,
                    child: Material(
                      elevation: 2,
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            Text(
                              "+91",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                            Transform.rotate(
                              angle: pi / 2,
                              child: SizedBox(
                                width: 35,
                                child: Divider(
                                  color: Colors.white,
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  onChanged: (value) {},
                                  maxLength: 10,
                                  keyboardType: TextInputType.number,
                                  controller: _controller,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(top: 17),
                                      border: InputBorder.none,
                                      hintText: 'Enter Mobile Number',
                                      hintStyle: TextStyle(
                                          fontSize: 17, color: Colors.white))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.pink,
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (_controller.text.length < 10) {
                          final snackBar = SnackBar(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                              content: const Text('Enter 10 digit mobile no.'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginVerificationScreen(
                                phoneNumber: _controller.text,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Continue",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
