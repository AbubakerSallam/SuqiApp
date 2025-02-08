// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:suqi/models/cart.dart';
import 'package:suqi/providers/order.dart';
import 'package:suqi/views/main/customer/order.dart';
import '../../../components/loading.dart';
import '../../../helpers/notification_helper.dart';
import '../../../models/global.dart';
import '../../../utilities/build_cart.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../providers/cart.dart';
import '../../../utilities/showMessage.dart';
import '../../../utilities/storage.dart';
import '../../auth/OtpVerification.dart';
import '../../auth/auth.dart';
import '../../../utilities/google_maps.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

enum Operation { checkoutCart, clearCart }

class _CartScreenState extends State<CartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneNumberController = TextEditingController();
  String? location;
  String? verifiedNmber;
  String? number;
  bool isLoading = false;
  _getUserNumber() async {
    if (currentUserId == null) {
    } else {
      final firebase = fire.FirebaseFirestore.instance;
      fire.DocumentSnapshot? userCredential;
      userCredential =
          await firebase.collection('customers').doc(currentUserId).get();
      number = userCredential['phone'];
      _phoneNumberController.text = number!;
    }
  }

  @override
  void initState() {
    _getUserNumber();
    var storage = SLocalStorage();
    location = storage.readData('address');
    verifiedNmber = storage.readData('verifiedNmber');
    super.initState();
  }

  final OrderData orderData = OrderData();
  Future<void> _verifyPhone(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final phoneNumber =
        _phoneNumberController.text.replaceAll(RegExp(r'\D'), '');

    // Check  phone number exactly 10 digits
    if (phoneNumber.length == 9) {
      final completePhoneNumber = '+967$phoneNumber';
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: completePhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // This callback is called if the phone number is automatically verified.
            try {
              final UserCredential authResult =
                  await _auth.signInWithCredential(credential);
              final User? user = authResult.user;

              if (user != null) {
                var storage = SLocalStorage();
                storage.saveData('verifiedNmber', completePhoneNumber);
                // ignore: use_build_context_synchronously
                showSnackBar("تم التحقق من الرقم ", context);
              } else {}
            } catch (e) {
              print(e);
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            // Handle verification failed
            print(e.message);
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OtpEntryPage(verificationId, _phoneNumberController.text),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          timeout: const Duration(seconds: 60), // Timeout duration
        );
      } catch (e) {
        setState(() {
          isLoading = true;
        });
        print(e);
      }
    } else {
      setState(() {
        isLoading = true;
      });
      showSnackBar(" تحقق من صحة رقم الهاتف في اعداداتك", context);
      print('Invalid Phone Number');
    }
  }

  @override
  Widget build(BuildContext context) {
    var cartData = Provider.of<CartData>(context, listen: false);

    // var orderData = Provider.of<OrderData>(context, listen: false);
    bool cartIsEmpty() {
      return (cartData.cartItemCount < 1);
    }

    _clearCart() {
      // clearing cart
      cartData.clearCart();
    }

    String? storeToken;
    String? username;
    // String? customerName;
    final firebase = fire.FirebaseFirestore.instance;
    fire.DocumentSnapshot? credential;
    fire.DocumentSnapshot? userCredential;

    showLoginOptions() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'تسجيل دخول !',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'يجب عليك تسجيل الدخول اولا',
            style: TextStyle(
              color: primaryColor,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Auth.routeName,
                  (route) => false,
                );
              },
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

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

    void _confirmOrder(String payMethod) async {
      isLoading = true;
      List<CartItem> items = cartData.cartItems;
      var sellerId = cartData.sellerId;
      var totalPrice = cartData.cartTotalPrice;
      credential = await firebase.collection('customers').doc(sellerId).get();
      userCredential =
          await firebase.collection('customers').doc(currentUserId).get();

      Order order = Order(
        id: DateTime.now().toString(),
        userId: currentUserId!,
        storeId: sellerId,
        totalPrice: totalPrice,
        items: items,
        address: location!.toString(),
        orderDate: DateTime.now(),
        status: 'قيد الإنتظار',
      );

      orderData.addToOrder(order);

      setState(() {});
      // _fetchStorerDetails(sellerId);
      if (mounted) {
        storeToken = credential!['userToken'];
        username = userCredential!['fullname'];
        PushNotificationHelper.notificationFormat(
          storeToken!,
          sellerId,
          "طلب جديد",
          username!,
        );

        try {
          fire.FirebaseFirestore.instance
              .collection('natifications')
              .doc()
              .set({
            'notif_id': DateTime.now().toString(),
            'receiver': sellerId,
            'sender': username,
            'content': "يوجد لديك طلب جديد من $username",
            'address': location!,
            'date': DateTime.now(),
          }).then((value) => {
                    showSnackBar('تم تقديم الطلب'),
                  });
        } on fire.FirebaseException catch (e) {
          showSnackBar('حدث خطأ ما ${e.message}');
        } catch (e) {
          {
            print('حدث خطأ ما  :)');
          }
        }
      }
      _clearCart();
      if (mounted) {
        isLoading = false;
        Navigator.of(context).pushNamed(
          CustomerOrderScreen.routeName,
        );
      }
    }

    void showPaymentOptions() async {
      showDialog(
        context: context,
        builder: (context) {
          String? selectedOption;
          TextEditingController fullNameController = TextEditingController();
          TextEditingController amountController = TextEditingController();
          double amountToPay = cartData.cartTotalPrice;
          amountController.text = amountToPay.toString();
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'خيارات الدفع',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    title: const Text('الدفع عبر بنك الكريمي'),
                    value: 'بنك الكريمي',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('الدفع عبر بايبال'),
                    value: 'بايبال',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('الدفع عند الاستلام'),
                    value: 'عند الاستلام',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                  if (selectedOption == 'بنك الكريمي') ...[
                    TextField(
                      controller: fullNameController,
                      decoration:
                          const InputDecoration(labelText: 'الاسم الكامل'),
                    ),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'المبلغ',
                        hintText: '$amountToPay',
                      ),
                      keyboardType: TextInputType.none,
                    ),
                  ]
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (selectedOption == null) {
                      showSnackBar(" يجب تحديد خيار الدفع");
                    } else {
                      if (selectedOption == 'بنك الكريمي') {
                        String fullName = fullNameController.text;
                        String amount = amountController.text;

                        _confirmOrder(
                            "الدفع عبر بنك الكريمي $amount من $fullName");
                      } else if (selectedOption == 'بايبال') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  PaypalCheckoutView(
                                sandboxMode: true,
                                clientId: PayPalData.client_id,
                                secretKey: PayPalData.secret_id,
                                transactions: [
                                  {
                                    "amount": {
                                      "total": amountToPay,
                                      "currency": "RY",
                                      "details": {
                                        "subtotal": amountToPay,
                                        "tax": "0.07",
                                        "shipping": "0.03",
                                        "handling_fee": "1.00",
                                        "shipping_discount": "-1.00",
                                        "insurance": "0.01"
                                      }
                                    },
                                    "description":
                                        "The payment transaction description.",
                                    "custom": "EBAY_EMS_90048630024435",
                                    "invoice_number": "48787589673",
                                    "payment_options": const {
                                      "allowed_payment_method":
                                          "INSTANT_FUNDING_SOURCE"
                                    },
                                    "soft_descriptor": "ECHI5786786",
                                    "item_list": {
                                      "items": [cartData.cartItems],
                                      //  [
                                      //   {
                                      //     "name": "hat",
                                      //     "description": "Brown hat.",
                                      //     "quantity": "5",
                                      //     "price": "3",
                                      //     "tax": "0.01",
                                      //     "sku": "1",
                                      //     "currency": "USD"
                                      //   },
                                      //   {
                                      //     "name": "handbag",
                                      //     "description": "Black handbag.",
                                      //     "quantity": "1",
                                      //     "price": "15",
                                      //     "tax": "0.02",
                                      //     "sku": "product34",
                                      //     "currency": "USD"
                                      //   }
                                      // ],
                                      "shipping_address": {
                                        "location": location!
                                        // "recipient_name": "Brian Robinson",
                                        // "line1": "4th Floor",
                                        // "line2": "Unit #34",
                                        // "city": "San Jose",
                                        // "country_code": "US",
                                        // "postal_code": "95131",
                                        // "phone": "011862212345678",
                                        // "state": "CA"
                                      }
                                    }
                                  }
                                ],
                                note:
                                    "Contact us for any questions on your order.",
                                onSuccess: (Map params) async {
                                  // log("onSuccess: $params");
                                  _confirmOrder("الدفع عبر بايبال");
                                  Navigator.pop(context);
                                },
                                onError: (error) {
                                  // log("onError: $error");
                                  Navigator.pop(context);
                                },
                                onCancel: () {
                                  print('cancelled:');
                                  Navigator.pop(context);
                                },
                              ),
                            ));
                      } else if (selectedOption == 'عند الاستلام') {
                        _confirmOrder("الدفع عبر عند الاستلام");
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'تأكيد',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    _checkOut() async {
      if (currentUserId == null) {
        showLoginOptions();
      } else {
        Navigator.of(context).pop();
        showPaymentOptions();
      }
    }

    confirmOptions(Operation operation) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: isLoading
              ? const Center(
                  child: Loading(
                    color: primaryColor,
                    kSize: 70,
                  ),
                )
              : Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      operation == Operation.clearCart
                          ? Icons.remove_shopping_cart_outlined
                          : Icons.shopping_cart_checkout_outlined,
                      color: primaryColor,
                    ),
                    Text(
                      operation == Operation.clearCart
                          ? 'تأكيد الحذف'
                          : 'تأكيد التقديم',
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
          content: Text(
            operation == Operation.clearCart
                ? 'متأكد من حذف السلة?'
                : 'متأكد من تقديم السلة كطلب إلى $location?, إذا كنت تود تغيير موقعك عد إلى الرئيسية واضغط على ايقونة الموقع',
            style: const TextStyle(
              color: primaryColor,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                operation == Operation.clearCart ? _clearCart() : _checkOut();
              },
              child: const Text(
                'نعم',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // remove from cart
    void removeFromCart(String prodId) {
      cartData.removeFromCart(prodId);
    }

    // increase item quantity
    void increaseQuantity(String id) {
      cartData.incrementProductQuantity(id);
    }

    // decrease item quantity
    void reduceQuantity(String id) {
      cartData.decrementProductQuantity(id);
    }

    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Stack(children: [
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: primaryColor,
                          ),
                          Text(
                            'السلة',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 28,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.83,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Consumer<CartData>(
                    builder: (context, data, child) => Column(
                      children: [
                        SizedBox(
                          height: size.height / 1.5,
                          child: data.cartItemCount < 1
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/sp2.png',
                                      width: 250,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      '! لايوجد شيء لعرضه',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 18,
                                      ),
                                    )
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(top: 5),
                                  scrollDirection: Axis.vertical,
                                  itemCount: data.cartItemCount,
                                  itemBuilder: (context, index) {
                                    var item = data.cartItems[index];
                                    return buildCart(
                                      removeFromCart,
                                      item,
                                      context,
                                      increaseQuantity,
                                      reduceQuantity,
                                    );
                                  },
                                ),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      ' ريال ${data.cartTotalPrice}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      ': إجمالي',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.shopping_cart_checkout,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      bool empty = cartIsEmpty();
                                      if (empty) {
                                        showSnackBar("السلة فارغة ");
                                      } else {
                                        if (currentUserId == null) {
                                          showLoginOptions();
                                        } else {
                                          // if (verifiedNmber == null) {
                                          //   showSnackBar("التحقق من الرقم ");
                                          //   _verifyPhone(context);
                                          // } else {
                                          location == null
                                              ? {
                                                  showSnackBar(
                                                      "يجب أولا تحديد موقعك"),
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                    MapScreen.routeName,
                                                  ),
                                                }
                                              : confirmOptions(
                                                  Operation.checkoutCart);
                                        }
                                      }
                                      // }
                                    },
                                    label: const Text(
                                      'تقديم',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class PayPalData {
  static String client_id = "";
  static String secret_id = "";
}
