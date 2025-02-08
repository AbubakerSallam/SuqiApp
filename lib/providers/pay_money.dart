// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suqi/models/global.dart';
import '../../../components/loading.dart';
import '../../../constants/colors.dart';
import '../components/kListTile.dart';

// for fields
enum Field {
  fullname,
  money,
  howmuchmoney,
  note,
}

class PayMoney extends StatefulWidget {
  const PayMoney({
    super.key,
    this.isUserMoney = false,
  });
  final bool isUserMoney;

  @override
  State<PayMoney> createState() => _PayMoneyState();
}

class _PayMoneyState extends State<PayMoney> {
  String? username = currentUserId;
  String? userMoney;
  String? imageUrl;
  int userMoneyn = 0;
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _moneyController = TextEditingController();
  final _howMuchMoneyController = TextEditingController();
  final _noteController = TextEditingController();
  final firebase = FirebaseFirestore.instance;

  var isLoading = true;
  var isInit = true;
  var changePassword = false;
  DocumentSnapshot? credential;
  DocumentSnapshot? paydetail;
  bool _hasStore = false;
  // fetch user credentials

  _fetchUserDetails() async {
    if (!widget.isUserMoney) {
      credential =
          await firebase.collection('sellers').doc(currentUserId).get();
      if (mounted) {
        _hasStore = credential!.exists;
        if (_hasStore) {
          imageUrl = credential!['image'];
        }
      }
    } else {
      credential =
          await firebase.collection('customers').doc(currentUserId).get();
    }
    paydetail = await firebase.collection('moneytext').doc('taizDevspay').get();

    setState(() {
      isLoading = false;
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
      keyboardType: field == Field.fullname
          ? TextInputType.text
          : field == Field.note
              ? TextInputType.text
              : TextInputType.number,
      autofocus: field == Field.fullname ? true : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
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
          case Field.fullname:
            if (value!.isEmpty || value.length < 7) {
              return 'الإسم غير مكتمل';
            }
            break;
          case Field.howmuchmoney:
            if (value!.length < 4) {
              return 'يجب أن يكون الإيداع أكثر من ألف ريال';
            } else if (value.isEmpty) {
              return 'ادخل الرقم المودع';
            }
            break;
          case Field.money:
            if (value!.isEmpty || value.length < 9) {
              return 'رقم الحوالة غير صالح';
            }
            break;
          case Field.note:
            break;
        }
        return null;
      },
    );
  }

  isLoadingFnc() {
    setState(() {
      isLoading = true;
    });

    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        // Navigate to the next screen
        Navigator.of(context).pop();
      }
    });
  }

  Timer? _timer;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

//authenticate us
  @override
  void initState() {
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
      ),
    );
  }

  Future _saveDetails() async {
    var valid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    if (!valid) {
      return null;
    }

    if (widget.isUserMoney) {
      try {
        await firebase.collection('payeddata').add({
          "user": currentUserId,
          "fullname": _fullnameController.text.trim(),
          "money": _moneyController.text.trim(),
          "how-much-money": _howMuchMoneyController.text.trim(),
          "note": _noteController.text.trim(),
          "isuserpay": widget.isUserMoney,
        });

        isLoadingFnc();
      } on FirebaseException catch (e) {
        showSnackBar('حدث خطأ! ${e.message}');
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      try {
        await firebase.collection('payeddata').add({
          "store": currentUserId,
          "fullname": _fullnameController.text.trim(),
          "money": _moneyController.text.trim(),
          "how-much-money": _howMuchMoneyController.text.trim(),
          "note": _noteController.text.trim(),
          "isuserpay": widget.isUserMoney,
        });

        await firebase.collection('ads').add({
          "seller_id": currentUserId,
          "image": credential!['image'],
        });

        isLoadingFnc();
      } on FirebaseException catch (e) {
        showSnackBar('حدث خطأ! ${e.message}');
      } catch (e) {
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
        onPressed: () {
          _saveDetails();
          showSnackBar('سيتم مراجعة الدفع و إبلاغك فورا');
        },
        label: const Text(
          'حفظ البيانات',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        icon: const Icon(
          Icons.save,
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
                    Center(
                      child: Text(
                        widget.isUserMoney ? 'إيداع للحساب' : 'دفع للمتجر',
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
                          Column(
                            children: [
                              KListTile(
                                title: 'طريقة الدفع',
                                icon: Icons.payments_outlined,
                                onTapHandler: () {
                                  setState(() {});
                                },
                                subtitle: paydetail!['toPay'],
                              ),
                              const SizedBox(height: 20),
                              kTextField(
                                _fullnameController,
                                _fullnameController.text,
                                'الإسم الثلاثي للمودع',
                                Field.fullname,
                                false,
                              ),
                              const SizedBox(height: 15),
                              kTextField(
                                _howMuchMoneyController,
                                _howMuchMoneyController.text,
                                'المبلغ المودع',
                                Field.howmuchmoney,
                                false,
                              ),
                              const SizedBox(height: 15),
                              kTextField(
                                _moneyController,
                                _moneyController.text,
                                'رقم المراجعة',
                                Field.money,
                                false,
                              ),
                              const SizedBox(height: 15),
                              kTextField(
                                _noteController,
                                _noteController.text,
                                widget.isUserMoney
                                    ? 'ملاحظات.. تغذية حسابي'
                                    : 'ملاحظات تغذية حسابي, ترويج للمتجر, ترويج للمنتج (إسم المنتج)',
                                Field.note,
                                false,
                              ),
                            ],
                          ),
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
