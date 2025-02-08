// ignore_for_file: unused_element, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../components/loading.dart';
import '../../constants/colors.dart';
import '../../helpers/image_picker.dart';
import '../../models/global.dart';
import '../main/customer/customer_bottomNav.dart';

enum Field {
  fullname,
  email,
  password,
  phone,
  location,
}

enum Field2 {
  email,
  password,
}

class Auth extends StatefulWidget {
  static const routeName = '/auth';
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _fullnameController = TextEditingController();
  final _passwordController = TextEditingController();
  var obscure = true; // password obscure value
  var isLogin = true;
  File? profileImage;
  var isLoading = false;

  final _auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;
  // toggle password obscure
  _togglePasswordObscure() {
    setState(() {
      obscure = !obscure;
    });
  }

  // snackbar for error message
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 3), // Set a duration for the SnackBar
        action: SnackBarAction(
          onPressed: () => ScaffoldMessenger.of(context)
              .hideCurrentSnackBar(), // Dismiss the SnackBar
          label: 'إلغاء',
          textColor: Colors.white,
        ),
      ),
    );
  }

  // custom textfield for all form fields
  Widget kTextField(
    TextEditingController controller,
    String hint,
    String label,
    Field field,
    bool obscureText,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: field == Field.email
          ? TextInputType.emailAddress
          : field == Field.phone
              ? TextInputType.number
              : TextInputType.text,
      textInputAction:
          field == Field.password ? TextInputAction.done : TextInputAction.next,
      autofocus: field == Field.fullname ? true : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
        suffixIcon: field == Field.password
            ? _passwordController.text.isNotEmpty ||
                    _password2Controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () => _togglePasswordObscure(),
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: primaryColor,
                    ),
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
        hintText: hint,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 2,
            color: primaryColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        ),
      ),
      validator: (value) {
        switch (field) {
          case Field.email:
            if (!value!.contains('@')) {
              return 'الإيميل غير صالح';
            }
            if (value.isEmpty) {
              return 'لايمكن أن يكون الإيميل فارغا';
            }
            break;
          case Field.password:
            if (value!.isEmpty || value.length < 8) {
              return 'تأكد من كتابة كلمة المرور , على الأقل ثمانية أحرف.';
            }
            if (_passwordController.text != _password2Controller.text) {
              return 'تأكد من صحة كتابة كلمتا المرور';
            }
            break;

          case Field.fullname:
            if (value!.isEmpty || value.length < 7) {
              return 'الإسم غير مكتمل';
            }
            break;

          case Field.location:
            if (value!.isEmpty || value.length < 10) {
              return 'ادخل موقعك بالتفصيل';
            }
            break;
          case Field.phone:
            if (value!.isEmpty || value.length < 9) {
              return 'ادخل رقمك الأساسي';
            }
            break;
        }

        return null;
      },
    );
  }

  Widget kTextField2(
    TextEditingController controller,
    String hint,
    String label,
    Field2 field2,
    bool obscureText,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: field2 == Field2.email
          ? TextInputType.emailAddress
          : TextInputType.text,
      textInputAction: field2 == Field2.password
          ? TextInputAction.done
          : TextInputAction.next,
      autofocus: field2 == Field2.email ? true : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
        suffixIcon: field2 == Field2.password
            ? _passwordController.text.isNotEmpty
                ? IconButton(
                    onPressed: () => _togglePasswordObscure(),
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: primaryColor,
                    ),
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
        hintText: hint,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 2,
            color: primaryColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        ),
      ),
      validator: (value) {
        switch (field2) {
          case Field2.email:
            if (!value!.contains('@')) {
              return 'الإيميل غير صالح';
            }
            if (value.isEmpty) {
              return 'لايمكن أن يكون الإيميل فارغا';
            }
            break;
          case Field2.password:
            if (value!.isEmpty || value.length < 8) {
              return 'تأكد من كتابة كلمة المرور , على الأقل ثمانية أحرف.';
            }

            break;
        }

        return null;
      },
    );
  }

  // for selecting photo
  _selectPhoto(File image) {
    setState(() {
      profileImage = image;
    });
  }

  void navigateToNextScreen() {
    Navigator.of(context).pushNamed(CustomerBottomNav.routeName);
  }

  _handleAuth() async {
    var valid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();

    if (!valid) {
      return; // Return without further action if validation fails
    }

    try {
      if (isLogin) {
        setState(() {
          isLoading = true;
        });
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _auth.authStateChanges().listen((user) {
          if (user == null) {
            setState(() {
              isLoading = false;
            });
            // User is not signed in, show error message
            showSnackBar('هذا الإيميل غير موجود.');
          } else {
            FirebaseAuth.instance.authStateChanges();
            setState(() {
              isLoading = false;
            });
            if (!mounted) {
              currentUserId = FirebaseAuth.instance.currentUser?.uid;
              // Navigator.of(context).pushNamed(CustomerBottomNav.routeName);
              Navigator.of(context).pushNamedAndRemoveUntil(
                CustomerBottomNav.routeName,
                (route) => false,
              );
            }
          }
        });
      } else {
        if (profileImage == null) {
          showSnackBar('لايجب أن تكون الصورة فارغة!');
          return;
        }
        setState(() {
          isLoading = true;
        });
        var credential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user-images')
            .child('${credential.user!.uid}.jpg');

        File? file;
        file = File(profileImage!.path);

        try {
          await storageRef.putFile(file);
          var downloadUrl = await storageRef.getDownloadURL();

          await firebase.collection('customers').doc(credential.user!.uid).set({
            'fullname': _fullnameController.text.trim(),
            'email': _emailController.text.trim(),
            'image': downloadUrl,
            'auth-type': 'email',
            'phone': _phoneController.text.trim(),
            'address': _locationController.text.trim(),
            'password': _passwordController.text.trim(),
          });

          // var storage = SLocalStorage();
          // storage.saveData('address', _locationController.text.trim());
          if (!mounted) {
            setState(() {
              isLoading = false;
            });
            showSnackBar('حدث خطأ ما!');
            return;
          }
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              CustomerBottomNav.routeName,
              (route) => false,
            );
          }
        } catch (e) {
          showSnackBar('حدث خطأ ما: $e');
        }
      }
    } on FirebaseAuthException catch (e) {
      var error = 'An error occurred. Check credentials!';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        showSnackBar('ايميل او باسسورد خاطئ');
      } else {
        showSnackBar('حدث خطأ ما: $e');
      }
      if (e.message != null) {
        if (e.code == 'user-not-found') {
          error = "المستخدم غير موجود!";
          return;
        } else if (e.code == 'account-exists-with-different-credential') {
          error = "الإيميل مستخدم مسبقا!";
          return;
        } else if (e.code == 'wrong-password') {
          error = 'إيميل أو باسوورد خاطئ!';
          return;
        } else if (e.code == 'network-request-failed') {
          error = 'خطأ في الشبكة!';
          return;
        } else {
          error = e.code;
          return;
        }
      }

      showSnackBar(error);
    } catch (e) {
      showSnackBar('حدث خطأ ما: $e');
    } finally {
      // Reset loading state
      setState(() {
        isLoading = false;
      });
    }
  }

  isLoadingFnc() {
    setState(() {
      isLoading = true;
    });
    _timer = Timer(const Duration(seconds: 4), () {
      // Check if the widget is still mounted
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          CustomerBottomNav.routeName,
          (route) => false,
        );
      }
    });
  }

  @override
  void initState() {
    _passwordController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  Timer? _timer;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<UserCredential> _googleAuth() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      var logCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(logCredential.user!.uid)
          .set(
        {
          'fullname': googleUser!.displayName,
          'email': googleUser.email,
          'image': googleUser.photoUrl,
          'auth-type': 'google',
          'phone': '',
          'address': '',
        },
      ).then((value) {
        isLoadingFnc();
      });
      // }
    } on FirebaseAuthException catch (e) {
      var error = 'جدث خطأ ما تأكد من بياناتك!';
      if (e.message != null) {
        error = e.message!;
      }
      showSnackBar(error); // showSnackBar will show error if any
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    // sign in with credential
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  // navigate to forgot password screen
  // _forgotPassword() {
  //   Navigator.of(context).pushNamed(ForgotPassword.routeName);
  // }

  _switchLog() {
    setState(() {
      isLogin = !isLogin;
      _passwordController.text = "";
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                !isLogin
                    ? ProfileImagePicker(selectImage: _selectPhoto)
                    : Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 60,
                          child: Image.asset('assets/images/login.png'),
                        ),
                      ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    isLogin ? 'تسجيل ' : 'دخول',
                    // 'مرحبا',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(
                        child: Loading(
                          color: primaryColor,
                          kSize: 70,
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            !isLogin
                                ? kTextField(
                                    _fullnameController,
                                    'محمد علي محمد',
                                    'الإسم الثلاثي',
                                    Field.fullname,
                                    false,
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 10),
                            !isLogin
                                ? kTextField(
                                    _phoneController,
                                    '777777777',
                                    'الرقم',
                                    Field.phone,
                                    false,
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 10),
                            !isLogin
                                ? kTextField(
                                    _locationController,
                                    'تعز / الموشكي / جوار المدرسه / عماره 33 / شقة 3',
                                    'الموقع',
                                    Field.location,
                                    false,
                                  )
                                //   Row(
                                // children: [

                                // GestureDetector(
                                //   onTap: () {
                                //     Navigator.of(context).pushNamed(
                                //       MapScreen.routeName,
                                //     );
                                //     setState(() {

                                //     });
                                //   },
                                //   child: FaIcon(
                                //     FontAwesomeIcons.mapLocation,
                                //     color: location == null
                                //         ? Colors.red
                                //         : primaryColor,
                                //     size: 24.1,
                                //   ),
                                // ),
                                //   ],
                                // )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 10),
                            !isLogin
                                ? kTextField(
                                    _emailController,
                                    'AbubakerSallam@gmail.com',
                                    'ايميل',
                                    Field.email,
                                    false,
                                  )
                                : const SizedBox.shrink(),
                            isLogin
                                ? kTextField2(
                                    _emailController,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'Please enter your email';
                                    //   }
                                    //   return null;
                                    // },
                                    'AbubakerSallam@gmail.com',
                                    'ايميل',
                                    Field2.email,
                                    false,
                                  )
                                : const SizedBox.shrink(),
                            // : const SizedBox.shrink(),
                            SizedBox(height: isLogin ? 10 : 10),
                            !isLogin
                                ? kTextField(
                                    _passwordController,
                                    '********',
                                    'رمزك',
                                    Field.password,
                                    obscure,
                                  )
                                : const SizedBox.shrink(),
                            isLogin
                                ? kTextField2(
                                    _passwordController,
                                    '********',
                                    'رمزك',
                                    Field2.password,
                                    obscure,
                                  )
                                : const SizedBox.shrink(),
                            SizedBox(height: isLogin ? 0 : 10),
                            !isLogin
                                ? kTextField(
                                    _password2Controller,
                                    '********',
                                    ' أعد إدخال الرمز',
                                    Field.password,
                                    obscure,
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 30),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                ),
                                icon: Icon(
                                  isLogin
                                      ? Icons.person
                                      : Icons.person_add_alt_1,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _handleAuth();
                                },
                                //onPressed: () => _handleAuth(),
                                label: Text(
                                  isLogin ? 'الدخول إلى حسابك' : 'تسجيل حساب',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(15),
                              ),
                              onPressed: () => {},
                              // onPressed: () => _googleAuth(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google.png',
                                    width: 20,
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    isLogin
                                        ? 'التسجيل بحساب جوجل'
                                        : 'الدخول بحساب جوجل',
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => {},
                                  // onPressed: () => _forgotPassword(),
                                  child: const Text(
                                    'نسيت الرمز؟',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _switchLog(),
                                  child: Text(
                                    isLogin
                                        ? 'مستخدم جديد؟ تسجيل الدخول'
                                        : 'لديك حساب بالفعل؟',
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            isLogin
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.all(15),
                                    ),
                                    //onPressed: () => {},
                                    onPressed: () {
                                      isLoadingFnc();
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'الدخول كزائر',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<FirebaseFirestore>('firebase', firebase));
    properties
        .add(DiagnosticsProperty<FirebaseFirestore>('firebase', firebase));
  }
}
