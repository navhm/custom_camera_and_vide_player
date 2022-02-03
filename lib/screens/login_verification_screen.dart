import 'dart:async';

import 'package:bc_assignment/screens/stream_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class LoginVerificationScreen extends StatefulWidget {
  static const String id = 'login_verification_screen';
  final String phoneNumber;

  LoginVerificationScreen({required this.phoneNumber});

  @override
  _LoginVerificationScreenState createState() =>
      _LoginVerificationScreenState();
}

class _LoginVerificationScreenState extends State<LoginVerificationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String? _verificationCode;
  int start = 30;
  Timer? timer;
  bool resendOtp = false;
  final TextEditingController _controller = TextEditingController();

  void _startTimer() {
    const onsec = Duration(seconds: 1);
    timer = Timer.periodic(onsec, (timer) {
      try {
        if (start == 0) {
          setState(() {
            timer.cancel();
            resendOtp = true;
          });
        } else {
          setState(() {
            start--;
          });
        }
      } catch (e) {
        throw (e);
      }
    });
  }

  void _stopTimer() {
    setState(() {
      start = 0;
      timer!.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
            child: Column(
              children: [
                Image(
                  height: 40,
                  image: AssetImage("images/bclogo.png"),
                ),
                Spacer(),
                SizedBox(
                  height: 70,
                  child: Material(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: TextField(
                        style: TextStyle(
                            fontSize: 25,
                            letterSpacing: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w900),
                        maxLength: 6,
                        controller: _controller,
                        textAlign: TextAlign.center,
                        onChanged: (value) {},
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 20),
                            border: InputBorder.none,
                            hintText: 'Enter OTP',
                            hintStyle: TextStyle(
                                fontSize: 17,
                                letterSpacing: 0,
                                color: Colors.white,
                                fontWeight: FontWeight.normal))),
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                resendOtp
                    ? GestureDetector(
                        onTap: () {
                          start = 60;
                          resendOtp = false;
                          _startTimer();
                          _verifyPhoneNumber();
                        },
                        child: Text(
                          "Did not get OTP, resend?",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : Text(
                        "Send OTP again in 00:$start secs",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                SizedBox(
                  height: 15,
                ),
                Container(
                    height: 45,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.pink,
                    ),
                    child: TextButton(
                      child: Text(
                        "Get started",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _login,
                    )),
                SizedBox(
                  height: 30,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      timer!.cancel();
                    });

                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _verifyPhoneNumber() {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phoneNumber}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => StreamPage()),
                  (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationCode = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationCode = verificationId;
          });
        },
        timeout: Duration(seconds: 60));
  }

  void _login() async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
              verificationId: _verificationCode!, smsCode: _controller.text))
          .then((value) async {
        if (value.user != null) {
          _stopTimer();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => StreamPage()),
              (route) => false);
        }
      });
    } catch (e) {
      final snackBar = SnackBar(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          content: const Text('invalid OTP'));

      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verifyPhoneNumber();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }
}
