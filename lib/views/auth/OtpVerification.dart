import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/loading.dart';
import '../../constants/colors.dart';
import '../../utilities/storage.dart';

class OtpEntryPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpEntryPage(this.verificationId, this.phoneNumber, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OtpEntryPageState createState() => _OtpEntryPageState();
}

class _OtpEntryPageState extends State<OtpEntryPage> {
  final TextEditingController _smsCodeController = TextEditingController();
  var isLoading = false;
  @override
  void initState() {
    super.initState();

    //maximum of 6 digits
    _smsCodeController.addListener(() {
      if (_smsCodeController.text.length > 6) {
        _smsCodeController.text = _smsCodeController.text.substring(0, 6);
        _smsCodeController.selection = TextSelection.fromPosition(
          TextPosition(offset: _smsCodeController.text.length),
        );
      }
    });
  }

  Future<void> _verifySmsCode() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _smsCodeController.text,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        var storage = SLocalStorage();
        storage.saveData('verifiedNmber', _smsCodeController.text.trim());
        _timer = Timer(const Duration(seconds: 4), () {
          // Check if the widget is still mounted
          if (mounted) {
            // Navigate to the next screen
            Navigator.of(context).pop();
          }
        });
      } else {}
    } catch (e) {
      print(e);
    }
  }
  // ignore: unused_field
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('ادخل الرمز'),
        backgroundColor: const Color.fromARGB(255, 4, 94, 97),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 233, 233),
      body: isLoading
          ? const Center(
              child: Loading(
                color: primaryColor,
                kSize: 40,
              ),
            )
          : Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'ادخل الرمز ل ${widget.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/login.png',
                      width: 300,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _smsCodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'SMS Code',
                        filled: true,
                        fillColor: const Color.fromARGB(255, 204, 231, 232),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 4, 94, 97),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      cursorColor: const Color.fromARGB(255, 91, 201, 205),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _verifySmsCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Text('تم'),
                  ),
                ],
              ),
            ),
    );
  }
}
