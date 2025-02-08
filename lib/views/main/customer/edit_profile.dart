// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/loading.dart';
import '../../../constants/colors.dart';
import '../../../helpers/image_picker.dart';
// import '../../../utilities/storage.dart';

// for fields
enum Field {
  fullname,
  email,
  password,
  phone,
  address,
}

class EditProfile extends StatefulWidget {
  const EditProfile({
    super.key,
    this.editPasswordOnly = false,
  });
  final bool editPasswordOnly;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  var obscure = true; // password obscure value
  File? profileImage;
  final _auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;
  var userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot? credential;
  var isLoading = true;
  var isInit = true;
  var changePassword = false;

  // fetch user credentials
  _fetchUserDetails() async {
    credential = await firebase.collection('customers').doc(userId).get();
    _emailController.text = credential!['email'];
    _fullnameController.text = credential!['fullname'];
    _phoneController.text = credential!['phone'];
    _addressController.text = credential!['address'];
    setState(() {
      isLoading = false;
    });
  }

  // toggle password obscure
  _togglePasswordObscure() {
    setState(() {
      obscure = !obscure;
    });
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
              ? TextInputType.phone
              : TextInputType.text,
      textInputAction:
          field == Field.password ? TextInputAction.done : TextInputAction.next,
      autofocus: field == Field.email ? true : false,
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

          case Field.fullname:
            if (value!.isEmpty || value.length < 3) {
              return 'الإسم غير مكتمل';
            }
            break;

          case Field.phone:
            if (value!.isEmpty || value.length < 9) {
              return 'الرقم غير صالح';
            }
            break;

          case Field.address:
            if (value!.isEmpty || value.length < 10) {
              return 'ادخل موقعك بالتفصيل';
            }
            break;

          case Field.password:
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

  // loading fnc
  isLoadingFnc() {
    setState(() {
      isLoading = true;
    });

    _timer = Timer(const Duration(seconds: 4), () {
      // Check if the widget is still mounted
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        // Navigate to the next screen
        Navigator.of(context).pop();
      }
    });
  }

  Timer? _timer;
  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

//authenticate us
  @override
  void initState() {
    _passwordController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      _fetchUserDetails();
    }
    setState(() {
      isInit = false;
    });
    super.didChangeDependencies();
  }

  // snackbar for error message
  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        action: SnackBarAction(
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          label: 'إلغاء',
          textColor: Colors.white,
        ),
      ),
    );
  }

  Future _saveDetails() async {
    setState(() {
      isLoading = false;
    });
    var valid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    if (!valid) {
      return null;
    }

    if (widget.editPasswordOnly || changePassword) {
      _auth.currentUser!.updatePassword(_passwordController.text.trim());
      isLoadingFnc();
    } else {
      var storageRef = FirebaseStorage.instance
          .ref()
          .child('user-images')
          .child('$userId.jpg');
      File? file;
      if (profileImage != null) {
        file = File(profileImage!.path);
      }

      try {
        if (profileImage != null) {
          await storageRef.putFile(file!);
        }
        //  obtain image download url
        var downloadUrl = await storageRef.getDownloadURL();

        _auth.currentUser!.updateEmail(_emailController.text.trim());
        firebase.collection('customers').doc(userId).update({
          "email": _emailController.text.trim(),
          "fullname": _fullnameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "address": _addressController.text.trim(),
          "image": downloadUrl,
        });
        //  var storage = SLocalStorage();
        //   storage.saveData('address', _addressController.text.trim());
        isLoadingFnc();
      } on FirebaseException catch (e) {
        setState(() {
          isLoading = false;
        });
        showSnackBar('حدث خطأ! ${e.message}');
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (kDebugMode) {
          print(e);
        }
      }
    }
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(builder: (context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.chevron_left,
              color: primaryColor,
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () => _saveDetails(),
        label: Text(
          widget.editPasswordOnly ? 'تغيير الرمز' : 'حفظ البيانات',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        icon: Icon(
          widget.editPasswordOnly ? Icons.key : Icons.save,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? const Center(
                child: Loading(
                  color: primaryColor,
                  kSize: 40,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.editPasswordOnly
                        ? const SizedBox.shrink()
                        : ProfileImagePicker(
                            selectImage: _selectPhoto,
                            isReg: false,
                            imgUrl: credential!['image'],
                          ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        widget.editPasswordOnly || changePassword
                            ? 'تعديل البيانات والرمز'
                            : 'تعديل بيانات البروفايل',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          widget.editPasswordOnly
                              ? const SizedBox.shrink()
                              : Column(
                                  children: [
                                    kTextField(
                                      _emailController,
                                      _emailController.text,
                                      'الإيميل',
                                      Field.email,
                                      false,
                                    ),
                                    const SizedBox(height: 15),
                                    kTextField(
                                      _fullnameController,
                                      _fullnameController.text,
                                      'الإسم الثلاثي',
                                      Field.fullname,
                                      false,
                                    ),
                                    const SizedBox(height: 15),
                                    kTextField(
                                      _phoneController,
                                      _phoneController.text,
                                      'الرقم',
                                      Field.phone,
                                      false,
                                    ),
                                    const SizedBox(height: 15),
                                    kTextField(
                                      _addressController,
                                      _addressController.text,
                                      'عنوان التوصيل',
                                      Field.address,
                                      false,
                                    ),
                                  ],
                                ),
                          widget.editPasswordOnly
                              ? const SizedBox.shrink()
                              : Row(
                                  children: [
                                    Text(
                                      changePassword
                                          ? 'عدم تغيير الرمز'
                                          : 'تغيير الرمز',
                                      style:
                                          const TextStyle(color: primaryColor),
                                    ),
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: primaryColor,
                                      value: changePassword,
                                      onChanged: (value) => setState(
                                        () {
                                          changePassword = value!;
                                        },
                                      ),
                                      side: const BorderSide(
                                        color: primaryColor,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                          changePassword || widget.editPasswordOnly
                              ? kTextField(
                                  _passwordController,
                                  '********',
                                  'الرمز',
                                  Field.password,
                                  obscure,
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
