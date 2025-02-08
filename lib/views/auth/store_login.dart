// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suqi/models/global.dart';
import 'package:suqi/views/main/seller/seller_bottomNav.dart';

import '../../components/loading.dart';
import '../../constants/colors.dart';
import '../../helpers/image_picker.dart';
import '../../utilities/categories_list.dart';
import '../main/seller/dashboard_screens/edit_product.dart';

// for fields
enum Field { fullname, email, password, phone, location, money, type }

class StoreAuth extends StatefulWidget {
  static const routeName = '/store-auth';

  const StoreAuth({
    super.key,
  });
  // final bool isSellerReg;

  @override
  State<StoreAuth> createState() => _StoreAuthState();
}

class _StoreAuthState extends State<StoreAuth> {
  //var userId = '123456789';
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _fullnameController = TextEditingController();
  final _typeController = TextEditingController();
  final _monyNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _houersController = TextEditingController();
  var obscure = true; // password obscure value
  var isLogin = true;
  File? profileImage;
  var isLoading = false;

  List<String> subCategory = [];
  List<String> myCategory = category;
  var currentCategory = '';
  var currentSubCategory = '';
  final firebase = FirebaseFirestore.instance;
  // ignore: prefer_typing_uninitialized_variables
  var userId;
  DocumentSnapshot? credential;

  // toggle password obscure
  _togglePasswordObscure() {
    setState(() {
      obscure = !obscure;
    });
  }

  _fetchUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    userId = user?.uid;

    // credential = await firebase.collection('customers').doc(userId).get();
    // setState(() {
    //   isLoading = false;
    // });
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
          : field == Field.phone || field == Field.money
              ? TextInputType.number
              : TextInputType.text,
      textInputAction:
          field == Field.password ? TextInputAction.done : TextInputAction.next,
      autofocus: field == Field.fullname ? true : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
        suffixIcon: field == Field.password
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
        switch (field) {
          case Field.email:
            if (!value!.contains('@')) {
              return 'الإيميل غير صالح';
            }
            if (value.isEmpty) {
              return 'لايمكن أن يكون الإيميل فارغا';
            }
            break;

          case Field.type:
            if (value!.isEmpty) {
              return 'يرجى تحديد نوع الخدمة';
            }
            break;
          case Field.fullname:
            if (value!.isEmpty || value.length < 5) {
              return 'الإسم غير مكتمل';
            }
            break;

          case Field.password:
            if (value!.isEmpty || value.length < 8) {
              return 'تأكد من كتابة كلمة المرور , على الأقل ثمانية أحرف.';
            }
            if (_passwordController != _password2Controller) {
              return 'تأكد من صحة كتابة كلمتا المرور';
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
          case Field.money:
            if (value!.isEmpty || value.length < 6) {
              return 'ادخل رقم حوالة صالح';
            }
            break;
        }
        return null;
      },
    );
  }

  Widget kDropDownField(
    DropDownType dropDownType,
    List<String> list,
    String currentValue,
    String label,
  ) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
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
      value: currentValue,
      borderRadius: BorderRadius.circular(20),
      items: list
          .map(
            (data) => DropdownMenuItem(
              value: data,
              child: Text(data),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          currentValue = value.toString();
          if (dropDownType == DropDownType.category) {
            currentCategory = value.toString();
          } else {
            currentSubCategory = value.toString();
          }
        });

        switch (value) {
          case 'مطاعم':
            setState(() {
              subCategory = resturantsCategories;
              currentSubCategory = resturantsCategories[0];
            });
            break;
          case 'ملابس':
            setState(() {
              subCategory = clothesCategories;
              currentSubCategory = clothesCategories[0];
            });
            break;

          case 'خدمات عمال':
            setState(() {
              subCategory = jopsCategories;
              currentSubCategory = jopsCategories[0];
            });
            break;

          case 'أخرى':
            setState(() {
              subCategory = otherCategories;
              currentSubCategory = otherCategories[0];
            });
            break;

          case 'ماركات':
            setState(() {
              subCategory = markatCategories;
              currentSubCategory = markatCategories[0];
            });
            break;
        }
      },
    );
  }

  // for selecting photo
  _selectPhoto(File image) {
    setState(() {
      profileImage = image;
    });
  }

  Timer? _timer;
  // loading fnc
  isLoadingFnc() {
    setState(() {
      isLoading = true;
    });
    _timer = Timer(const Duration(seconds: 4), () {
      // Check if the widget is still mounted
      if (mounted) {
        // Navigate to the next screen
        Navigator.of(context).pushNamed(SellerBottomNav.routeName);
        //  Navigator.of(context).pushNamed(SellerBottomNav.routeName);
      }
    });
  }

  void navigateToNextScreen() {
    Navigator.of(context).pushNamed(SellerBottomNav.routeName);
  }

  // handle sign in and  sign up
  _handleAuth() async {
    var valid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    if (!valid) {
      return;
    }

    try {
      if (profileImage == null) {
        // profile image is empty
        showSnackBar('لايجب أن تكون الصورة فارغة!');
        return null;
      }

      setState(() {
        isLoading = true;
      });
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('store-images')
          .child('$currentUserId.jpg');

      File? file;
      file = File(profileImage!.path);

      try {
        await storageRef.putFile(file);
        var downloadUrl = await storageRef.getDownloadURL();

        await firebase.collection('sellers').doc(userId).set({
          'owner-id': userId,
          'fullname': _fullnameController.text.trim(),
          'email': _emailController.text.trim(),
          'image': downloadUrl,
          'type': _typeController.text.trim(),
          'money': _monyNumberController.text.trim(),
          // 'auth-type': 'email',
          'phone': _phoneController.text.trim(),
          'address': _locationController.text.trim(),
          'hours': _houersController.text.trim(),
          'category': _categoryController.text.trim(),
          'description': _descriptionController.text.trim(),
          'totalRatings': 0,
          'averageRating': 0.0,
          'isactive': false,
          'isband': false,
        });
          if (!mounted) {
              setState(() {
              isLoading = false;
            });
            showSnackBar('حدث خطأ ما!');
            return;
          }
        navigateToNextScreen();
        //isLoadingFnc();
      } catch (e) {
        if (kDebugMode) {
          showSnackBar('حدث خطأ ما');
        }
      }
    } on FirebaseAuthException catch (e) {
      var error = 'حدث خطأ ما: !';
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

      // showSnackBar(error);
      // setState(() {
      //   isLoading = false;
      // });
    } catch (e) {
      // if (kDebugMode) {
      showSnackBar('حدث خطأ ما: $e');
    } finally {
      // Reset loading state
      setState(() {
        isLoading = false;
      });
    }
  }

  _switchLog() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    currentCategory = category[0];
    _passwordController.addListener(() {
      setState(() {});
    });
    super.initState();
    _fetchUserDetails();
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
                Center(
                  child: isLogin
                      ? ProfileImagePicker(selectImage: _selectPhoto)
                      // CircleAvatar(
                      //     backgroundColor: Colors.white,
                      //     radius: 60,
                      //     child: Image.asset('assets/images/login.png'),
                      //   ),
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    // isLogin
                    //     ? '276198692769'
                    //     :'تسجيل متجري',

                    isLogin
                        ? 'تسجيل متجري'
                        : isLoading
                            ? 'تسجيل المتجر'
                            : '276198692769',

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
                                    _typeController,
                                    'شهري/سنوي',
                                    'نوع الاشتراك',
                                    Field.type,
                                    false,
                                  )
                                : kTextField(
                                    _fullnameController,
                                    'محلات الشميري',
                                    'اسم المتجر',
                                    Field.fullname,
                                    false,
                                  ),

                            const SizedBox(height: 10),
                            !isLogin
                                ? kTextField(
                                    _monyNumberController,
                                    '98******',
                                    'رقم المراجعة بعد الإيداع للرقم أعلاه',
                                    Field.phone,
                                    false,
                                  )
                                : kTextField(
                                    _phoneController,
                                    '777777777',
                                    'الرقم',
                                    Field.phone,
                                    false,
                                  ),
                            const SizedBox(height: 10),
                            !isLogin
                                ? kTextField(
                                    _descriptionController,
                                    'لبيع الماكولات ..إلخ',
                                    'وصف المحل',
                                    Field.fullname,
                                    false,
                                  )
                                : kTextField(
                                    _locationController,
                                    'تعز / الموشكي / مقابل الكريمي',
                                    'الموقع',
                                    Field.fullname,
                                    false,
                                  ),

                            const SizedBox(height: 10),
                            !isLogin
                                ? kDropDownField(
                                    DropDownType.category,
                                    myCategory,
                                    currentCategory,
                                    'الخدمة',
                                  )
                                : kTextField(
                                    _emailController,
                                    'alshameery@gmail.com',
                                    'ايميل المحل',
                                    Field.email,
                                    false,
                                  ),
                            const SizedBox(height: 10),
                            !isLogin
                                ? kTextField(
                                    _houersController,
                                    '8:00 AM to 8:00 PM',
                                    'ساعات العمل',
                                    Field.fullname,
                                    false,
                                  )
                                : kTextField(
                                    _passwordController,
                                    '********',
                                    'رمزك',
                                    Field.password,
                                    obscure,
                                  ),
                            // const SizedBox(height: 10),

                            const SizedBox(height: 30),
                            isLogin
                                ? Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.all(15),
                                      ),
                                      icon: const Icon(
                                        Icons.next_plan_outlined,
                                        color: Colors.white,
                                      ),

                                      onPressed: () {
                                        setState(() {});
                                        _switchLog();
                                      },

                                      //onPressed: () => _handleAuth(),
                                      label: const Text(
                                        'التالي',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            !isLogin
                                ? TextButton(
                                    onPressed: () => _switchLog(),
                                    child: const Text(
                                      'السابق',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            !isLogin
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.all(15),
                                    ),
                                    //onPressed: () => {},
                                    onPressed: () {
                                      _handleAuth();
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'تأكيد الحساب',
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
