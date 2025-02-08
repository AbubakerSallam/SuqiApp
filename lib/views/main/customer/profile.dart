import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suqi/models/global.dart';
import 'package:suqi/providers/pay_money.dart';
import '../../../components/loading.dart';
import '../../../constants/colors.dart';
import 'order.dart';
import 'edit_profile.dart';
import '../../../components/kListTile.dart';
import '../../auth/auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var firebase = FirebaseFirestore.instance;
  // var auth = FirebaseAuth.instance;
  DocumentSnapshot? credential;
  var isLoading = true;
  var isInit = true;

  // fetch user credentials
  _fetchUserDetails() async {
    if (currentUserId != null) {
      credential =
          await firebase.collection('customers').doc(currentUserId).get();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  showLogoutOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Image.asset(
              'assets/images/profile.png',
              width: 35,
              color: primaryColor,
            ),
            const Text(
              'تسجيل خروج',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'متأكد من تسجيل الخروج?',
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
            onPressed: () => _logout(),
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

  _logout() {
    if (currentUserId != null) {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamed(Auth.routeName);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _editProfile() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const EditProfile(),
          ),
        )
        .then(
          (value) => setState(
            () {},
          ),
        );
  }

  _payMoney() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const PayMoney(
              isUserMoney: true,
            ),
          ),
        )
        .then(
          (value) => setState(
            () {},
          ),
        );
  }

  _settings() {
    Navigator.of(context).pushNamed('');
  }

  _changePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfile(
          editPasswordOnly: true,
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return isLoading
        ? const Center(
            child: Loading(
              color: primaryColor,
              kSize: 50,
            ),
          )
        : currentUserId == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/sad.png',
                      width: 120,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'لم تسجل دخولك بعد!',
                      style: TextStyle(
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    expandedHeight: 130,
                    backgroundColor: primaryColor,
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        return FlexibleSpaceBar(
                          titlePadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          title: AnimatedOpacity(
                            opacity: constraints.biggest.height <= 120 ? 1 : 0,
                            duration: const Duration(
                              milliseconds: 300,
                            ),
                            child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: primaryColor,
                                    backgroundImage: NetworkImage(
                                      credential!['image'],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    credential!['fullname'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ]),
                          ),
                          background: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  Colors.black26,
                                ],
                                stops: [0.1, 1],
                                end: Alignment.topRight,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: primaryColor,
                                  backgroundImage: NetworkImage(
                                    credential!['image'],
                                  ),
                                ),
                                Text(
                                  credential!['fullname'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            width: size.width / 0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      backgroundColor: bWhite,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          bottomLeft: Radius.circular(30),
                                        ),
                                      ),
                                    ),
                                    onPressed: () => Navigator.of(context)
                                        .pushNamed(
                                            CustomerOrderScreen.routeName),
                                    child: const Text(
                                      'الطلبات',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Navigator.of(context)
                                      //     .pushNamed(FavoriteScreen.routeName);
                                    },
                                    child: const Text(
                                      'المفضلة',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      backgroundColor: bWhite,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(30),
                                          bottomRight: Radius.circular(30),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      _payMoney();
                                    },
                                    child: const Text(
                                      'رصيدي',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // const KDividerText(title: 'Account Information'),
                          const SizedBox(height: 20),
                          Container(
                            height: size.height / 2.8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                KListTile(
                                  title: 'الإيميل',
                                  subtitle: credential!['email'],
                                  icon: Icons.email,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Divider(thickness: 1),
                                ),
                                KListTile(
                                  title: 'الرقم',
                                  subtitle: credential!['phone'] == ""
                                      ? 'لم يضف بعد'
                                      : credential!['phone'],
                                  icon: Icons.phone,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Divider(thickness: 1),
                                ),
                                KListTile(
                                  title: 'عنواني',
                                  subtitle: credential!['address'] == ""
                                      ? 'لم يحدد بعد'
                                      : credential!['address'],
                                  icon: Icons.location_pin,
                                ),
                              ],
                            ),
                          ),
                          // const KDividerText(title: 'Account Settings'),
                          const SizedBox(height: 20),
                          Container(
                            height: size.height / 3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                KListTile(
                                  title: 'اعدادات التطبيق',
                                  icon: Icons.settings,
                                  onTapHandler: _settings,
                                  showSubtitle: false,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Divider(thickness: 1),
                                ),
                                KListTile(
                                  title: 'تعديل بروفايلي',
                                  icon: Icons.edit_note,
                                  onTapHandler: _editProfile,
                                  showSubtitle: false,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Divider(thickness: 1),
                                ),
                                KListTile(
                                  title: 'تغيير الرمز',
                                  icon: Icons.key,
                                  onTapHandler: _changePassword,
                                  showSubtitle: false,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Divider(thickness: 1),
                                ),
                                KListTile(
                                  title: 'تسجيل خروج',
                                  icon: Icons.logout,
                                  onTapHandler: showLogoutOptions,
                                  showSubtitle: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
  }
}
